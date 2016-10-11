//
//  FaceViewsManager.m
//  Phototest
//
//  Created by Pavlo on 7/12/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "FaceViewsManager.h"
#import "RectCalculator.h"

#import "FaceView.h"
#import <AVFoundation/AVMetadataObject.h>

#import "UIColor+AppColors.h"

@interface FaceViewsManager ()

@property (weak, nonatomic) UIView *facesParentView;
@property (strong, nonatomic) NSMutableArray<FaceView *> *faceViews;
@property (strong, nonatomic) id<FaceValidation> facesValidator;

@end

@implementation FaceViewsManager

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"You must specify parent view through %@ initializer", NSStringFromSelector(@selector(initWithFacesParentView:facesValidator:))];
    }
    return self;
}

- (instancetype)initWithFacesParentView:(UIView *)parentView facesValidator:(id<FaceValidation>)validator
{
    self = [super init];
    if (self) {
        _facesValidator = validator;
        _facesParentView = parentView;
        _faceViews = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Private

- (void)readjustFacesArrayWithFaces:(NSArray<AVMetadataFaceObject *> *)faces
{
    CGColorRef faceRectsColor = [self.facesValidator areFacesValid:faces] ? [UIColor applicationGreenColor].CGColor : [UIColor redColor].CGColor;
    
    NSMutableArray<NSValue *> *rects = [NSMutableArray arrayWithArray:[faces valueForKeyPath:@"bounds"]];
    
    NSInteger sizeDifference = faces.count - self.faceViews.count;
    if (sizeDifference > 0) {
        [self handleNegativeSizeDifferenceForFaces:faces rects:rects rectsColor:faceRectsColor];
    } else if (sizeDifference < 0) {
        [self handlePositiveSizeDifferenceForFaces:faces rects:rects rectsColor:faceRectsColor];
    } else {
        [self handleAbsentSizeDifferenceForFaces:faces rects:rects rectsColor:faceRectsColor];
    }
}

- (void)handleNegativeSizeDifferenceForFaces:(NSArray<AVMetadataFaceObject *> *)faces rects:(NSMutableArray<NSValue *> *)rects rectsColor:(CGColorRef)color
{
    NSUInteger i;
    // Readjust existing views
    for (i = 0; i < self.faceViews.count; i++) {
        FaceView *faceView = self.faceViews[i];
        faceView.layer.borderColor = color;
        CGRect nearestRect = [RectCalculator nearestRectFromArray:rects forRect:faceView.frame];
        [rects removeObject:[NSValue valueWithCGRect:nearestRect]];
        [self showFaceView:faceView withNewFrame:nearestRect];
    }
    // Add new (missing) views
    for (NSUInteger j = i; j < faces.count; j++) {
        FaceView *newFace = [FaceView new];
        newFace.layer.borderColor = color;
        [self.faceViews addObject:newFace];
        [self.facesParentView addSubview:newFace];
        [self showFaceView:newFace withNewFrame:faces[i].bounds];
    }
}

- (void)handlePositiveSizeDifferenceForFaces:(NSArray<AVMetadataFaceObject *> *)faces rects:(NSMutableArray<NSValue *> *)rects rectsColor:(CGColorRef)color
{
    NSUInteger i;
    // Readjust existing views
    for (i = 0; i < faces.count; i++) {
        FaceView *faceView = self.faceViews[i];
        faceView.layer.borderColor = color;
        CGRect nearestRect = [RectCalculator nearestRectFromArray:rects forRect:faceView.frame];
        [rects removeObject:[NSValue valueWithCGRect:nearestRect]];
        [self showFaceView:faceView withNewFrame:nearestRect];
    }
    // Hide unnecessary views
    for (NSUInteger j = i; j < self.faceViews.count; j++) {
        FaceView *faceView = self.faceViews[j];
        [self hideFaceViewAnimated:faceView];
        faceView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (void)handleAbsentSizeDifferenceForFaces:(NSArray<AVMetadataFaceObject *> *)faces rects:(NSMutableArray<NSValue *> *)rects rectsColor:(CGColorRef)color
{
    // Readjust all existing views
    for (NSUInteger i = 0; i < self.faceViews.count; i++) {
        FaceView *faceView = self.faceViews[i];
        faceView.layer.borderColor = color;
        CGRect nearestRect = [RectCalculator nearestRectFromArray:rects forRect:faceView.frame];
        [rects removeObject:[NSValue valueWithCGRect:nearestRect]];
        [self showFaceView:faceView withNewFrame:nearestRect];
    }
}

- (void)showFaceView:(FaceView *)faceView withNewFrame:(CGRect)newFrame
{
    CGFloat diagonal = [RectCalculator diagonalOfRect:newFrame];
    CGFloat travelDistance = [RectCalculator distanceFromPoint:faceView.center toPoint:[RectCalculator centerForRect:newFrame]];
    
    // Prevent views from traveling too far. If the traveling distance is greater than the new frame's diagonal, only smoothly reappear view on the new position
    if (travelDistance > diagonal) {
        faceView.alpha = 0.0;
        faceView.frame = newFrame;
        [UIView animateWithDuration:0.2 animations:^{
            faceView.alpha = 1.0;
        }];
    } else { // Otherwise, show a full traveling animation, like in the native camera app
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             faceView.frame = newFrame;
                         } completion:nil];
    }
}

- (void)hideFaceViewAnimated:(FaceView *)faceView
{
    [UIView animateWithDuration:0.2 animations:^{
        faceView.alpha = 0.0;
    }];
}

#pragma mark - Public

- (void)showFaceViewsForFaces:(NSArray<AVMetadataFaceObject *> *)faces
{
    [self readjustFacesArrayWithFaces:faces];
}

@end
