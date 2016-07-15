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
    CGContextRef bitmap = CGBitmapContextCreate(nil,
                                                newSize.height,
                                                newSize.width,
                                                CGImageGetBitsPerComponent(self.CGImage),
                                                4 * newSize.height, CGImageGetColorSpace(self.CGImage),
                                                (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, newSize.height, newSize.width), self.CGImage);
    
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    
    return newImage;
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
