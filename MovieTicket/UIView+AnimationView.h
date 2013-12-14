//
//  UIView+AnimationView.h
//  123Phim
//
//  Created by Le Ngoc Duy on 6/3/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AnimationView)
- (void)performTransition:(UIViewAnimationOptions)options fromView:(UIView *)toView toView:(UIView *)fromView;
- (void)performActionAnimation:(UIViewAnimationOptions)option duration:(NSTimeInterval)duration delay:(NSTimeInterval)timeDelay;
@end
