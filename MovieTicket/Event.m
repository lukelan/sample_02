//
//  Event.m
//  123Phim
//
//  Created by Nhan Mai on 6/21/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "Event.h"

@implementation Event

@synthesize title, link, webLink;
- (id)init
{
    self = [super init];
    if (self) {
        title = @"defaul tittle";
        link = @"123phim.vn/event";
        webLink = @"";
    }
    return self;
}


@end
