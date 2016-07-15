//
//  CaptureButton.m
//  Phototest
//
//  Created by Pavlo on 7/12/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "CaptureButton.h"

#import "UIColor+AppColors.h"

@interface CaptureButton ()

@property (strong, nonatomic) CAShapeLayer *accessoryLayer;

@end

@implementation CaptureButton

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.backgroundColor = [UIColor applicationGreenColor].CGColor;
    [self addAccessoryLayer];
    [self addTarget:self action:@selector(pressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.cornerRadius = CGRectGetMidX(self.bounds);
    [self.accessoryLayer removeFromSuperlayer];
    [self addAccessoryLayer];
}

#pragma mark - Accessors

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    self.layer.backgroundColor = enabled ? [UIColor applicationGreenColor].CGColor : [UIColor lightGrayColor].CGColor;
    self.accessoryLayer.strokeColor = enabled ? [UIColor whiteColor].CGColor : [UIColor redColor].CGColor;
}

#pragma mark - Private

- (void)addAccessoryLayer
{
    CGFloat dx = CGRectGetWidth(self.bounds) / 20.f;
    CGFloat dy = CGRectGetHeight(self.bounds) / 20.f;
    CGRect targetRect = CGRectInset(self.bounds, dx, dy);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:targetRect];
    
    CAShapeLayer *accessoryLayer = [CAShapeLayer layer];
    accessoryLayer.path = circlePath.CGPath;
    accessoryLayer.fillColor = [UIColor clearColor].CGColor;
    accessoryLayer.strokeColor = [UIColor whiteColor].CGColor;
    accessoryLayer.lineWidth = (dx + dy) / 2.f;
    
    [self.layer addSublayer:accessoryLayer];
    self.accessoryLayer = accessoryLayer;
}

// Capture press event, then block user interaction to prevent button spam
- (void)pressed
{
    self.enabled = NO;
}

@end
