//
//  FilmCinemaCell.m
//  123Phim
//
//  Created by Le Ngoc Duy on 8/20/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "FilmCinemaCell.h"
#import "Session.h"

#define BUTTON_SESSION_TAG_ADDED 101

@implementation FilmCinemaCell

@synthesize sessionDelegate = _sessionDelegate;

@synthesize cinemaName = _cinemaName;
@synthesize cinemaAddress = _cinemaAddress;
@synthesize distanceTo = _distanceTo;
@synthesize scrollView = _scrollView;
@synthesize indicatorLoading = _indicatorLoading;
@synthesize lblType = _lblType;

- (void)dealloc
{
    _sessionDelegate = nil;
    [_indicatorLoading stopAnimating];
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

//load cell for FilmCinemaViewController
-(void)loadDataWithOnline: (CinemaWithDistance *)cinema_distance curFilm:(Film *)film withMargin:(int)margin_film_left withHeight:(CGFloat)heighCell
{
    NSString* cinemaName = cinema_distance.cinema.cinema_name;
    NSString* cinemaAddress = cinema_distance.cinema.cinema_address;
    BOOL isOnline = [cinema_distance.cinema.is_booking integerValue] == 1;
    int film2D3D = [((Session*)[cinema_distance.arraySessions objectAtIndex:0]).version_id intValue];
    BOOL is_VNese_voice = NO;
    if ([cinema_distance.arraySessions count] > 0) {
        is_VNese_voice = ((Session*)[cinema_distance.arraySessions objectAtIndex:0]).is_voice;
    }
    
    self.distanceTo.layer.cornerRadius = 5;
    [self.lblType.layer setCornerRadius:5];
    if (isOnline)
    {
        [self.ivOnline setHidden:NO];
        [self.ivOffline setHidden:YES];
    }
    else
    {
        [self.ivOnline setHidden:YES];
        [self.ivOffline setHidden:NO];
    }
    NSString* version = nil;
    if (film2D3D != -1)
    {
        if (film2D3D != 3) {
            if (is_VNese_voice == YES) {
                version = @"2D-Lồng tiếng";
            }else{
                version = @"2D";
            }
        }else{
            if (is_VNese_voice == YES) {
                version = [NSString stringWithFormat:@"3D-Lồng tiếng"];
            }else{
                version = [NSString stringWithFormat:@"3D"];
            }
        }
        CGRect frame = self.cinemaName.frame;
        frame.size.width = 165;
        [self.cinemaName setFrame:frame];
        [self.lblType setHidden:NO];
        [self.lblType setText:version];
    }
    else
    {
        CGRect frame = self.cinemaName.frame;
        frame.size.width = 225;
        [self.cinemaName setFrame:frame];
        [self.lblType setHidden:YES];
    }
    
    self.cinemaName.text = cinemaName;
    self.cinemaAddress.text = cinemaAddress;
    if (cinema_distance.distance >= 0) {
        self.distanceTo.hidden = NO;
        self.distanceTo.text = [NSString stringWithFormat:@"%.01fkm",cinema_distance.distance/1000];
    }
    else
    {
        self.distanceTo.hidden = YES;
    }
    CGRect frame = _scrollView.frame;
    frame.size.height = heighCell - frame.origin.y - (frame.origin.y - (self.ivOnline.frame.origin.y + self.ivOnline.frame.size.height));
    [_scrollView setFrame:frame];
    CGRect frameLoading = self.indicatorLoading.frame;
    frameLoading.origin.y = self.scrollView.frame.origin.y + (frame.size.height - frameLoading.size.height)/2;
    [self.indicatorLoading setFrame:frameLoading];
    [self.viewDiscount setHidden:YES];
    if ((film.discount_type.intValue == ENUM_DISCOUNT_NONE && cinema_distance.cinema.discount_type.intValue == ENUM_DISCOUNT_NONE) || !isOnline)
    {
        return;
    }
    else
    {
        if ([[self getTextDisplayDiscount:film atCinema:cinema_distance] isKindOfClass:[NSString class]])
        {
            [self.lbDiscount setText:[self getTextDisplayDiscount:film atCinema:cinema_distance]];
            [self.viewDiscount setHidden:NO];
        }
    }
}

- (NSString *)getTextDisplayDiscount:(Film *)curFilm atCinema:(CinemaWithDistance *)cinemaDistance
{
    [(AppDelegate *)[UIApplication sharedApplication].delegate setDiscountTypeEffect:DISCOUNT_TYPE_FILM];
    if (curFilm.discount_type.intValue == ENUM_DISCOUNT_PERCENT)
    {
        return [NSString stringWithFormat:@"-%d%@", curFilm.discount_value.intValue,@"%"];
    }
    else if (curFilm.discount_type.intValue == ENUM_DISCOUNT_MONEY)
    {
        return [NSString stringWithFormat:@"-%dK", curFilm.discount_value.intValue/1000];
    }
    else
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate setDiscountTypeEffect:DISCOUNT_TYPE_CINEMA];
        if (cinemaDistance.cinema.discount_type.intValue == ENUM_DISCOUNT_PERCENT)
        {
            return [NSString stringWithFormat:@"-%d%@", cinemaDistance.cinema.discount_value.intValue,@"%"];
        }
        else if (cinemaDistance.cinema.discount_type.intValue == ENUM_DISCOUNT_MONEY)
        {
            return [NSString stringWithFormat:@"-%dK", cinemaDistance.cinema.discount_value.intValue/1000];
        }
    }
    [(AppDelegate *)[UIApplication sharedApplication].delegate setDiscountTypeEffect:DISCOUNT_TYPE_NONE];
    return nil;
}

//----layout session cell
- (void) layoutCellSession: (NSMutableArray *)arraySessions currentRow:(int)curSelect
{
    curIndexSelect = curSelect;
    for(int i=0;i< [arraySessions count];i++)
    {
        Session *sessionCur=[arraySessions objectAtIndex:i];
        UIButton *btnSelectSession = (UIButton *)[_scrollView viewWithTag:BUTTON_SESSION_TAG_ADDED + i];
        if (!btnSelectSession)
        {
            NSString *thePath = [[NSBundle mainBundle] pathForResource:@"button_session" ofType:@"png"];
            UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
            int buttonWidth = prodImg.size.width;
            int buttonHeight = prodImg.size.height;
            int distance_Button = (300 - MAX_ITEM_CELL_SESSION_LAYOUT*buttonWidth)/ (MAX_ITEM_CELL_SESSION_LAYOUT + 1);
            int xAdjust = distance_Button;
            int yAdjust = distance_Button;
            
            if (i < MAX_ITEM_CELL_SESSION_LAYOUT)
            {
                xAdjust = distance_Button + i*(buttonWidth + distance_Button);
            }
            else
            {
                if(i%MAX_ITEM_CELL_SESSION_LAYOUT != 0)
                {
                    xAdjust = distance_Button + (i%MAX_ITEM_CELL_SESSION_LAYOUT)*(buttonWidth + distance_Button);
                }
                yAdjust = distance_Button + (i/MAX_ITEM_CELL_SESSION_LAYOUT)*(buttonHeight + distance_Button);
            }
            btnSelectSession = [[UIButton alloc] init];
            [btnSelectSession setBackgroundImage:prodImg forState:UIControlStateNormal];
            [btnSelectSession setFrame:CGRectMake(xAdjust, yAdjust, buttonWidth, buttonHeight)];
            btnSelectSession.tag = BUTTON_SESSION_TAG_ADDED + i;
            [_scrollView addSubview:btnSelectSession];
        }
        btnSelectSession.titleLabel.font = [UIFont getFontCustomSize:19];
        [btnSelectSession setHidden:NO];
        [btnSelectSession setTitle:[sessionCur getForMatStringTimeFromTimeTamp:sessionCur.session_time] forState:UIControlStateNormal];
        if([sessionCur.status isEqualToNumber:[NSNumber numberWithInt:STATUS_SESSION_DISABLE]])
        {
            [btnSelectSession setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            btnSelectSession.enabled = NO;
        }
        else if([sessionCur.status isEqualToNumber:[NSNumber numberWithInt:STATUS_SESSION_ACTIVE]])
        {
            btnSelectSession.enabled = YES;
            [btnSelectSession addTarget:self action:@selector(buttonActionPressed:) forControlEvents:UIControlEventTouchUpInside];
            [btnSelectSession setTitleColor:[UIColor colorWithRed:10.0 / 255 green:150.0 / 255 blue:60.0 / 255 alpha:1.0] forState:UIControlStateNormal];
        }
    }
    [_scrollView.layer setCornerRadius:MARGIN_EDGE_TABLE_GROUP/2];
    [self.indicatorLoading setHidden:YES];
}

- (void) buttonActionPressed:(id)sender
{
    if (self.sessionDelegate && [self.sessionDelegate respondsToSelector:@selector(didSelectCinemaSession:curIndexCinema:)]) {
        [_sessionDelegate didSelectCinemaSession:([(UIButton *)sender tag] - BUTTON_SESSION_TAG_ADDED) curIndexCinema:curIndexSelect];
    }
}
- (void) configLayout
{
    //_lbDiscount.transform= CGAffineTransformMakeRotation(-DEGREES_TO_RADIANS(45));
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
      _viewLayout.frame = CGRectMake(_viewLayout.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, _viewLayout.frame.origin.y, _viewLayout.frame.size.width, _viewLayout.frame.size.height);
        [self.ivOffline setImage:[UIImage imageNamed:@"online_disable7.png"]];
        [self.ivOnline setImage:[UIImage imageNamed:@"online7.png"]];
    }
   
}
-(void)hideAllSubViewFromView:(UIView *)contentView
{
    for (UIView *view in contentView.subviews) {
        [view setHidden:YES];
    }
}

- (void)prepareForReuse
{
    [self hideAllSubViewFromView:self.scrollView];
    [self.indicatorLoading setHidden:NO];
}
@end
