//
//  NetworkOperation.m
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "NetworkOperation.h"
#import "NetworkRequest.h"

static NSString *const NetworkOperationErrorDomain = @"NetworkOperationErrorDomain";

@interface NetworkOperation ()

@property (strong, nonatomic) NSMutableURLRequest *urlRequest;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong, nonatomic) NSURLSessionUploadTask *uploadTask;

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@property (strong, nonatomic) NSMutableArray<ProgressBlock> *progressObservers;

@end

@implementation NetworkOperation

#pragma mark - Lifecycle

- (instancetype)initWithNetworkRequest:(NetworkRequest *)networkRequest
                        networkManager:(AFHTTPSessionManager *)networkManager
{
    if ((self = [super init])) {
        _progressObservers = [NSMutableArray array];
        _request = networkRequest;
        _sessionManager = networkManager;
        __weak typeof(self) weakSelf = self;
        
        // Serialize request
        
        NSError *requestSerializationError;
        
        if (networkRequest.multipartFormDataConstructingBlock) {
            self.urlRequest = [networkManager.requestSerializer multipartFormRequestWithMethod:networkRequest.method
                                                                                     URLString:[NSURL URLWithString:networkRequest.path relativeToURL:networkManager.baseURL].absoluteString
                                                                                    parameters:networkRequest.parameters
                                                                     constructingBodyWithBlock:networkRequest.multipartFormDataConstructingBlock
                                                                                         error:&requestSerializationError];
            
        } else {
            NSString *URLString = [NSString stringWithFormat:@"%@%@", networkManager.baseURL, networkRequest.path];
            self.urlRequest = [networkManager.requestSerializer requestWithMethod:networkRequest.method
                                                                        URLString:URLString
                                                                       parameters:networkRequest.parameters
                                                                            error:&requestSerializationError];
        }
        
        if (requestSerializationError) {
            NSLog(@"Request serialization ERROR: %@", requestSerializationError.localizedDescription);
            return self;
        }
        
        [networkRequest.customHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [weakSelf.urlRequest addValue:obj forHTTPHeaderField:key];
        }];
        
        [self initializeTasks];
    }
    return self;
}

- (void)setCompletionSuccessBlock:(SuccessOperationBlock)successBlock andFailureBlock:(FailureOperationBlock)failureBlock
{
    _successBlock = successBlock;
    _failureBlock = failureBlock;
}

- (void)initializeTasks
{
    __weak typeof(self) weakSelf = self;
    
    void (^SuccessOperationBlock)(id operation, id responseObject) = ^(id operation, id responseObject) {
        NSError *responseParsingError;
        
        if ([self.request parseResponse:responseObject error:&responseParsingError]) {
            if (weakSelf.successBlock) {
                weakSelf.successBlock(self);
            }
        } else {
            if (weakSelf.failureBlock) {
                weakSelf.failureBlock(self, responseParsingError, NO);
            }
        }
    };
    
    void (^FailureOperationBlock)(id operation, NSError *error) = ^(id operation, NSError *error) {
        NSLog(@"Status Code: %ld\n Request %@ failed with error:\n %@", (long)self.statusCode, ((NSURLResponse*)operation).URL.path, error.localizedDescription);
        
        if (weakSelf.failureBlock) {
            weakSelf.failureBlock(self, error, error.code == NSURLErrorCancelled);
        }
    };
    
    if (self.request.multipartFormDataConstructingBlock) {
        _uploadTask = [self.sessionManager uploadTaskWithStreamedRequest:self.urlRequest progress:^(NSProgress * _Nonnull uploadProgress) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf->_currentProgress = uploadProgress;
            dispatch_apply(strongSelf.progressObservers.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
                strongSelf.progressObservers[index](uploadProgress);
            });
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf->_statusCode = ((NSHTTPURLResponse *)response).statusCode;
            
            if (!error) {
                SuccessOperationBlock(response, responseObject);
            } else {
                strongSelf->_error = error;
                FailureOperationBlock(response, error);
            }
        }];
    } else {
        _dataTask = [self.sessionManager dataTaskWithRequest:self.urlRequest completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf->_statusCode = ((NSHTTPURLResponse *)response).statusCode;
            
            if (!error) {
                SuccessOperationBlock(response, responseObject);
            } else {
                strongSelf->_error = error;
                FailureOperationBlock(response, error);
            }
        }];
    }
}

#pragma mark - Accessors

- (void)setPerformInBackgroundIfPossible:(BOOL)performInBackgroundIfPossible
{
    _performInBackgroundIfPossible = performInBackgroundIfPossible;
    
    if (performInBackgroundIfPossible) {
        self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        }];
    } else {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    }
}

#pragma mark - Utils

- (void)printRequestData:(NSURLRequest*)request
{
    NSLog(@"Request >>> : \n%@\nmethod - %@\n%@\nHeaders\n%@",
          request.URL.absoluteString,
          request.HTTPMethod,
          [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding],
          request.allHTTPHeaderFields);
}

#pragma mark - Public methods

/**
 *  Start the operation
 */
- (void)start
{
    if (_dataTask) {
        [_dataTask resume];
    } else if (_uploadTask) {
        [_uploadTask resume];
    } else if (_downloadTask) {
        [_downloadTask resume];
    }
    
#ifdef DEBUG
    if (!_downloadTask) {
        [self printRequestData:self.urlRequest];
    }
#endif
}

/**
 *  Restart the operation
 */
- (void)restart
{
    [self initializeTasks];
    [self start];
}

/**
 *  Pause the operation
 */
- (void)pause
{
    if (_dataTask) {
        [_dataTask suspend];
    } else if (_uploadTask) {
        [_uploadTask suspend];
    } else if (_downloadTask) {
        [_downloadTask suspend];
    }
}

/**
 *  Cancel operation
 */
- (void)cancel
{
    if (_dataTask) {
        [_dataTask cancel];
    } else if (_uploadTask) {
        [_uploadTask cancel];
    } else if (_downloadTask) {
        [_downloadTask cancel];
    }
}

/**
 *  Check whether any operation is in process
 *
 *  @return Returns 'YES'
 */
- (BOOL)isInProcess
{
    if (_dataTask) {
        return _dataTask.state == NSURLSessionTaskStateRunning;
    } else if (_uploadTask) {
        return _uploadTask.state == NSURLSessionTaskStateRunning;;
    } else if (_downloadTask) {
        return _downloadTask.state == NSURLSessionTaskStateRunning;;
    }
    return NO;
}

- (void)addProgressObserver:(ProgressBlock)observer
{
    [self.progressObservers addObject:observer];
}

- (void)removeProgressObserver:(ProgressBlock)observer
{
    [self.progressObservers removeObject:observer];
}

@end
