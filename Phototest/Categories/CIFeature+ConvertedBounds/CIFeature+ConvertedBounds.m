//
//  CIFeature+ConvertedBounds.m
//  Phototest
//
//  Created by Pavlo on 7/12/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "CIFeature+ConvertedBounds.h"

#import <objc/runtime.h>

/**
 *  This category adds an ability to attach a UIKit friendly bounds information to the CIFeature objects
 */
@implementation CIFeature (ConvertedBounds)

- (CGRect)UIKitOrientedBounds
{
    NSValue *rect = objc_getAssociatedObject(self, @selector(UIKitOrientedBounds));
    return rect.CGRectValue;
}

- (void)setUIKitOrientedBounds:(CGRect)UIKitOrientedBounds
{
    objc_setAssociatedObject(self, @selector(UIKitOrientedBounds), [NSValue valueWithCGRect:UIKitOrientedBounds], OBJC_ASSOCIATION_RETAIN);
}

@end
