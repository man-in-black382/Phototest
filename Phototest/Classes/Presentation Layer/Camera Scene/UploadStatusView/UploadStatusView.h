//
//  UploadStatusView.h
//  Phototest
//
//  Created by Pavlo on 7/13/16.
//  Copyright © 2016 Pavlo Muratov. All rights reserved.
//

@interface UploadStatusView : UIView

- (void)uploadStarted;
- (void)uploadCompleted;
- (void)uploadFailed;
- (void)uploadCancelled;
- (void)adjustForDeviceOrientation:(UIDeviceOrientation)orientation;

@end
