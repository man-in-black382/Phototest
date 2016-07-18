//
//  UIImage+Size.m
//  Phototest
//
//  Created by Pavlo on 7/14/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "UIImage+Size.h"

@implementation UIImage (Size)

- (UIImage *)scaledImageWithScaleFactor:(CGFloat)scaleFactor
{
    CGSize newSize = CGSizeMake(self.size.width * scaleFactor, self.size.height * scaleFactor);
    UIGraphicsBeginImageContextWithOptions(newSize, YES, self.scale);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *scaledAndNormalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledAndNormalizedImage;
}

- (UIImage *)webSuitedImage
{
    const CGFloat treshold = 800.f;
    CGFloat maxDimension = MAX(self.size.width, self.size.height);
    
    if (maxDimension < treshold) {
        return self;
    }
    
    CGFloat downscaleFactor = treshold / maxDimension;
    return [self scaledImageWithScaleFactor:downscaleFactor];
}

@end
