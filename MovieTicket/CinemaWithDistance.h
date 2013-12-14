//
//  CinemaWithDistance.h
//  MovieTicket
//
//  Created by Nhan Mai on 2/3/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cinema.h"

@interface CinemaWithDistance : NSObject
{
    
}
@property (nonatomic, strong) Cinema* cinema;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) NSInteger driving_time;
@property (nonatomic, assign) NSInteger walking_time;
@property (nonatomic, strong) NSMutableArray * arraySessions;
@end
