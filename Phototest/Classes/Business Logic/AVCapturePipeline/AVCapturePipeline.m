//
//  AVCapturePipeline.m
//  Phototest
//
//  Created by Pavlo on 7/11/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "AVCapturePipeline.h"

#import <ImageIO/ImageIO.h>

#import "RectCalculator.h"

static CGFloat const MaxZoomFactor = 8.f;

@interface AVCapturePipeline () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>

// Session
@property (strong, nonatomic) AVCaptureSession *session;

// Devices
@property (strong, nonatomic) AVCaptureDevice *backCamera;

// Device inputs
@property (strong, nonatomic) AVCaptureDeviceInput *videoDeviceInput;

// Device outputs
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureMetadataOutput *metadataOutput;

// Queues
@property (strong, nonatomic) dispatch_queue_t sampleBuffersDispatchQueue;
@property (strong, nonatomic) dispatch_queue_t metadataOutputQueue;

@property (assign, nonatomic, getter = isRecordingAllowed) BOOL recordingAllowed;

@end

@implementation AVCapturePipeline

@synthesize paused = _paused;

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sampleBuffersDispatchQueue = dispatch_queue_create("com.capt.videocapture.samle.buffers.queue", DISPATCH_QUEUE_SERIAL);
        _metadataOutputQueue = dispatch_queue_create("com.capt.videocapture.metadata.queue", DISPATCH_QUEUE_SERIAL);
        
        [self setupSession];
        
        [self setupDevices];
        [self setupDeviceInputs];
        [self setupDataOutputs];
        [self setupVideoCapturePreviewLayer];
        
        self.captureSessionPreset = AVCaptureSessionPresetPhoto;
        
        [_session startRunning];
    }
    return self;
}

#pragma mark - Accessors

- (void)setZoomFactor:(CGFloat)zoomFactor
{
    NSError *error;
    
    [self.backCamera lockForConfiguration:&error];
    
    if (error) {
        NSLog(@"%@", error);
    } else {
        _zoomFactor = MAX(1.0, MIN(zoomFactor, MaxZoomFactor));
        self.backCamera.videoZoomFactor = _zoomFactor;
    }
    
    [self.backCamera unlockForConfiguration];
}

- (void)setCaptureSessionPreset:(NSString *)captureSessionPreset
{
    if ([self.session canSetSessionPreset:captureSessionPreset]) {
        _captureSessionPreset = captureSessionPreset;
        self.session.sessionPreset = captureSessionPreset;
    } else {
        NSLog(@"Session preset (%@) not supported", captureSessionPreset);
    }
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode
{
    NSError *error;
    
    [self.backCamera lockForConfiguration:&error];
    
    if (error) {
        NSLog(@"%@", error);
    } else if (self.backCamera.torchAvailable) {
        _flashMode = flashMode;
        self.backCamera.flashMode = flashMode;
    } else {
        NSLog(@"Flash is unavailable");
    }
    
    [self.backCamera unlockForConfiguration];
}

- (void)setPaused:(BOOL)paused
{
    @synchronized (self) {
        _paused = paused;
        self.videoCapturePreviewLayer.connection.enabled = !paused;
    }
}

- (BOOL)isPaused
{
    @synchronized (self) {
        return _paused;
    }
}

- (BOOL)isFlashAvailable
{
    return self.backCamera.flashAvailable;
}

#pragma mark - Setups

- (void)setupSession
{
    self.session = [AVCaptureSession new];
    self.session.automaticallyConfiguresApplicationAudioSession = NO;
}

- (void)setupDevices
{
    self.backCamera = [self cameraWithDevicePosition:AVCaptureDevicePositionBack];
}

- (void)setupDeviceInputs
{
    NSError *error;
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.backCamera error:&error];
    
    if (error) {
        NSLog(@"Failed to retrieve device input for CAMERA: %@", error);
    }
    
    if ([self.session canAddInput:self.videoDeviceInput]) {
        [self.session addInput:self.videoDeviceInput];
    } else {
        NSLog(@"Cannot add Video Device Input to session");
    }
}

- (void)setupDataOutputs
{
    self.stillImageOutput = [AVCaptureStillImageOutput new];
    
    self.metadataOutput = [AVCaptureMetadataOutput new];
    [self.metadataOutput setMetadataObjectsDelegate:self queue:self.metadataOutputQueue];
    
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    } else {
        NSLog(@"Cannot add Still Image Data Output to session");
    }
    
    if ([self.session canAddOutput:self.metadataOutput]) {
        [self.session addOutput:self.metadataOutput];
        self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
    } else {
        NSLog(@"Cannot add Metadata Output to session");
    }
}

- (void)setupVideoCapturePreviewLayer
{
    self.videoCapturePreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.videoCapturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (self.paused) {
        return;
    }
    
    NSMutableArray *transformedFaces = [NSMutableArray array];
    for (AVMetadataFaceObject *face in metadataObjects) {
        [transformedFaces addObject:[self.videoCapturePreviewLayer transformedMetadataObjectForMetadataObject:face]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(capturePipeline:didRecognizeFaces:)]) {
            [self.delegate capturePipeline:self didRecognizeFaces:transformedFaces];
        }
    });
}

#pragma mark - Utility methods

- (AVCaptureDevice *)cameraWithDevicePosition:(AVCaptureDevicePosition)devicePosition
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *videoDevice in videoDevices) {
        if (videoDevice.position == devicePosition) {
            return videoDevice;
        }
    }
    
    return nil;
}

- (AVCaptureVideoOrientation)videoOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    // IMPORTANT: returning AVCaptureVideoOrientationLandscapeRight for UIDeviceOrientationLandscapeLeft and vise versa,
    // because AVCaptureVideoOrientations are following the UIInterfaceOrientation convention, not the UIDeviceOrientation one
    // (UIDeviceOrientationLandscapeLeft == UIInterfaceOrientationLandscapeRight for some reason)
    // See http://stackoverflow.com/a/9491477 for discussion
    
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait: {
            return AVCaptureVideoOrientationPortrait;
        }
        case UIDeviceOrientationLandscapeRight: {
            return AVCaptureVideoOrientationLandscapeLeft;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            return AVCaptureVideoOrientationPortraitUpsideDown;
        }
        default: {
            return AVCaptureVideoOrientationLandscapeRight;
        }
    }
}

#pragma mark - Device interaction

- (void)focusAndExposeAtDevicePoint:(CGPoint)point
{
    NSError *error;
    
    [self.backCamera lockForConfiguration:&error];
    
    if (error) {
        NSLog(@"Error occured while trying to focus and expose: %@", error);
    } else {
        if (self.backCamera.focusPointOfInterestSupported) {
            self.backCamera.focusPointOfInterest = point;
            self.backCamera.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        
        if (self.backCamera.exposurePointOfInterestSupported) {
            self.backCamera.exposurePointOfInterest = point;
            self.backCamera.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
    }
    
    [self.backCamera unlockForConfiguration];
}

#pragma mark - Public

- (void)focusAndExposePoint:(CGPoint)point
{
    CGPoint convertedPoint = [self.videoCapturePreviewLayer captureDevicePointOfInterestForPoint:point];
    [self focusAndExposeAtDevicePoint:convertedPoint];
}

- (void)captureStillImage
{
    AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    connection.videoOrientation = [self videoOrientationFromDeviceOrientation:[UIDevice currentDevice].orientation];
    
    __weak typeof(self) weakSelf = self;
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(capturePipeline:capturedStillImage:)]) {
                [weakSelf.delegate capturePipeline:weakSelf capturedStillImage:image];
            }
        });
    }];
}

@end
