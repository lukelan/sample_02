//
//  FilmInfoCell.m
//  123Phim
//
//  Created by Le Ngoc Duy on 8/1/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "FilmInfoCell.h"
#import "PlayTrailerViewController.h"
#import "GAI.h"
#import "AppDelegate.h"

@interface FilmInfoCell ()
{
    NSString *linkTrailer;
    PlayTrailerViewController* player;
}
@end

@implementation FilmInfoCell
@synthesize myfilm;
@synthesize delegate = _delegate;
@synthesize imgViewPoster = _imgViewPoster;
@synthesize btnPlayTrailer = _btnPlayTrailer;
@synthesize imageStarMask = _imageStarMask;
@synthesize lblCate = _lblCate;
@synthesize lblDura = _lblDura;
@synthesize lblRatingPoint = _lblRatingPoint;
@synthesize lblSrollTitle = _lblSrollTitle;
@synthesize lblVer = _lblVer;
@synthesize webView = _webView;
@synthesize btnLike = _btnLike;
@synthesize imgViewRatingPoint = _imgViewRatingPoint;
@synthesize btnShowFulFilmlDetail = _btnShowFulFilmlDetail;

- (void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
    }
    
    [_webView cleanForDealloc];
    _webView = nil;
    _delegate = nil;
    myfilm = nil;
    self.imgViewPoster = nil;
    self.btnLike = nil;
    self.btnPlayTrailer = nil;
    self.btnShowFulFilmlDetail = nil;
    self.imgViewRatingPoint = nil;
    self.lblCate = nil;
    self.lblDura = nil;
    self.lblRatingPoint = nil;
    self.lblSrollTitle = nil;
    self.lblVer = nil;
    
    if (player) {
        [player.moviePlayer stop];
        player = nil;
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

- (IBAction)btnShowFullDetail_click:(UIButton *)sender
{
    [self showFullOrShortDes];
}

-(IBAction)requestPlayTralerByFilm:(id)sender
{
    if ([AppDelegate isNetWorkValiable]) {
        [[APIManager sharedAPIManager] getTrailerLinkOfFilm:self.myfilm.film_id.intValue context:self];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:@"Để xem trailer của phim bạn phải kết nối Internet. Vui lòng kiểm tra trong mục Cài đặt." delegate:self cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)handleActionLike:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate handleFilmLikedTouched:sender];
}

- (void) setStatusForFavoriteButton
{
    if (!_btnLike.strPathImage || _btnLike.strPathImage.length == 0) {
        [_btnLike setStrPathImage:@"btnFilm_like"];
    }
    _btnLike.filmId = [self.myfilm.film_id integerValue];
    _btnLike.isLiked = [self.myfilm.is_like boolValue];
//    _btnLike.isLiked = [self.myfilm.isLike boolValue];
}

#pragma mark - ASIHttpRequestDelegate
-(void)requestFinished:(ASIHTTPRequest *)request
{
    if(request.tag == ID_REQUEST_GET_TRAILER_URL_OF_FILM)
    {
        [self parseToGetTrailerLinkOfFilm:[request responseString]];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    //    LOG_123PHIM(@"failed: Can't communication with server");
}

-(void)setHTTPRequest: (ASIHTTPRequest *) theRequest
{
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
    }
    httpRequest = theRequest;
}

-(void) parseToGetTrailerLinkOfFilm:(NSString *)response
{
    linkTrailer = @"";
    NSDictionary * dicObject = [[APIManager sharedAPIManager].parser objectWithString:response error:nil];
    NSDictionary *token = [dicObject  objectForKey:@"result"];
    if ([token isKindOfClass:[NSDictionary class]]) {
        id getData = [token objectForKey:@"v480p"];
        if([[APIManager sharedAPIManager] isValidData:getData])
        {
            linkTrailer = getData;
        }
    }
    dicObject = nil;
    [self playTrailer];
}

- (void)playTrailer
{
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Film"
                                                    withAction:@"Play Trailer"
                                                     withLabel:@"ButtonPressed"
                                                     withValue:[NSNumber numberWithInt:101]];
    player  = [[PlayTrailerViewController alloc] initWithContentURL:[NSURL URLWithString:linkTrailer]];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *currentNav = (UINavigationController *)[delegate.tabBarController selectedViewController] ;
    [currentNav presentMoviePlayerViewControllerAnimated:player];
    
    // send log to 123phim server
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL: NSStringFromClass([player class]) comeFrom:delegate.currentView withActionID:ACTION_FILM_PLAY_TRAILER currentFilmID:self.myfilm.film_id currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID] returnCodeValue:0 context:nil];
}

#pragma mark load data for cell
-(void)setContentForCell:(Film *)film
{
    if (![self.myfilm isEqual:film]) {
        self.myfilm = film;
        [self setStatusForFavoriteButton];

        CGFloat ratingPoint = [film.film_point_rating floatValue];
        [_lblRatingPoint setText:[NSString stringWithFormat:@"%0.1f",ratingPoint]];

        //set clip for UIImageView
        CGRect boundStar = _imageStarMask.frame;
        boundStar.size.width = _imageStarMask.frame.size.width * (ratingPoint/10);
        [_imgViewRatingPoint setFrame:boundStar];
        
        if (contentRect.size.width == 0)
        {
            contentRect = _imgViewPoster.frame;
            contentRect.origin.y += self.lblVer.frame.size.height + (MARGIN_EDGE_TABLE_GROUP / 2);
            contentRect.size.width = self.lblVer.frame.origin.x - contentRect.origin.x;
            contentRect.size.height = self.imageStarMask.frame.origin.y + self.imageStarMask.frame.size.height - contentRect.origin.y;
        }
        
        [_lblSrollTitle setText:film.film_name];
        
        [_lblVer setText:self.myfilm.film_version];
        [_lblDura setText:[NSString stringWithFormat:@"%d phút",[self.myfilm.film_duration intValue]]];
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"d/M/y"];
        [_lblCate setText:[dateFormat stringFromDate:self.myfilm.publish_date]];
        if (!film.film_description)
        {
            [film loadDetailOfFilm];
        }
        CGRect frame = self.webView.frame;
        frame.size.height = self.frame.size.height - 1 - self.btnShowFulFilmlDetail.frame.size.height;
        self.webView.frame = frame;
        self.webView.clipsToBounds = YES;
        self.clipsToBounds = YES;
        [_imgViewPoster setImageWithURL:[NSURL URLWithString:film.poster_url]];
    }
    if (_isIOS7==NO)
    {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        _viewLayout.frame = CGRectMake(_viewLayout.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, _viewLayout.frame.origin.y, _viewLayout.frame.size.width, _viewLayout.frame.size.height);
        _isIOS7= YES;
    }
    }
    [self loadContentForWebViewWithDesc: film.film_description];
}

-(void)loadContentForWebViewWithDesc: (NSString *) desc
{
    if (!desc)
    {
        desc = STR_LOADING;
    }
    _webView.delegate = self;
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString *myHTML = [NSString stringWithFormat: @"<html style='padding: 0; margin: 0; border: 0; outline: 0'><header><style>* {font-family: %@ !important; font-weight: normal !important; font-size:13px !important}</style></header><body style='padding: 0px; margin: %fpx;  border: 0; outline: 0;'><div style='margin-top: %fpx; color:#666666; text-align:justify'><div style='float: left; width: %f; height: %f; margin-right: %dpx'></div>%@</div></body></html>",@"Helvetica",contentRect.origin.x, contentRect.origin.y, contentRect.size.width, contentRect.size.height, 0, desc];
    [_webView loadHTMLString:myHTML baseURL:baseURL];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self updateWebViewFrame];
}

-(void)updateWebViewFrame
{
    CGFloat h = _webView.scrollView.contentSize.height;
    if (h + 1 > self.frame.size.height) // webivew heigh = cell height - 1, need show expand button
    {
        self.btnShowFulFilmlDetail.hidden = NO;
        UIImage *image = [UIImage imageNamed:@"expand_icon.png"];
        [self.btnShowFulFilmlDetail setImage:image forState:UIControlStateNormal];
        h = kCell_Film_Info_Height - self.btnShowFulFilmlDetail.frame.size.height - 1;
    }
    else
    {
        if (self.frame.size.height <= kCell_Film_Info_Height + 1)
        {
            self.btnShowFulFilmlDetail.hidden = YES;
            h = kCell_Film_Info_Height - 1;
        }
        else //need show collapse button
        {
            self.btnShowFulFilmlDetail.hidden = NO;
            UIImage *image = [UIImage imageNamed:@"collapse_icon.png"];
            [self.btnShowFulFilmlDetail setImage:image forState:UIControlStateNormal];
            [self.btnShowFulFilmlDetail setImageEdgeInsets:UIEdgeInsetsMake(0, 0,0, 0)];
        }
    }
    CGRect frame = self.webView.frame;
    frame.size.height = h;
    self.webView.frame = frame;
    CGRect frame1 = _viewLayout.frame;
    frame1.size.height = h + _btnShowFulFilmlDetail.frame.size.height;
    _viewLayout.frame = frame1;
}
- (void)showFullOrShortDes
{
    if (_btnShowFulFilmlDetail.hidden)
    {
        return;
    }
    CGFloat h = kCell_Film_Info_Height;
    if (self.webView.frame.size.height <= kCell_Film_Info_Height)
    {
        h = self.webView.scrollView.contentSize.height + self.btnShowFulFilmlDetail.frame.size.height + 1;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(filmInfoCell:didUpdateLayoutWithHeight:)])
    {
        [self.delegate filmInfoCell:self didUpdateLayoutWithHeight:h];
    }
}

- (IBAction)viewLayout:(UIButton *)sender
{
    [self showFullOrShortDes];
}
@end
