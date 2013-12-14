//
//  UIViewController+showhideTabbar.h
//  123Phim
//
//  Created by Le Ngoc Duy on 5/27/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (showhideTabbar)
- (void)performPushViewControllerAndShowTaBar;
- (void)performPushViewControllerAndHideTaBar;
- (void) showTheTabBarWithAnimation:(BOOL) withAnimation;
- (void) hideTheTabBarWithAnimation:(BOOL) withAnimation;
@end
