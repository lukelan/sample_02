//
//  CinemaTableViewLocationItem.m
//  123Phim
//
//  Created by Tai Truong on 12/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CinemaTableViewLocationItem.h"

@implementation CinemaTableViewLocationItem

-(id)initWithTitle:(NSString *)title andAddress:(NSString *)address isActive:(BOOL)isLocationActive
{
    self = [super initWithTitle:title andAddress:address];
    if (self) {
        _isActive = isLocationActive;
    }
    return self;
}
@end
