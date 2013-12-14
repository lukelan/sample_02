//
//  Session.h
//  MovieTicket
//
//  Created by Le Ngoc Duy on 2/6/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Session : NSObject

@property (nonatomic, strong) NSNumber * cinema_id;
@property (nonatomic, strong) NSNumber * film_id;
@property (nonatomic, strong) NSNumber * room_id;
@property (nonatomic, strong) NSNumber * session_id;
@property (nonatomic, strong) NSNumber * session_time;
@property (nonatomic, strong) NSNumber * status;
@property (nonatomic, strong) NSNumber * version_id;
@property (nonatomic, strong) NSString * session_link;
@property (nonatomic, strong) NSString * room_title;
@property (nonatomic, assign) BOOL is_voice;

-(NSString *)getForMatStringTimeFromTimeTamp:(NSNumber *)timetamp;
-(NSString *)getForMatStringAsDateFromTimeTamp;
-(id)initWithDictionary:(NSDictionary *)dict;
-(NSDictionary *)toDictionary;
@end
