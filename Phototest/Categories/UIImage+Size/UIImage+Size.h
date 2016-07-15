//
//  UIImage+Size.h
//  Phototest
//
//  Created by Pavlo on 7/14/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

@interface UIImage (Size)

- (UIImage *)scaledImageWithScaleFactor:(CGFloat)scaleFactor;
- (UIImage *)webSuitedImage;

@end
