//
//  UIView+AnimationView.m
//  123Phim
//
//  Created by Le Ngoc Duy on 6/3/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "UIView+AnimationView.h"

@implementation UIView (AnimationView)
- (void)performTransition:(UIViewAnimationOptions)options fromView:(UIView *)toView toView:(UIView *)fromView
{
    [UIView transitionWithView:fromView duration:0.6 options:UIViewAnimationCurveLinear animations:^{
        if (fromView.center.y >= toView.frame.size.height) {
            [fromView setCenter:CGPointMake(fromView.center.x, fromView.center.y - toView.frame.size.height)];
        } else {
            [fromView setCenter:CGPointMake(fromView.center.x, fromView.center.y + toView.frame.size.height)];
        }
    } completion:^(BOOL finished) {
        
    }];
}

-(void)performActionAnimation:(UIViewAnimationOptions)option duration:(NSTimeInterval)duration delay:(NSTimeInterval)timeDelay
{
    [UIView beginAnimations:@"Change View" context:nil];
    [UIView  setAnimationDuration:duration];
    [UIView setAnimationDelay:timeDelay];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:option forView:self cache:YES];
    [UIView commitAnimations];
}
@end
