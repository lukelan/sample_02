//
//  CinemaTableViewItem.h
//  123Phim
//
//  Created by Tai Truong on 12/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CinemaTableViewItem : NSObject
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *address;

-(id)initWithTitle:(NSString*)title andAddress:(NSString*)address;

@end
