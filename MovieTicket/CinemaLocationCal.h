//
//  CinemaLocationCal.h
//  123Phim
//
//  Created by Phuc Phan on 4/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CinemaWithDistance.h"
#import "Location.h"

@interface CinemaLocationCal : NSObject

- (void)getDistance:(NSArray *)cinemas withLocation:(Location *)location context:(id)context selector:(SEL)selector;

@end
