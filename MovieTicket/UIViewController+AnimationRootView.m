//
//  UIViewController+AnimationRootView.m
//  123Phim
//
//  Created by Le Ngoc Duy on 6/3/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "UIViewController+AnimationRootView.h"

@implementation UIViewController (AnimationRootView)
#pragma mark change view by move view from right to Left or left to right
- (void)performHorizontalChangeRootViewDuration:(NSTimeInterval)duration fromViewDefault:(UITableView *)layoutTable toViewPrepair:(UITableView *)tempTable isCurrentPrepairView:(BOOL)isDislayingTempTable isFromRightToLeft:(BOOL)isFromRightToLeft compelete:(void(^)())blockCode
{
    CGRect rectOriginal = layoutTable.frame;
    CGRect rectSource = tempTable.frame;
    CGRect rectDes = CGRectMake(rectOriginal.origin.x - rectOriginal.size.width, rectOriginal.origin.y, rectOriginal.size.width, rectOriginal.size.height);
    if (isDislayingTempTable) {
        if (![layoutTable superview]) {
            [self.view addSubview:layoutTable];
        }
        rectOriginal = tempTable.frame;
        rectSource = layoutTable.frame;
        rectDes = CGRectMake(rectOriginal.origin.x -rectSource.size.width, rectOriginal.origin.y, rectOriginal.size.width, rectOriginal.size.height);
    } else {
        if (![tempTable superview]) {
            [self.view addSubview:tempTable];
        }
    }
    if (!isFromRightToLeft) {
        CGRect temp = rectDes;
        rectDes = rectSource;
        rectDes.origin.x = fabsf(rectDes.origin.x);
        rectSource = temp;
    }
    
    [UIView animateWithDuration:duration animations:^{
        if (isDislayingTempTable) {
            tempTable.frame = rectDes;
            layoutTable.frame = rectOriginal;
//            if ([layoutTable isKindOfClass:[UITableView class]])
//            {
//                [(UITableView *)layoutTable reloadData];
//            }
        } else {
            layoutTable.frame = rectDes;
            tempTable.frame = rectOriginal;
//            if ([tempTable isKindOfClass:[UITableView class]])
//            {
//                [(UITableView *)tempTable reloadData];
//            }
        }
    } completion:^(BOOL finished) {
        if (isDislayingTempTable)
        {
            tempTable.frame = rectSource;
//            [tempTable removeFromSuperview];
        }
        else
        {
            layoutTable.frame = rectSource;
//            [layoutTable removeFromSuperview];
        }
        if (blockCode) {
            blockCode();
        }
    }];
}

#pragma mark animation flip from top -> bottom and then
- (void)performVeticalChangeRootViewDuration:(NSTimeInterval)duration fromViewDefault:(UITableView *)layoutTable toViewPrepair:(UITableView *)tempTable isCurrentPrepairView:(BOOL)isDislayingTempTable isFromTopToBottom:(BOOL)isFromTopToBottom compelete:(void(^)())blockCode
{
    CGRect rectOriginal = layoutTable.frame;
    CGRect rectSource = tempTable.frame;
    CGRect rectDes = CGRectMake(rectOriginal.origin.x, rectOriginal.origin.y - rectOriginal.size.height, rectOriginal.size.width, rectOriginal.size.height);
    if (isDislayingTempTable) {
        if (![layoutTable superview]) {
            [self.view addSubview:layoutTable];
        }
        rectOriginal = tempTable.frame;
        rectSource = layoutTable.frame;
        rectDes = CGRectMake(rectOriginal.origin.x, rectOriginal.origin.y - rectOriginal.size.height, rectOriginal.size.width, rectOriginal.size.height);
    } else {
        if (![tempTable superview]) {
            [self.view addSubview:tempTable];
        }
    }
    if (isFromTopToBottom) {
        CGRect temp = rectDes;
        rectDes = rectSource;
        rectDes.origin.y = fabsf(rectDes.origin.y);
        rectSource = temp;
    }
    
    [UIView animateWithDuration:duration animations:^{
        if (isDislayingTempTable) {
            tempTable.frame = rectDes;
            layoutTable.frame = rectOriginal;
            if ([layoutTable isKindOfClass:[UITableView class]])
            {
                [(UITableView *)layoutTable reloadData];
            }
        } else {
            layoutTable.frame = rectDes;
            tempTable.frame = rectOriginal;
            if ([tempTable isKindOfClass:[UITableView class]]) {
                [(UITableView *)tempTable reloadData];
            }
        }
    } completion:^(BOOL finished) {
        if (isDislayingTempTable)
        {
            tempTable.frame = rectSource;
            [tempTable removeFromSuperview];
        }
        else
        {
            layoutTable.frame = rectSource;
            [layoutTable removeFromSuperview];
        }
        if (blockCode) {
            blockCode();
        }
    }];
}
@end
