//
//  FaceViewsManager.h
//  Phototest
//
//  Created by Pavlo on 7/12/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import <CoreImage/CoreImage.h>

#import "FaceValidation.h"

@interface FaceViewsManager : NSObject

- (instancetype)initWithFacesParentView:(UIView *)parentView facesValidator:(id<FaceValidation>)validator;
- (void)showFaceViewsWithFaces:(NSArray<CIFaceFeature *> *)faces animated:(BOOL)animated;

@end
