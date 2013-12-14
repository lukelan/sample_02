//
//  UIViewController+CaptureSceen.h
//  123Phim
//
//  Created by Nhan Mai on 6/28/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CaptureSceen)

@property (nonatomic,retain) UIWindow* coverWindow;

- (void)captureScreen;

@end
