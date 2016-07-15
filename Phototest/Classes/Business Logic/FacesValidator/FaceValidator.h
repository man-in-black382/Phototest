//
//  FacesValidator.h
//  Phototest
//
//  Created by Pavlo on 7/12/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import <CoreImage/CoreImage.h>

#import "FaceValidation.h"

@interface FaceValidator : NSObject <FaceValidation>

- (instancetype)initWithFacesWorkingSurface:(CGRect)surface;

@end
