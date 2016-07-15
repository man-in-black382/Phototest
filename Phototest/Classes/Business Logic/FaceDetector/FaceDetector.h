//
//  FaceDetector.h
//  Phototest
//
//  Created by Pavlo on 7/11/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "FaceDetection.h"

@interface FaceDetector : NSObject <FaceDetection>

- (instancetype)initWithMinimumUpdateInterval:(CGFloat)minimumUpdateInterval;

@end
