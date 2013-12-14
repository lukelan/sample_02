//
//  BuyingInfo.m
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/7/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#import "BuyingInfo.h"
#import "AppDelegate.h"
#import "SeatInfo.h"

@implementation BuyingInfo
@synthesize chosenSession, chosenCinema, chosenFilm, chosenSeatInfoList;
@synthesize room_name, totalMoney;

-(id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [self init])
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *arr = [dict objectForKey:@"chosenSeatInfoList"];
        NSMutableArray *mArr = [[NSMutableArray alloc] init];
        for (NSString *key in arr)
        {
            SeatInfo *seat = [[SeatInfo alloc] init];
            [seat setIdentify:key];
            [mArr addObject:seat];
        }
        self.chosenSeatInfoList = mArr;
        self.chosenSession = [[Session alloc] initWithDictionary:[dict objectForKey:@"chosenSession"]];
        self.chosenFilm = [app getFilmWithID:[dict objectForKey:@"chosenFilm"]];
        self.chosenCinema = [app getCinemaWithID:[dict objectForKey:@"chosenCinema"]];
        self.totalMoney = [[dict objectForKey:@"totalMoney"] intValue];
        self.room_name = [dict objectForKey:@"room_name"];
        self.orderNo = [dict objectForKey:@"orderNo"];
    }
    return self;
}

-(NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.chosenSeatInfoList)
    {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (SeatInfo *seatInfo in self.chosenSeatInfoList)
        {
            NSString *key;
            key = seatInfo.identify;
            [arr addObject:key];
        }
        [dict setObject:arr forKey:@"chosenSeatInfoList"];
    }
    if (self.chosenSession)
    {
        [dict setObject:[self.chosenSession toDictionary] forKey:@"chosenSession"];
    }
    if (self.chosenFilm)
    {
        [dict setObject:self.chosenFilm.film_id forKey:@"chosenFilm"];
    }
    if (self.chosenCinema)
    {
        [dict setObject:self.chosenCinema.cinema_id forKey:@"chosenCinema"];
    }
    [dict setObject:[NSNumber numberWithInt:totalMoney] forKey:@"totalMoney"];
    if (self.room_name) {
        [dict setObject:self.room_name forKey:@"room_name"];
    }    
    if (self.orderNo) {
        [dict setObject:self.orderNo forKey:@"orderNo"];
    }    
    return dict;
}


@end
