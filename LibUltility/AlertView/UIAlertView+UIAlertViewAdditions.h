//
//  UIAlertView+UIAlertViewAdditions.h
//  123Phim
//
//  Created by Le Ngoc Duy on 10/2/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (UIAlertViewAdditions)
+ (UIAlertView *) getUIAlertViewIfShown;
+ (void)dimissCurrentAlertView;
+ (void)dimissAlertViewWithTag:(int)tag;
@end
