//
//  SessionManager.h
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "NetworkOperation.h"

typedef void (^CleanBlock)();

@class NetworkRequest;

@interface SessionManager : NSObject

@property (assign, atomic, readonly) NSInteger requestNumber;
@property (strong, nonatomic, readonly) NSURL *baseURL;

- (instancetype)initWithBaseURLString:(NSString *)baseURLString;

- (void)cancelAllOperations;
- (void)cleanManagersWithCompletionBlock:(CleanBlock)block;

- (NetworkOperation *)enqueueOperationWithNetworkRequest:(NetworkRequest *)networkRequest
                                                 success:(SuccessOperationBlock)successBlock
                                               orFailure:(FailureOperationBlock)failureBlock;

- (BOOL)isOperationInProcess;

@end
