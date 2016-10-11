//
//  FaceViewsManager.h
//  Phototest
//
//  Created by Pavlo on 7/12/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "FaceValidation.h"

@class AVMetadataFaceObject;

@interface FaceViewsManager : NSObject

- (instancetype)initWithFacesParentView:(UIView *)parentView facesValidator:(id<FaceValidation>)validator;
- (void)showFaceViewsForFaces:(NSArray<AVMetadataFaceObject *> *)faces;

@end

