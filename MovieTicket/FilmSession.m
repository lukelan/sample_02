//
//  FilmSession.m
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/6/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#import "FilmSession.h"

@implementation FilmSession
@synthesize film;
@synthesize sessionArrays;

- (void)dealloc
{
    [sessionArrays removeAllObjects];
}
@end
