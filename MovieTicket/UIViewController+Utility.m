//
//  UIViewController+Utility.m
//  123Phim
//
//  Created by Nhan Mai on 7/15/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "UIViewController+Utility.h"

@implementation UIViewController (Utility)

-(void)removeAllSubViewFromView:(UIView *)contentView
{
    for (UIView *view in contentView.subviews) {
        [view removeFromSuperview];
    }
}
@end
