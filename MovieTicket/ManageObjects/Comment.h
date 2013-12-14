//
//  Comment.h
//  MovieTicket
//
//  Created by Le Ngoc Duy on 1/17/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Film;
@interface Comment : NSManagedObject<NSCoding>

@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSString * date_add;
@property (nonatomic, strong) NSString * date_update;
@property (nonatomic, strong) NSString * user_name;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSNumber *ratingFilm;
@property (nonatomic, strong) NSNumber *comment_id;
@property (nonatomic, strong) NSNumber *film_id;
@property (nonatomic, strong) id list_image;
@property (nonatomic, strong) NSNumber *order_id;
@property (nonatomic, strong) Film *film;

@end
