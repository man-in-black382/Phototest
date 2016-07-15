//
//  RectCalculator.m
//  Phototest
//
//  Created by Pavlo on 7/11/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "RectCalculator.h"

@implementation RectCalculator

#pragma mark - Private

+ (CGFloat)scaleToAspectFitRect:(CGRect)rfit inRect:(CGRect)rtarget
{
    CGFloat s = CGRectGetWidth(rtarget) / CGRectGetWidth(rfit);
    if (CGRectGetHeight(rfit) * s <= CGRectGetHeight(rtarget)) {
        return s;
    }
    return CGRectGetHeight(rtarget) / CGRectGetHeight(rfit);
}

+ (CGFloat)scaleToAspectFitRect:(CGRect)rfit aroundRect:(CGRect)rtarget
{
    return 1 / [self scaleToAspectFitRect:rtarget inRect:rfit];
}

+ (CGPoint)centerForRect:(CGRect)rect
{
    return CGPointMake((CGRectGetMinX(rect) + CGRectGetMaxX(rect)) / 2.f,
                       (CGRectGetMinY(rect) + CGRectGetMaxY(rect)) / 2.f);
}

+ (CGFloat)distanceFromPoint:(CGPoint)from toPoint:(CGPoint)to
{
    CGFloat xDifference = to.x - from.x;
    CGFloat yDifference = to.y - from.y;
    return sqrt(xDifference * xDifference + yDifference * yDifference);
}

#pragma mark - Public

+ (CGRect)aspectFitRect:(CGRect)rfit inRect:(CGRect)rtarget
{
    CGFloat s = [self scaleToAspectFitRect:rfit inRect:rtarget];
    CGFloat w = CGRectGetWidth(rfit) * s;
    CGFloat h = CGRectGetHeight(rfit) * s;
    CGFloat x = CGRectGetMidX(rtarget) - w / 2;
    CGFloat y = CGRectGetMidY(rtarget) - h / 2;
    return CGRectMake(x, y, w, h);
}

+ (CGRect)aspectFitRect:(CGRect)rfit aroundRect:(CGRect)rtarget
{
    CGFloat s = [self scaleToAspectFitRect:rfit aroundRect:rtarget];
    CGFloat w = CGRectGetWidth(rfit) * s;
    CGFloat h = CGRectGetHeight(rfit) * s;
    CGFloat x = CGRectGetMidX(rtarget) - w / 2;
    CGFloat y = CGRectGetMidY(rtarget) - h / 2;
    return CGRectMake(x, y, w, h);
}

+ (CGRect)nearestRectFromArray:(NSArray<NSValue *> *)array forRect:(CGRect)rect
{
    if (!array.count) {
        return CGRectZero;
    }
    
    CGPoint rectCenter = [self centerForRect:rect];
    CGFloat minimumDistance = [self distanceFromPoint:[self centerForRect:array.firstObject.CGRectValue] toPoint:rectCenter];
    CGRect nearestRect = array.firstObject.CGRectValue;
    
    for (NSUInteger i = 1; i < array.count; i++) {
        CGRect iRect = array[i].CGRectValue;
        CGFloat distance = [self distanceFromPoint:[self centerForRect:iRect] toPoint:rectCenter];
        if (distance < minimumDistance) {
            minimumDistance = distance;
            nearestRect = iRect;
        }
    }
    return nearestRect;
}

+ (CGFloat)rectArea:(CGRect)rect
{
    return CGRectGetWidth(rect) * CGRectGetHeight(rect);
}

@end
