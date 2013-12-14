//
//  NSDate+NSDate_Operator.h
//  123Phim
//
//  Created by phuonnm on 5/7/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (App)

+ (NSString *) getStringFormatFromDateByStepDay:(int)step date:(NSDate*)date;

//get format date as patter (H:mm | d/m/y or both)
+ (NSString *)getStringFormatFromTimeTamp:(double)timeTamp format:(NSString *)pattern;
+ (NSString *)getStringFormatFromNSDate:(NSDate *)date format:(NSString *)pattern;

//get format as date (H:mm today | H:mm 20/01/1986)
+(NSString *)getForMatStringAsDateFromTimeTamp:(double)timeTamp formatClock:(NSString *)patternClock formatDate:(NSString *)patternDate desExtend:(NSString *)strExtend;

+(NSString *)getStringFormatedFromTimeTamp:(double)timeTamp clockPattern:(NSString *)patternClock datePattern:(NSString *)patternDate seperatorString:(NSString *)seperatorSring replaceTodayString: (NSString*) todayString;
+(int)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2;
@end
