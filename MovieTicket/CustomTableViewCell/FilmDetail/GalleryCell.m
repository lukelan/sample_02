//
//  GalleryCell.m
//  123Phim
//
//  Created by Le Ngoc Duy on 3/10/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#define TAG_CUSTOMVIEW_START 10

#import "GalleryCell.h"

#import "AppDelegate.h"

@implementation GalleryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        isLoadingGalaryOfFilmID = 0;
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)layoutGallery:(Film *)film
{
    for (int i = 0; i < 4; i++)
    {
        CGRect frameImg = CGRectMake(i*smallPicW +(i*5) + MARGIN_EDGE_TABLE_GROUP, MARGIN_EDGE_TABLE_GROUP,  smallPicW, smallPicH) ;
        SDImageView *customimageView = [[SDImageView alloc] initWithFrame:frameImg];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
         customimageView.frame = CGRectMake(customimageView.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, customimageView.frame.origin.y, customimageView.frame.size.width, customimageView.frame.size.height);
        }
        [customimageView setBackgroundColor:[UIColor clearColor]];
        [customimageView.layer setBorderColor:[[UIColor grayColor] CGColor]];
        customimageView.layer.borderWidth = 0.5;
        [customimageView setUserInteractionEnabled:YES];
        customimageView.tag = TAG_CUSTOMVIEW_START + i;
        [self.contentView addSubview:customimageView];
    }
    
    if ((!film.arrayImageThumbnailReviews || film.arrayImageThumbnailReviews.count == 0))
    {
        film.arrayImageThumbnailReviews = [film.list_image_thumbnail_review componentsSeparatedByString:@"∂"];
    }
    
    if (!film.list_image_thumbnail_review || film.list_image_thumbnail_review.length == 0)
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        [self loadDataForCell];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
}

-(void)setContentForCell:(Film *)film
{
    if ([self.myfilm isEqual:film] && (isLoadingGalaryOfFilmID == film.film_id.integerValue)) {
        return;
    }
    self.myfilm = film;
    if (!film.list_image_thumbnail_review || film.list_image_thumbnail_review.length == 0)
    {
        [film loadDetailOfFilm];
    }
    
    [self reloadContentCell:film];
}

-(void) reloadContentCell:(Film *)film
{
    if ((film.arrayImageThumbnailReviews || film.arrayImageThumbnailReviews.count == 0))
    {
        film.arrayImageThumbnailReviews = [film.list_image_thumbnail_review componentsSeparatedByString:@"∂"];
    }
    
    if (!film.arrayImageThumbnailReviews || film.arrayImageThumbnailReviews .count == 0) {
        return;
    }
   
    [self loadDataForCell];
}

-(void)loadDataForCell
{
    isLoadingGalaryOfFilmID = self.myfilm.film_id.integerValue;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < (4 < self.myfilm.arrayImageThumbnailReviews.count ? 4 : self.myfilm.arrayImageThumbnailReviews.count); i++)
    {
        SDImageView *imgCusView = (SDImageView *)[self.contentView viewWithTag:TAG_CUSTOMVIEW_START + i];
        NSInteger index = i;
        if (self.myfilm.arrayImageThumbnailReviews.count > 4)
        {
            index = rand() % self.myfilm.arrayImageThumbnailReviews.count;
            NSNumber *num = [NSNumber numberWithInt:index];
            while ([array containsObject:num])
            {
                index = rand() % self.myfilm.arrayImageThumbnailReviews.count;
                num = [NSNumber numberWithInt:index];
            }
            [array addObject:num];
        }
        
        id url = [self.myfilm.arrayImageThumbnailReviews objectAtIndex:index];
        if (url != [NSNull null])
        {
            [imgCusView setImageWithURL:[NSURL URLWithString:url]];
        }
    }
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleGray;
}

//-(void)prepareForReuse
//{
//    for (int i = 0; i < 4; i++)
//    {
//        SDImageView *imgCusView = (SDImageView *)[self.contentView viewWithTag:TAG_CUSTOMVIEW_START + i];
//        imgCusView.image = nil;
//    }
//}

#pragma mark release object
-(void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}
@end
