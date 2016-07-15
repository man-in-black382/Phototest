//
//  NetworkRequest.m
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "NetworkRequest.h"

@implementation NetworkRequest

#pragma mark - Lifecycle

- (id)init
{
    if (self = [super init]) {
        _path = @"";
        _parameters = @{};
        _customHeaders = @{};
        _serializationType = RequestSerializationTypeJSON;
    }
    return self;
}

#pragma mark - Methods

- (BOOL)parseResponse:(id)response error:(NSError **)error
{
    if (!response) {
        *error = [NSError errorWithDomain:@"ErrorEmptyResponse"
                                     code:1
                                 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"%@ - response is empty", NSStringFromClass([self class])] }];
        return NO;
    }
    
    if ([response isKindOfClass:[NSData class]]) {
        _preliminarilyParsedResponse = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:error];
        
        if (*error) {
            return NO;
        }
    } else if ([response isKindOfClass:[NSDictionary class]] || [response isKindOfClass:[NSArray class]]) {
        _preliminarilyParsedResponse = response;
    } else {
        *error = [NSError errorWithDomain:@"ErrorResponseWrongType"
                                     code:1
                                 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Response is of wrong type (%@)", NSStringFromClass([response class])] }];
        return NO;
    }
    
    return YES;
}

@end
