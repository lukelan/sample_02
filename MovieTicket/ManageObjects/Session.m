//
//  Session.m
//  MovieTicket
//
//  Created by Le Ngoc Duy on 2/6/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "Session.h"


@implementation Session

-(id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [self init])
    {   
        self.cinema_id = [dict objectForKey:@"cinema_id"];
        self.film_id = [dict objectForKey:@"film_id"];
        self.room_id = [dict objectForKey:@"room_id"];
        self.session_id = [dict objectForKey:@"session_id"];
        self.session_time = [dict objectForKey:@"session_time"];
        self.status = [dict objectForKey:@"status"];
        self.version_id = [dict objectForKey:@"version_id"];
        self.session_link = [dict objectForKey:@"session_link"];
        self.room_title = [dict objectForKey:@"room_title"];
        self.is_voice = [[dict objectForKey:@"is_voice"] boolValue];
    }
    return self;
}
-(NSDictionary *)toDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:self.cinema_id, @"cinema_id", self.film_id, @"film_id", self.room_id, @"room_id", self.session_id, @"session_id", self.session_time, @"session_time", self.status, @"status", self.version_id, @"version_id", self.session_link, @"session_link", self.room_title, @"room_title", [NSNumber numberWithBool:self.is_voice], @"is_voice", nil];
}

-(NSString *)getForMatStringTimeFromTimeTamp:(NSNumber *)timetamp
{
    NSDate *today = [NSDate dateWithTimeIntervalSinceReferenceDate:[timetamp doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormatter setDateFormat:@"H:mm"];
    return  [dateFormatter stringFromDate:today];
}

-(NSString *)getForMatStringAsDateFromTimeTamp
{
    NSDate *today = [NSDate date];
    NSDate *currentDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[self.session_time doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormatter setDateFormat:@"H:mm "];
    NSMutableString *strResult = [[NSMutableString alloc] initWithString:[dateFormatter stringFromDate:currentDate]];
    
    [dateFormatter setDateFormat:@"d/M/y"];
    NSString *temp = [dateFormatter stringFromDate:today];
    NSDate *date1 = [dateFormatter dateFromString:temp];
    NSString *temp2 = [dateFormatter stringFromDate:currentDate];
    NSDate *date2 = [dateFormatter dateFromString:temp2];
    if ([date1 isEqualToDate:date2]) {
        [strResult appendString:@"Hôm nay"];
    } else {
        [strResult appendString:temp2];
    }
    return strResult;
}

@end
