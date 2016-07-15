//
//  UserInteractionMenu.m
//  Phototest
//
//  Created by Pavlo on 7/12/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "UserInteractionMenu.h"
#import "CaptureButton.h"

@interface UserInteractionMenu ()

@property (weak, nonatomic) IBOutlet CaptureButton *captureButton;
@property (weak, nonatomic) IBOutlet UIView *dialogView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dialogViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dialogViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dialogViewVerticalConstraint;

@property (strong, nonatomic) CAShapeLayer *backgroundLayer;

@end

@implementation UserInteractionMenu

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setDefaultState];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.dialogViewHeightConstraint.constant = CGRectGetWidth(self.bounds);
    self.dialogViewWidthConstraint.constant = CGRectGetHeight(self.bounds);
    [self addBackgroundLayer];
}

#pragma mark - Accessors

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    
    self.captureButton.enabled = userInteractionEnabled;
    self.backgroundLayer.fillColor = userInteractionEnabled ? [UIColor whiteColor].CGColor : [UIColor lightGrayColor].CGColor;
}

#pragma mark - Private

- (void)setDefaultState
{
    self.dialogView.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.dialogViewVerticalConstraint.constant = CGRectGetHeight(self.bounds);
    self.dialogView.alpha = 0.f;
}

- (void)addBackgroundLayer
{
    [self.backgroundLayer removeFromSuperlayer];
    
    CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
    backgroundLayer.path = [self defaultPath];
    backgroundLayer.fillColor = [UIColor whiteColor].CGColor;
    backgroundLayer.frame = self.bounds;
    backgroundLayer.position = CGPointMake(backgroundLayer.position.x, [self yPositionForBackgroundLayerDefaultState]);
    [self.layer insertSublayer:backgroundLayer atIndex:0];
    self.backgroundLayer = backgroundLayer;
}

- (CGPathRef)defaultPath
{
    CGFloat captureButtomCenterToBottomDistance = CGRectGetHeight(self.bounds) - self.captureButton.center.y;
    CGFloat newBackgroundHeight = captureButtomCenterToBottomDistance * 2.f;
    CGRect bounds = self.bounds;
    bounds.origin.y = bounds.size.height - newBackgroundHeight;
    bounds.size.height = newBackgroundHeight;
    return [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                 byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                       cornerRadii:CGSizeMake(captureButtomCenterToBottomDistance, captureButtomCenterToBottomDistance)].CGPath;
}

- (CGPathRef)expandedPath
{
    return [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                 byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                       cornerRadii:CGSizeMake(10.f, 10.f)].CGPath;
}

- (CGFloat)yPositionForBackgroundLayerDefaultState
{
    CGFloat captureButtomCenterToBottomDistance = CGRectGetHeight(self.bounds) - self.captureButton.center.y;
    CGRect bounds = self.bounds;
    return bounds.size.height - captureButtomCenterToBottomDistance * 2.f + CGRectGetMidY(self.bounds);
}

- (CGFloat)yPositionForBackgroundLayerExpandedState
{
    return CGRectGetMidY(self.bounds);
}

- (void)animateBackgroundPositionWithStartY:(CGFloat)startY endY:(CGFloat)endY
{
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    positionAnimation.fromValue = @(startY);
    positionAnimation.toValue = @(endY);
    positionAnimation.duration = 0.2f;
    [self.backgroundLayer addAnimation:positionAnimation forKey:@"PositionAnimationKey"];
    self.backgroundLayer.position = CGPointMake(self.backgroundLayer.position.x, endY);
}

- (void)animateBackgroundPathWithStartPath:(CGPathRef)startPath endPath:(CGPathRef)endPath
{
    CABasicAnimation *cornerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    cornerAnimation.fromValue = (__bridge id)(startPath);
    cornerAnimation.toValue = (__bridge id)(endPath);
    cornerAnimation.duration = 0.2f;
    [self.backgroundLayer addAnimation:cornerAnimation forKey:nil];
    self.backgroundLayer.path = endPath;
}

#pragma mark - Public

- (void)showDialog
{
    self.dialogViewVerticalConstraint.constant = 0.f;
    [UIView animateWithDuration:0.2f animations:^{
        self.dialogView.alpha = 1.f;
        self.captureButton.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        self.captureButton.alpha = 0.f;
        [self layoutIfNeeded];
    }];

    [self animateBackgroundPositionWithStartY:[self yPositionForBackgroundLayerDefaultState]
                                         endY:[self yPositionForBackgroundLayerExpandedState]];
    [self animateBackgroundPathWithStartPath:[self defaultPath] endPath:[self expandedPath]];
    
    self.userInteractionEnabled = YES;
}

- (void)hideDialog
{
    self.dialogViewVerticalConstraint.constant = CGRectGetHeight(self.bounds);
    [UIView animateWithDuration:0.2f animations:^{
        self.dialogView.alpha = 0.f;
        self.captureButton.transform = CGAffineTransformMakeScale(1.f, 1.f);
        self.captureButton.alpha = 1.f;
        [self layoutIfNeeded];
    }];

    [self animateBackgroundPositionWithStartY:[self yPositionForBackgroundLayerExpandedState]
                                         endY:[self yPositionForBackgroundLayerDefaultState]];
    [self animateBackgroundPathWithStartPath:[self expandedPath] endPath:[self defaultPath]];
    
    self.captureButton.enabled = YES;
}

- (void)adjustForDeviceOrientation:(UIDeviceOrientation)orientation
{
    if (!UIDeviceOrientationIsLandscape(orientation)) {
        return;
    }
    
    CGFloat angle;
    
    switch (orientation) {
        case UIDeviceOrientationLandscapeRight: {
            angle = -M_PI_2;
            break;
        }
            
        default: {
            angle = M_PI_2;
        }
    }
    
    CGAffineTransform firstTransform = CGAffineTransformMakeRotation(0);
    firstTransform = CGAffineTransformScale(firstTransform, 0.01f, 0.01f);
    
    CGAffineTransform secondTransform = CGAffineTransformMakeRotation(angle);
    secondTransform = CGAffineTransformScale(secondTransform, 1.f, 1.f);
    
    [UIView animateKeyframesWithDuration:0.3f
                                   delay:0.f
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.f
                                                          relativeDuration:0.5f
                                                                animations:^{
                                                                    self.dialogView.transform = firstTransform;
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:0.5f
                                                          relativeDuration:0.5f
                                                                animations:^{
                                                                    self.dialogView.transform = secondTransform;
                                                                }];
                              } completion:nil];
}

@end
