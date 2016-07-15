//
//  NetworkFacade.m
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "NetworkFacade.h"
#import "SessionManager.h"

#import "ImageUploadRequest.h"

static NSString *const BaseURLString = @"https://dio.privatbank.ua/api/";

@implementation NetworkFacade

#pragma mark - Lifecycle

+ (SessionManager *)sessionManager
{
    static SessionManager *sessionManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [[SessionManager alloc] initWithBaseURLString:BaseURLString];
    });
    return sessionManager;
}

#pragma mark - Public

+ (NetworkOperation *)uploadImage:(UIImage *)image withIdentifier:(NSString *)identifier
                      withSuccess:(void (^)())successBlock orFailure:(void (^)(NSUInteger))failureBlock
{
    ImageUploadRequest *request = [[ImageUploadRequest alloc] initWithImage:image identifier:identifier];
    
    return [[self sessionManager] enqueueOperationWithNetworkRequest:request success:^(NetworkOperation *operation) {
        if (successBlock) {
            successBlock();
        }
    } orFailure:^(NetworkOperation *operation, NSError *error, BOOL isCanceled) {
        if (!isCanceled && failureBlock) {
            failureBlock(operation.statusCode);
        }
    }];
}

@end
