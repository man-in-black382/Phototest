//
//  PositiveDialogButton.m
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "PositiveDialogButton.h"

#import "UIColor+AppColors.h"

@implementation PositiveDialogButton

#pragma mark - Lifecycle

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.accessoryLayer.fillColor = [UIColor whiteColor].CGColor;
    [self addCheckMark];
}

#pragma mark - Private

- (void)addCheckMark
{
    [self.checkMarkLayer removeFromSuperlayer];
    
    CGRect frame = self.accessoryLayer.bounds;
    CGFloat xOffsetLeft = CGRectGetWidth(frame) / 10.f;
    CGFloat xOffsetRight = CGRectGetWidth(frame) / 6.f;
    CGFloat yOffsetRight = CGRectGetHeight(frame) / 10.f;
    CGFloat yOffsetBottom = CGRectGetHeight(frame) / 8.f;
    
    UIBezierPath *checkMarkPath = [UIBezierPath bezierPath];
    CGPoint leftPoint = CGPointMake(CGRectGetMidX(frame) - xOffsetLeft, CGRectGetMidY(frame));
    CGPoint bottomPoint = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame) + yOffsetBottom);
    CGPoint rightPoint = CGPointMake(CGRectGetMidX(frame) + xOffsetRight, CGRectGetMidY(frame) - yOffsetRight);
    [checkMarkPath moveToPoint:leftPoint];
    [checkMarkPath addLineToPoint:bottomPoint];
    [checkMarkPath addLineToPoint:rightPoint];
    
    CAShapeLayer *checkMarkLayer = [CAShapeLayer layer];
    checkMarkLayer.path = checkMarkPath.CGPath;
    checkMarkLayer.fillColor = [UIColor clearColor].CGColor;
    checkMarkLayer.lineWidth = 2.f;
    checkMarkLayer.strokeColor = [UIColor applicationGreenColor].CGColor;
    [self.accessoryLayer addSublayer:checkMarkLayer];
    
    _checkMarkLayer = checkMarkLayer;
}

@end
