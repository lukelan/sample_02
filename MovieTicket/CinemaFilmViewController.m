//
//  CinameFilmView.m
//  MovieTicket
//
//  Created by Nhan Ho Thien on 1/11/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#define kHeightCell 125
#define SECTION_NEWS_BANNER 1
#define SECTION_FILM_BEGIN 2

#import "CinemaFilmViewController.h"
#import "CellFilm.h"
#import "Film.h"
#import "FilmCinemaViewController.h"
#import "APIManager.h"
#import "Session.h"
#import "ShowMapViewController.h"
#import "CinemaViewController.h"
#import "CheckInViewController.h"
#import "SelectSeatViewController.h"
#import "CheckoutWebViewController.h"
#import "PromotionViewController.h"
#import "NewsBannerCell.h"

@interface CinemaFilmViewController ()

@end

@implementation CinemaFilmViewController
@synthesize curCinemaDistance,arrFilmSessionTime,filmTableView = _tableView;//,delegate=_delegate

-(void)dealloc
{
    [arrFilmSessionTime removeAllObjects];
    arrFilmSessionTime = nil;
    curCinemaDistance = nil;
    self.news = nil;
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
        httpRequest = nil;
    }
    wifiOn = nil;
    httpRequest = nil;
    curCinemaDistance = nil;
    _tableView = nil;
    _news = nil;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        arrFilmSessionTime = [[NSMutableArray alloc] init];
        viewName = CINEMA_FILM_VIEW_NAME;
    }
    return  self;
}


#pragma mark table datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *thePath = [[NSBundle mainBundle] pathForResource:@"cinema_info@2x" ofType:@"png"];
        UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
        int height = prodImg.size.height;
        return height;
    }
    if (indexPath.section == SECTION_NEWS_BANNER)
    {
        return NEWS_BANNER_CELL_HEIGHT;
    }
    CGFloat heightCell = kHeightCell;
    if (arrFilmSessionTime && arrFilmSessionTime.count > (indexPath.section - SECTION_FILM_BEGIN))
    {
        FilmSession *curFilSes = [arrFilmSessionTime objectAtIndex:(indexPath.section - SECTION_FILM_BEGIN)];
        if (curFilSes.sessionArrays)
        {
            int iNguyen = (curFilSes.sessionArrays.count + MAX_ITEM_CELL_SESSION_LAYOUT - 1) /MAX_ITEM_CELL_SESSION_LAYOUT - 1; // -1 : added to kHeightCell
            NSString *thePath = [[NSBundle mainBundle] pathForResource:@"button_session" ofType:@"png"];
            UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
            heightCell += iNguyen *(prodImg.size.height + 1) + 1; // +1 for border
        }

    }
    return heightCell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_NEWS_BANNER)
    {
        if (self.news && self.news.bannerURL && self.news.bannerURL.length > 0)
        {
            return 1;
        }
        return 0;
    }
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [arrFilmSessionTime count] + SECTION_FILM_BEGIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return MARGIN_EDGE_TABLE_GROUP/2;
    }
    return MARGIN_EDGE_TABLE_GROUP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
}

#pragma mark Time Compare
- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    //icon cell
    if (indexPath.section == 0)
    {
        NSString* iconCell = [NSString stringWithFormat:@"icon_cell_%d", wifiOn];
        UITableViewCell* cell = [myTableView dequeueReusableCellWithIdentifier:iconCell];
        if (cell == nil)
        {
            cell = (CinemaInfoCell*)[[CinemaInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iconCell];
            myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

            if (!wifiOn) {
                ((CinemaInfoCell*)cell).imageView2.image = [UIImage imageNamed:@"wifi_disable.png"];
                ((CinemaInfoCell*)cell).button2.showsTouchWhenHighlighted = NO;
            }else{
                [((CinemaInfoCell*)cell).button2 addTarget:self action:@selector(handleWifiTouch) forControlEvents:UIControlEventTouchUpInside];
            }
            [((CinemaInfoCell*)cell).button0 addTarget:self action:@selector(handleCallTouch) forControlEvents:UIControlEventTouchUpInside];
            [((CinemaInfoCell*)cell).button1 addTarget:self action:@selector(handleViewMapTouch) forControlEvents:UIControlEventTouchUpInside];
            [((CinemaInfoCell*)cell).button3 addTarget:self action:@selector(handleCheckInTouch) forControlEvents:UIControlEventTouchUpInside];
           
        }
        return cell;
    }
    
    if (indexPath.section == SECTION_NEWS_BANNER)
    {
        NewsBannerCell* cell = [myTableView dequeueReusableCellWithIdentifier:@"news_banner_cell"];
        if (!cell)
        {
            NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"NewsBannerCell" owner:self options:nil];
            cell = (NewsBannerCell*)[arr objectAtIndex:0];
            cell.backgroundView = [[UIView alloc]init];
        }
        [cell.sdImageView setImageWithURL:[NSURL URLWithString:self.news.bannerURL]];
        return cell;
    }
    
    //film cell
    static NSString* filmCell = @"film_session_cell_id";
    FilmSession *filmsession=[arrFilmSessionTime objectAtIndex:(indexPath.section - SECTION_FILM_BEGIN)];
    CellFilm* cell = [myTableView dequeueReusableCellWithIdentifier:filmCell];
    if (cell == nil)
    {
         NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"FilmSessionCell" owner:self options:nil];
        cell = (CellFilm*)[arr objectAtIndex:0];
        //configLayout when cell nil
        [(CellFilm *)cell configLayout];
        [(CellFilm *)cell setSessionDelegate:self];
    }
    [[cell uiViewDiscount] setHidden:YES];
    if (filmsession.film.discount_type.intValue != ENUM_DISCOUNT_NONE || curCinemaDistance.cinema.discount_type.intValue != ENUM_DISCOUNT_NONE)
    {
        if ([[self getTextDisplayDiscount:filmsession.film atCinema:curCinemaDistance] isKindOfClass:[NSString class]])
        {
            [cell.lbDiscount setText:[self getTextDisplayDiscount:filmsession.film atCinema:curCinemaDistance]];
            [[cell uiViewDiscount] setHidden:NO];
        }
    }
    CGFloat heightCell = [self tableView:myTableView heightForRowAtIndexPath:indexPath];
    [cell setDataFilmCell:filmsession withHeight:heightCell currentRow:(indexPath.section - SECTION_FILM_BEGIN)];
    [cell layoutCellSession:filmsession.sessionArrays];
    return cell;
}

- (NSString *)getTextDisplayDiscount:(Film *)curFilm atCinema:(CinemaWithDistance *)cinemaDistance
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
    else
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
    }
    [(AppDelegate *)[UIApplication sharedApplication].delegate setDiscountTypeEffect:DISCOUNT_TYPE_NONE];
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_NEWS_BANNER)
    {
        [[PromotionViewController sharedPromotionViewController] pushPromotionDetailViewFor:self.news];
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showCinemaOnMap
{
    
    ShowMapViewController *showMapViewController = [[ShowMapViewController alloc] init];
    CLLocationCoordinate2D centerOfCinemaGroupMap = CLLocationCoordinate2DMake([self.curCinemaDistance.cinema.cinema_latitude doubleValue], [self.curCinemaDistance.cinema.cinema_longtitude doubleValue]);    
    showMapViewController.currentLocationState = YES;
    showMapViewController.typeOfMap = MapTypeCinemaIndividual;
    showMapViewController.currentCinemaDistance = self.curCinemaDistance;
    showMapViewController.mapCenterUserChoice = centerOfCinemaGroupMap;
    showMapViewController.mapSpanUserChoice = MKCoordinateSpanMake(0.01, 0.01);
    [showMapViewController setTabBarDisplayType:TAB_BAR_DISPLAY_HIDE];
    [self.navigationController pushViewController:showMapViewController animated:YES];
}


#pragma mark Process View delegate appear, disappear
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setTitleLabelForNavigationController:self withTitle:self.curCinemaDistance.cinema.cinema_name];
    [super viewWillAppear:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![AppDelegate isNetWorkValiable])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Để xem lịch chiếu của phim tại rạp bạn phải kết nối Internet. Vui lòng kiểm tra trong mục Cài đặt." delegate:self cancelButtonTitle:@"Tiếp tục" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        if(self.arrFilmSessionTime != nil & [self.arrFilmSessionTime count] > 0)
        {
            [self hideLoadingView];
            return;
        }
        else
        {
            [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR];
        }
        if ([self.arrFilmSessionTime count] > 0) {
            [self reloadData];
            [self hideLoadingView];
        } else {
            [AppDelegate resetStartTime];
            [[APIManager sharedAPIManager] getListFilmSessionByCinema:[self.curCinemaDistance.cinema.cinema_id intValue] context:self];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setDiscountTypeEffect:DISCOUNT_TYPE_NONE];
    self.view.backgroundColor = [UIFont colorBackGroundApp];
//    [self.view addSubview:self.filmTableView];
    self.trackedViewName = viewName;
    [self initHandleSwipeGestureRecognizer];
    wifiOn = self.curCinemaDistance.cinema.cinema_wifi_pwd != NULL && (![self.curCinemaDistance.cinema.cinema_wifi_pwd isEqualToString:@""]);
       
    NSArray *arrNews = [PromotionViewController sharedPromotionViewController].myArrayNews;
    self.news = nil;
    if (arrNews)
    {
        [arrNews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             News *news = (News *)obj;
             if (self.curCinemaDistance.cinema.news_id && self.curCinemaDistance.cinema.news_id.integerValue == news.news_id)
             {
                 self.news = news;
                 *stop = YES;
             }
         }];
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

-(void)initHandleSwipeGestureRecognizer
{
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(handleSwipeFrom:)];
    [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [gesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:gesture];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [delegate popViewController];
    }
}

#pragma mark - ASIHttpRequestDelegate
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    NSString *response = [request responseString];
//    NSUInteger bytes = [response lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//    LOG_123PHIM(@"Load Danh Sach Phim cua Rap = %i bytes", bytes);
    if (self.arrFilmSessionTime != nil) {
        [self.arrFilmSessionTime removeAllObjects];
    }
    [[APIManager sharedAPIManager] parseListFilmSessionByCinema:[curCinemaDistance.cinema.cinema_id intValue] toArray:arrFilmSessionTime with:response];
    NSDate *endDate = [NSDate date];
    NSDate *startDate = [AppDelegate getStartTime];
    NSTimeInterval timeDiff = [endDate timeIntervalSinceDate:startDate];
    [[GAI sharedInstance].defaultTracker sendTimingWithCategory:@"Loading" withValue:timeDiff withName:@"LoadRapFilm" withLabel:nil];
    
    [self reloadData];
    [self hideLoadingView];
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    [super requestFailed:request];
}

-(void) reloadData
{
    [self.filmTableView reloadData];
}

#pragma mark - Button action
- (void)handleCallTouch
{
//    LOG_123PHIM(@"handleCallTouch");
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Cinema" withAction:@"Call" withLabel:@"ButtonPressed" withValue:[NSNumber numberWithInteger:112]];
    
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:@"[Call-program]"
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_CINEMA_CALL
                                                     currentFilmID:[NSNumber numberWithInt:NO_FILM_ID]
                                                   currentCinemaID:curCinemaDistance.cinema.cinema_id
                                                   returnCodeValue:0 context:nil];
    
    [self processActionMakeACall];
    
    
}

- (void)handleViewMapTouch
{
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Cinema" withAction:@"ViewMap" withLabel:@"ButtonPressed" withValue:[NSNumber numberWithInteger:111]];
    
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:NSStringFromClass([ShowMapViewController class])
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_CINEMA_VIEW_MAP
                                                     currentFilmID:[NSNumber numberWithInt:NO_FILM_ID]
                                                   currentCinemaID:curCinemaDistance.cinema.cinema_id
                                                   returnCodeValue:0 context:nil];
    
    [self showCinemaOnMap];

}

- (void)handleWifiTouch
{
//    self.curCienmaDistance.cinema.cinema_wifi_pwd = @"12345";
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Cinema" withAction:@"Wifi" withLabel:@"ButtonPressed" withValue:[NSNumber numberWithInteger:113]];
    
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:delegate.currentView
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_CINEMA_COPY_WIFI_PASS
                                                     currentFilmID:[NSNumber numberWithInt:NO_FILM_ID]
                                                   currentCinemaID:curCinemaDistance.cinema.cinema_id
                                                   returnCodeValue:0 context:nil];
    
    
    if (wifiOn) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Wifi password" message:self.curCinemaDistance.cinema.cinema_wifi_pwd delegate:self cancelButtonTitle:@"Huỷ" otherButtonTitles: @"Copy", nil];
        [alert show];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Wifi password" message: @"Vui lòng liên hệ rạp." delegate:nil cancelButtonTitle:@"Tiếp tục" otherButtonTitles: nil];
        [alert show];
    }
    
}

- (void)handleCheckInTouch
{
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Cinema" withAction:@"CheckIn" withLabel:@"ButtonPressed" withValue:[NSNumber numberWithInteger:114]];
    
    CheckInViewController* checkInViewController = [[CheckInViewController alloc] init];
    checkInViewController.link = self.curCinemaDistance.cinema.cinema_url;
    checkInViewController.fbShareType = FBShareTypeCheckInCinema;
    checkInViewController.cinemaTitle = self.curCinemaDistance.cinema.cinema_name;
    checkInViewController.cinema = self.curCinemaDistance.cinema;
    [self.navigationController pushViewController: checkInViewController animated:YES];
    
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:checkInViewController.viewName
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_CINEMA_CHECK_IN
                                                     currentFilmID:[NSNumber numberWithInt:NO_FILM_ID]
                                                   currentCinemaID:curCinemaDistance.cinema.cinema_id
                                                   returnCodeValue:0 context:nil];
    
}

- (void)processActionMakeACall
{
    NSString *cinemaPhone = [[self.curCinemaDistance.cinema.cinema_phone componentsSeparatedByString:@"/"] objectAtIndex:0];
    if (cinemaPhone == nil || cinemaPhone .length < 3) {
        return;
    }
    NSString *phoneNumber = [@"tel://" stringByAppendingString:[cinemaPhone stringByReplacingOccurrencesOfString:@" " withString:@""]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

#pragma mark - UIAlert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.curCinemaDistance.cinema.cinema_wifi_pwd;
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

-(void)setHTTPRequest: (ASIHTTPRequest *) theRequest
{
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
    }
    httpRequest = theRequest;
}

#pragma mark process delegate when user select session
-(void)didSelectCinemaSession:(int)indexOfSession curFilmInCinema:(int)curFilm
{
    if (!arrFilmSessionTime && arrFilmSessionTime.count <= curFilm)
    {
        return;
    }
    FilmSession *curFilSes = [arrFilmSessionTime objectAtIndex:curFilm];
    if (!curFilSes || curFilSes.sessionArrays.count <= indexOfSession) {
        return;
    }
    Session *currentSession = [curFilSes.sessionArrays objectAtIndex:indexOfSession];
    if (curCinemaDistance.cinema.is_booking.integerValue > 0)
    {
        SelectSeatViewController *view = [[SelectSeatViewController alloc] init];
        view.currentFilm = curFilSes.film;
        view.currentCinemaWithDistance = curCinemaDistance;
        [view setCurrentSession:currentSession];
        [self.navigationController pushViewController:view animated:YES];
        return;
    }
    else
    {
        if (curCinemaDistance.cinema.is_booking.integerValue == 0) {
            CheckoutWebViewController *checkout = [[CheckoutWebViewController alloc] init];
            checkout.currentCinemaWithDistance = curCinemaDistance;
            checkout.currentFilm = curFilSes.film;
            checkout.currentSession = currentSession;
            [self.navigationController pushViewController:checkout animated:YES];
        } else {
            NSString *message = [NSString stringWithFormat:THANHTOAN_TEXT_CINEMA_NOT_SUPPORT_ONLINE, curCinemaDistance.cinema.cinema_name];
            if (curCinemaDistance.cinema.is_booking.integerValue == -2) {
                message = [NSString stringWithFormat:THANHTOAN_TEXT_WARNING_CINEMA_IS_MAINTAINING, curCinemaDistance.cinema.cinema_name];
            }
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE message:message delegate:nil cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end
