//
//  AVCapturePipeline.m
//  Phototest
//
//  Created by Pavlo on 7/11/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "AVCapturePipeline.h"

#import <ImageIO/ImageIO.h>

#import "FaceDetector.h"
#import "RectCalculator.h"

static CGFloat const MaxZoomFactor = 8.f;

@interface AVCapturePipeline () <AVCaptureVideoDataOutputSampleBufferDelegate>

// Session
@property (strong, nonatomic) AVCaptureSession *session;

// Devices
@property (strong, nonatomic) AVCaptureDevice *backCamera;

// Device inputs
@property (strong, nonatomic) AVCaptureDeviceInput *videoDeviceInput;

// Device outputs
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureVideoDataOutput *videoDataOutput;

// Queues
@property (strong, nonatomic) dispatch_queue_t callbackQueue;

@property (assign, nonatomic, getter = isRecordingAllowed) BOOL recordingAllowed;

@end

@implementation AVCapturePipeline

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _callbackQueue = dispatch_queue_create("com.capt.videocapture.callback.queue", DISPATCH_QUEUE_SERIAL);
        
        [self setupSession];
        
        [self setupDevices];
        [self setupDeviceInputs];
        [self setupDataOutputs];
        [self setupVideoCapturePreviewLayer];
        
        self.captureSessionPreset = AVCaptureSessionPresetPhoto;
        self.videoOrientation = AVCaptureVideoOrientationPortrait;
        
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

- (void)setVideoOrientation:(AVCaptureVideoOrientation)videoOrientation
{
    _videoOrientation = videoOrientation;
    
    AVCaptureConnection *stillImageConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    stillImageConnection.videoOrientation = videoOrientation;
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
    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.callbackQueue];
    
    self.stillImageOutput = [AVCaptureStillImageOutput new];
    
    if ([self.session canAddOutput:self.videoDataOutput]) {
        [self.session addOutput:self.videoDataOutput];
    } else {
        NSLog(@"Cannot add Video Data Output to session");
    }
    
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    } else {
        NSLog(@"Cannot add Still Image Data Output to session");
    }
}

- (void)setupVideoCapturePreviewLayer
{
    self.videoCapturePreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.videoCapturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
}

#pragma mark - AVCaptureVideo(Audio)DataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (self.paused) {
        return;
    }
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer];
    
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect cleanAperture = CMVideoFormatDescriptionGetCleanAperture(formatDescription, true);
    _videoBox = [self videoPreviewBoxForPreviewLayer:self.videoCapturePreviewLayer cleanAperture:cleanAperture];

    [self.faceDetector detectFacesInImage:ciImage videoBox:_videoBox];
}

#pragma mark - Utility methods

- (CGRect)videoPreviewBoxForPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer cleanAperture:(CGRect)cleanAperture
{
    CGRect videoBox = CGRectZero;
    
    if ([previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        videoBox = [RectCalculator aspectFitRect:cleanAperture aroundRect:previewLayer.bounds];
    } else if ([previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        videoBox = [RectCalculator aspectFitRect:cleanAperture inRect:previewLayer.bounds];
    } else if ([previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResize]) {
        videoBox = previewLayer.bounds;
    }
    
    return videoBox;
}

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
  
    // Pause preview layer
    self.videoCapturePreviewLayer.connection.enabled = NO;
    __weak typeof(self) weakSelf = self;
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(capturePipeline:capturedStillImage:)]) {
                [weakSelf.delegate capturePipeline:weakSelf capturedStillImage:image];
            }
        });
        
        weakSelf.videoCapturePreviewLayer.connection.enabled = YES;
    }];
}

@end
