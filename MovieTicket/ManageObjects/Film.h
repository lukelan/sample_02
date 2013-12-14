//
//  Film.h
//  MovieTicket
//
//  Created by Le Ngoc Duy on 1/17/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#define NOTIFICATION_NAME_FILM_DETAIL_DID_LOAD_WITH_FILM_ID @"NOTIFICATION_NAME_FILM_DETAIL_DID_LOAD_WITH_FILM_ID_%d"

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ASIHTTPRequestDelegate.h"


@interface Film : NSManagedObject <ASIHTTPRequestDelegate>
{
    NSMutableArray *imageViewList;
    BOOL isDownloadingPoster;
    NSOperationQueue *queue;
    NSInteger _loadingDetail;
}

@property (nonatomic, strong) NSString * film_actors;
@property (nonatomic, strong) NSString * film_description;
@property (nonatomic, strong) NSString * film_description_short;
@property (nonatomic, strong) NSString * film_version;
@property (nonatomic, strong) NSNumber * film_duration;
@property (nonatomic, strong) NSNumber * film_id;
@property (nonatomic, strong) NSString * film_name;
@property (nonatomic, strong) NSString * film_publisher;
@property (nonatomic, strong) NSNumber * is_like;
@property (nonatomic, strong) NSString * list_image_review;
@property (nonatomic, strong) NSString * list_image_thumbnail_review;
@property (nonatomic, strong) NSString * poster_url;
@property (nonatomic, strong) NSString * film_url;
@property (nonatomic, strong) NSDate * publish_date;
@property (nonatomic, strong) NSNumber * status_id;
@property (nonatomic, strong) NSNumber * film_total_rating;
@property (nonatomic, strong) NSNumber * film_point_rating;
@property (nonatomic, strong) NSNumber * is_new;
@property (nonatomic, strong) NSNumber * type_id;
@property (nonatomic, strong) NSNumber * order_id;
//using propety for discount film
@property (nonatomic, strong) NSNumber * discount_value;
@property (nonatomic, strong) NSNumber * discount_type;
@property (nonatomic, strong) NSDate * date_start;
@property (nonatomic, strong) NSDate * date_end;
@property (nonatomic, strong) NSNumber * total;
@property (nonatomic, strong) NSNumber * buy;
@property (nonatomic, strong) NSString *image;

@property (nonatomic, strong) NSString * filmIconName;
@property (nonatomic, strong) UIImage * filmIconImage;
@property (nonatomic, strong) NSArray * arrayImageReviews;
@property (nonatomic, strong) NSArray * arrayImageThumbnailReviews;
@property (nonatomic, strong) NSSet *comment;

-(void)loadDetailOfFilm;

@end
