//
//  InMemoryStorage.h
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

@interface InMemoryStorage : NSObject

+ (instancetype)storage;

@property (strong, nonatomic) NSString *applicationIdentifier;

@end
