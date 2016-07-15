//
//  FacesValidation.h
//  Phototest
//
//  Created by Pavlo on 7/12/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

@class CIFaceFeature;

@protocol FaceValidation <NSObject>

- (BOOL)areFacesValid:(NSArray<CIFaceFeature *> *)faces;

@end
