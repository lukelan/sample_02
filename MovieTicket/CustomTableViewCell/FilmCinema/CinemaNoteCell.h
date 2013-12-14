//
//  CinemaNoteCell.h
//  MovieTicket
//
//  Created by Le Ngoc Duy on 2/20/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#define TAG_CUSTOM_IMAGE_POSTER 99
#define TAG_LABEL_FILM_VERSION  100
#define TAG_LABEL_FILM_DURATION 101
#define TAG_LABEL_FILM_PUBLISH_DATE 102

#import <UIKit/UIKit.h>
#import "Film.h"

@interface CinemaNoteCell : UITableViewCell
{
    
}
@property (nonatomic, weak) Film *myFilm;

@property (weak, nonatomic) IBOutlet SDImageView *imgPoster;
@property (weak, nonatomic) IBOutlet UIScrollView *lblFilmName;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UILabel *lblPublishDate;
@property (strong, nonatomic) IBOutlet UIView *viewLayout;

-(void) layoutNoticeView:(Film *)film;
-(void) layoutNoticeView:(NSString *)film_name filmVersion:(NSString *)film_version filmDuration:(int)film_duration publishDate:(NSString *)publish_date imagePoster:(UIImage *)imgBG posterURL:(NSString *)url;
@end
