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

#import "CIFeature+ConvertedBounds.h"
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
                    format:@"You must specify parent view using %@ initializer", NSStringFromSelector(@selector(initWithFacesParentView:facesValidator:))];
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

- (void)readjustFacesArrayWithFaces:(NSArray<CIFaceFeature *> *)faces
{
    CGColorRef faceRectsColor = [self.facesValidator areFacesValid:faces] ? [UIColor applicationGreenColor].CGColor : [UIColor redColor].CGColor;
    NSMutableArray<NSValue *> *rects = [NSMutableArray arrayWithArray:[faces valueForKeyPath:@"UIKitOrientedBounds"]];
    
    NSInteger sizeDifference = faces.count - self.faceViews.count;
    if (sizeDifference > 0) {
        [self handleNegativeSizeDifferenceForFaces:faces rects:rects rectsColor:faceRectsColor];
    } else if (sizeDifference < 0) {
        [self handlePositiveSizeDifferenceForFaces:faces rects:rects rectsColor:faceRectsColor];
    } else {
        [self handleAbsentSizeDifferenceForFaces:faces rects:rects rectsColor:faceRectsColor];
    }
}

- (void)handleNegativeSizeDifferenceForFaces:(NSArray<CIFaceFeature *> *)faces rects:(NSMutableArray<NSValue *> *)rects rectsColor:(CGColorRef)color
{
    NSUInteger i;
    // Readjust existing views
    for (i = 0; i < self.faceViews.count; i++) {
        FaceView *faceView = self.faceViews[i];
        faceView.layer.borderColor = color;
        CGRect nearestRect = [RectCalculator nearestRectFromArray:rects forRect:faceView.frame];
        [rects removeObject:[NSValue valueWithCGRect:nearestRect]];
        faceView.frame = nearestRect;
        faceView.hidden = NO;
    }
    // Add new (missing) views
    for (NSUInteger j = i; j < faces.count; j++) {
        FaceView *newFace = [[FaceView alloc] initWithFrame:faces[i].UIKitOrientedBounds];
        newFace.layer.borderColor = color;
        [self.faceViews addObject:newFace];
        [self.facesParentView addSubview:newFace];
    }
}

- (void)handlePositiveSizeDifferenceForFaces:(NSArray<CIFaceFeature *> *)faces rects:(NSMutableArray<NSValue *> *)rects rectsColor:(CGColorRef)color
{
    NSUInteger i;
    // Readjust existing views
    for (i = 0; i < faces.count; i++) {
        FaceView *faceView = self.faceViews[i];
        faceView.layer.borderColor = color;
        CGRect nearestRect = [RectCalculator nearestRectFromArray:rects forRect:faceView.frame];
        [rects removeObject:[NSValue valueWithCGRect:nearestRect]];
        faceView.frame = nearestRect;
        faceView.hidden = NO;
    }
    // Hide unnecessary views
    for (NSUInteger j = i; j < self.faceViews.count; j++) {
        FaceView *faceView = self.faceViews[j];
        faceView.hidden = YES;
        faceView.center = self.facesParentView.center;
        faceView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (void)handleAbsentSizeDifferenceForFaces:(NSArray<CIFaceFeature *> *)faces rects:(NSMutableArray<NSValue *> *)rects rectsColor:(CGColorRef)color
{
    // Readjust all existing views
    for (NSUInteger i = 0; i < self.faceViews.count; i++) {
        FaceView *faceView = self.faceViews[i];
        faceView.layer.borderColor = color;
        CGRect nearestRect = [RectCalculator nearestRectFromArray:rects forRect:faceView.frame];
        [rects removeObject:[NSValue valueWithCGRect:nearestRect]];
        faceView.frame = nearestRect;
        faceView.hidden = NO;
    }
}

#pragma mark - Public

- (void)showFaceViewsWithFaces:(NSArray<CIFaceFeature *> *)faces animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.2f
                              delay:0.f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self readjustFacesArrayWithFaces:faces];
                         } completion:nil];
    } else {
        [self readjustFacesArrayWithFaces:faces];
    }
}

@end
