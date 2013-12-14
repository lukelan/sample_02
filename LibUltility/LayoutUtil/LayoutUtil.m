//
//  LayoutUtil.m
//  123Phim
//
//  Created by Le Ngoc Duy on 8/5/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "LayoutUtil.h"

@implementation LayoutUtil
+ (id)loadController:(Class)classType
{
    NSString *className = NSStringFromClass(classType);
    UIViewController *controller = [[classType alloc] initWithNibName:className bundle:nil];
    return controller;
}
@end
