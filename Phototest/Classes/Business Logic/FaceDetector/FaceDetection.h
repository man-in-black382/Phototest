//
//  FaceDetection.h
//  Phototest
//
//  Created by Pavlo on 7/11/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

@protocol FaceDetection;

@protocol FaceDetectorDelegate <NSObject>

- (void)faceDetector:(id<FaceDetection>)detector didDetectFaces:(NSArray<CIFaceFeature *> *)faces;

@end

@protocol FaceDetection <NSObject>

@property (weak, nonatomic) id<FaceDetectorDelegate> delegate;

- (void)detectFacesInImage:(CIImage *)image videoBox:(CGRect)videoBox;

@end
