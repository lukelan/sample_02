//
//  CellFilm.m
//  MovieTicket
//
//  Created by Nhan Ho Thien on 1/25/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#define MAX_LENGTH 100
#define BUTTON_SESSION_TAG_ADDED 101
#import "CellFilm.h"
#import "Film.h"
#import "MainViewController.h"
#import "Session.h"
#import "DefineConstant.h"
@implementation CellFilm

@synthesize filmImg,tvDesc,scrollView,autoLable;
@synthesize sessionDelegate = _sessionDelegate;
@synthesize indicatorLoading = _indicatorLoading;
- (void)setDataFilmCell:(FilmSession *)filmsesion withHeight:(CGFloat)heighCell currentRow:(int)curSelect
{
   
    curIndexSelect = curSelect;
    Film *film=filmsesion.film;
    [filmImg setImageWithURL:[NSURL URLWithString:film.poster_url]];

    autoLable.backgroundColor=[UIColor clearColor];
    autoLable.font=[UIFont getFontBoldSize12];
    autoLable.textColor = [UIColor blackColor];
    autoLable.text = film.film_name;
    Session *sessionCur  = nil;
    if ([filmsesion.sessionArrays count] > 0) {
        sessionCur = [filmsesion.sessionArrays objectAtIndex:0];
        self.autoLable.text = [[NSString alloc] initWithFormat:@"%@ - %dD",film.film_name,[sessionCur.version_id intValue]];
        if ([sessionCur.version_id intValue] != 3) {
            self.autoLable.text = [[NSString alloc] initWithFormat:@"%@ - 2D",film.film_name];
        }
    }  
    
    NSString *desc1=film.film_description_short;
    if (!desc1 || desc1.length == 0)
    {
        desc1 = STR_LOADING;
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didLoadFilmDetail:) name:[NSString stringWithFormat:NOTIFICATION_NAME_FILM_DETAIL_DID_LOAD_WITH_FILM_ID, film.film_id.integerValue] object:nil];
        [film loadDetailOfFilm];
    }
    NSString * desc = desc1;
    if (desc.length > MAX_LENGTH)
    {
        desc=[desc1 stringByPaddingToLength:MAX_LENGTH withString:desc1 startingAtIndex:0];
    }
    tvDesc.text=[desc stringByAppendingString:@"..."];
    CGRect frame = scrollView.frame;
    frame.size.height = heighCell - frame.origin.y - (frame.origin.y - (filmImg.frame.origin.y + filmImg.frame.size.height));
    [scrollView setFrame:frame];
    CGRect frameLoading = self.indicatorLoading.frame;
    frameLoading.origin.y = self.scrollView.frame.origin.y + (frame.size.height - frameLoading.size.height)/2;
    [self.indicatorLoading setFrame:frameLoading];
//    _uiViewDiscount.hidden = true;
}

-(void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    [_indicatorLoading stopAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)didLoadFilmDetail: (NSNotification *) notification
{
    self.tvDesc.text = ((Film *)notification.object).film_description_short;
}

//----layout session cell
- (void) layoutCellSession: (NSMutableArray *)arraySessions
{
    if (!_isIOS7)
    {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        scrollView.frame = CGRectMake(scrollView.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height);
        filmImg.frame = CGRectMake(filmImg.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, filmImg.frame.origin.y, filmImg.frame.size.width, filmImg.frame.size.height);
         tvDesc.frame = CGRectMake(tvDesc.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, tvDesc.frame.origin.y, tvDesc.frame.size.width, tvDesc.frame.size.height);
         autoLable.frame = CGRectMake(autoLable.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, autoLable.frame.origin.y, autoLable.frame.size.width, autoLable.frame.size.height);
        _uiViewDiscount.frame = CGRectMake(_uiViewDiscount.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, _uiViewDiscount.frame.origin.y, _uiViewDiscount.frame.size.width, _uiViewDiscount.frame.size.height);
        _isIOS7=YES;
    }
    }
    for(int i=0;i< [arraySessions count];i++)
    {
        Session *sessionCur=[arraySessions objectAtIndex:i];
        UIButton *btnSelectSession = (UIButton *)[scrollView viewWithTag:BUTTON_SESSION_TAG_ADDED + i];
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
            [scrollView addSubview:btnSelectSession];
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
    [scrollView.layer setCornerRadius:MARGIN_EDGE_TABLE_GROUP/2];
    [self.indicatorLoading setHidden:YES];
}

- (void) buttonActionPressed:(id)sender
{
    if (self.sessionDelegate && [self.sessionDelegate respondsToSelector:@selector(didSelectCinemaSession:curFilmInCinema:)]) {
        [_sessionDelegate didSelectCinemaSession:([(UIButton *)sender tag] - BUTTON_SESSION_TAG_ADDED) curFilmInCinema:curIndexSelect];
    }
}

-(void)hideAllSubViewFromView:(UIView *)contentView
{
    for (UIView *view in contentView.subviews) {
        [view setHidden:YES];
    }
}
- (void) configLayout
{
   // _lbDiscount.transform= CGAffineTransformMakeRotation(-DEGREES_TO_RADIANS(45));
}
- (void)prepareForReuse
{
    [self hideAllSubViewFromView:self.scrollView];
    [self.indicatorLoading setHidden:NO];
    [scrollView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
}
@end
