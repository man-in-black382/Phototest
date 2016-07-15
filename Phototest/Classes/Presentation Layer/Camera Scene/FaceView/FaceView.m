//
//  FaceView.m
//  Phototest
//
//  Created by Pavlo on 7/11/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "FaceView.h"

@implementation FaceView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat thickness = 2.f;
        self.layer.borderWidth = thickness;
        self.layer.borderColor = [UIColor yellowColor].CGColor;
        self.layer.cornerRadius = 6.f;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
