//
//  DefineCategory.h
//  MovieTicket
//
//  Created by Le Ngoc Duy on 1/11/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#ifndef MovieTicket_DefineCategory_h
#define MovieTicket_DefineCategory_h
@implementation UIView (performAnimationView)
#pragma mark method play animation
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

@implementation UINavigationController (Rotation_IOS6)

-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
#endif
