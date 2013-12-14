//
//  UIAlertView+UIAlertViewAdditions.m
//  123Phim
//
//  Created by Le Ngoc Duy on 10/2/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "UIAlertView+UIAlertViewAdditions.h"

@implementation UIAlertView (UIAlertViewAdditions)
+ (UIAlertView *) getUIAlertViewIfShown {
    if ([[[UIApplication sharedApplication] windows] count] == 1) {
        return nil;
    }
    
    NSArray *arrWindows = [[UIApplication sharedApplication] windows];
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:(arrWindows.count - 1)];
    for (int i = 0; i < window.subviews.count; i++) {
        UIView *view = [window.subviews objectAtIndex:i];
        if ([view isKindOfClass:[UIAlertView class]]) {
            return (UIAlertView *) view;
        }
    }

    return nil;
}

+ (void)dimissAlertViewWithTag:(int)tag
{
    if ([[[UIApplication sharedApplication] windows] count] == 1) {
        return;
    }

    UIAlertView *alert = nil;
    NSArray *arrWindows = [[UIApplication sharedApplication] windows];
    if (arrWindows > 0) {
        UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:(arrWindows.count - 1)];
        UIView *view = [window viewWithTag:tag];
        if ([view isKindOfClass:[UIAlertView class]]) {
            alert = (UIAlertView *)view;
        }
    }

    if (alert) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    }
}

+ (void)dimissCurrentAlertView
{
    UIAlertView *alert = [UIAlertView getUIAlertViewIfShown];
    if (alert) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    }
}
@end
