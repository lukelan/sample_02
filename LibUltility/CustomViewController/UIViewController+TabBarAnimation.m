//
//  UIViewController+TabBarAnimation.m
//  123Phim
//
//  Created by phuonnm on 8/2/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "UIViewController+TabBarAnimation.h"

@implementation UIViewController (TabBarAnimation)

- (void)performShowTabBar
{
    CGRect frame = self.tabBarController.tabBar.frame;
    frame.origin.y --;
    if (frame.origin.y == self.tabBarController.tabBar.window.frame.size.height)
    {
        frame.origin.y -= frame.size.height;
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
            self.tabBarController.tabBar.frame = frame;
            
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)performHideTabBar
{
    CGRect frame = self.tabBarController.tabBar.frame;
    frame.origin.y += frame.size.height;
    if (frame.origin.y == self.tabBarController.tabBar.window.frame.size.height)
    {
        frame.origin.y++;
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
            self.tabBarController.tabBar.frame = frame;
        } completion:^(BOOL finished) {
        }];
    }
}


- (void)performHideNavigatorBar
{
    CGRect frame = self.navigationController.navigationBar.frame;
    if (frame.origin.y == TITLE_BAR_HEIGHT)
    {
        frame.origin.y -= (frame.size.height + 1 + TITLE_BAR_HEIGHT) ;
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
            self.navigationController.navigationBar.frame = frame;
            
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)performShowNavigatorBar
{
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.origin.y += frame.size.height + 1 + TITLE_BAR_HEIGHT;
    if (frame.origin.y == TITLE_BAR_HEIGHT)
    {
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
            self.navigationController.navigationBar.frame = frame;
        } completion:^(BOOL finished) {
        }];
    }
}

@end
