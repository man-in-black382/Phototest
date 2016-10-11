//
//  FacesValidator.m
//  Phototest
//
//  Created by Pavlo on 7/12/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "FaceValidator.h"
#import "RectCalculator.h"
#import <AVFoundation/AVMetadataObject.h>

static CGFloat const MinimumValidFaceToCaptureSurfaceRatio = 0.37f;

@interface FaceValidator ()

@property (assign, nonatomic) CGRect facesWorkingSurface;

@end

@implementation FaceValidator

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"You must specify working surface using %@ initializer", NSStringFromSelector(@selector(initWithFacesWorkingSurface:))];
    }
    return self;
}

- (instancetype)initWithFacesWorkingSurface:(CGRect)surface
{
    self = [super init];
    if (self) {
        _facesWorkingSurface = surface;
    }
    return self;
}

#pragma mark - FacesValidation

- (BOOL)areFacesValid:(NSArray<AVMetadataFaceObject *> *)faces
{
    if (faces.count != 1) {
        return NO;
    }
    
    AVMetadataFaceObject *face = faces.firstObject;
    CGFloat captureSurfaceArea = [RectCalculator rectArea:self.facesWorkingSurface];
    CGFloat faceArea = [RectCalculator rectArea:face.bounds];
    CGFloat faceAreaPortion = faceArea / captureSurfaceArea;
    
    if (faceAreaPortion < MinimumValidFaceToCaptureSurfaceRatio) {
        return NO;
    }
    
    return YES;
}

@end
