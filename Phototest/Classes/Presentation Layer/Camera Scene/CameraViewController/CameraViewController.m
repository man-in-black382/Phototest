//
//  CameraViewController.m
//  Phototest
//
//  Created by Pavlo on 7/11/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "CameraViewController.h"

#import "FaceView.h"
#import "UserInteractionMenu.h"
#import "UploadStatusView.h"

#import "AVCapturePipeline.h"
#import "FaceDetector.h"
#import "FaceViewsManager.h"
#import "FaceValidator.h"
#import "InMemoryStorage.h"
#import "NetworkFacade.h"

#import "UIColor+AppColors.h"
#import "UIImage+Size.h"

@interface CameraViewController () <AVCapturePipelineDelegate, FaceDetectorDelegate>

@property (weak, nonatomic) IBOutlet UIView *cameraPreviewView;
@property (weak, nonatomic) IBOutlet UIView *deniedVideoPermisisonsView;
@property (weak, nonatomic) IBOutlet UIView *faceViewsContainer;
@property (weak, nonatomic) IBOutlet UIImageView *capturedImagePreviewImageView;
@property (weak, nonatomic) IBOutlet UploadStatusView *uploadStatusView;
@property (weak, nonatomic) IBOutlet UserInteractionMenu *userInteractionMenu;

@property (strong, nonatomic) AVCapturePipeline *capturePipeline;
@property (strong, nonatomic) FaceDetector *faceDetector;
@property (strong, nonatomic) FaceViewsManager *faceViewsManager;
@property (strong, nonatomic) FaceValidator *facesValidator;

@property (strong, nonatomic) NetworkOperation *uploadOperation;
@property (strong, nonatomic) UIImage *capturedImage;

@end

@implementation CameraViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Force early layout for video preview layer's immediate proper size calculation
    [self.view layoutIfNeeded];
    [self requestPermissionsAndSetupPipeline];
    [self subscribeForNotifications];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.capturePipeline.videoCapturePreviewLayer.frame = self.cameraPreviewView.bounds;
}

- (void)dealloc
{
    [self unsubscribeFromNotifications];
}

#pragma mark - Accessors, Lazy init

- (FaceDetector *)faceDetector
{
    if (!_faceDetector) {
        _faceDetector = [[FaceDetector alloc] initWithMinimumUpdateInterval:0.1f];
        _faceDetector.delegate = self;
    }
    return _faceDetector;
}

- (FaceViewsManager *)faceViewsManager
{
    if (!_faceViewsManager) {
        _faceViewsManager = [[FaceViewsManager alloc] initWithFacesParentView:self.faceViewsContainer facesValidator:self.facesValidator];
    }
    return _faceViewsManager;
}

- (FaceValidator *)facesValidator
{
    if (!_facesValidator) {
        _facesValidator = [[FaceValidator alloc] initWithFacesWorkingSurface:self.capturePipeline.videoBox];
    }
    return _facesValidator;
}

#pragma mark - Actions

- (IBAction)handleSettingsPress:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (IBAction)capturePressed:(id)sender
{
    self.capturePipeline.paused = YES;
    [self.faceViewsManager showFaceViewsWithFaces:nil animated:NO];
    [self.capturePipeline captureStillImage];
}

- (IBAction)sendImagePressed:(id)sender
{
    self.capturedImagePreviewImageView.image = nil;
    [self.userInteractionMenu hideDialog];
    [self.uploadStatusView uploadStarted];
    self.capturePipeline.paused = NO;
    
    __weak typeof(self) weakSelf = self;
    self.uploadOperation = [NetworkFacade uploadImage:self.capturedImage
                                       withIdentifier:[InMemoryStorage storage].applicationIdentifier
                                          withSuccess:^{
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [weakSelf.uploadStatusView uploadCompleted];
                                                  weakSelf.uploadOperation = nil;
                                              });
                                          } orFailure:^(NSUInteger statusCode) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [weakSelf.uploadStatusView uploadFailed];
                                              });
                                          }];
}

- (IBAction)discardImagePressed:(id)sender
{
    self.capturePipeline.paused = NO;
    self.capturedImagePreviewImageView.image = nil;
    [self.userInteractionMenu hideDialog];
}

- (IBAction)retryUploadPressed:(id)sender
{
    [self.uploadOperation restart];
    [self.uploadStatusView uploadStarted];
}

- (IBAction)cancelUploadPressed:(id)sender
{
    [self.uploadOperation cancel];
    self.uploadOperation = nil;
    [self.uploadStatusView uploadCancelled];
}

#pragma mark - FaceDetectorDelegate

- (void)faceDetector:(id<FaceDetection>)detector didDetectFaces:(NSArray<CIFaceFeature *> *)faces
{
    [self.faceViewsManager showFaceViewsWithFaces:!self.uploadOperation ? faces : nil animated:YES];
    self.userInteractionMenu.userInteractionEnabled = [self.facesValidator areFacesValid:faces] && !self.uploadOperation;
}

#pragma mark - AVCapturePipelineDelegate

- (void)capturePipeline:(AVCapturePipeline *)pipeline capturedStillImage:(UIImage *)image
{
    self.capturedImage = [image webSuitedImage];
    self.capturedImagePreviewImageView.image = image;
    [self.userInteractionMenu showDialog];
}

#pragma mark - Private

- (void)requestPermissionsAndSetupPipeline
{
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    __weak typeof(self) weakSelf = self;
    if (videoStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.deniedVideoPermisisonsView.hidden = granted;
                [weakSelf setupCapturePipeline];
            });
        }];
    } else {
        self.deniedVideoPermisisonsView.hidden = videoStatus == AVAuthorizationStatusAuthorized;
        [self setupCapturePipeline];
    }
}

- (void)setupCapturePipeline
{
    self.capturePipeline = [AVCapturePipeline new];
    self.capturePipeline.delegate = self;
    [self.cameraPreviewView.layer addSublayer:self.capturePipeline.videoCapturePreviewLayer];
    self.capturePipeline.videoCapturePreviewLayer.frame = self.cameraPreviewView.layer.bounds;
    self.capturePipeline.faceDetector = self.faceDetector;
}

#pragma mark - Notifications

- (void)subscribeForNotifications
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)unsubscribeFromNotifications
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    [self.userInteractionMenu adjustForDeviceOrientation:orientation];
    [self.uploadStatusView adjustForDeviceOrientation:orientation];
}

#pragma mark - UI

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
