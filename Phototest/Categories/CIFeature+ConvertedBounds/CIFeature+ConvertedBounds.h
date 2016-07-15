//
//  CIFeature+ConvertedBounds.h
//  Phototest
//
//  Created by Pavlo on 7/12/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CIFeature (ConvertedBounds)

@property (assign, nonatomic) CGRect UIKitOrientedBounds;

@end
