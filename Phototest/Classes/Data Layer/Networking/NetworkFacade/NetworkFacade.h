//
//  NetworkFacade.h
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "NetworkOperation.h"

@interface NetworkFacade : NSObject

+ (NetworkOperation *)uploadImage:(UIImage *)image withIdentifier:(NSString *)identifier
                          withSuccess:(void(^)())successBlock orFailure:(void(^)(NSUInteger statusCode))failureBlock;

@end
