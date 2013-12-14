//
//  CinemaNoteCell.m
//  MovieTicket
//
//  Created by Le Ngoc Duy on 2/20/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CinemaNoteCell.h"
#import "MainViewController.h"
#import "AutoScrollLabel.h"


@implementation CinemaNoteCell
@synthesize myFilm;
@synthesize imgPoster = _imgPoster;
@synthesize lblFilmName = _lblFilmName;
@synthesize lblVersion = _lblVersion;
@synthesize lblDuration = _lblDuration;
@synthesize lblPublishDate = _lblPublishDate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) layoutNoticeView:(Film *)film
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d/M"];
    NSString* dateString = [dateFormat stringFromDate:film.publish_date];
        
    [self layoutNoticeView:film.film_name filmVersion:film.film_version filmDuration:[film.film_duration intValue] publishDate:dateString imagePoster:nil posterURL:film.poster_url];
 
}
-(void) layoutNoticeView:(NSString *)film_name filmVersion:(NSString *)film_version filmDuration:(int)film_duration publishDate:(NSString *)publish_date imagePoster:(UIImage *)imgBG posterURL:(NSString *)url
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        _viewLayout.frame = CGRectMake(_viewLayout.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, _viewLayout.frame.origin.y, _viewLayout.frame.size.width, _viewLayout.frame.size.height);
    }
    if (imgBG)
    {
        [self.imgPoster setImage:imgBG];
    }
    else
    {
        [self.imgPoster setImageWithURL:[NSURL URLWithString:url]];
    }
    self.imgPoster.tag = TAG_CUSTOM_IMAGE_POSTER;
    
    self.lblFilmName.backgroundColor=[UIColor clearColor];
    ((AutoScrollLabel*)self.lblFilmName).font=[UIFont getFontBoldSize12];

    ((AutoScrollLabel*)self.lblFilmName).textColor = [UIColor blackColor];
    ((AutoScrollLabel*)self.lblFilmName).text = film_name;
    self.lblFilmName.tag = TAG_AUTO_SCROLL_LABEL;

    [self.lblVersion setFont:[UIFont getFontNormalSize10]];
    [self.lblVersion setBackgroundColor:[UIColor orangeColor]];
    self.lblVersion.layer.cornerRadius = 5;
    [self.lblVersion setTextColor:[UIColor whiteColor]];
    [self.lblVersion setTextAlignment:UITextAlignmentCenter];
    self.lblVersion.text = film_version;
    self.lblVersion.tag = TAG_LABEL_FILM_VERSION;

    [self.lblDuration setFont:[UIFont getFontNormalSize10]];
    [self.lblDuration setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    self.lblDuration.layer.cornerRadius = 5;
    [self.lblDuration setTextColor:[UIColor whiteColor]];
    [self.lblDuration setTextAlignment:UITextAlignmentCenter];
    self.lblDuration.text = [NSString stringWithFormat:@"%d phút",film_duration];
    self.lblDuration.tag = TAG_LABEL_FILM_DURATION;
    
    [self.lblPublishDate setFont:[UIFont getFontNormalSize10]];
    self.lblPublishDate.layer.cornerRadius = 5;
    [self.lblPublishDate setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    self.lblPublishDate.text = [NSString stringWithFormat:@"Khởi chiếu: %@", publish_date];
    [self.lblPublishDate setTextAlignment:UITextAlignmentCenter];
    [self.lblPublishDate setTextColor:[UIColor whiteColor]];
    self.lblPublishDate.tag = TAG_LABEL_FILM_PUBLISH_DATE;
 
}

-(void)refreshData
{
    if (!myFilm) {
        return;
    }
    UIView *curView = [self.contentView viewWithTag:TAG_CUSTOM_IMAGE_POSTER];
    if([curView isKindOfClass:[SDImageView class]])
    {
        [(SDImageView *)curView setImageWithURL:[NSURL URLWithString:myFilm.poster_url]];
    }
    curView = [self.contentView viewWithTag:TAG_LABEL_FILM_VERSION];
    if ([curView isKindOfClass:[UILabel class]])
    {
        [(UILabel *)curView setText:myFilm.film_version];
    }
    curView = [self.contentView viewWithTag:TAG_AUTO_SCROLL_LABEL];
    if ([curView isKindOfClass:[AutoScrollLabel class]])
    {
        [(UILabel *)curView setText:myFilm.film_name];
    }
    
    curView = [self.contentView viewWithTag:TAG_LABEL_FILM_DURATION];
    if ([curView isKindOfClass:[UILabel class]])
    {
        [(UILabel *)curView setText:[NSString stringWithFormat:@"%d phút",[myFilm.film_duration intValue]]];
    }
    curView = [self.contentView viewWithTag:TAG_LABEL_FILM_PUBLISH_DATE];
    if ([curView isKindOfClass:[UILabel class]])
    {
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"d/M"];
        NSString* dateString = [dateFormat stringFromDate:myFilm.publish_date];
        [(UILabel *)curView setText:[NSString stringWithFormat:@"Khởi chiếu: %@", dateString]];
    }
}

@end
