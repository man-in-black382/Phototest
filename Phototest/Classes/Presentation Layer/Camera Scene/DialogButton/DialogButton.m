//
//  DialogButton.m
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "DialogButton.h"

@implementation DialogButton

#pragma mark - Lifecycle

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self addAccessoryLayer];
    [self adjustTitleInsets];
    self.layer.cornerRadius = 3.f;
    self.layer.backgroundColor = self.backgroundColor.CGColor;
}

#pragma mark - Private

- (void)addAccessoryLayer
{
    [self.accessoryLayer removeFromSuperlayer];
    
    CGFloat height = CGRectGetHeight(self.bounds);
    CGRect frame = CGRectMake(0.f, 0.f, height, height);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(frame, height / 7.f, height / 7.f)];
    CAShapeLayer *accessoryLayer = [CAShapeLayer layer];
    accessoryLayer.path = circlePath.CGPath;
    accessoryLayer.frame = frame;
    [self.layer insertSublayer:accessoryLayer atIndex:0];
    _accessoryLayer = accessoryLayer;
}

- (void)adjustTitleInsets
{
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat freeWidth = CGRectGetWidth(self.bounds) - height;
    CGFloat expectedXPosition = freeWidth / 2.f + height;
    self.titleLabel.center = CGPointMake(expectedXPosition, self.titleLabel.center.y);
}

@end
