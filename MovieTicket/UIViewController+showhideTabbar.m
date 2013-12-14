//
//  UIViewController+showhideTabbar.m
//  123Phim
//
//  Created by Le Ngoc Duy on 5/27/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "UIViewController+showhideTabbar.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIViewController (showhideTabbar)
#pragma mark show hide tabbar by push
- (void)performPushViewControllerAndShowTaBar
{
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setDuration:0.3];
    [[self.view.window layer] addAnimation:animation forKey:@"PopShowTabar"];
    [self.tabBarController.tabBar setHidden:NO];
}
- (void)performPushViewControllerAndHideTaBar
{
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromRight];
    [animation setDuration:0.3];
    [[self.view.window layer] addAnimation:animation forKey:@"PushHideTabar"];
    [self.tabBarController.tabBar setHidden:YES];
}

#pragma show hide tabbar by alpha
- (void) hideTheTabBarWithAnimation:(BOOL) withAnimation
{
    if (!self.tabBarController)
    {
        return;
    }
    
    if (withAnimation == NO) {
        [self.tabBarController.tabBar setHidden:YES];
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:nil];
        [UIView setAnimationDuration:0.75];
        
        [self.tabBarController.tabBar setAlpha:0.0];
        
        [UIView commitAnimations];
    }
}

- (void) showTheTabBarWithAnimation:(BOOL) withAnimation
{
    if (!self.tabBarController)
    {
        return;
    }
    
    if (withAnimation == NO) {
        [self.tabBarController.tabBar setHidden:NO];
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:nil];
        [UIView setAnimationDuration:0.75];
        
        [self.tabBarController.tabBar setAlpha:1];
        
        [UIView commitAnimations];
    }
}
@end
