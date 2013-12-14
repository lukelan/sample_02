//
//  NSDate+NSDate_Operator.m
//  123Phim
//
//  Created by phuonnm on 5/7/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "NSDate+App.h"

@implementation NSDate (App)

+ (NSString *) getStringFormatFromDateByStepDay:(int)step date:(NSDate*)date
{
    if (!date)
    {
        date = [NSDate date];
    }
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDate *today = [NSDate date];
    NSDateComponents *addComp = [[NSDateComponents alloc] init];
    [addComp setDay:step];
    NSDate *currentDate = [calendar dateByAddingComponents:addComp toDate:date options:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = calendar;
    addComp = [calendar components:NSWeekdayCalendarUnit fromDate:currentDate];
    
    int dayInWeek = [addComp weekday];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSString *strFormat = [dateFormatter stringFromDate:currentDate];
    NSString *content = [NSString stringWithFormat:@"Thứ %d,  %@",dayInWeek,strFormat];
    if (dayInWeek == 1) {
        content = [NSString stringWithFormat:@"Chủ Nhật,  %@",strFormat];
    }
    
    NSDateFormatter* monthFormater = [[NSDateFormatter alloc] init];
    [monthFormater setDateFormat:@"M"];
    NSDateFormatter* dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"d"];
    
    return content;
}

#pragma mark get format as (HH:MM or d/m/y or both)
+ (NSString *)getStringFormatFromTimeTamp:(double)timeTamp format:(NSString *)pattern
{
    NSDate *today = [NSDate dateWithTimeIntervalSinceReferenceDate:timeTamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormatter setDateFormat:pattern];
    return  [dateFormatter stringFromDate:today];
}

+ (NSString *)getStringFormatFromNSDate:(NSDate *)date format:(NSString *)pattern
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormatter setDateFormat:pattern];
    return  [dateFormatter stringFromDate:date];
}

#pragma mark format data type (HH:mm hom nay | HH:mm 20/01/1986)

+(NSString *)getForMatStringAsDateFromTimeTamp:(double)timeTamp formatClock:(NSString *)patternClock formatDate:(NSString *)patternDate  desExtend:(NSString *)strExtend
{
        return [self getStringFormatedFromTimeTamp:timeTamp clockPattern:patternClock datePattern:patternDate seperatorString:@" " replaceTodayString:strExtend];
}

+(NSString *)getStringFormatedFromTimeTamp:(double)timeTamp clockPattern:(NSString *)patternClock datePattern:(NSString *)patternDate seperatorString:(NSString *)seperatorSring replaceTodayString: (NSString*) todayString
{
    NSDate *today = [NSDate date];
    NSDate *currentDate = [NSDate dateWithTimeIntervalSinceReferenceDate:timeTamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormatter setDateFormat:patternClock];
    NSMutableString *strResult = [[NSMutableString alloc] initWithString:[dateFormatter stringFromDate:currentDate]];
    [strResult appendString:seperatorSring];
    
    [dateFormatter setDateFormat:patternDate];
    NSString *temp = [dateFormatter stringFromDate:today];
    NSDate *date1 = [dateFormatter dateFromString:temp];
    NSString *temp2 = [dateFormatter stringFromDate:currentDate];
    NSDate *date2 = [dateFormatter dateFromString:temp2];
    if (todayString && todayString.length > 0 && [date1 isEqualToDate:date2]) {
        [strResult appendString:todayString];
    } else {
        [strResult appendString:temp2];
    }
    return strResult;
}

#pragma mark calculate distance between 2 day
+ (int)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2
{
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:dt1];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:dt2];
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    return [difference day];
}
@end
