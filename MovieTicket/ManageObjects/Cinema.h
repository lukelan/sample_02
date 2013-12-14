//
//  Cinema.h
//  MovieTicket
//
//  Created by Le Ngoc Duy on 1/17/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Cinema : NSManagedObject
@property (nonatomic, strong) NSString * cinema_url;
@property (nonatomic, strong) NSString * cinema_phone;
@property (nonatomic, strong) NSString * cinema_address;
@property (nonatomic, strong) NSString * cinema_wifi_pwd;
@property (nonatomic, strong) NSNumber * is_cinema_favourite;
@property (nonatomic, strong) NSNumber * cinema_id;
@property (nonatomic, strong) NSNumber * cinema_latitude;
@property (nonatomic, strong) NSNumber * cinema_longtitude;
@property (nonatomic, strong) NSString * cinema_name;
@property (nonatomic, strong) NSNumber * is_booking;
@property (nonatomic, strong) NSNumber * time_car;
@property (nonatomic, strong) NSNumber * time_moto;
@property (nonatomic, strong) NSNumber * distance;
@property (nonatomic, strong) NSNumber * p_cinema_id;
@property (nonatomic, strong) NSNumber * location_id;
@property (nonatomic, strong) NSNumber * maxSeatToBook;
@property (nonatomic, strong) NSNumber * news_id;
@property (nonatomic, strong) NSNumber * order_id;
//using propety for discount Cinema
@property (nonatomic, strong) NSNumber * discount_value;
@property (nonatomic, strong) NSNumber * discount_type;
@property (nonatomic, strong) NSDate * date_start;
@property (nonatomic, strong) NSDate * date_end;
@property (nonatomic, strong) NSNumber * total;
@property (nonatomic, strong) NSNumber * buy;
@end
