//
//  BuyingInfo.h
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/7/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"
#import "Film.h"
#import "CinemaWithDistance.h"

@interface BuyingInfo : NSObject

@property (nonatomic, strong) NSArray *chosenSeatInfoList;
@property (nonatomic, strong) Session *chosenSession;
@property (nonatomic, strong) Film *chosenFilm;
@property (nonatomic, strong) Cinema *chosenCinema;
@property (nonatomic, strong) NSString *room_name;
@property int totalMoney;
-(id)initWithDictionary:(NSDictionary *)dict;
-(NSDictionary *)toDictionary;
@property (nonatomic, strong) NSString *orderNo;
@end
