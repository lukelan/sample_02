//
//  CinameFilmView.m
//  MovieTicket
//
//  Created by Nhan Ho Thien on 1/11/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//


#import "CinameFilmView.h"
#import "CellFilm.h"
#import "Film.h"
#import "FilmCinemaViewController.h"
#import "DefineConstant.h"
#import "APIManager.h"
#import "Session.h"
#import "CinemaFilmTitleCell.h"
#import "ShowMapViewController.h"
#import "CinemaViewController.h"
#import "CheckInViewController.h"

@interface CinameFilmView ()

@end

@implementation CinameFilmView
@synthesize curCienmaDistance,arrFilmSessionTime,filmTableView,indexOfCurrentCinemaDistancesInArray;//,delegate=_delegate

-(id)init
{
    self = [super init];
    if (self)
    {
        filmTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height - TITLE_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
        UIView* transColor = [[UIView alloc] init];
        transColor.backgroundColor = [UIColor clearColor];
        self.filmTableView.backgroundView = transColor;
        [transColor release];
        self.filmTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.filmTableView.delegate=self;
        self.filmTableView.dataSource=self;
        
        
        arrFilmSessionTime = [[NSMutableArray alloc] init];
        self.indexOfCurrentCinemaDistancesInArray = -1;
        viewName = CINEMA_FILM_VIEW_NAME;
        
    }
    return  self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       // [self.navigationController setTitle:@"dfdsf"];//=cienmaName;
    }
    return self;
}

#pragma mark table datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *thePath = [[NSBundle mainBundle] pathForResource:@"cinema_info@2x" ofType:@"png"];
        UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
        int height = prodImg.size.height;
        [prodImg release];
        return height;
    }
    return 115;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section != 0)
    {
        return  [arrFilmSessionTime count];
    }
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


#pragma mark Time Compare
- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cellfilm_%d_%d_%d",[self.curCienmaDistance.cinema.cinema_id intValue],indexPath.row, wifiOn];
    if ([arrFilmSessionTime count] == 0) {
        CellIdentifier = [NSString stringWithFormat:@"Cellfilm_%d_%d",indexPath.row, wifiOn];
    }
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        if(indexPath.section == 0)
        {
            cell = (CinemaInfoCell*)[[[CinemaInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            if (!wifiOn) {
                ((CinemaInfoCell*)cell).imageView2.image = [UIImage imageNamed:@"wifi_disable.png"];
                ((CinemaInfoCell*)cell).button2.showsTouchWhenHighlighted = NO;
            }else{
                [((CinemaInfoCell*)cell).button2 addTarget:self action:@selector(handleWifiTouch) forControlEvents:UIControlEventTouchUpInside];
            }
            [((CinemaInfoCell*)cell).button0 addTarget:self action:@selector(handleCallTouch) forControlEvents:UIControlEventTouchUpInside];
            [((CinemaInfoCell*)cell).button1 addTarget:self action:@selector(handleViewMapTouch) forControlEvents:UIControlEventTouchUpInside];
            [((CinemaInfoCell*)cell).button3 addTarget:self action:@selector(handleCheckInTouch) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        
        cell = [[[CellFilm alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withHeigh:[myTableView rowHeight]] autorelease];
        if([arrFilmSessionTime count] > indexPath.row && [arrFilmSessionTime count] > 0)
        {
            FilmSession *filmsession=[arrFilmSessionTime objectAtIndex:[indexPath row] ];
            [(CellFilm *)cell loadStructureWithData:filmsession];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    if(indexPath.section == 0)
    {
//        if (indexPath.row == 0)
//        {
//            [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Cinema" withAction:@"ViewMap" withLabel:@"ButtonPressed" withValue:[NSNumber numberWithInteger:111]];
//            [self showCinemaOnMap];
//
//        }else if (indexPath.row == 1){
//            [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Cinema" withAction:@"Call" withLabel:@"ButtonPressed" withValue:[NSNumber numberWithInteger:112]];
//            [(CinemaFilmTitleCell *)cell processActionMakeACall];
//
//        }else if (indexPath.row == 2){
//            if (self.curCienmaDistance.cinema.cinema_wifi_pwd != NULL) {
//                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//                pasteboard.string = self.curCienmaDistance.cinema.cinema_wifi_pwd;
//                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"123Phim" message:@"Bạn đã copy password wifi." delegate:self cancelButtonTitle:@"Đóng" otherButtonTitles: nil];
//                [alert show];
//                [alert release];
//            }
//        }
//        else{}
//        return;
    }
    else
    {
        FilmSession *curFilmSession = [self.arrFilmSessionTime objectAtIndex:indexPath.row];
        Film* selectedFilm = curFilmSession.film;
        self.curCienmaDistance.arraySessions = curFilmSession.sessionArrays;
        int versionID = 0;
        if (self.curCienmaDistance.arraySessions.count > 0) {
            versionID = [[(Session *)[self.curCienmaDistance.arraySessions objectAtIndex:0] version_id] intValue];
        }

        FilmCinemaViewController *cinemaFilmController = [[FilmCinemaViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [cinemaFilmController setIndexOfCurrentCienmaDistance:indexPath.row];
        [cinemaFilmController setIsLoadingSessionFromCinema:YES];
        [cinemaFilmController setFilm:selectedFilm];
        [cinemaFilmController setCinema_id_fromCinemaFilmView:[self.curCienmaDistance.cinema.cinema_id intValue]];
        [cinemaFilmController setSession_version_id_fromCinemaFilmView:versionID];
        [cinemaFilmController requestAPIGetListCinemaSession];
        [cinemaFilmController setHideTabBarWhenAppear:YES];
        [self.navigationController pushViewController:cinemaFilmController animated:YES];
        [cinemaFilmController release];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showCinemaOnMap
{
    ShowMapViewController *showMapViewController = [[ShowMapViewController alloc] init];
    CLLocationCoordinate2D centerOfCinemaGroupMap = CLLocationCoordinate2DMake([self.curCienmaDistance.cinema.cinema_latitude doubleValue], [self.curCienmaDistance.cinema.cinema_longtitude doubleValue]);    
    showMapViewController.currentLocationState = YES;
    showMapViewController.typeOfMap = MapTypeCinemaIndividual;
    showMapViewController.currentCinemaDistance = self.curCienmaDistance;
    showMapViewController.mapCenterUserChoice = centerOfCinemaGroupMap;
    showMapViewController.mapSpanUserChoice = MKCoordinateSpanMake(0.01, 0.01);
//    [showMapViewController setHideTabBarWhenAppear:YES];
    [self.navigationController pushViewController:showMapViewController animated:YES];
    [showMapViewController release];
}


#pragma mark Process View delegate appear, disappear
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setTitleLabelForNavigationController:self withTitle:self.curCienmaDistance.cinema.cinema_name];
    [super viewWillAppear:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![AppDelegate isNetWorkValiable])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Để xem lịch chiếu của phim tại rạp bạn phải kết nối Internet. Vui lòng kiểm tra trong mục Cài đặt." delegate:self cancelButtonTitle:@"Tiếp tục" otherButtonTitles:nil];
        [alert show];
        [alert release];
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
        if(self.curCienmaDistance.cinema.arrayIdListFilm == nil || [self.curCienmaDistance.cinema.arrayIdListFilm count] == 0)
        {
            self.curCienmaDistance.cinema.arrayIdListFilm = [[[self.curCienmaDistance.cinema.cinema_list_film componentsSeparatedByString:@","] mutableCopy] autorelease];
        }
    //    [self getListSessionTimeByTime:[NSDate date]];
        if ([self.arrFilmSessionTime count] > 0) {
            [self reloadData];
            [self hideLoadingView];
        } else {
            [AppDelegate resetStartTime];
            [[APIManager sharedAPIManager] getListFilmSessionByCinema:[self.curCienmaDistance.cinema.cinema_id intValue] context:self];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    self.view.backgroundColor = [MainViewController colorBackGroundApp];
    [self.view addSubview:self.filmTableView];
    self.trackedViewName = @"UIRap-Film";
    [self initHandleSwipeGestureRecognizer];
    wifiOn = self.curCienmaDistance.cinema.cinema_wifi_pwd != NULL && (![self.curCienmaDistance.cinema.cinema_wifi_pwd isEqualToString:@""]);
    NSString* previewView = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).currentView;
    NSString* currentView = viewName;
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:currentView comeFrom:previewView withActionID:LOG_ACTION_ID_VIEW currentFilmID:[NSNumber numberWithInt:NO_FILM_ID] currentCinemaID:self.curCienmaDistance.cinema.cinema_id returnCodeValue:0 context:self];
}

-(void)initHandleSwipeGestureRecognizer
{
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(handleSwipeFrom:)];
    [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [gesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:gesture];
    [gesture release];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [delegate popViewController];
    }
}

-(void)dealloc
{
    [curCienmaDistance release];
    [filmTableView release];
    [arrFilmSessionTime release];
    [super dealloc];
}

#pragma mark - ASIHttpRequestDelegate
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    NSString *response = [request responseString];
    if (self.arrFilmSessionTime != nil) {
        [self.arrFilmSessionTime removeAllObjects];
    }
    [[APIManager sharedAPIManager] parseListFilmSessionByCinema:arrFilmSessionTime with:response];
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
    [filmTableView reloadData];
}

#pragma mark - Button action
- (void)handleCallTouch
{
//    NSLog(@"handleCallTouch");
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Cinema" withAction:@"Call" withLabel:@"ButtonPressed" withValue:[NSNumber numberWithInteger:112]];
    [self processActionMakeACall];
}

- (void)handleViewMapTouch
{
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Cinema" withAction:@"ViewMap" withLabel:@"ButtonPressed" withValue:[NSNumber numberWithInteger:111]];
    [self showCinemaOnMap];

}

- (void)handleWifiTouch
{
//    self.curCienmaDistance.cinema.cinema_wifi_pwd = @"12345";
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Cinema" withAction:@"Wifi" withLabel:@"ButtonPressed" withValue:[NSNumber numberWithInteger:113]];
    if (wifiOn) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Wifi password" message:self.curCienmaDistance.cinema.cinema_wifi_pwd delegate:self cancelButtonTitle:@"Huỷ" otherButtonTitles: @"Copy", nil];
        [alert show];
        [alert release];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Wifi password" message: @"Vui lòng liên hệ rạp." delegate:nil cancelButtonTitle:@"Tiếp tục" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
}

- (void)handleCheckInTouch
{
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Cinema" withAction:@"CheckIn" withLabel:@"ButtonPressed" withValue:[NSNumber numberWithInteger:114]];
    CheckInViewController* checkInViewController = [[CheckInViewController alloc] init];
    checkInViewController.cinema = self.curCienmaDistance.cinema;
    [self.navigationController pushViewController: checkInViewController animated:YES];
    [checkInViewController release];
}

- (void)processActionMakeACall
{
    NSString *cinemaPhone = [[self.curCienmaDistance.cinema.cinema_phone componentsSeparatedByString:@"/"] objectAtIndex:0];
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
        pasteboard.string = self.curCienmaDistance.cinema.cinema_wifi_pwd;
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}


@end
