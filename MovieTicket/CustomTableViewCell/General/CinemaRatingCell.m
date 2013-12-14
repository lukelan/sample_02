//
//  CinemaTitleCell.m
//  123Phim
//
//  Created by Le Ngoc Duy on 3/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#define TAG_BUTTON_FILM_LIKE   99
#define TAG_LABEL_RATING_POINT 100
#define TAG_LABEL_TOTAL_RATING 101

#import "CinemaRatingCell.h"
#import "MainViewController.h"
#import "APIManager.h"
#import "FavoriteButton.h"

@implementation CinemaRatingCell

@synthesize cinemaShareDelegate = _cinemaShareDelegate;
@synthesize commentDelegate = _commentDelegate;
@synthesize myFilm;

-(void)dealloc
{
    if (_cinemaShareDelegate) {
        _cinemaShareDelegate = nil;
    }
    if (_commentDelegate) {
        _commentDelegate = nil;
    }
}

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

- (float)getRatingPointOfFilm:(Film*)film{
    float pointValue = 0;
    if ([film.film_point_rating floatValue] > 0) {
        pointValue = [film.film_point_rating floatValue];
    }
    else
    {
        pointValue = arc4random()%10;
        if (pointValue == 0) {
            pointValue = 1;
        }
    }
    return pointValue;
}

-(void)layoutCellCinemaHeader:(Film *)film isViewShare:(BOOL)isShareScreen;
{
    myFilm = film;
    int distance_margin = MARGIN_EDGE_TABLE_GROUP/2;
    FavoriteButton* btnWatchList = [[FavoriteButton alloc] init];
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"btnadd_to_watch_list" ofType:@"png"];
    UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
    [btnWatchList setFrame:CGRectMake(self.contentView.frame.size.width/2 - 20, distance_margin, 150,prodImg.size.height)];

    btnWatchList.tag = TAG_BUTTON_FILM_LIKE;
    btnWatchList.filmId = [film.film_id integerValue];
    btnWatchList.isLiked = [film.is_like boolValue];
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [btnWatchList addTarget:appDelegate action:@selector(handleFilmLikedTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btnWatchList];
    
    UILabel *lblRatingPoint = [[UILabel alloc] init];
    [lblRatingPoint setFont:[UIFont getFontBoldSize18]];
    [lblRatingPoint setBackgroundColor:[UIColor clearColor]];//////////
    [lblRatingPoint setTextColor:[UIColor orangeColor]];
    lblRatingPoint.tag = TAG_LABEL_RATING_POINT;
    float pointValue = [self getRatingPointOfFilm:film];
    [lblRatingPoint setText:[NSString stringWithFormat:@"%.01f",pointValue]];
    CGSize sizeText = [@"10.0" sizeWithFont:lblRatingPoint.font];
//    int index = roundf(pointValue/2);
    UIButton *btnRating = [[UIButton alloc] initWithFrame:CGRectMake(0, distance_margin, btnWatchList.frame.size.width, btnWatchList.frame.size.height)];
    
    thePath = [[NSBundle mainBundle] pathForResource:@"rate_star_1" ofType:@"pnd"];
    prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
    UIImageView *imgViewStar = [[UIImageView alloc] init];
    [imgViewStar setFrame:CGRectMake(distance_margin, (btnRating.frame.size.height - prodImg.size.height)/2, prodImg.size.width, prodImg.size.height)];
    
    int posY = imgViewStar.frame.origin.y + imgViewStar.frame.size.height/2 - sizeText.height;
    int posX = imgViewStar.frame.origin.x + imgViewStar.frame.size.width + 3;
    
    [lblRatingPoint setFrame:CGRectMake(posX, posY + distance_margin, sizeText.width, sizeText.height)];
   
    UILabel *lblTotalPoint = [[UILabel alloc] init];
    [lblTotalPoint setFont:[UIFont getFontNormalSize10]];
    [lblTotalPoint setBackgroundColor:[UIColor clearColor]];
    [lblTotalPoint setTextColor:[UIColor colorWithWhite:0 alpha:0.4]];
    lblTotalPoint.text = @"/10 ";
    sizeText = [lblTotalPoint.text sizeWithFont:lblTotalPoint.font];
    [lblTotalPoint setFrame:CGRectMake(lblRatingPoint.frame.origin.x + lblRatingPoint.frame.size.width, lblRatingPoint.frame.origin.y + lblRatingPoint.frame.size.height - sizeText.height - 2, sizeText.width, sizeText.height)];
    UILabel *lblTotalRating = [[UILabel alloc] init];
    [lblTotalRating setFont:[UIFont getFontNormalSize10]];
    [lblTotalRating setTextColor:lblTotalPoint.textColor];
    [lblTotalRating setBackgroundColor:[UIColor clearColor]];
    lblTotalRating.tag = TAG_LABEL_TOTAL_RATING;
    lblTotalRating.text = [NSString stringWithFormat:@"%d lượt",[film.film_total_rating intValue]];
    sizeText = [lblTotalRating.text sizeWithFont:lblTotalRating.font];
    posY = lblTotalPoint.frame.origin.y + lblTotalPoint.frame.size.height;
    posX = lblRatingPoint.frame.origin.x;
    [lblTotalRating setFrame:CGRectMake(posX, posY, lblRatingPoint.frame.size.width + lblTotalPoint.frame.size.width, sizeText.height)];
    
    [btnRating addSubview:imgViewStar];
    [btnRating addSubview:lblRatingPoint];
    [btnRating addSubview:lblTotalPoint];
    [btnRating addSubview:lblTotalRating];
    
    UIView *viewLayout =  [[UIView alloc] initWithFrame:self.contentView.frame];
    // click rating button
    [btnRating addTarget:self action:@selector(buttonActionRating) forControlEvents:UIControlEventTouchUpInside];
    [viewLayout addSubview:btnRating];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {      viewLayout.frame = CGRectMake(viewLayout.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, viewLayout.frame.origin.y, viewLayout.frame.size.width, viewLayout.frame.size.height);
     
    }
   [self.contentView addSubview:viewLayout];
}

- (void) setStatusForFavoriteButton
{
    UIView *curView = [self.contentView viewWithTag:TAG_BUTTON_FILM_LIKE];
    if([curView isKindOfClass:[FavoriteButton class]])
    {
        ((FavoriteButton *)curView).filmId = [self.myFilm.film_id integerValue];
        ((FavoriteButton *)curView).isLiked = [self.myFilm.is_like boolValue];
        
    }
}

-(void)refreshData
{
    [self setStatusForFavoriteButton];
    UIView *curView = [self.contentView viewWithTag:TAG_LABEL_RATING_POINT];
    if ([curView isKindOfClass:[UILabel class]]) {
        float pointValue = [self getRatingPointOfFilm:myFilm];
        [(UILabel *)curView setText:[NSString stringWithFormat:@"%.01f",pointValue]];
    }
    
    curView = [self.contentView viewWithTag:TAG_LABEL_TOTAL_RATING];
    if ([curView isKindOfClass:[UILabel class]]) {
        [(UILabel *)curView setText:[NSString stringWithFormat:@"%d lượt",[myFilm.film_total_rating intValue]]];
    }
}

-(void)setContentForCell:(Film *)film
{
    if ([self.myFilm isEqual:film]) {
        [self setStatusForFavoriteButton];
        return;
    }
    self.myFilm = film;
    [self refreshData];
}

-(void)buttonActionShare
{
    if (self.cinemaShareDelegate != nil && [self.cinemaShareDelegate respondsToSelector:@selector(didSelectShareAction)])
    {
        [self.cinemaShareDelegate didSelectShareAction];
    }
}

-(void)buttonActionRating
{
    if (_commentDelegate != nil && [_commentDelegate respondsToSelector:@selector(pushVCFilmCommentWithFilm:)]) {
        [_commentDelegate pushVCFilmCommentWithFilm:self.myFilm];
    }
}
@end
