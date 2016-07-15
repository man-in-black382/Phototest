//
//  ImageUploadRequest.m
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "ImageUploadRequest.h"

static NSString *const ImageKey = @"image";
static NSString *const IdentifierKey = @"id";

@implementation ImageUploadRequest

#pragma mark - Lifecycle

- (instancetype)initWithImage:(UIImage *)image identifier:(NSString *)identifier
{
    if (self = [super init]) {
        _path = @"scanner/put.php";
        _method = @"POST";
        _multipartFormDataConstructingBlock = ^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.f) name:ImageKey fileName:@"photo.jpeg" mimeType:@"image/jpeg"];
        };
        _parameters = @{ IdentifierKey : identifier ?: @""};
    }
    return self;
}

@end
