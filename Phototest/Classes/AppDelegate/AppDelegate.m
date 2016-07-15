//
//  AppDelegate.m
//  Phototest
//
//  Created by Pavlo on 7/11/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "AppDelegate.h"

#import "InMemoryStorage.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    [InMemoryStorage storage].applicationIdentifier = [url.query componentsSeparatedByString:@"="].lastObject;
    return YES;
}

@end
