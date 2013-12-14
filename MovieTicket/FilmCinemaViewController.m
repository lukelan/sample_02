 //
//  CiemaViewController.m
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/7/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.

#import "FilmCinemaViewController.h"
#import "FilmDetailViewController.h"
#import "APIManager.h"
#import "MainViewController.h"
#import "CinemaViewController.h"
#import "ShareFilmViewController.h"
#import "CinemaNoteCell.h"
#import "SelectDateCell.h"
#import "SelectCityCell.h"
#import "CinemaWithDistance.h"
#import "Cinema.h"
#import "Session.h"
#import "NSArray+Sort.h"
#import "UIViewController+Utility.h"
#import "SelectSeatViewController.h"
#import "CheckoutWebViewController.h"
#import "HMSegmentedControl.h"
#import "HMSegmentedControlContainerView.h"
#import "PromotionViewController.h"


@interface FilmCinemaViewController ()
@end

@implementation FilmCinemaViewController
@synthesize film, isLoadingCinemaSessionComplete,indexOfCurrentCienmaDistance,stepNextDayShowSession;
@synthesize session_version_id_fromCinemaFilmView,cinema_id_fromCinemaFilmView;
@synthesize cinemaListWithDistance;

-(void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
    }
    [_listOfCinenaGroup removeAllObjects];
    [cinemaListWithDistance removeAllObjects];
    [_bookingCinemaWithDistanceList removeAllObjects];
    [_nonBookingCinemaWithDistanceList removeAllObjects];
    
    httpRequest = nil;
    _current_cinema_id_needUpdate = nil;
    cinema_id_fromCinemaFilmView = nil;
    session_version_id_fromCinemaFilmView = nil;
    stepNextDayShowSession = nil;
    indexOfCurrentCienmaDistance = nil;
    isLoadingCinemaSessionComplete = nil;
    film = nil;
    _listOfCinenaGroup = nil;
    cinemaListWithDistance = nil;
    _bookingCinemaWithDistanceList = nil;
    _nonBookingCinemaWithDistanceList = nil;
    _scrollViewGroupCinema = nil;
    _layoutGroupSessionView = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self refreshResourceTableView];
        self.indexOfCurrentCienmaDistance = -1;
        self.stepNextDayShowSession = 0;
        self.cinema_id_fromCinemaFilmView = -1;
        self.session_version_id_fromCinemaFilmView = -1;
        
        viewName = FILM_CINEMA_VIEW_NAME;
        
        self.tabBarDisplayType = TAB_BAR_DISPLAY_HIDE;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didLoadCinemaWithDistance:) name:NOTIFICATION_NAME_CINEMA_WITH_DISTANCE_DID_LOAD object:nil];
        [center addObserver:self selector:@selector(didChangeCity:) name:NOTIFICATION_NAME_NEW_CITY object:nil];
        [center addObserver:self selector:@selector(didLoadCinema:) name:NOTIFICATION_NAME_CINEMA_DID_LOAD object:nil];
        
        //[self setHidesBottomBarWhenPushed:YES];
    }
    return self;
}

#pragma mark init data

-(void)refreshResourceTableView
{
    // Custom initialization
    isLoadingCinemaSessionComplete = NO;
}

-(void)updateCinemaGroupView
{
    UIView* oldCinemaGroupView = [self.view viewWithTag:129];
    if (oldCinemaGroupView != nil) {
        [oldCinemaGroupView removeFromSuperview];
    }
    
    if (self.listOfCinenaGroup.count > 1) {
        NSDictionary* nearMe = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:0], @"cinemaGrpId", @"Xung Quanh", @"cinemaGrpName", nil];
        [self.listOfCinenaGroup insertObject:nearMe atIndex:0];
    }
    
    NSMutableArray* cinemaTitleList = [[NSMutableArray alloc] init];
//    NSInteger segmentSelectedIndex = 0;
    for (int i = 0; i<self.listOfCinenaGroup.count; i++){
        NSDictionary* cinemaG = [self.listOfCinenaGroup objectAtIndex:i];
        [cinemaTitleList addObject:[cinemaG valueForKey:@"cinemaGrpName"]];
    }

    if (cinemaTitleList.count > 0) {
        [self setupContent:cinemaTitleList];
    }
    else
    {
        UIView *lblView = [self.view viewWithTag:129];
        [lblView removeFromSuperview];
        
        // no sesssion
        UILabel* noSessionView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, HEIGH_GROUP_TITLE_CINEMA)];
        noSessionView.tag = 129;
        noSessionView.clipsToBounds = NO;
        noSessionView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
        noSessionView.textAlignment = UITextAlignmentCenter;
        noSessionView.font = [UIFont getFontNormalSize15];
        noSessionView.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        Location *loc = [APIManager loadLocationObject];
        NSString *city = loc.location_name;
        noSessionView.text = [NSString stringWithFormat:@"Đã hết suất chiếu tại %@", city];
        CALayer* layer = noSessionView.layer;
        layer.shadowOffset = CGSizeMake(0, 2);
        layer.shadowOpacity = 0.5;
        layer.shadowRadius = 2.0;
        layer.shadowColor = [[UIColor blackColor] CGColor];
        [self.view addSubview:noSessionView];
    }
    
}

- (void)setupContent:(NSArray *)listGroupCinema
{
    [self.scrollViewGroupCinema setValues:listGroupCinema];
    [self.scrollViewGroupCinema setDelegate:self];
    [self.scrollViewGroupCinema setUpdateIndexWhileScrolling:NO];
}

- (void)scrollView:(MVSelectorScrollView *)scrollView pageSelected:(int)pageSelected
{
//    LOG_123PHIM(@"%s scroll view %d, selected page: %d", __func__, scrollView.tag, pageSelected);
    [self reloadData];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    
    // set properties for navigator bar
    UIImage *imageRight = [UIImage imageNamed:@"edittext.png"];
    UIButton *customButtonR = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0, 0, imageRight.size.width, imageRight.size.height);
    customButtonR.frame = frame;
    [customButtonR setBackgroundImage:imageRight forState:UIControlStateNormal];
    [customButtonR addTarget:self action:@selector(showChooseCityViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc] initWithCustomView:customButtonR];
    self.navigationItem.rightBarButtonItem = btnRight;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:film.film_name];
    [delegate setDiscountTypeEffect:DISCOUNT_TYPE_NONE];
    self.trackedViewName = viewName;
}

- (void) viewWillDisappear:(BOOL)animated
{
    if (self.scrollViewGroupCinema)
    {
        if (self.scrollViewGroupCinema.selectedIndex < self.listOfCinenaGroup.count) {
            NSDictionary* cinemaG = [self.listOfCinenaGroup objectAtIndex:self.scrollViewGroupCinema.selectedIndex];
            if (cinemaG)
            {
                int GroupId = [[cinemaG objectForKey:@"cinemaGrpId"] intValue];
                [APIManager setValueForKey:[NSNumber numberWithInt:GroupId] ForKey:[NSString stringWithFormat:@"%@_%d",KEY_STORE_GROUP_ID_CINEMA, [AppDelegate getMyLocationId]]];
            }
        }
    }
    [super viewWillDisappear:animated];
}

-(void)viewDidUnload
{
    [self setScrollViewGroupCinema:nil];
    [self setLayoutGroupSessionView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Process Action
-(void)requestAPIGetListCinemaSession
{
    if ([AppDelegate isNetWorkValiable])
    {
        if(!isLoadingCinemaSessionComplete)
        {
            [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR];
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if (!delegate.arrayCinema || delegate.arrayCinema.count == 0) {
                [[APIManager sharedAPIManager] getListAllCinemaByLocation:[AppDelegate getMyLocationId] context:[CinemaViewController sharedCinemaViewController]];
            }
            else
            {
                [AppDelegate resetStartTime];
                NSString *tempDate = [self getDateForTomorrow:self.stepNextDayShowSession];
                [[APIManager sharedAPIManager] getListCinemaSessionByFilm:[film.film_id intValue] byDate:tempDate atLocation:[AppDelegate getMyLocationId] withRequestID:(MAX_ID_REQUEST + self.stepNextDayShowSession) context:self];
            }
            return;
        }
    }
    [self hideLoadingView];
}

- (NSString *) getDateForTomorrow:(int)step
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //Xu ly duyet ngay thang o day
    if (step == 0)
    {
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        return strDate;
    }
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *addComp = [[NSDateComponents alloc] init];
    [addComp setDay:step];
    NSDate *currentDate = [calendar dateByAddingComponents:addComp toDate:today options:0];
    NSString *strDate = [dateFormatter stringFromDate:currentDate];
    return strDate;
}

#pragma mark implement SelectDateViewControllerDelegate, ChooseCityViewControllerDelegate
-(void)receiveNumberStepDayFromNow:(int)stepDay
{
    if (self.stepNextDayShowSession != stepDay)
    {
        self.stepNextDayShowSession = stepDay;
        isLoadingCinemaSessionComplete = NO;
        [self requestAPIGetListCinemaSession];
    }
}

- (void)didChangeCity:(NSNotification *) notification
{
    [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR];
}

- (void)didLoadCinema:(NSNotification *) notification
{
    NSArray *cinemaList = [notification object];
    if (cinemaList && [cinemaList count] > 0)
    {
        // re get list session when city changed -> cinema list changed
        isLoadingCinemaSessionComplete = NO;
        [self requestAPIGetListCinemaSession];
    }
}

-(void)didSelectShareAction
{
    ShareFilmViewController *shareFilmViewController = [[ShareFilmViewController alloc] init];
    [shareFilmViewController setFilm:self.film];
    [self.navigationController pushViewController:shareFilmViewController animated:YES];
}

- (void)cinemaSegmentValueChanged:(UISegmentedControl*)segmentCtrl
{
    [self reloadData];
}

-(void)executeLoadDataToDisplayLayout
{
    [self updateCinemaGroupView];
    [self setIndexForCinemaGroup];
    //        self.view.userInteractionEnabled = YES;
    self.isLoadingCinemaSessionComplete = YES;
    [self hideLoadingView];
    NSDate *endDate = [NSDate date];
    NSDate *startDate = [AppDelegate getStartTime];
    NSTimeInterval timeDiff = [endDate timeIntervalSinceDate:startDate];
    [[GAI sharedInstance].defaultTracker sendTimingWithCategory:@"Loading" withValue:timeDiff withName:@"LoadSuatChieu" withLabel:nil];
}

#pragma mark - ASIHttpRequestDelegate
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    NSString *response = [request responseString];
    
    if (request.tag == (MAX_ID_REQUEST + self.stepNextDayShowSession))
    {
        if (self.cinemaListWithDistance != nil)
        {
            [self.cinemaListWithDistance removeAllObjects];
        } else {
            self.cinemaListWithDistance = [[NSMutableArray alloc] init];
        }
        if (self.listOfCinenaGroup != nil) {
            [self.listOfCinenaGroup removeAllObjects];
        } else {
            self.listOfCinenaGroup = [[NSMutableArray alloc] init];
        }
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *arrayCinemaDistance = delegate.arrayCinemaDistance;
        if (!arrayCinemaDistance || arrayCinemaDistance.count == 0)
        {
            return;
        }
        
        [[APIManager sharedAPIManager] parseListCinemaSession:self.cinemaListWithDistance cinemaGroup:self.listOfCinenaGroup byFilm:[film.film_id integerValue] with:response];
        [self executeLoadDataToDisplayLayout];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    [super requestFailed:request];
}

-(void)setHTTPRequest: (ASIHTTPRequest *) theRequest
{
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
    }
    httpRequest = theRequest;
}

- (void) orderCinemaListWithDistance:(NSMutableArray*)inArray
{
    NSArray* sortDescription = [NSArray getCinemaSortDescriptor];   
    
    // list of booking
    if (!self.bookingCinemaWithDistanceList)
    {
        self.bookingCinemaWithDistanceList = [[NSMutableArray alloc] init];
    }
    [self.bookingCinemaWithDistanceList removeAllObjects];
    // list of non booking
    if (!self.nonBookingCinemaWithDistanceList)
    {
        self.nonBookingCinemaWithDistanceList = [[NSMutableArray alloc] init];
    }
    [self.nonBookingCinemaWithDistanceList removeAllObjects];
    BOOL isSkipped = self.listOfCinenaGroup.count == 1;
    for (int i = 0; i < inArray.count; i++) {
        CinemaWithDistance* cinema = [inArray objectAtIndex:i];
        if ([cinema.cinema.is_booking integerValue] == 1 || isSkipped) {
            [self.bookingCinemaWithDistanceList addObject:cinema];
        }
        else
        {
            [self.nonBookingCinemaWithDistanceList addObject:cinema];
        }
    }
    [self.bookingCinemaWithDistanceList sortUsingDescriptors:sortDescription];
    [self.nonBookingCinemaWithDistanceList sortUsingDescriptors:sortDescription];

    // merging
    [self.cinemaListWithDistance removeAllObjects];
    [self.cinemaListWithDistance addObjectsFromArray:self.bookingCinemaWithDistanceList];
    [self.cinemaListWithDistance addObjectsFromArray:self.nonBookingCinemaWithDistanceList];
    [self.bookingCinemaWithDistanceList removeAllObjects];
    [self.nonBookingCinemaWithDistanceList removeAllObjects];
}

-(void)didLoadCinemaWithDistance: (NSNotification *) notification
{
    NSArray *cinemaList = [notification object];
    if (cinemaList && [cinemaList count] > 0)
    {
        NSString *response = httpRequest.responseString;
        
        [[APIManager sharedAPIManager] parseListCinemaSession:self.cinemaListWithDistance cinemaGroup:self.listOfCinenaGroup byFilm:[film.film_id integerValue] with:response];
        
        // wait getting session list
        if (response && [response isEqualToString:@""])
        {
            [self setIndexForCinemaGroup];
//            self.view.userInteractionEnabled = YES;
            self.isLoadingCinemaSessionComplete = YES;
            [self hideLoadingView];
        }
        else
        {
            [self executeLoadDataToDisplayLayout];
        }
    }
}

-(void)reloadData
{
    if (self.cinemaListWithDistance && self.cinemaListWithDistance.count > 0)
    {
        [self orderCinemaListWithDistance:self.cinemaListWithDistance];
    }
    [self setReloadDataForTableSession];
}

-(void)setReloadDataForTableSession
{
    [self.layoutGroupSessionView  setFilm:film];
    [self.layoutGroupSessionView  setDelegate:self];

    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSInteger num = 0;
    NSInteger cinemaGId = 0;
    __block News *groupNews = nil;
    if (self.scrollViewGroupCinema.selectedIndex == 0)
    {
        [arr addObjectsFromArray:self.cinemaListWithDistance];
        num = [self.bookingCinemaWithDistanceList count];
        if ([self.listOfCinenaGroup count] == 1)
        {
            cinemaGId = [[[self.listOfCinenaGroup objectAtIndex: self.scrollViewGroupCinema.selectedIndex] valueForKey:@"cinemaGrpId"] intValue];
        }
    }
    else
    {
        if (self.listOfCinenaGroup && [self.listOfCinenaGroup count] > self.scrollViewGroupCinema.selectedIndex)
        {
            cinemaGId = [[[self.listOfCinenaGroup objectAtIndex: self.scrollViewGroupCinema.selectedIndex] valueForKey:@"cinemaGrpId"] intValue];
            for (CinemaWithDistance* item in self.cinemaListWithDistance)
            {
                if ([item.cinema.p_cinema_id intValue] == cinemaGId)
                {
                    [arr addObject:item];
                }
            }
        }
    }
    NSArray *arrNews = [PromotionViewController sharedPromotionViewController].myArrayNews;
    if (cinemaGId > 0 && arrNews)
    {
        [arrNews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            News *news = (News *)obj;
            if (news.cinemaGroupID && news.cinemaGroupID.integerValue == cinemaGId && news.cinemaID && news.cinemaID.integerValue == 0 && news.filmIDList && news.filmIDList.length > 0)
            {
                NSArray *filmIDList = [news.filmIDList componentsSeparatedByString:@","];
                if (filmIDList)
                {
                    __block BOOL stop0 = NO;
                    [filmIDList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([obj isKindOfClass:[NSString class]] && [[self.film.film_id stringValue] isEqualToString:obj])
                        {
                            groupNews = news;
                            *stop = YES;
                            stop0 = YES;
                        }
                    }];
                    if (stop0)
                    {
                        *stop = YES;
                    }
                }
            }
        }];
    }
    
    [self.layoutGroupSessionView setStepNextDayShowSession:stepNextDayShowSession];
    [self.layoutGroupSessionView setCinemaListByGroupWithDistance:arr];
    [self.layoutGroupSessionView setNumberOfBookingCinema:num];
    [self.layoutGroupSessionView setNews:groupNews];
    [self.layoutGroupSessionView reloadData];
}

- (void)setIndexForCinemaGroup
{
    id value = [APIManager getValueForKey:[NSString stringWithFormat:@"%@_%d",KEY_STORE_GROUP_ID_CINEMA, [AppDelegate getMyLocationId]]];
    if (!value && ![value isKindOfClass:[NSNumber class]])
    {
        [self reloadData];
        return;
    }
    int iSelectIndex = [value intValue];
    if (!self.listOfCinenaGroup || self.listOfCinenaGroup.count == 0 || iSelectIndex >= self.listOfCinenaGroup.count)
    {
        [self reloadData];
        return;
    }
    NSInteger segmentSelectedIndex = 0;
    for (int i = 0; i<self.listOfCinenaGroup.count; i++){
        NSDictionary* cinemaG = [self.listOfCinenaGroup objectAtIndex:i];
        if ([[cinemaG valueForKey:@"cinemaGrpId"] integerValue] == iSelectIndex) {
            segmentSelectedIndex = i;
        }
    }

    [self.scrollViewGroupCinema setSelectedIndex:segmentSelectedIndex animated:NO];
    [self reloadData];
}

#pragma mark
#pragma mark FilmCinemaPageViewDelegate
-(void)showSeletedDateViewController
{
    SelectDateViewController *selectDateView = [[SelectDateViewController alloc] init];
    [selectDateView setDateOfNearestSession:[[NSDate alloc] init]];
    [selectDateView setSelectDateDelegate:self];
    [selectDateView setIndexSelectedDate:self.stepNextDayShowSession];
    [selectDateView setTitle:self.film.film_name];
    [self.navigationController pushViewController:selectDateView animated:YES];
}

-(void)showChooseCityViewController
{
    if (isLoadingCinemaSessionComplete)
    {
        ChooseCityViewController* chooseCityViewController = [[ChooseCityViewController alloc] init];
        [chooseCityViewController setFullScreen];
        chooseCityViewController.chosenCity = [APIManager loadLocationObject];
        [self.navigationController pushViewController:chooseCityViewController animated:YES];
    }
}

-(void)didSelectCinemaSession:(Session *)session film:(Film *)theFilm cinemaWithDistance:(CinemaWithDistance *)cinemaWithDistance
{
    if (cinemaWithDistance.cinema.is_booking.integerValue > 0)
    {
        SelectSeatViewController *view = [[SelectSeatViewController alloc] init];
        view.currentFilm = theFilm;
        view.currentCinemaWithDistance = cinemaWithDistance;
        [view setCurrentSession:session];
        
        [self.navigationController pushViewController:view animated:YES];
        return;
    }
    else
    {
        if (cinemaWithDistance.cinema.is_booking.integerValue == 0) {
            CheckoutWebViewController *checkout = [[CheckoutWebViewController alloc] init];
            checkout.currentCinemaWithDistance = cinemaWithDistance;
            checkout.currentFilm = theFilm;
            checkout.currentSession = session;
            [self.navigationController pushViewController:checkout animated:YES];
        } else {
            NSString *message = [NSString stringWithFormat:THANHTOAN_TEXT_CINEMA_NOT_SUPPORT_ONLINE, cinemaWithDistance.cinema.cinema_name];
            if (cinemaWithDistance.cinema.is_booking.integerValue == -2) {
                message = [NSString stringWithFormat:THANHTOAN_TEXT_WARNING_CINEMA_IS_MAINTAINING, cinemaWithDistance.cinema.cinema_name];
            }
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE message:message delegate:nil cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(void)filmCinemaPage:(FilmCinemaPageView *)page didSelectNews:(News *)news
{
    if (news)
    {
        [[PromotionViewController sharedPromotionViewController] pushPromotionDetailViewFor:news];
    }
}

@end
