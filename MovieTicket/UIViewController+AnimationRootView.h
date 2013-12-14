//
//  UIViewController+AnimationRootView.h
//  123Phim
//
//  Created by Le Ngoc Duy on 6/3/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AnimationRootView)
- (void)performHorizontalChangeRootViewDuration:(NSTimeInterval)duration fromViewDefault:(UIView *)layoutTable toViewPrepair:(UIView *)tempTable isCurrentPrepairView:(BOOL)isCurrentDefault isFromRightToLeft:(BOOL)isFromRightToLeft compelete:(void(^)())blockCode;
- (void)performVeticalChangeRootViewDuration:(NSTimeInterval)duration fromViewDefault:(UIView *)layoutTable toViewPrepair:(UIView *)tempTable isCurrentPrepairView:(BOOL)isDislayingTempTable isFromTopToBottom:(BOOL)isFromTopToBottom compelete:(void(^)())blockCode;
@end
