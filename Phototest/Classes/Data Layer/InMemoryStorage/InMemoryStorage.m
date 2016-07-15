//
//  InMemoryStorage.m
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "InMemoryStorage.h"

@implementation InMemoryStorage

+ (instancetype)storage
{
    static InMemoryStorage *sharedStorage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStorage = [InMemoryStorage new];
    });
    return sharedStorage;
}

@end
