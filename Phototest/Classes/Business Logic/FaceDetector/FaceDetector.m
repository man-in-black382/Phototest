//
//  FaceDetector.m
//  Phototest
//
//  Created by Pavlo on 7/11/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "FaceDetector.h"

#import "CIFeature+ConvertedBounds.h"

typedef NS_ENUM(NSUInteger, EXIFOrientation) {
    EXIFOrientationTopLeft = 1,
    EXIFOrientationTopRight = 2,
    EXIFOrientationBottomRight = 3,
    EXIFOrientationBottomLeft = 4,
    EXIFOrientationLeftTop = 5,
    EXIFOrientationRightTop = 6,
    EXIFOrientationRightBottom = 7,
    EXIFOrientationLeftBottom = 8,
};

@interface FaceDetector ()

@property (strong, nonatomic) CIDetector *detector;
@property (assign, nonatomic) EXIFOrientation previousEXIFOrientation;
@property (assign, nonatomic) CGFloat minimumUpdateInterval;
@property (strong, atomic) NSTimer *updateCountdownTimer;

@end

@implementation FaceDetector

@synthesize delegate = _delegate;

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [self initWithMinimumUpdateInterval:1.f];
    }
    return self;
}

- (instancetype)initWithMinimumUpdateInterval:(CGFloat)minimumUpdateInterval
{
    self = [super init];
    if (self) {
        _minimumUpdateInterval = minimumUpdateInterval;
        NSDictionary *options = @{ CIDetectorAccuracy : CIDetectorAccuracyLow };
        _detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
    }
    return self;
}

#pragma mark - Private

- (NSNumber *)EXIFOrientationFromDeviceOrientation:(UIDeviceOrientation)orientation
{
    EXIFOrientation exifOrientation;
    
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown: {
            exifOrientation = EXIFOrientationBottomRight;
            break;
        }
        case UIDeviceOrientationLandscapeLeft: {
            exifOrientation = EXIFOrientationRightBottom;
            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            exifOrientation = EXIFOrientationLeftTop;
            break;
        }
        case UIDeviceOrientationPortrait: {
            exifOrientation = EXIFOrientationTopLeft;
            break;
        }
        default: {
            exifOrientation = self.previousEXIFOrientation;
        }
    }
    
    self.previousEXIFOrientation = exifOrientation;
    return @(exifOrientation);
}

- (void)updateCountdownTimerFired
{
    self.updateCountdownTimer = nil;
}

#pragma mark - Public

- (void)detectFacesInImage:(CIImage *)image videoBox:(CGRect)videoBox
{
    if (self.updateCountdownTimer) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.updateCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:self.minimumUpdateInterval
                                                                     target:self
                                                                   selector:@selector(updateCountdownTimerFired)
                                                                   userInfo:nil
                                                                    repeats:NO];
    });
    
    UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
    NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:[self EXIFOrientationFromDeviceOrientation:currentDeviceOrientation]
                                                             forKey:CIDetectorImageOrientation];
    
    NSArray *features = [self.detector featuresInImage:image options:imageOptions];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGAffineTransform transform = CGAffineTransformMakeScale(1.f / scale, -1.f / scale);
    transform = CGAffineTransformTranslate(transform, 0, -image.extent.size.height);
    
    for (CIFaceFeature *faceFeature in features) {
        CGRect faceRect = CGRectApplyAffineTransform(faceFeature.bounds, transform);
        CGFloat dx = videoBox.origin.x;
        CGFloat dy = videoBox.origin.y;
        faceRect = CGRectOffset(faceRect, dx, dy);
        faceFeature.UIKitOrientedBounds = faceRect;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(faceDetector:didDetectFaces:)]) {
            [self.delegate faceDetector:self didDetectFaces:features];
        }
    });
}

@end
