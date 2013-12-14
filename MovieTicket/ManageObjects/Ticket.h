//
//  Ticket.h
//  123Phim
//
//  Created by Le Ngoc Duy on 5/16/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Ticket : NSManagedObject

@property (nonatomic, strong) NSString * date_buy;
@property (nonatomic, strong) NSString * ticket_url;
@property (nonatomic, strong) NSString * film_publish_date;
@property (nonatomic, strong) NSString * date_show;
@property (nonatomic, strong) NSString * film_name;
@property (nonatomic, strong) NSString * film_poster_url;
@property (nonatomic, strong) NSString * film_version;
@property (nonatomic, strong) NSData * ticket_data;
@property (nonatomic, strong) NSString * listSeat;
@property (nonatomic, strong) NSString * room_name;
@property (nonatomic, strong) NSString * invoice_no;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * ticket_code;
@property (nonatomic, strong) NSNumber * ticket_total_price;
@property (nonatomic, strong) NSNumber * film_duration;
@property (nonatomic, strong) NSString * cinema_name;
@property (nonatomic, strong) NSString * film_url;
@property (nonatomic, strong) NSNumber * film_id;
@property (nonatomic, strong) NSNumber * cinema_id;
@property (nonatomic, strong) NSNumber * session_id;
@property (nonatomic, strong) NSNumber * order_id;
@end
