//
//  RectCalculator.h
//  Phototest
//
//  Created by Pavlo on 7/11/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

@interface RectCalculator : NSObject

+ (CGPoint)centerForRect:(CGRect)rect;
+ (CGFloat)distanceFromPoint:(CGPoint)from toPoint:(CGPoint)to;
+ (CGFloat)diagonalOfRect:(CGRect)rect;
+ (CGRect)aspectFitRect:(CGRect)rfit inRect:(CGRect)rtarget;
+ (CGRect)aspectFitRect:(CGRect)rfit aroundRect:(CGRect)rtarget;
+ (CGRect)nearestRectFromArray:(NSArray<NSValue *> *)array forRect:(CGRect)rect;
+ (CGFloat)rectArea:(CGRect)rect;

@end
