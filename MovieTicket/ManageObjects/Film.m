//
//  Film.m
//  MovieTicket
//
//  Created by Le Ngoc Duy on 1/17/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "Film.h"
#import "AppDelegate.h"
#import "UIImageView+Action.h"
#import "ASIHTTPRequest.h"
#import "NSData+FileHandler.h"
#import "UIImage+Ultility.h"
#import "APIManager.h"

@implementation Film

@dynamic film_actors;
@dynamic film_description;
@dynamic film_version;
@dynamic film_duration;
@dynamic film_id;
@dynamic film_name;
@dynamic film_publisher;
@dynamic is_like;
@dynamic poster_url;
@dynamic film_url;
@dynamic publish_date;
@dynamic status_id;
@dynamic list_image_review;
@dynamic list_image_thumbnail_review;
@dynamic film_total_rating;
@dynamic film_point_rating;
@dynamic film_description_short;
@dynamic is_new, type_id, order_id;
@dynamic discount_type, discount_value, buy, date_end, date_start,total,image;
@dynamic comment;

@synthesize filmIconName, filmIconImage,arrayImageReviews, arrayImageThumbnailReviews;

-(void)addUIImageViewNeedUpdatePosterImage:(UIImageView *)imageView
{
    if (!imageViewList)
    {
        imageViewList = [[NSMutableArray alloc] init];
    }
    [imageViewList addObject:imageView];
}

-(void)dealloc
{
    if (queue)
    {
        for (ASIHTTPRequest *rq in queue.operations)
        {
            [rq setDelegate: nil];
            [rq setDidFinishSelector: nil];
        }
        [queue cancelAllOperations];
    }
//    [filmPosterImage release];
}

-(void)loadDetailOfFilm
{
    if (_loadingDetail == 0)
    {
        _loadingDetail ++;
        [[APIManager sharedAPIManager] getDetailForFilm:[self.film_id integerValue] responseID:self];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [self requestFinished:request];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *response = request.responseString;   
    if (request.tag == ID_REQUEST_GET_FILM_DETAIL)
    {
        [[APIManager sharedAPIManager] parseToUpdateFilm:self withResponse:response];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:[NSString stringWithFormat:NOTIFICATION_NAME_FILM_DETAIL_DID_LOAD_WITH_FILM_ID, self.film_id.integerValue] object:self];
    }
}

@end
