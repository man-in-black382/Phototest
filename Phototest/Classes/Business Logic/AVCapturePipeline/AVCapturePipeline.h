//
//  AVCapturePipeline.h
//  Phototest
//
//  Created by Pavlo on 7/11/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class AVCapturePipeline;

@protocol AVCapturePipelineDelegate <NSObject>

@optional
- (void)capturePipeline:(AVCapturePipeline *)pipeline capturedStillImage:(UIImage *)image;
- (void)capturePipeline:(AVCapturePipeline *)pipeline didRecognizeFaces:(NSArray<AVMetadataFaceObject *> *)faces;

@end

@interface AVCapturePipeline : NSObject

@property (weak, nonatomic) id<AVCapturePipelineDelegate> delegate;
@property (strong, nonatomic) NSString *captureSessionPreset;
@property (assign, nonatomic) CGFloat zoomFactor;
@property (assign, nonatomic) AVCaptureFlashMode flashMode;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoCapturePreviewLayer;
@property (assign, nonatomic, readonly, getter = isFlashAvailable) BOOL flashAvailable;\
@property (assign, atomic, getter = isPaused) BOOL paused;
@property (assign, nonatomic, readonly) CGRect videoBox;

- (void)focusAndExposePoint:(CGPoint)point;
- (void)captureStillImage;

@end
