//
//  NetworkRequest.h
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import <AFNetworking/AFURLRequestSerialization.h>

typedef NS_ENUM(NSInteger, RequestSerializationType) {
    RequestSerializationTypeHTTP,
    RequestSerializationTypeJSON
};

@interface NetworkRequest : NSObject {
@protected
    NSString *_path;
    NSDictionary *_parameters;
    NSString *_method;
    NSDictionary *_customHeaders;
    
    id _preliminarilyParsedResponse;
    
    void(^_multipartFormDataConstructingBlock)(id<AFMultipartFormData> formData);
}

@property (strong, nonatomic, readonly) NSString *path;
@property (strong, nonatomic, readonly) NSDictionary *parameters;
@property (strong, nonatomic, readonly) NSString *method;
@property (strong, nonatomic, readonly) NSDictionary *customHeaders;
@property (copy, nonatomic, readonly) void(^multipartFormDataConstructingBlock)(id<AFMultipartFormData> formData);
@property (assign, nonatomic) RequestSerializationType serializationType;

- (BOOL)parseResponse:(id)response error:(NSError **)error;

@end
