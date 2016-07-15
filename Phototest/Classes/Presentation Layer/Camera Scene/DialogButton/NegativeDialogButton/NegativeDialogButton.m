//
//  NegativeDialogButton.m
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "NegativeDialogButton.h"

@implementation NegativeDialogButton

#pragma mark - Lifecycle

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.accessoryLayer.fillColor = [UIColor blackColor].CGColor;
    [self addPointer];
}

#pragma mark - Private

- (void)addPointer
{
    [self.pointerLayer removeFromSuperlayer];
    
    CGRect frame = self.accessoryLayer.bounds;
    CGFloat xOffset = CGRectGetWidth(frame) / 10.f;
    CGFloat yOffset = CGRectGetHeight(frame) / 5.f;
    UIBezierPath *pointerPath = [UIBezierPath bezierPath];
    CGPoint topPoint = CGPointMake(CGRectGetMidX(frame) + xOffset, CGRectGetMidY(frame) - yOffset);
    CGPoint middlePoint = CGPointMake(CGRectGetMidX(frame) - xOffset, CGRectGetMidY(frame));
    CGPoint bottomPoint = CGPointMake(CGRectGetMidX(frame) + xOffset, CGRectGetMidY(frame) + yOffset);
    [pointerPath moveToPoint:topPoint];
    [pointerPath addLineToPoint:middlePoint];
    [pointerPath addLineToPoint:bottomPoint];
    
    CAShapeLayer *pointerLayer = [CAShapeLayer layer];
    pointerLayer.path = pointerPath.CGPath;
    pointerLayer.fillColor = [UIColor clearColor].CGColor;
    pointerLayer.lineWidth = 2.f;
    pointerLayer.strokeColor = [UIColor whiteColor].CGColor;
    [self.accessoryLayer addSublayer:pointerLayer];
    
    _pointerLayer = pointerLayer;
}

@end
