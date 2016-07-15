//
//  ImageUploadRequest.h
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "NetworkRequest.h"

@interface ImageUploadRequest : NetworkRequest

- (instancetype)initWithImage:(UIImage *)image identifier:(NSString *)identifier;

@end
