//
//  CinemaTableViewItem.m
//  123Phim
//
//  Created by Tai Truong on 12/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CinemaTableViewItem.h"

@implementation CinemaTableViewItem

-(id)initWithTitle:(NSString*)title andAddress:(NSString*)address
{
    self = [super init];
    if (self) {
        _title = title;
        _address = address;
    }
    return self;
}

@end
