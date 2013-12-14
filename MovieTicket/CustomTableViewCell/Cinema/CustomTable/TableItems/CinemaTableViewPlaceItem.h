//
//  CinemaTableViewPlaceItem.h
//  123Phim
//
//  Created by Tai Truong on 12/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CinemaTableViewItem.h"

@interface CinemaTableViewPlaceItem : CinemaTableViewItem
@property (nonatomic, retain) NSNumber *cinema_id;
@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, assign) BOOL isLike;
@property (nonatomic, assign) BOOL youAreHere;
@property (nonatomic, retain) NSString *discount;
@property (nonatomic, retain) NSString *distance;
@property (nonatomic, retain) NSString *estimateTimeBike;
@property (nonatomic, retain) NSString *estimateTimeCar;

@end
