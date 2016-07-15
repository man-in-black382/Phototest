//
//  UploadStatusView.m
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

#import "UploadStatusView.h"
#import "PositiveDialogButton.h"

#import "UIColor+AppColors.h"

@interface UploadStatusView ()

@property (weak, nonatomic) IBOutlet UIView *progressingUploadView;
@property (weak, nonatomic) IBOutlet UIView *failedUploadView;
@property (weak, nonatomic) IBOutlet PositiveDialogButton *successfullUploadDialogButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalConstraint;

@property (assign, nonatomic) UIDeviceOrientation previousOrientation;

@end

@implementation UploadStatusView

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self customizeSuccessfullDialogButton];
    [self setupDefaults];
    [self adjustForDeviceOrientation:UIDeviceOrientationLandscapeLeft];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self customizeSuccessfullDialogButton];
}

#pragma mark - Private

- (void)setupDefaults
{
    self.progressingUploadView.layer.cornerRadius = 2.f;
    self.failedUploadView.layer.cornerRadius = 2.f;
    self.successfullUploadDialogButton.hidden = self.progressingUploadView.hidden = self.failedUploadView.hidden = YES;
    self.successfullUploadDialogButton.alpha = self.progressingUploadView.alpha = self.failedUploadView.alpha = 0.f;
}

- (void)customizeSuccessfullDialogButton
{
    self.successfullUploadDialogButton.enabled = NO;
    self.successfullUploadDialogButton.accessoryLayer.fillColor = [UIColor applicationGreenColor].CGColor;
    self.successfullUploadDialogButton.checkMarkLayer.strokeColor = [UIColor whiteColor].CGColor;
}

- (void)fadeTo:(CGFloat)to view:(UIView *)view completion:(void(^)())completion
{
    [self fadeTo:to withDelay:0.f view:view completion:completion];
}

- (void)fadeTo:(CGFloat)to withDelay:(CGFloat)delay view:(UIView *)view completion:(void(^)())completion
{
    [UIView animateWithDuration:0.2f
                          delay:delay
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         view.alpha = to;
                     } completion:^(BOOL finished) {
                         if (finished && completion) {
                             completion();
                         }
                     }];
}

#pragma mark - Public

- (void)uploadStarted
{
    self.successfullUploadDialogButton.hidden = YES;
    
    self.progressingUploadView.hidden = NO;
    [self fadeTo:1.f view:self.progressingUploadView completion:nil];
    
    [self fadeTo:0.f view:self.failedUploadView completion:^{
        self.failedUploadView.hidden = self.failedUploadView.alpha < 1.f;
    }];
}

- (void)uploadFailed
{
    self.failedUploadView.hidden = NO;
    [self fadeTo:1.f view:self.failedUploadView completion:nil];
    
    [self fadeTo:0.f view:self.progressingUploadView completion:^{
        self.progressingUploadView.hidden = self.progressingUploadView.alpha < 1.f;
    }];
}

- (void)uploadCompleted
{
    self.successfullUploadDialogButton.hidden = NO;
    [self fadeTo:1.f view:self.successfullUploadDialogButton completion:nil];
    
    [self fadeTo:0.f withDelay:2.f view:self.successfullUploadDialogButton completion:^{
        self.successfullUploadDialogButton.hidden = self.successfullUploadDialogButton.alpha < 1.f;
    }];
    
    [self fadeTo:0.f view:self.progressingUploadView completion:^{
        self.progressingUploadView.hidden = self.progressingUploadView.alpha < 1.f;
    }];
}

- (void)uploadCancelled
{
    [self fadeTo:0.f view:self.failedUploadView completion:^{
        self.failedUploadView.hidden = self.failedUploadView.alpha < 1.f;
    }];
}

- (void)adjustForDeviceOrientation:(UIDeviceOrientation)orientation
{
    if (!UIDeviceOrientationIsLandscape(orientation) || self.previousOrientation == orientation) {
        return;
    }
    
    self.previousOrientation = orientation;
    
    [self fadeTo:0.f view:self completion:^{
        switch (orientation) {   
            case UIDeviceOrientationLandscapeRight: {
                self.verticalConstraint.constant = CGRectGetMidX(self.bounds) - CGRectGetMidY(self.superview.bounds);
                self.horizontalConstraint.constant = CGRectGetMidY(self.bounds) - CGRectGetMidX(self.superview.bounds);
                self.transform = CGAffineTransformMakeRotation(-M_PI_2);
                [self fadeTo:1.f view:self completion:nil];
                break;
            }
                
            default: {
                self.verticalConstraint.constant = CGRectGetMidX(self.bounds) - CGRectGetMidY(self.superview.bounds);
                self.horizontalConstraint.constant = CGRectGetMidX(self.superview.bounds) - CGRectGetMidY(self.bounds);
                self.transform = CGAffineTransformMakeRotation(M_PI_2);
                [self fadeTo:1.f view:self completion:nil];
            }
        }
    }];
}

@end
