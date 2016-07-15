//
//  ReacabilityManager.m
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import <AFNetworking/AFNetworkReachabilityManager.h>

@interface ReachabilityManager : NSObject

@property (assign, nonatomic, readonly) AFNetworkReachabilityStatus reachabilityStatus;

+ (instancetype)sharedManager;
- (BOOL)checkConnection:(NSError **)error;
- (void)addReachabilityStatusChangeHandler:(void(^)(AFNetworkReachabilityStatus newStatus))handler;

@end
