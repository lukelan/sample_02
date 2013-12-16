//
//  CiemaViewController.m
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/7/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//
#define TEXT_CASE1 @"Vị trí trung tâm được tính từ: %@."
#define TEXT_CASE2 @"Vị trí trung tâm được tính từ: %@. Vui lòng \"Bật định vị\" để có thông tin chính xác hơn."
#import "CinemaViewController.h"
#import "CinemaWithDistance.h"
#import "APIManager.h"
#import "DistanceTimeCell.h"
#import "CinemaLocationCal.h"
#import "CinemaContentCell.h"
#import "PositionOffCell.h"
#import "NSArray+Sort.h"
#import "UIViewController+Utility.h"
#import "CinemaTableViewCell.h"
#import "CinemaTableViewLocationCell.h"
#import "CinemaTableViewPlaceCell.h"

#define STRING_KEY_ITEMS @"items"
#define STRING_KEY_SECTION_TITLE @"sectionTitle"

@interface CinemaViewController ()<NSFetchedResultsControllerDelegate, CinemaTableViewCellDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property int numberCinemaFavorite;
@property (nonatomic, retain) NSMutableArray *datasource;
@end

@implementation CinemaViewController

@synthesize tableView = _tableView;
@synthesize yourPosition,cinemaList,isLoadedCinemaComplete;
@synthesize centerOfCinemaGroupMap, centerOfPositionChoiceMap, spanOfCinemaGroupMap, spanOfPositionChoiceMap;
@synthesize yourCity;
@synthesize cinemaListWithDistance = _cinemaListWithDistance;
@synthesize displayLocation = _displayLocation;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize numberCinemaFavorite;

static CinemaViewController* _sharedMyCinemaView = nil;
static bool distanceGetFromCurrentPos = NO;

-(NSMutableArray *)datasource
{
    if (!_datasource) {
        _datasource = [NSMutableArray array];
    }
    return _datasource;
}

- (void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:NOTIFICATION_NAME_NEW_CITY object:nil];
    [NSFetchedResultsController deleteCacheWithName:@"cinema"];
    [cinemaList removeAllObjects];
    [_cinemaListWithDistance removeAllObjects];
    strDes = nil;
    isNeedReloadCell = nil;
    strDes = nil;
    isNeedReloadCell = nil;
    lastTimeLoading = 0;
    _tableView = nil;
    cinemaList = nil;
    yourCity = nil;
    yourPosition = nil;
    _displayLocation = nil;
    _cinemaListWithDistance = nil;
    _datasource = nil;
}

+(CinemaViewController*)sharedCinemaViewController
{
    //This way guaranttee only a thread execute and other thread will be returned when thread was running finished process
    if(_sharedMyCinemaView != nil)
    {
        return _sharedMyCinemaView;
    }
    static dispatch_once_t _single_thread;//block thread
    dispatch_once(&_single_thread, ^ {
        _sharedMyCinemaView = [[super allocWithZone:nil] initWithNibName:@"CinemaViewControllerTable" bundle:[NSBundle mainBundle]];
    });//This code is called most once.
    return _sharedMyCinemaView;
}

#pragma implements these methods below to do the appropriate things to ensure singleton status.
//if you want a singleton instance but also have the ability to create other instances as needed through allocation and initialization, do not override allocWithZone: and the orther methods below
//We don't want to allocate a new instance, so return the current one
+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedCinemaViewController];
}


//We don't want to generate mutiple conpies of the singleton
-(id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController{
    
    if (!_fetchedResultsController)
    {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Cinema class])];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"cinema_id" ascending:YES]];
        NSPredicate* cinemaPredicate = [NSPredicate predicateWithFormat:@"location_id=%d", [AppDelegate getMyLocationId]];
        [fetchRequest setPredicate:cinemaPredicate];
        
        NSFetchedResultsController *myFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:@"cinema"];
        [myFetchedResultsController setDelegate:self];
        self.fetchedResultsController = myFetchedResultsController;
        
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
        
        //        LOG_123PHIM(@"aaaa %@",[self.fetchedResultsController fetchedObjects]);
        
        NSAssert(!error, @"Error performing fetch request: %@", error);
    }
    return _fetchedResultsController;
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //    LOG_123PHIM(@"sajdfkldjslkafjkdlsajlkfdsajklfd");
    [self loadDataForView];
}

- (void)loadDataForView
{
    [self.cinemaList removeAllObjects];
    [self.cinemaListWithDistance removeAllObjects];
    self.cinemaList = [NSMutableArray arrayWithArray:[self.fetchedResultsController fetchedObjects]];
    if ([self.cinemaList count] == 0) {
        self.isLoadedCinemaComplete = NO;
        return;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setArrayCinema:cinemaList]; //ENTRY
    self.isLoadedCinemaComplete = YES;
    [self layoutCinemaList];
    lastTimeLoading = [NSDate timeIntervalSinceReferenceDate];
}

#pragma mark init nib file with name
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage *img=[UIImage imageNamed:@"footer-button-theater-active.png"];
        [self.tabBarItem setFinishedSelectedImage:img withFinishedUnselectedImage:[UIImage imageNamed:@"footer-button-theater.png"] ];
        [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor whiteColor], UITextAttributeTextColor,
                                                   nil] forState:UIControlStateNormal];
        self.yourPosition = [[Position alloc] init];
        self.yourPosition.address = @"";
        [self.tabBarItem setTitle:@"Rạp chiếu"];
        
        cinemaList=[[NSMutableArray alloc]init];
        _cinemaListWithDistance = [[NSMutableArray alloc] init];
        
        self.isLoadedCinemaComplete = NO;
        self.centerOfCinemaGroupMap = CLLocationCoordinate2DMake(0, 0);
        self.centerOfPositionChoiceMap = CLLocationCoordinate2DMake(0, 0);
        
        UIImage *imageRight = [UIImage imageNamed:@"edittext.png"];
        UIButton *customButtonR = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(0, 0, imageRight.size.width, imageRight.size.height);
        customButtonR.frame = frame;
        [customButtonR setBackgroundImage:imageRight forState:UIControlStateNormal];
        [customButtonR addTarget:self action:@selector(choosenCity) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *btnRight = [[UIBarButtonItem alloc] initWithCustomView:customButtonR];
        self.navigationItem.rightBarButtonItem = btnRight;
        strDes = TEXT_CASE2;
        isNeedReloadCell = NO;
        
        //init your choosen city
        yourCity = [[Location alloc] init];
        _displayLocation = [[Position alloc] init];
        
        [self loadDataForView];
        Location* city = [APIManager loadLocationObject];
        [[APIManager sharedAPIManager] getListAllCinemaByLocation:city.location_id context:self];
        
        // TrongV - 08/12/2013 - Show Tab bar as default
        self.tabBarDisplayType = TAB_BAR_DISPLAY_SHOW;
        
        viewName = CINEMA_VIEW_NAME;
        
        NSNotificationCenter* receiveNotification = [NSNotificationCenter defaultCenter];
        [receiveNotification addObserver:self selector:@selector(handleNewCity) name:NOTIFICATION_NAME_NEW_CITY object:nil];
    }
    return self;
}

-(void)checkLoadDataIfNeed
{
    NSTimeInterval timeCurrent = [NSDate timeIntervalSinceReferenceDate];
    int timeLitmit = 259200;
    id temp = MAX_TIME_RETRY_GET_LIST_CINEMA;
    if ([temp isKindOfClass:[NSNumber class]]) {
        timeLitmit = [temp intValue];
    }
    if ((!self.isLoadedCinemaComplete || ((timeCurrent - lastTimeLoading) > timeLitmit && lastTimeLoading != 0)))
    {
        [self loadCinemaByLocationId:[AppDelegate getMyLocationId]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //load ultility
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if(!self.isLoadedCinemaComplete && [AppDelegate isNetWorkValiable])
    {
        [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_TABBAR];
    } else {
        [self reloadTableData];
        [self.tableView setContentOffset:CGPointZero animated:NO];
        [self hideLoadingView];
    }
    if (0 == self.centerOfCinemaGroupMap.latitude && 0 == self.centerOfCinemaGroupMap.longitude) {
        self.centerOfCinemaGroupMap = self.yourPosition.positionCoodinate2D;
        self.spanOfCinemaGroupMap = MKCoordinateSpanMake(0.01, 0.01);
    }
    if (0 == self.centerOfPositionChoiceMap.latitude && 0 == self.centerOfPositionChoiceMap.longitude) {
        self.centerOfPositionChoiceMap = self.yourPosition.positionCoodinate2D;
        self.spanOfPositionChoiceMap = MKCoordinateSpanMake(0.01, 0.01);
    }
    // display navigation title
    NSString* tittle = self.yourCity.location_name;
    if (self.navigationController.title != tittle)
    {
        [delegate setTitleLabelForNavigationController:self withTitle:tittle];
    }
    if (isChangeNewCity) {
        isChangeNewCity = NO;
        [self loadDataForView];
    }
    [self checkLoadDataIfNeed];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    //entry point of your postion
    self.yourPosition.positionCoodinate2D = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).userPosition.positionCoodinate2D;
    self.yourPosition.address = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).userPosition.address;
    
    [self.view setBackgroundColor:[UIFont colorBackGroundApp]];
    self.trackedViewName = CINEMA_VIEW_NAME;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return  [textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(Class)cellClassForObject:(id)object
{
    if ([object isMemberOfClass:[CinemaTableViewLocationItem class]]) {
        return [CinemaTableViewLocationCell class];
    }
    else if ([object isMemberOfClass:[CinemaTableViewPlaceItem class]])
    {
        return [CinemaTableViewPlaceCell class];
    }
    
    return [CinemaTableViewPlaceCell class];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datasource.count;
}

// Customize the number of rows in the table view.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.datasource objectAtIndex:section] objectForKey:STRING_KEY_ITEMS] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [[[self.datasource objectAtIndex:indexPath.section] objectForKey:STRING_KEY_ITEMS] objectAtIndex:indexPath.row];
    Class cellClass = [self cellClassForObject:object];
    return [cellClass tableView:self.tableView rowHeightForObject:object];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [[[self.datasource objectAtIndex:indexPath.section] objectForKey:STRING_KEY_ITEMS] objectAtIndex:indexPath.row];
    Class cellClass = [self cellClassForObject:object];
    NSString *indentifier = [cellClass description];
    
    CinemaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
        cell.delegate = self;
    }
    
    if ([cell isKindOfClass:[CinemaTableViewCell class]]) {
        [cell setObject:object];
    }
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = [[self.datasource objectAtIndex:section] valueForKey:STRING_KEY_SECTION_TITLE];
    if (title) {
        UIView* ret = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 21)];
        UILabel *lblRatingPoint = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_EDGE_TABLE_GROUP + 5, 0, 280, 21)];
        [lblRatingPoint setFont:[UIFont getFontBoldSize13]];
        [lblRatingPoint setBackgroundColor:[UIColor clearColor]];
        [lblRatingPoint setTextColor:[UIColor blackColor]];
        [ret addSubview:lblRatingPoint];
        
        lblRatingPoint.text = title;
        //        ret.backgroundColor = [UIColor greenColor];
        return ret;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *title = [[self.datasource objectAtIndex:section] valueForKey:STRING_KEY_SECTION_TITLE];
    if (title) {
        return 22;
    }
    return  0;
//    return title ? 22 : 0;
}

#pragma mark - CinemaTableViewCellDelegate
-(void)cinemaTableViewCell:(CinemaTableViewCell *)cell didSelect:(id)object atIndex:(NSInteger)index
{
    if (!self.isLoadedCinemaComplete) {
        return;
    }
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if ([object isMemberOfClass:[CinemaTableViewLocationItem class]])
    {
        if ([APIManager getBooleanInAppForKey:KEY_STORE_IS_SHOW_MY_LOCATION] == YES)
        {
            [self specifyYourPosition];
        }
        else
        {
            delegate.tabBarController.selectedIndex = 3;
        }
    }
    else
    {
        for (CinemaWithDistance *cinemaWithDistance in self.cinemaListWithDistance) {
            if ([cinemaWithDistance.cinema.cinema_id integerValue] == [[object cinema_id] integerValue]) {
                [self pushFilmListCinemaView: cinemaWithDistance];
                
                // send log to 123phim server
                [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:NSStringFromClass([CinemaFilmViewController class])
                                                                      comeFrom:delegate.currentView
                                                                  withActionID:ACTION_CINEMA_VIEW
                                                                 currentFilmID:[NSNumber numberWithInt:NO_FILM_ID]
                                                               currentCinemaID: cinemaWithDistance.cinema.cinema_id
                                                               returnCodeValue:0 context:nil];
                break;
            }
        }
        
    }
}


- (UIColor*) yourPositionColor
{
    return [UIColor colorWithWhite:0.0 alpha:1.0];
}

- (NSArray*)sortArray: (NSArray*)array
{
    NSArray* sortedArray = [NSArray arrayWithArray:[array sortedArrayUsingComparator:^(id obj1, id obj2) {
        if ([obj1 isKindOfClass:[CinemaWithDistance class]] && [obj2 isKindOfClass:[CinemaWithDistance class]]) {
            CinemaWithDistance* cinema1 = obj1;
            CinemaWithDistance* cinema2 = obj2;
            
            if (cinema1.distance < cinema2.distance) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            if (cinema1.distance > cinema2.distance) {
                return (NSComparisonResult)NSOrderedDescending;
            }
        }
        return (NSComparisonResult)NSOrderedSame;
        
    }]];
    return sortedArray;
}

#pragma mark - calculate Distance Cinema
-(void)layoutCinemaList
{
    [self reloadDataDistancenMyCinema];
    [self hideLoadingView];
}

- (void)reloadDataDistancenMyCinema
{
    BOOL locationOn = [APIManager getBooleanInAppForKey:KEY_STORE_IS_SHOW_MY_LOCATION];
    
    if (locationOn == YES && [AppDelegate isNetWorkValiable]) {
        //get distance from user current position -> city
        CLLocation* fromLocation = [[CLLocation alloc] initWithLatitude:self.yourPosition.positionCoodinate2D.latitude longitude:self.yourPosition.positionCoodinate2D.longitude];
        CLLocation* toLocation = [[CLLocation alloc] initWithLatitude:self.yourCity.latitude longitude:self.yourCity.longtitude];
        CGFloat distanceFromUserToCity = ([toLocation distanceFromLocation:fromLocation] / 1000)*1.3; // unit: km
        if (distanceFromUserToCity < MAX_DISTANCE_TO_CINEMA)
        {
            // phucph5
            distanceGetFromCurrentPos = YES;
            Location *location = [[Location alloc] init];
            location.latitude = self.yourPosition.positionCoodinate2D.latitude;
            location.longtitude = self.yourPosition.positionCoodinate2D.longitude;
            CinemaLocationCal *cal = [[CinemaLocationCal alloc] init];
            [cal getDistance:self.cinemaList withLocation:location context:self selector:@selector(getDistanceFinish:)];
            isNeedReloadCell = NO;
        }
        else
        {
            isNeedReloadCell = YES;
            strDes = TEXT_CASE1;
            [self loadCinemaListDefault];
        }
    }
    else
    {
        strDes = TEXT_CASE2;
        [self loadCinemaListDefault];
    }
}

- (void) loadCinemaListDefault
{
    distanceGetFromCurrentPos = NO;
    NSMutableArray* listTemp = [[NSMutableArray alloc] init];
    for (Cinema* theCinema in self.cinemaList)
    {
        CinemaWithDistance* cinema_distane = [[CinemaWithDistance alloc] init];
        cinema_distane.distance = [theCinema.distance floatValue];
        
        cinema_distane.cinema = theCinema;
        cinema_distane.driving_time = [theCinema.time_car integerValue];
        [listTemp addObject:cinema_distane];
    }
    self.cinemaListWithDistance = listTemp;//ENTRY
    listTemp = nil;
    //reload table
    //    [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO]; // do this on main thread to fixing bug show wrong data
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setArrayCinemaDistance:self.cinemaListWithDistance];
    
    [self reloadTableData];
    self.isLoadedCinemaComplete = YES;
}

- (void)getDistanceFinish:(NSMutableArray *)list
{
    
    if (list == nil)
    {
        // get distance failed
        [self loadCinemaListDefault];
        return;
    }
    self.cinemaListWithDistance = list;//ENTRY
    
    //set cinema list of delegate(with distance)
    AppDelegate  *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app performSelectorOnMainThread:@selector(setArrayCinemaDistance:) withObject:list waitUntilDone:YES];
    
    [self reloadTableData];
    self.isLoadedCinemaComplete = YES;
}

#pragma mark - ShowMapViewControlerDelegate
-(void)receiveLocationData:(Position*)locationData andMapStatusOfCenter:(CLLocationCoordinate2D)center andMapStatusOfSpan:(MKCoordinateSpan)span
{
    self.centerOfPositionChoiceMap = center;
    self.spanOfPositionChoiceMap = span;
}

-(void)pushFilmListCinemaView:(CinemaWithDistance *)cinemaWithDistance
{
    CinemaFilmViewController* cinemaFilm = [[CinemaFilmViewController alloc] initWithNibName:@"CinemaFilmTable" bundle:[NSBundle mainBundle]];
    cinemaFilm.curCinemaDistance = cinemaWithDistance;
    [cinemaFilm setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:cinemaFilm animated:YES];
}

#pragma mark Handle button

-(void) specifyYourPosition
{
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:NSStringFromClass([ShowMapViewController class])
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_MAP_VIEW
                                                     currentFilmID:[NSNumber numberWithInt:NO_FILM_ID]
                                                   currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID]
                                                   returnCodeValue:0 context:nil];
    
    ShowMapViewController* showMapViewController = [[ShowMapViewController alloc] init];
    showMapViewController.delegate = self;
    showMapViewController.mapCenterUserChoice = CLLocationCoordinate2DMake([AppDelegate getPresentPoint].latitude, [AppDelegate getPresentPoint].longitude);
    showMapViewController.mapSpanUserChoice = MKCoordinateSpanMake(0.01, 0.01);
    showMapViewController.cinemaListWithDistance = self.cinemaListWithDistance;
    [showMapViewController setTabBarDisplayType:TAB_BAR_DISPLAY_HIDE];
    [self.navigationController pushViewController: showMapViewController animated:YES];
}

- (void)choosenCity
{
    //    LOG_123PHIM(@"choosenCity");
    ChooseCityViewController* chooseCityViewController = [[ChooseCityViewController alloc] init];
    chooseCityViewController.chosenCity = self.yourCity;
    [chooseCityViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:chooseCityViewController animated:YES];
}

#pragma mark - handle selector
- (void)handleNewCity
{
    //    LOG_123PHIM(@"cinema handleNewCity");
    Location* newCity = [APIManager loadLocationObject];
    self.isLoadedCinemaComplete = NO;
    // set your chosen city
    [self.yourCity setLocationObject:newCity];
    //load cinemas for new city
    [NSFetchedResultsController deleteCacheWithName:@"cinema"];
    _fetchedResultsController = nil;
    isChangeNewCity = YES;
    //    [self loadDataForView];
    //    [self loadCinemaByLocationId:newCity.location_id];
    // update display position
    [self updateDisplayLocation];
    
}

- (void)loadCinemaByLocationId: (NSInteger)locationId
{
    //    [self.cinemaList performSelectorOnMainThread:@selector(removeAllObjects) withObject:nil waitUntilDone:YES];
    if ([AppDelegate isNetWorkValiable]) {
        [[APIManager sharedAPIManager] getListAllCinemaByLocation:locationId context:self];
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)newLocation:(CLLocation*)location address:(NSString*)address
{
    //update yourPosition
    self.yourPosition.positionCoodinate2D = location.coordinate;
    self.yourPosition.address = address;
    [self updateDisplayLocation];
    if (self.cinemaList.count > 0) {
        [self reloadDataDistancenMyCinema];
    }
}


#pragma mark Make Favourite cinema list and Not one
- (NSMutableArray*) orderCinemaListWithDistance:(NSMutableArray*)inArray
{
    NSArray* sortDescription = [NSArray getCinemaSortDescriptor];
    
    // split list booking and nonbooking
    NSMutableArray* cinemaBookingList = [[NSMutableArray alloc] init];
    NSMutableArray* cinemaUnbookingList = [[NSMutableArray alloc] init];
    for (int i = 0; i < inArray.count; i++) {
        CinemaWithDistance* cinema = [inArray objectAtIndex:i];
        if ([cinema.cinema.is_booking integerValue] == 1) {
            [cinemaBookingList addObject:cinema];
        }
        else
        {
            [cinemaUnbookingList addObject:cinema];
        }
    }
    numberCinemaFavorite = cinemaBookingList.count;//get number of favourite cinemas
    [cinemaBookingList sortUsingDescriptors:sortDescription];
    [cinemaUnbookingList sortUsingDescriptors:sortDescription];
    
    //merge
    for (int i = 0; i < cinemaUnbookingList.count; i++) {
        CinemaWithDistance* cinema = [cinemaUnbookingList objectAtIndex:i];
        [cinemaBookingList addObject:cinema];
    }
    
    return cinemaBookingList;
    
}

- (void)reloadTableData
{
    //order
    self.cinemaListWithDistance = [self orderCinemaListWithDistance:self.cinemaListWithDistance];
    
    // building datasource (should release cinemaListWithDistance later; For now, keep it for another screen)
    // clean datasource
    [self.datasource removeAllObjects];
    // location cell
    NSString *currentLocation = @"";
    NSString *address = @"";
    BOOL isLocationActive = NO;
    if ([APIManager getBooleanInAppForKey:KEY_STORE_IS_SHOW_MY_LOCATION] == YES && !isNeedReloadCell)
    {
        currentLocation = @"Vị trí hiện tại";
        address = self.yourPosition.address;
        isLocationActive = YES;
    }
    else {
        address = [NSString stringWithFormat:strDes, self.yourCity.center_name];
    }
    CinemaTableViewLocationItem *locationItem = [[CinemaTableViewLocationItem alloc] initWithTitle:currentLocation andAddress:address isActive:isLocationActive];
    [self.datasource addObject:[NSDictionary dictionaryWithObjectsAndKeys:@[locationItem], STRING_KEY_ITEMS, nil]];
    
    // favorite places
    NSInteger i = 0;
    NSMutableArray *favoritePlaces = [NSMutableArray array];
    NSMutableArray *places = [NSMutableArray array];
    for (; i < self.cinemaListWithDistance.count ; i++) {
        CinemaWithDistance* cinema_distance = [self.cinemaListWithDistance objectAtIndex:i];
        CinemaTableViewPlaceItem *item = [[CinemaTableViewPlaceItem alloc] initWithTitle:cinema_distance.cinema.cinema_name andAddress:cinema_distance.cinema.cinema_address];
        item.cinema_id = cinema_distance.cinema.cinema_id;
        item.isOnline = [cinema_distance.cinema.is_booking integerValue] == 1;
        item.isLike = [cinema_distance.cinema.is_cinema_favourite boolValue];
        CGFloat distance = cinema_distance.distance/1000;
        if( [self isDistanceFromYourPos] && distance < MIN_DISTANCE_TO_CINEMA )
        {
            item.youAreHere = YES;
        }
        if (cinema_distance.cinema.discount_type.intValue == ENUM_DISCOUNT_PERCENT)
        {
            item.discount = [NSString stringWithFormat:@"-%d%@", cinema_distance.cinema.discount_value.intValue,@"%"];
        }
        else if (cinema_distance.cinema.discount_type.intValue == ENUM_DISCOUNT_MONEY)
        {
            item.discount = [NSString stringWithFormat:@"-%dK", cinema_distance.cinema.discount_value.intValue/1000];
        }
        // distance
        
        NSString* distanceString = [NSString stringWithFormat:@"%.01f Km",distance];
        if (distance > 20.0)
        {
            item.distance = @"20+";
            item.estimateTimeBike = @"...";
            item.estimateTimeCar = @"...";
            
        }else{
            NSInteger timeCarMinutes = cinema_distance.driving_time/60;
            NSInteger timeCarHourPart = timeCarMinutes / 60;
            NSInteger timeCarMiniPart = timeCarMinutes % 60;
            
            NSInteger timeMotoMinutes = timeCarMinutes * 1.2;
            NSInteger timeMotoHourPart = timeMotoMinutes / 60;
            NSInteger timeMotoMiniPart = timeMotoMinutes % 60;
            
            item.distance = distanceString;
            item.estimateTimeBike = [NSString stringWithFormat:@"%@ %@", (timeMotoHourPart > 0?([NSString stringWithFormat:@"%d giờ", timeMotoHourPart]):(@"")), (timeMotoMiniPart > 0?([NSString stringWithFormat:@"%d phút", timeMotoMiniPart]):(@"1 phút"))];
            item.estimateTimeCar = [NSString stringWithFormat:@"%@ %@", (timeCarHourPart > 0?([NSString stringWithFormat:@"%d giờ", timeCarHourPart]):(@"")), (timeCarMiniPart > 0?([NSString stringWithFormat:@"%d phút", timeCarMiniPart]):(@"1 phút"))];
        }
        
        // add to array
        if (i < numberCinemaFavorite) {
            [favoritePlaces addObject:item];
        }
        else {
            [places addObject:item];
        }
        
    }
    
    // add to datasource
    if (favoritePlaces.count > 0) {
        [self.datasource addObject:[NSDictionary dictionaryWithObjectsAndKeys:TITLE_SUPPORT_BUY_TICKET_ONLINE_123PHIM, STRING_KEY_SECTION_TITLE, favoritePlaces, STRING_KEY_ITEMS, nil]];
    }
    if (places.count > 0) {
        [self.datasource addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Rạp xung quanh", STRING_KEY_SECTION_TITLE, places, STRING_KEY_ITEMS, nil]];
    }
    
    [self.tableView reloadData];
}

- (BOOL)isDistanceFromYourPos
{
    BOOL ret = YES;
    
    BOOL locationOn = [APIManager getBooleanInAppForKey:KEY_STORE_IS_SHOW_MY_LOCATION];
    if (locationOn == YES) {
        //get distance from user current position -> city
        CLLocation* fromLocation = [[CLLocation alloc] initWithLatitude:self.yourPosition.positionCoodinate2D.latitude longitude:self.yourPosition.positionCoodinate2D.longitude];
        CLLocation* toLocation = [[CLLocation alloc] initWithLatitude:self.yourCity.latitude longitude:self.yourCity.longtitude];
        CGFloat distanceFromUserToCity = ([toLocation distanceFromLocation:fromLocation] / 1000)*1.3; // unit: km
        if (distanceFromUserToCity >= MAX_DISTANCE_TO_CINEMA)
        {
            ret = NO;
        }
    }else{
        ret = NO;
    }
    
    return ret;
    
}

- (void)updateDisplayLocation
{
    if ([self isDistanceFromYourPos]) {
        self.displayLocation.positionCoodinate2D = self.yourPosition.positionCoodinate2D;
        self.displayLocation.address = self.yourPosition.address;
    }else{
        self.displayLocation.positionCoodinate2D = CLLocationCoordinate2DMake(self.yourCity.latitude, self.yourCity.longtitude);
        self.displayLocation.address = self.yourCity.center_name;
    }
    [AppDelegate setPresentPoint: self.displayLocation.positionCoodinate2D];
}

- (UIColor*) color
{
    return [UIColor grayColor];
}

@end
