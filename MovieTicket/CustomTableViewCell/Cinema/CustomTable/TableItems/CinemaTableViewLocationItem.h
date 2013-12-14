//
//  CinemaTableViewLocationItem.h
//  123Phim
//
//  Created by Tai Truong on 12/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CinemaTableViewItem.h"

@interface CinemaTableViewLocationItem : CinemaTableViewItem
@property (nonatomic, assign) BOOL isActive;

-(id)initWithTitle:(NSString *)title andAddress:(NSString *)address isActive:(BOOL)isLocationActive;
@end
