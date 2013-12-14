//
//  AppDelegate.m
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/5/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#define DYNAMIC_VIEW_OBJECT_PROPERTIES @"object_properties"
#define DYNAMIC_VIEW_OBJECT_NAME @"object_name"
#define DYNAMIC_VIEW_OBJECT_GETTER @"object_getter"
#define DYNAMIC_VIEW_OBJECT_IS_DB_ENTITY @"is_db_entity"

#import "AppDelegate.h"
#import "MainViewController.h"
#import "CinemaViewController.h"
#import "AccountViewController.h"
#import "PromotionViewController.h"
#import "APIManager.h"
#import "FacebookManager.h"
#import "WelcomeViewController.h"
#import "GAI.h"
#import "VersionNotificationViewController.h"
#import "UIDevice+IdentifierAddition.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "CheckoutResultViewController.h"
#import "GoogleConversionPing.h"
#import "FavoriteButton.h"
#import "URLParser.h"
#import "FilmCinemaViewController.h"
#import "AutoScrollLabel.h" 
#import "Ticket.h"
#import "Comment.h"
#import "SeatInfo.h"
#import "ConfirmInputViewController.h"
#import "RKXMLReaderSerialization.h"

@implementation AppDelegate

static bool isNetworkAvailable = NO;
static int iMyLocation = 1;
static bool iCurrentPostionON = YES;
static  CLLocationCoordinate2D presentPoint;
static NSDate *startTime;
UpdateLocationType updateLocationFrom = UpdateLocationTypeAuto;
NSTimeInterval lastTimeSentLocationToServer;
double lastSentLat = 0;
double lastSentLog = 0;

@synthesize userPosition, locationManager;

@synthesize window = _window;
@synthesize navCinema, navUser,activityIndicator,userProfile, currentView;
@synthesize arrayCinema,arrayCinemaDistance,arrayFilmComing,arrayFilmShowing,arrayFilmFavorite;
@synthesize Invoice_No, ticket_code, email, phone, _SmartlinkOrderId, _SmartlinkSessionId;
//using for thanhToan
@synthesize _Amount;
//object dictionary for text define 
@synthesize dicObjectText;
@synthesize icountTryRequestTransaction;
@synthesize requestAppRating = _requestAppRating;
@synthesize updatedFavouriteFilmList = _updatedFavouriteFilmList;
@synthesize dictCinemaGroup = _dictCinemaGroup;

#pragma mark static function and for share resource all application
+(NSDate *)getStartTime
{
    return startTime;
}

+(CLLocationCoordinate2D)getPresentPoint
{
    return presentPoint;
}

+(void)setPresentPoint:(CLLocationCoordinate2D)point
{
    presentPoint = point;
}

+(void)resetStartTime
{
    if(startTime)
    {
        startTime = nil;
    }
    startTime = [NSDate date];
}

+(BOOL) isNetWorkValiable
{
    return  isNetworkAvailable;
}

+(void)setNetWorkValiable:(BOOL)on
{
    isNetworkAvailable = on;
}

+(int) getMyLocationId
{
    return iMyLocation;
}

+(void) setMyLocationId:(int)locationId
{
    iMyLocation = locationId;
}

+(void) setCurrentPostionON: (bool)on
{
    iCurrentPostionON = on;
}

+(bool) getCurrentPostionON
{
    return iCurrentPostionON;
}

+(NSString *)getVersionOfApplication
{
    NSString* versionNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (versionNum.length < 4) {
        return versionNum;
    }
    NSString* tmp = [versionNum substringWithRange:NSMakeRange([versionNum length]-3, 3)];
    return tmp;
//    NSString* tmp = [versionNum substringWithRange:NSMakeRange(0, 3)];
//    return tmp;
}

#pragma mark process update, access list object
-(void)initVariableList
{
    if(arrayFilmComing == nil)
    {
        arrayFilmComing = [[NSMutableArray alloc] init];
    }
    if(arrayFilmShowing == nil)
    {
        arrayFilmShowing = [[NSMutableArray alloc] init];
    }
    if(arrayCinemaDistance == nil)
    {
        arrayCinemaDistance = [[NSMutableArray alloc] init];
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(cinemaWithDistanceDidLoad:) name:NOTIFICATION_NAME_CINEMA_WITH_DISTANCE_DID_LOAD object:nil];
    [center addObserver:self selector:@selector(filmListDidLoad:) name:NOTIFICATION_NAME_FILM_LIST_DID_LOAD object:nil];
    [center addObserver:self selector:@selector(promotionListDidLoad:) name:NOTIFICATION_NAME_PROMOTION_LIST_DID_LOAD object:nil];
}

-(int)getIndexOfCinemaInArrayCinemaDistance:(int)cinema_id
{
    if (self.arrayCinemaDistance != nil && [self.arrayCinemaDistance count] > 0) {
        for (int i = 0; i < [self.arrayCinemaDistance count]; i++) {
            CinemaWithDistance *cur = [self.arrayCinemaDistance objectAtIndex:i];
            if ([cur.cinema.cinema_id intValue] == cinema_id) {
                return i;
            }
        }
    }
    return -1;
}


-(Film *)getFilmWithID:(NSNumber *)filmID
{
    for (Film *film in arrayFilmShowing) {
        if (film.film_id.intValue == filmID.intValue) {
            return film;
        }
    }
    for (Film *film in arrayFilmComing) {
        if (film.film_id.intValue == filmID.intValue) {
            return film;
        }
    }
    return nil;
}

- (Film*)getPreviousFilmInFilmArrayOfFilmId:(int)filmId withStatus:(int)filmStatus
{
    NSMutableArray* filmArray = nil;
    
    if (filmStatus == ID_REQUEST_FILM_LIST_SHOWING) {
        filmArray = self.arrayFilmShowing;
 
    }else if (filmStatus == ID_REQUEST_FILM_LIST_COMMING){
        filmArray = self.arrayFilmComing;
    
    }else{}

    if (filmArray.count > 0) {
        for (int i=0; i<filmArray.count; i++) {
            Film* findFilm = [filmArray objectAtIndex:i];
            if ([findFilm.film_id intValue] == filmId) {
                return [filmArray objectAtIndex:--i];
            }
        }
    }    
    return nil;
}

- (Film*)getPreviousFavoriteFilmInFilmArrayOfFilmId:(int)filmId
{
    if (self.arrayFilmFavorite.count > 0) {
        for (int i=0; i<self.arrayFilmFavorite.count; i++) {
            Film* findFilm = [self.arrayFilmFavorite objectAtIndex:i];
            if ([findFilm.film_id intValue] == filmId) {
                    return [self.arrayFilmFavorite objectAtIndex:--i];                   
            }
        }    
    }
    return nil;
}

-(Film *)getNextFilmInFilmArrayOfFilmId:(int)film_id withStatus:(int)filmStatus
{
    if (filmStatus == ID_REQUEST_FILM_LIST_SHOWING) {
        if (self.arrayFilmShowing != nil && [self.arrayFilmShowing count] > 0) {
            for (int i = 0; i < [self.arrayFilmShowing count]; i++) {
                Film *cur = [self.arrayFilmShowing objectAtIndex:i];
                if ([cur.film_id intValue] == film_id)
                {
                    if (i == (self.arrayFilmShowing.count - 1)) {
                        return [self.arrayFilmShowing objectAtIndex:0];
                    }
                    return [self.arrayFilmShowing objectAtIndex:(i+1)];
                }
            }
            
        }
    } else {
        if (self.arrayFilmComing != nil && [self.arrayFilmComing count] > 0) {
            for (int i = 0; i < [self.arrayFilmComing count]; i++) {
                Film *cur = [self.arrayFilmComing objectAtIndex:i];
                if ([cur.film_id intValue] == film_id)
                {
                    if (i == (self.arrayFilmComing.count - 1)) {
                        return [self.arrayFilmComing objectAtIndex:0];
                    }
                    return [self.arrayFilmComing objectAtIndex:(i+1)];
                }
            }

        }
    }
    return nil;
}

-(Film*)getNextFilmInFavoutiteFilmArrayOfFilmId:(int)film_id
{
    for (int i = 0; i < [self.arrayFilmFavorite count]; i++) {
        LOG_123PHIM(@"%@", ((Film*)[self.arrayFilmFavorite objectAtIndex:i]).film_name);
        if (film_id == [((Film*)[self.arrayFilmFavorite objectAtIndex:i]).film_id intValue]) {
            return [self.arrayFilmFavorite objectAtIndex:(i == ([self.arrayFilmFavorite count] - 1)?0:++i)];
        }
    }
    return nil;
}

-(Cinema *)getCinemaWithID:(NSNumber *)cinemaID
{
    for (Cinema *cinema in self.arrayCinema) {
        if (cinema.cinema_id.integerValue == cinemaID.integerValue)
        {
            return cinema;
        }
    }
    return nil;
}

-(CinemaWithDistance *)getCinemaWithDistanceWithCinemaID:(NSNumber *)cinemaID
{
    for (CinemaWithDistance *cinema in self.arrayCinemaDistance) {
        if (cinema.cinema.cinema_id.integerValue == cinemaID.integerValue)
        {
            return cinema;
        }
    }
    return nil;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    if (arrayFilmFavorite) {
        [arrayFilmFavorite removeAllObjects];
    }
    [activityIndicator stopAnimating];
    dicLocalNotification = nil;
}
#pragma mark - Create custom NavigationBar
-(void)setBackGroundImage:(NSString *) linkImage forNavigationBar:(UINavigationBar *)naviBar
{
    UIImage *img=[UIImage imageNamed:linkImage];
    if (img != nil) {
        float version=[[[UIDevice currentDevice]systemVersion]floatValue];
        if (version>=5.0) {
            [naviBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
        }else{
            [naviBar insertSubview:[[UIImageView alloc] initWithImage:img] atIndex:0];
        }
        naviBar.layer.shadowOffset=CGSizeMake(0, 2);
        naviBar.layer.shadowRadius=5;
        naviBar.layer.shadowOpacity=0.5;
    }
}

-(void)setTitleLabelForNavigationController:(UIViewController *)viewController  withTitle:(NSString *)title
{
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"header-button-go-back" ofType:@"png"];
    UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
    CGSize size = [title sizeWithFont:[UIFont getFontBoldSize14]];
    int h =  size.height;
    int w = viewController.view.frame.size.width;
    CGFloat xOffsetLeft = 0;
    CGFloat xOffsetRight = 0;
    if (viewController.navigationItem.leftBarButtonItem != nil) {
        w -= prodImg.size.width;
        xOffsetLeft = 2*MARGIN_EDGE_TABLE_GROUP;
    }
    if (viewController.navigationItem.rightBarButtonItem != nil) {
        w -= prodImg.size.width;
        xOffsetRight = 2*MARGIN_EDGE_TABLE_GROUP;
    }
    CGRect frameSroll = CGRectMake((viewController.view.frame.size.width - size.width)/2 - xOffsetLeft + xOffsetRight, 0, w - xOffsetLeft + xOffsetRight, h);
    AutoScrollLabel *autoLable=[[AutoScrollLabel alloc] init];
    [autoLable setFrame:frameSroll];
    autoLable.backgroundColor=[UIColor clearColor];
    autoLable.font=[UIFont getFontBoldSize14];
    autoLable.textColor = [UIColor colorWithWhite:255 alpha:0.9f];
    autoLable.text = title;
//    autoLable.backgroundColor = [UIColor redColor];
    autoLable.textAlignment = UITextAlignmentCenter;
    autoLable.tag = TAG_AUTO_SCROLL_LABEL;
    [autoLable setAlignmentForText:UITextAlignmentCenter];
    [viewController.navigationItem.titleView setBackgroundColor:[UIColor redColor]];
    [viewController.navigationItem.titleView setContentMode:UIViewContentModeCenter];
    viewController.navigationItem.titleView = autoLable;
}

-(void)updateTitle:(NSString *)title forViewController:(UIViewController *)viewController
{
    if (!viewController) {
        return;
    }
    UIView *curView = [viewController.navigationItem.titleView viewWithTag:TAG_AUTO_SCROLL_LABEL];
    if([curView isKindOfClass:[AutoScrollLabel class]])
    {
        [(AutoScrollLabel *)curView setText:title];
    }
}

#pragma mark Custom Button for NavigationBar
-(void)setCustomBackButtonForNavigationItem:(UINavigationItem *) navigationItem
{
    UIImage *imageLeft = [UIImage imageNamed:@"header-button-go-back.png"];
    UIButton *customButtonL = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0, 0, imageLeft.size.width, imageLeft.size.height);
    customButtonL.frame = frame;    
    [customButtonL setBackgroundImage:imageLeft forState:UIControlStateNormal];
    [customButtonL addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnleft = [[UIBarButtonItem alloc] initWithCustomView:customButtonL];
    navigationItem.leftBarButtonItem = btnleft;
}

-(void) popViewController
{
    UINavigationController *currentNavigationView = (UINavigationController *)[self.tabBarController selectedViewController] ;
    UIViewController *vc = [currentNavigationView.viewControllers lastObject];
    if ([vc respondsToSelector:@selector(willPopViewController)])
    {
        [vc performSelector:@selector(willPopViewController)];
    }
    if ([vc respondsToSelector:@selector(popToViewController)])
    {
        [vc performSelector:@selector(popToViewController)];
    }
    else
    {
        [currentNavigationView popViewControllerAnimated:YES];
    }
}

- (void) popToViewController:(Class)viewController_ animated:(BOOL)animated_
{
    self._TransactionID = @"";
    UINavigationController* navi = (UINavigationController*)[self.tabBarController selectedViewController];
    BOOL popped = NO;
    for (id item in navi.viewControllers) {
        if ([item isMemberOfClass:viewController_]) {
            if ([item respondsToSelector:@selector(willPopViewController)])
            {
                [item performSelector:@selector(willPopViewController)];
            }
            [navi popToViewController:item animated:animated_];
            popped = YES;
        }
    }
    if (!popped)
    {
        [navi popToRootViewControllerAnimated:animated_];
    }
}

#pragma mark life circle of application
-(void) checkLoadDataUser
{
    Location *myLocation = (Location *)[APIManager loadLocationObject];
    if (myLocation != nil)
    {
        [AppDelegate setMyLocationId:myLocation.location_id];
        [[CinemaViewController sharedCinemaViewController].yourCity setLocationObject:myLocation];
        myLocation = nil;
    }
    else
    {
        Location *locDefault = [[Location alloc] init];
        locDefault.location_id = 1;
        locDefault.location_name = @"Hồ Chí Minh";
        locDefault.latitude    = 10.771928;
        locDefault.longtitude   = 106.698328;
        locDefault.center_name = @"Chợ Bến Thành";
        [APIManager saveLocationObject:locDefault];
        [[CinemaViewController sharedCinemaViewController].yourCity setLocationObject:locDefault];
        locDefault = nil;
    }
//    [[CinemaViewController sharedCinemaViewController] setIsChoosedCityOptional:YES];
    [self cleanDataIfNeed];
    
    //set flag to set status of thanh toan
    [self checkAndDisableWarningWhenTimeOut];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return YES;
}

- (void)setupReskit123Phim
{
    //let AFNetworking manage the activity indicator
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;    
    // Initialize RestKit
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:BASE_URL_SERVER]];//[[RKObjectManager alloc] initWithHTTPClient:client];
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    manager.managedObjectStore = managedObjectStore;
    
    /**
     Complete Core Data stack initialization
     */
    [managedObjectStore createPersistentStoreCoordinator];
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"CoreDataMovie.sqlite"];
    NSError *error;
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil  withConfiguration:nil options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    // Create the managed object contexts
    [managedObjectStore createManagedObjectContexts];
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"text/html"];
    [[RKObjectManager sharedManager] setAcceptHeaderWithMIMEType:@"text/html"];
    
    [[RKObjectManager sharedManager] addFetchRequestBlock:^NSFetchRequest *(NSURL *URL)
     {
         RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:BASE_URL_SERVER];
         NSDictionary *filmDict = nil;
         BOOL match = [pathMatcher matchesPath:BASE_URL_SERVER tokenizeQueryStrings:NO parsedArguments:&filmDict];
         if (match) {
             RKResponseDescriptor *currentResponse = nil;
             if (![RKObjectManager sharedManager].responseDescriptors || [RKObjectManager sharedManager].responseDescriptors.count == 0) {
                 return nil;
             }
             currentResponse = [RKObjectManager sharedManager].responseDescriptors[0];
             if (!currentResponse || ![currentResponse.mapping isKindOfClass:[RKEntityMapping class]]) {
                 return nil;
             }
             if ([[(RKEntityMapping *)currentResponse.mapping entity].name isEqualToString:NSStringFromClass([Comment class])]) {
                 return nil;
             }
//             NSLog(@"----gia tri name cua entity = %@---",[(RKEntityMapping *)currentResponse.mapping entity].name);             
             NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
             NSEntityDescription *entity = [NSEntityDescription entityForName:[(RKEntityMapping *)currentResponse.mapping entity].name inManagedObjectContext:[RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext];
             [fetchRequest setEntity:entity];
             return fetchRequest;
         }
         
         return nil;
     }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    #ifdef DEBUG
        [Crittercism enableWithAppID:@"529c35b78b2e33351a000008"]; //Dev
    #else
        [Crittercism enableWithAppID:@"52a67e17558d6a242700000b"]; // Pro
    #endif
    [[APIManager sharedAPIManager] setWasSendLogin:NO];
    
    if(IS_NEED_OVERRIDE_DATABASE)
    {
        [self replaceDatabase];
    }
    [self setupReskit123Phim];
    // init cache and clear mem
    [[SDWebImageManager sharedManagerWithCachePath:CACHE_IMAGE_PATH] setCacheKeyFilter:^NSString *(NSURL *url) {
        if ([url isKindOfClass:[NSURL class]])
        {
            return [url absoluteString];
        }
        return (NSString *)url;
    }];
    
    #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    
    //Tranking Conversion only support ios 6.0 or later
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
    {
        [GoogleConversionPing pingWithConversionId:@"983463027" label:@"FaebCO3VswUQ8-j51AM" value:@"5000" isRepeatable:NO idfaOnly:YES];
    }
    
    #pragma GCC diagnostic warning "-Wdeprecated-declarations"
    
//    LOG_123PHIM(@"didFinishLaunchingWithOptions");
#if IS_DEBUG_LOG_MEM
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(logMemory) userInfo:nil repeats:YES];
#endif
    
    //set ON for get User Location default
    [APIManager setBooleanInApp:YES ForKey:KEY_STORE_IS_SHOW_MY_LOCATION];
    
//    increase number òf lapp leanching
    NSInteger number = [[APIManager getValueForKey:KEY_STORE_NUMBER_APP_LAUNCHING] integerValue];
    if (number >= 0)
    {
        number++;
        if (number >= [NUMBER_TO_REQUEST_RATING_APP integerValue])
        {
            _requestAppRating = YES;
            number = 0;
        }
        [APIManager setValueForKey:[NSNumber numberWithInteger:number] ForKey:KEY_STORE_NUMBER_APP_LAUNCHING];
    }
    
    //init lastTimeSentLocationToServer
    lastTimeSentLocationToServer = [NSDate timeIntervalSinceReferenceDate] - (INTERVAL_BETWEEN_TWO_SEND_USER_LOCATION_TO_SERVER+20);
    
    // init location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 100.0f;
    userPosition = [[Position alloc] init];
    
    // update location
    if ([APIManager getBooleanInAppForKey:KEY_STORE_IS_SHOW_MY_LOCATION]) {
        [self updateUserLocationWithType:UpdateLocationTypeAuto];
    }
    
    if (IS_GA_ENABLE) {
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        [GAI sharedInstance].dispatchInterval = 20;
        [GAI sharedInstance].debug = !YES;
        id ga = [[GAI sharedInstance] trackerWithTrackingId:GA_TRACKING_ID];
        [ga setAppVersion:[AppDelegate getVersionOfApplication]];
        [GAI sharedInstance].defaultTracker = ga;
    }

    currentView = @"new_load";
    
    [self initResourceToCheckNetWork];
    [self checkLoadDataUser];

    CGRect frameWindow = [[UIScreen mainScreen]bounds];
    self.window=[[UIWindow alloc]initWithFrame:frameWindow];
    
    NSString *strBG = @"header-bar-ios7.png";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        strBG = @"header-bar.png";
    }
    
    CinemaViewController* cinemaViewController = [CinemaViewController sharedCinemaViewController];
    navCinema=[[UINavigationController alloc]initWithRootViewController:cinemaViewController];
    [self setBackGroundImage:strBG forNavigationBar:navCinema.navigationBar];

    self.tabBarController=[[UITabBarController alloc] init];
    CGRect frame = self.tabBarController.tabBar.frame;
    frame.origin.y += frame.size.height - NAVIGATION_BAR_HEIGHT;
    frame.size.height = NAVIGATION_BAR_HEIGHT;
    self.tabBarController.tabBar.frame = frame;
  
    MainViewController *mainViewController = [MainViewController sharedMainViewController];
    UINavigationController *navMain = [[UINavigationController alloc]initWithRootViewController:mainViewController];
    [self setBackGroundImage:strBG forNavigationBar:navMain.navigationBar];
    
    PromotionViewController *promotionViewController = [PromotionViewController sharedPromotionViewController];
    UINavigationController *navPromotion = [[UINavigationController alloc]initWithRootViewController:promotionViewController];
    [self setBackGroundImage:strBG forNavigationBar:navPromotion.navigationBar];
    
    AccountViewController *accountView=[[AccountViewController alloc] init];
    navUser=[[UINavigationController alloc]initWithRootViewController:accountView];
    [self setBackGroundImage:strBG forNavigationBar:navUser.navigationBar];
    
    NSArray *arrTab=[[NSArray alloc]initWithObjects:navCinema,navMain,navPromotion,navUser, nil];
    self.tabBarController.viewControllers=arrTab;
    [self.tabBarController.view setFrame:CGRectZero];

    [self.tabBarController.tabBar setBackgroundColor:[UIColor redColor]];
    
    [self.tabBarController.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"footer-bar-active.png"]];
    [self.tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"footer-bar.png"]];
    self.tabBarController.selectedIndex=1;
    [self updateAppWithNewState: APP_STATE_INIT];
    
    [self.window makeKeyAndVisible];
    //xu ly khi nguoi dung mo = notification o day
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        // Show Alert Here
        if (dicLocalNotification) {
            dicLocalNotification = nil;
        }
        dicLocalNotification = localNotif.userInfo;
       // LOG_123PHIM(@"----gia tri object = %@---", dicLocalNotification);
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self saveFavouriteFilmList];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//    LOG_123PHIM(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    LOG_123PHIM(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if ([APIManager getBooleanInAppForKey:KEY_STORE_IS_SHOW_MY_LOCATION]) {
        [self updateUserLocationWithType:UpdateLocationTypeAuto];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[FBSession activeSession] closeAndClearTokenInformation];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    // Send device token to the Provider
    NSString *tokenStr=[deviceToken description];
    NSString *pushToken=[[[tokenStr stringByReplacingOccurrencesOfString:@">" withString:@""]stringByReplacingOccurrencesOfString:@"<" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
//    LOG_123PHIM(@"--------------device token = %@", pushToken);
    NSString *deviceLocal = [APIManager getStringInAppForKey:KEY_STORE_MY_DEVICE_TOKEN];
    if (![pushToken isEqualToString:deviceLocal]) {
        [[APIManager sharedAPIManager] postUIID:[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] andDeviceToken:pushToken context:[MainViewController sharedMainViewController]];
        [APIManager setStringInApp:pushToken ForKey:KEY_STORE_MY_DEVICE_TOKEN];
    }
    [self generateAccessTokenForData:pushToken];
}

- (void)generateAccessTokenForData:(NSString *)pushToken
{
    NSMutableString *pass = [[NSMutableString alloc] initWithString:[NSString stringWithoutCharacterFrom:pushToken]];
    [pass stringByAppendingString:[pushToken substringToIndex:GA_TRACKING_ID.length]];
    [pass deleteCharactersInRange:NSMakeRange(KEY_STORE_MY_USER_ID.length, GA_TRACKING_ID.length)];
    [pass stringByAppendingString:[[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] substringToIndex:KEY_STORE_MY_USER_ID.length]];
    [[APIManager sharedAPIManager] setAccessTokenKey:pass];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	LOG_123PHIM(@"Failed to get token, error: %@", error.localizedDescription);    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Show Alert Here
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];	
	application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
    
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//    // Show Alert Here
    if (dicLocalNotification) {
        dicLocalNotification = nil;
    }
    dicLocalNotification = notification.userInfo;
    [self processActionPostLocalNotification];
}

- (void) processActionPostLocalNotification
{
    UIViewController *currentViewController = [self getCurrentViewController];
    if (!dicLocalNotification || !currentViewController || [currentViewController isKindOfClass:
    [ConfirmInputViewController class]]
)
    {
        return;
    }
    id status = [APIManager getValueForKey:KEY_STORE_STATUS_THANH_TOAN];
    if (!status && ![status isKindOfClass:[NSNumber class]])
    {
        return;
    }
    if ([status intValue] == STATUS_WAITING_INPUT_OTP) {
        [self processPushVerifyOTPViewController];
    }
}

- (void)checkAndDisableWarningWhenTimeOut
{
    id status = [APIManager getValueForKey:KEY_STORE_STATUS_THANH_TOAN];
    if (!status && ![status isKindOfClass:[NSNumber class]])
    {
        return;
    }
    if ([status intValue] != STATUS_WAITING_INPUT_OTP) {
        return;
    }
    
    NSDictionary *dicThanhToan = [APIManager getValueForKey:KEY_STORE_INFO_THANH_TOAN];
    if (!dicThanhToan || ![dicThanhToan isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    NSNumber *buyingDate = [dicThanhToan objectForKey:DICT_KEY_DATE_BUYING];
    if (buyingDate)
    {
        double timeBuy = [buyingDate doubleValue];
        double timeCurrent = [NSDate timeIntervalSinceReferenceDate];
        double distanceTime = timeCurrent - timeBuy;
        if (distanceTime > [MAX_TIME_WAITING_INPUT_OTP intValue]) {
            [self checkAndSendCleanWarning];
        } else {
          [self performSelector:@selector(checkAndSendCleanWarning) withObject:nil afterDelay:(distanceTime + 2)];
        }
    }
}

- (void)checkAndSendCleanWarning
{
    UIViewController *currentViewController = [self getCurrentViewController];
    if ([currentViewController isKindOfClass:[CustomGAITrackedViewController class]])
    {
        [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_OUT_RANGE] ForKey:KEY_STORE_STATUS_THANH_TOAN];
        [(CustomGAITrackedViewController *)currentViewController cleanWarning];
        
        NSDictionary *dicThanhToan = [APIManager getValueForKey:KEY_STORE_INFO_THANH_TOAN];
        if (dicThanhToan &&[dicThanhToan isKindOfClass:[NSDictionary class]])
        {
            [APIManager deleteObjectForKey:KEY_STORE_INFO_THANH_TOAN];
            [self showAlert:ALERT_TITLE content:NOTICE_ABORT_INPUT_OTP_TIME_OUT];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkAndSendCleanWarning) object:nil];
        return;
    }
    else
    {
        [self performSelector:@selector(checkAndSendCleanWarning) withObject:nil afterDelay:[MAX_TIME_WAITING_INPUT_OTP intValue]/5];
    }
}

-(void)pushViewControllerAccordingToStatus
{
    UIViewController *currentViewController = [self getCurrentViewController];
    NSDictionary *dicThanhToan = [APIManager getValueForKey:KEY_STORE_INFO_THANH_TOAN];
    if (!dicThanhToan || ![dicThanhToan isKindOfClass:[NSDictionary class]] || [currentViewController isKindOfClass:[CheckoutResultViewController class]])
    {
        return;
    }
    
    NSDictionary *buyDic = [dicThanhToan objectForKey:DICT_KEY_BUY_INFO];
    if (!buyDic || buyDic.count == 0 || ![buyDic isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    BuyingInfo *buyInfo = [[BuyingInfo alloc] initWithDictionary:buyDic];
    //push view ticket
    [self pushCheckOutResultViewController:buyInfo];
}

-(void)pushCheckOutResultViewController:(BuyingInfo *)buyInfo
{
    UIViewController *currentViewController = [self getCurrentViewController];
    CheckoutResultViewController *resultSucessViewController = [[CheckoutResultViewController alloc] init];
    [resultSucessViewController setBuyInfo:buyInfo];
    [currentViewController.navigationController pushViewController:resultSucessViewController animated:YES];
}

-(void)pushConfirmViewControllerWithBuyingInfo:(BuyingInfo *)buyInfo bankInfo:(BankInfo *)bankInfo bankData:(NSDictionary *)bankData
{
    UIViewController *currentViewController = [self getCurrentViewController];
    ConfirmInputViewController *vcConfirm = [[ConfirmInputViewController alloc] init];
    [vcConfirm setCanCancelTransaction:YES];
    [vcConfirm setBuyInfo:buyInfo];
    [vcConfirm setBankData:bankData];
    [vcConfirm setBankInfo:bankInfo];
    [currentViewController.navigationController pushViewController:vcConfirm animated:YES];
}

-(void)pushVerifyOTPFromPendingOnApp
{
    if (dicLocalNotification) {
        dicLocalNotification = nil;
    }
    dicLocalNotification = [APIManager getValueForKey:KEY_STORE_INFO_THANH_TOAN];
    if (!dicLocalNotification || ![dicLocalNotification isKindOfClass:[NSDictionary class]]) {
        return;
    }
    [self processPushVerifyOTPViewController];
}

- (void) processPushVerifyOTPViewController
{
    UIViewController *currentViewController = [self getCurrentViewController];
    if (!dicLocalNotification || !currentViewController || [currentViewController isKindOfClass:[ConfirmInputViewController class]]) {
        return;
    }
    NSDictionary *dict = [APIManager getValueForKey:KEY_STORE_INFO_THANH_TOAN];
    NSDictionary *dictBank = [dict objectForKey:DICT_KEY_BANK_INFO];
    BankInfo *bankInfo = [[BankInfo alloc] initWithDictionary:dictBank];
    NSDictionary *dictBuyInfo = [dict objectForKey:DICT_KEY_BUY_INFO];
    BuyingInfo *buyingInfo = [[BuyingInfo alloc] initWithDictionary:dictBuyInfo];
    NSDictionary *bankData = [APIManager decryptDictionaryWithDictionary:[dict objectForKey:DICT_KEY_BANK_DATA]];
    [self pushConfirmViewControllerWithBuyingInfo:buyingInfo bankInfo:bankInfo bankData: bankData];
}
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
//    return [[NSBundle mainBundle] resourceURL];
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(NSMutableArray *)fetchRecords:(NSString *)entityName sortWithKey:(NSString *)keyName withPredicate:(NSPredicate *)predicate
{
    return [self fetchRecords:entityName sortWithKey:keyName ascending:YES withPredicate:predicate];
}

-(NSMutableArray *)fetchRecords:(NSString *)entityName sortWithKey:(NSString *)keyName ascending:(BOOL)isAscending withPredicate:(NSPredicate *)predicate
{
    //Define out table/entity to use
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
    
    //setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    //Create predicate (contraint dieu kien de lay du lieu)
    if (predicate) {
        [request setPredicate:predicate];
    }
    
    //Define how we will sort the records
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:keyName ascending:isAscending];
    NSArray *sortArray = [NSArray arrayWithObject:sortDescriptor];
    
    [request setSortDescriptors:sortArray];
    
    //Fetch the records and handle an error
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if (!mutableFetchResults) {
        //Handle error here
    }
    
    return  mutableFetchResults;
}

-(NSManagedObject *)getManageObject:(NSString *)entityName withPredicate:(NSPredicate *)predicate
{
    //Define out table/entity to use
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
    
    //setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    //Create predicate (contraint dieu kien de lay du lieu)
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"location_id = 2"];
    if (predicate) {
        [request setPredicate:predicate];
    }
    //Fetch the records and handle an error
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if (!mutableFetchResults) {
        //Handle error here
    }
    
    if (mutableFetchResults != nil && [mutableFetchResults count] > 0) {
        return  [mutableFetchResults objectAtIndex:0];
    }
    return nil;
}

-(void)deleteAllRecordsInTable:(NSString *)tableName sortWithKey:(NSString *)keyName
{
    NSMutableArray *filmArray = [self fetchRecords:tableName sortWithKey:keyName withPredicate:nil];
    for (NSManagedObject *manageObject in filmArray) {
        [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext deleteObject:manageObject];
    }
    [NSThread sleepForTimeInterval:0.5];
    // Commit the change.
    NSError *error;    
    if (![[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext save:&error]) {
        // Handle the error.
        LOG_123PHIM(@"Save error = %@", error.description);
    }
}

-(void) saveRecordInTable: (NSString *)tableName sortWithKey:(NSString *)keyName
{
    NSMutableArray *filmArray = [self fetchRecords:tableName sortWithKey:keyName withPredicate:nil];
    for (NSManagedObject *manageObject in filmArray) {
        [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext deleteObject:manageObject];
    }
    [NSThread sleepForTimeInterval:0.5];
    // Commit the change.
    
//    self.managedObjectContext objectRegisteredForID:<#(NSManagedObjectID *)#>
    NSError *error;
    if (![[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext save:&error])
    {
        // Handle the error.
        LOG_123PHIM(@"Save error = %@", error.description);
    }
}

#pragma mark check network connect

- (void)networkConnectionChanged:(NSNotification*)obj
{
    isNetworkAvailable = [self checkNetWork];
}

- (void) updateInterfaceWithReachability
{
    [self showLoadingViewWithType:LOADING_TYPE_FULLSCREEN viewOnTop:nil];
    if (!isNetworkAvailable)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Không thể kết nối Internet. Vui lòng kiểm tra trong mục Cài đặt." delegate:self cancelButtonTitle:@"Tiếp tục" otherButtonTitles:nil];
        [alert show];
        [self.window setRootViewController:self.tabBarController];
    }
    else
    {
        [[APIManager sharedAPIManager] setDefaultCookies];
        // Register notifications.
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound)];
        [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];

        //can kiem tra gia tri nay chi chay 1 lan khi lauch app
        [self initVariableList];
        loadingViewController = [[WelcomeViewController alloc] init];
        loadingViewController.canLaunchApp = NO;
        [loadingViewController setLoadingStateString:STR_LOADING];
        [self.window setRootViewController:loadingViewController];
        [loadingViewController setLoadingStateString:@"Đang kết nối với server..."];
        [[APIManager sharedAPIManager] getFileDefineTextWithContext:self];
    }
}

-(void) showAlert:(NSString *)title content:(NSString *)content
{
    [self hideLoadingViewForViewOnTop:nil];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:content delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    [alert setDelegate:nil];
}

-(void)initResourceToCheckNetWork
{
    icountTryRequestTransaction = 0;
    CGRect frameWindow = [[UIScreen mainScreen]bounds];
    activityIndicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0,0, frameWindow.size.width, frameWindow.size.height)];
    activityIndicator.hidden=NO;
    [activityIndicator setColor:[UIColor whiteColor]];
    [activityIndicator setBackgroundColor:[UIColor grayColor]];
    [activityIndicator setAlpha:0.5];
    [activityIndicator.layer setCornerRadius:10];
    
    //register to notification center for getting network connection status changed
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(networkConnectionChanged:) name: kReachabilityChangedNotification object: nil];
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
}

#if IS_DEBUG_LOG_MEM
-(void) logMemory
{
    [Memory logMemUsage];
}
#endif


-(void) cleanDataIfNeed
{
    NSString *dataPath = GALLERY_PATH;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    unsigned long long cacheSize;
    NSArray *caches = [self getSortedSubFolderForPath:dataPath totalSize:&cacheSize];
    if (cacheSize < DATA_MAX_SIZE)
    {
        return;
    }
    int index = 0;
    while (cacheSize >= DATA_MAX_SIZE && index < caches.count)
    {
        NSDictionary *object = [caches objectAtIndex:index];
        NSString *cache = [object objectForKey:@"path"];
        unsigned long long size = [[object objectForKey:@"size"] unsignedLongLongValue];
        cacheSize -= size;
        ++index;
        error = nil;
        [fileManager removeItemAtPath:[dataPath stringByAppendingString:cache] error:&error];
        if (error)
        {
            LOG_123PHIM(@"Error when delete %@ __: %@", cache, error);
            break;
        }
    }
}

- (unsigned long long) sizeOfFolderAtPath:(NSString *)path
{
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
    NSEnumerator *enumerator = [files objectEnumerator];
    NSString *fileName;
    unsigned long long size = 0;
    NSError *error = nil;
    
    while (fileName = [enumerator nextObject])
    {
//        size += [[[NSFileManager defaultManager] fileAttributesAtPath: traverseLink:YES] fileSize];
        
        size += [[[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName] error:&error] fileSize];
        
        if (error) {
            break;
        }
    }
    return size;
}


-(NSArray *)getSortedSubFolderForPath: (NSString *) path totalSize: (unsigned long long *)totalSize
{
    NSError* error = nil;
    NSArray* filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    if(error != nil) {
        LOG_123PHIM(@"Error in reading files: %@", [error localizedDescription]);
        return nil;
    }
    unsigned long long total = 0;
    // sort by creation date
    NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
    
    for(NSString* file in filesArray)
    {
        NSString* filePath = [path stringByAppendingPathComponent:file];
        NSDictionary* properties = [[NSFileManager defaultManager]
                                    attributesOfItemAtPath:filePath
                                    error:&error];
        NSDate* modDate = [properties objectForKey:NSFileModificationDate];
        unsigned long long size = [self sizeOfFolderAtPath:filePath];
        NSNumber *numSize = [NSNumber numberWithLongLong:size];
        total += size;
        if(error == nil)
        {
            [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           file, @"path",
                                           modDate, @"lastModDate",
                                           numSize, @"size",
                                           nil]];
        }
    }
    *totalSize = total;
    // sort using a block
    // order inverted as we want latest date first
    NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                            ^(id path1, id path2)
                            {
                                // compare
                                NSComparisonResult comp = [[path1 objectForKey:@"lastModDate"] compare:
                                                           [path2 objectForKey:@"lastModDate"]];
                                // invert ordering
                                if (comp == NSOrderedDescending) {
                                    comp = NSOrderedAscending;
                                }
                                else if(comp == NSOrderedAscending){
                                    comp = NSOrderedDescending;
                                }
                                return comp;
                            }];
    
    return sortedFiles;
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
//    if (buttonIndex == alertView.cancelButtonIndex)
//    {
//        _connectionMode = CONNECTION_STATE_OFFLINE;
//    }
}

#pragma mark - Facebook Handle
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    [self handleLaunchOpenUrl:url];
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)handleUserAccount
{
    FacebookManager *fbManager = [FacebookManager shareMySingleton];
    BOOL actived = [fbManager initFacebookSession];
    [self updateAppWithNewState:APP_STATE_START];
    if (actived)
    {
       //[self performSelectorInBackground:@selector(getFacebookAccountInfo) withObject:nil];
        [self getFacebookAccountInfo];
    }
}

-(void)getFacebookAccountInfo
{
    LOG_123PHIM(@"begin get face book info");
    FacebookManager *fbManager = [FacebookManager shareMySingleton];
    [fbManager getFacebookAccountInfoWithResponseContext:self selector:@selector(finishGetFacebookAccountInfo:)];
}

- (void)finishGetFacebookAccountInfo:(id<FBGraphUser>)fbUser
{
//    LOG_123PHIM(@"end get face book info");
    if (fbUser)
    {
        if (userProfile == nil) {
            userProfile = [[UserProfile alloc] init];
        }

        NSString *userid = [APIManager getStringInAppForKey:KEY_STORE_MY_USER_ID];
        
        if ([userid length] > 0)
        {
            self.userProfile.user_id = [APIManager getStringInAppForKey:KEY_STORE_MY_USER_ID];
        }
        [[APIManager sharedAPIManager] getRequestLoginFaceBookAccountWithContext:[APIManager sharedAPIManager]];
//        [self updateAppWithNewState:APP_STATE_START];
    }
    else
    {
//        login but can not get profile
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:@"Không thể kết nối tới Facebook" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }

}

- (BOOL)isUserLoggedIn
{
    return self.userProfile != nil;
}
- (void)handleLogout
{
    [[APIManager sharedAPIManager] setWasSendLogin:NO];
    [[FacebookManager shareMySingleton] logout];
    userProfile = nil;
    _isBeingLogin = NO;
}

#pragma mark -
#pragma mark RKManagerDelegate
#pragma mark -
-(void)processResultResponseDictionaryMapping:(DictionaryMapping *)dictionary requestId:(int)request_id
{
    if (request_id == ID_REQUEST_GET_FILE_DEFINE_TEXT)
    {
        [[APIManager sharedAPIManager] parseToGetFileTextDefine:dictionary.curDictionary];
        [self updateAppWithNewState:APP_STATE_VERSION_CHECKING];
    }
    else if (request_id == ID_REQUEST_CHECK_VERSION)
    {
        [self getResultCheckVersionResponse:[[APIManager sharedAPIManager] parseToGetVersionInfo:dictionary.curDictionary]];
    }
    else if(request_id == ID_REQUEST_THANHTOAN_INFOR_TRANSACTION_DETAIL)
    {
        [self parseToGetResultTransactionDetail:dictionary.curDictionary];
    }
    else if(request_id == ID_REQUEST_FILM_POST_UPDATE_FAVOURITE)
    {
        BOOL flag = [[APIManager sharedAPIManager] parseToGetStatusOfUpdatingFavouriteFilmListWithResponse:dictionary.curDictionary];
        if (flag && _svFavouriteFilmIDList)
        {
            for (NSNumber *filmID in _svFavouriteFilmIDList)
            {
                NSString *key = [NSString stringWithFormat:@"%d", filmID.integerValue];
                BOOL changed = NO;
                NSNumber *ptChanged = [NSNumber numberWithBool:changed];
                [_updatedFavouriteFilmList setObject:ptChanged forKey:key];
            }
            SAFE_RELEASE(_svFavouriteFilmIDList)
        }
    }
}

- (void)getResultCheckVersionResponse:(NSDictionary *)dic
{
    if (dic)
    {
        NSString *imageLink = [dic objectForKey:@"logo"];
        NSNumber *status = [dic objectForKey:@"status"];
        BOOL canSkip = status.intValue < 2;
        VersionNotificationViewController *versionNotifiCation = [[VersionNotificationViewController alloc] init];
        versionNotifiCation.canSkip = canSkip;
        versionNotifiCation.imageLink = imageLink;
        [self.window setRootViewController:versionNotifiCation];
    }
    else
    {
        [self updateAppWithNewState:APP_STATE_LOGIN_CHECKING];
    }
}

#pragma mark handle update state of app
- (void)requestFilmList
{
    startTime = [NSDate date];
    [[APIManager sharedAPIManager] getBannerListWithResponseTo:[MainViewController sharedMainViewController]];
    //get transaction con pending truoc do
    [self getTransationDetail];
}

-(void) updateAppWithNewState: (AppState) newState
{
    switch (newState) {
        case APP_STATE_INIT:
        {
            isNetworkAvailable = [self checkNetWork];
            [self updateInterfaceWithReachability];
        }
            break;
        case APP_STATE_VERSION_CHECKING:
        {
            [loadingViewController setLoadingStateString:@"Đang kiểm tra phiên bản..."];
            NSString *ver = @"0.2";
            ver = AppDelegate.getVersionOfApplication;
            [[APIManager sharedAPIManager] checkAppVersion:ver responseContext:self request:nil];
        }
            break;
        case APP_STATE_LOGIN_CHECKING:
        {
            [loadingViewController setLoadingStateString:@"Đang kiểm tra trạng thái đăng nhập..."];
            [self handleUserAccount];
        }
            break;
        case APP_STATE_START:
        {
            [loadingViewController setLoadingStateString:@"Đang tải danh sách phim..."];
            [self requestFilmList];
            [self performSelector:@selector(pushTabBarViewController) withObject:nil afterDelay:1.5];
        }
            break;
        default:
            break;
    }
}

#pragma mark parse to get ticket after retry query transaction detail
-(void)getTransationDetail
{
    icountTryRequestTransaction++;
    [[APIManager sharedAPIManager] thanhToanRequestGetInforTransactionDetail:self];
}

-(void)parseToGetResultTransactionDetail:(NSDictionary *)dicObject
{
    int status = [[dicObject objectForKey:@"status"] intValue];
    if(status == 0)
    {
        return;
    }
    id getData = [dicObject objectForKey:@"result"];
    if([[APIManager sharedAPIManager] isValidData:getData] && [getData isKindOfClass:[NSDictionary class]])
    {
        //    {"transaction_id":"2049",
        //        "customer_id":"43",
        //        "invoice_no":"20130606103708157218",
        //        "responseCode": (0, 1, -1),  trong đó 0 là tiếp tục chờ, 1 là thành công (có ticket_code), -1 là thất bại
        //        "ticket_code":"10213060646870"}
        int thanhtoan_status = [[getData objectForKey:@"responseCode"] integerValue];
        if (thanhtoan_status == 0)//dang cho ket qua
        {            
            if (icountTryRequestTransaction > MAX_REQUEST_GET_TRANSACTION_DETAIL) {
                return;
            }
            //request in background
            int timeInterval = icountTryRequestTransaction * TIME_INTERVAL_RETRY_GET_TRANSACTION_DETAIL;
            [self performSelector:@selector(getTransationDetail) withObject:nil afterDelay:timeInterval];
        }
        else if (thanhtoan_status == 1)//thanh cong
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            id temp = [getData objectForKey:@"ticket_code"];
            if (temp && [temp isKindOfClass:[NSString class]]) {
                if ([(NSString *)temp length]) {
                    appDelegate.ticket_code = temp;
                }
            }
            appDelegate.Invoice_No = [getData objectForKey:@"invoice_no"];
            
            //cap nhat status sang trai thai don hang thanh cong
            [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_RESULT_SUCCESS] ForKey:KEY_STORE_STATUS_THANH_TOAN];
            //Xoa gia tri pending cua transaction
            [APIManager setStringInApp:@"" ForKey:KEY_STORE_TRANSACTION_ID_PENDING];
            [self pushViewControllerAccordingToStatus];
            [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_OUT_RANGE] ForKey:KEY_STORE_STATUS_THANH_TOAN];
        }
        else//that bai
        {
            //cap nhat status sang trai thai don hang failed
            [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_RESULT_FAILED] ForKey:KEY_STORE_STATUS_THANH_TOAN];
            //Xoa gia tri pending cua transaction
            [APIManager setStringInApp:@"" ForKey:KEY_STORE_TRANSACTION_ID_PENDING];
            [self pushViewControllerAccordingToStatus];
            [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_OUT_RANGE] ForKey:KEY_STORE_STATUS_THANH_TOAN];
        }
    }
}

-(void)pushTabBarViewController
{
    [self.window setRootViewController:self.tabBarController];
//    [self processActionPostLocalNotification];
}
#pragma mark override database prevent crash app
- (void)replaceDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // remove old sqlite database from documents directory
    NSURL *dbDocumentsURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataMovie.sqlite"];
    NSString *dbDocumentsPath = [dbDocumentsURL path];
    if ([fileManager fileExistsAtPath:dbDocumentsPath]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:dbDocumentsPath error:&error];
        if (error) {
            LOG_123PHIM(@"Error deleting sqlite database: %@", [error localizedDescription]);
        }
    }
}

-(void)setUserProfile:(UserProfile *)theUserProfile
{
    if (userProfile)
    {
        userProfile = nil;
    }
    if (theUserProfile)
    {
        userProfile = theUserProfile;
    }
}

#pragma mark getIPAddress and create checksum
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    if ([address isEqualToString:@"error"]) {
        return @"127.0.0.1";
    }
    return address;
}

-(void)setArrayCinema:(NSMutableArray *)theArrayCinema
{
    SAFE_RELEASE(arrayCinema)
    if (theArrayCinema)
    {
        arrayCinema = theArrayCinema;
        // assign to cinema group
        [arrayCinema enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SAFE_RELEASE(_dictCinemaGroup)
            _dictCinemaGroup = [[NSMutableDictionary alloc]init];
            NSInteger groupID = ((Cinema*)obj).p_cinema_id.integerValue;
            NSString *key = [NSString stringWithFormat:@"groupid_%d", groupID];
            NSMutableArray *arr = [_dictCinemaGroup objectForKey:key];
            if (!arr)
            {
                arr = [[NSMutableArray alloc] init];
                [_dictCinemaGroup setObject:arr forKey:key];
            }
            [arr addObject:obj];
        }];
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NOTIFICATION_NAME_CINEMA_DID_LOAD object:arrayCinema];
}

-(void)setArrayCinemaDistance:(NSMutableArray *)theArrayCinemaDistance
{
    if (arrayCinemaDistance)
    {
        arrayCinemaDistance = nil;
    }
    if (theArrayCinemaDistance)
    {
        arrayCinemaDistance = theArrayCinemaDistance;
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NOTIFICATION_NAME_CINEMA_WITH_DISTANCE_DID_LOAD object:arrayCinemaDistance];
}

-(UIViewController *) getCurrentViewController
{
    UINavigationController *currentNavi = (UINavigationController *)[self.tabBarController selectedViewController] ;
    UIViewController *currentViewController = [currentNavi topViewController];
    return currentViewController;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Location
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    double distance = CGFLOAT_MAX;
    if (oldLocation)
    {
        distance = [newLocation distanceFromLocation:oldLocation];
    }
    // accurary is 100 metters
    if (distance > 100.0) //metters
    {
//        LOG_123PHIM(@"distance = %f", distance);
        // update new location
        userPosition.positionCoodinate2D = newLocation.coordinate;
        [self getUserPositionFromLocation:newLocation];//it also reload Location cell in Accout view
    }
    else
    {
        CinemaViewController* cinema = [self.navCinema.viewControllers objectAtIndex:0];
        [cinema newLocation:newLocation address:userPosition.address];
    }
    [locationManager stopUpdatingLocation];
}

- (void)getUserPositionFromLocation:(CLLocation *)newLocation
{
    userPosition.positionCoodinate2D = newLocation.coordinate;
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", newLocation.coordinate.latitude, newLocation.coordinate.longitude]];    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error)
        {
            SBJsonParser* parsor = [[SBJsonParser alloc] init];
            NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary* rawData = [parsor objectWithString:string];
            
            if ([[rawData objectForKey:@"status"] isEqual:@"OK"]) {
                
                NSArray* result = [rawData objectForKey:@"results"];
                
                NSDictionary* address = [result objectAtIndex:0];
                
                NSString* formatted_address = [address objectForKey:@"formatted_address"];
                
                userPosition.address = formatted_address;
                
                if (updateLocationFrom == UpdateLocationTypeAuto) {
                    //get user location then save on server
                    [self storeUserLocationHistory];
                }
                CinemaViewController* cinema = [self.navCinema.viewControllers objectAtIndex:0];
                [cinema newLocation:newLocation address:userPosition.address];
                
                AccountViewController* account = [self.navUser.viewControllers objectAtIndex:0];
                [account newLocation:newLocation address:userPosition.address];
            }
        }
    }];
}

- (void)updateUserLocationWithType:(UpdateLocationType)type
{
//    LOG_123PHIM(@"updateUserLocationWithType");
    [locationManager startUpdatingLocation];
    updateLocationFrom = type;
}

- (void)storeUserLocationHistory
{
    if (!self.isUserLoggedIn) {
        return;
    }
    NSString* addr;
    NSString* lat;
    NSString* log;
    NSString* time;
    
    addr =  userPosition.address;
    lat =  [NSString stringWithFormat:@"%f", userPosition.positionCoodinate2D.latitude];
    log =  [NSString stringWithFormat:@"%f", userPosition.positionCoodinate2D.longitude];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    time = [dateFormatter stringFromDate:[NSDate date]];
    if ([lat doubleValue] != lastSentLat || [log doubleValue] != lastSentLog) { //if new location       
        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
        if ((now - lastTimeSentLocationToServer) > INTERVAL_BETWEEN_TWO_SEND_USER_LOCATION_TO_SERVER) {
            [[APIManager sharedAPIManager] user: (self.isUserLoggedIn?self.userProfile.user_id:[NSString stringWithFormat:@"%d", NO_USER_ID]) beInAddress:addr lat:lat log:log atTime:time context:[MainViewController sharedMainViewController]];
            lastSentLat = [lat doubleValue];
            lastSentLog = [log doubleValue];
            lastTimeSentLocationToServer = now;
        }
    }
}

#pragma mark write out parser for my string
+ (NSString *)outParserConvertFormat:(NSString *)strKey
{
    if (!strKey || strKey.length < 1) {
        return @"123Phim";
    }
    AppDelegate *currentInstance = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *strValue = [currentInstance.dicObjectText objectForKey:strKey];
    if (!strValue)
    {
        if ([strKey isEqualToString:@"STR_LOADING"])
        {
            return @"Đang tải dữ liệu...";
        }
        else
        {
            return strKey;
        }
    }
    NSMutableString *strResult = [[NSMutableString alloc] initWithString:strValue];
    NSString *strPattern = @"[@]";
    NSUInteger lengPattern = [strPattern length];
    NSUInteger lengParam = 0;
    NSUInteger length = [strResult length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [strResult rangeOfString:strPattern options:0 range:range];
        if(range.location != NSNotFound)
        {
            NSString *strCurrentArg = @"%@";
            [strResult replaceCharactersInRange:range withString:strCurrentArg];
            //edit range when replace text pattern by text param
            lengParam = [strCurrentArg length];
            range.length += (lengParam - lengPattern);
            length = [strResult length];
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
        }
    }
    return strResult;
}

#pragma mark process get and display dynamic View
-(void)pushViewControllerWithActionInfo:(NSDictionary *)actionInfo
{
    NSString *viewControllerNameToPush = [actionInfo objectForKey:DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_ACTION_VIEW_CONTROLLER_NAME];
    if (viewControllerNameToPush)
    {
        Class theClass = NSClassFromString(viewControllerNameToPush);
        
        for (UINavigationController *nc in self.tabBarController.viewControllers)
        {
            UIViewController *vc = nil;
            if ([nc isKindOfClass:[UINavigationController class]])
            {
                vc = [nc.viewControllers objectAtIndex:0]; // only main views on tabbar
            }
            else
            {
                vc = nc;
            }
            if ([vc isKindOfClass:theClass])
            {
//                    exist viewcontroller
                [self.tabBarController setSelectedViewController:nc];
                [self popToViewController:theClass animated:YES];
                return;
            }
        }
        
//        new view controller
        UIViewController *vc = [[theClass alloc] init];
        
//        set properties
        NSArray *properties = [actionInfo objectForKey:DYNAMIC_VIEW_OBJECT_PROPERTIES];
        if (properties)
        {
            for (int i = 0; i < properties.count; i++) {
                SEL setter = NSSelectorFromString([properties objectAtIndex:i++]);
                id object = nil;
                NSDictionary *objectInfo = [properties objectAtIndex:i];
                if ([objectInfo isKindOfClass:[NSDictionary class]])
                {
                    object = [self getOjectFromInfo:objectInfo];
                }
                else
                {
                    object = objectInfo;
                }
                if ([vc respondsToSelector:setter])
                {
                    [vc performSelector:setter withObject:object];
                }
            }
        }
//        push view controller
        [((UINavigationController *)self.tabBarController.selectedViewController) pushViewController:vc animated:YES];
    }
}

-(id)getOjectFromInfo:(NSDictionary*) objectInfo
{
    id object = nil;
    NSString *objName = [objectInfo objectForKey:DYNAMIC_VIEW_OBJECT_NAME];
    NSArray *objProperties = [objectInfo objectForKey:DYNAMIC_VIEW_OBJECT_PROPERTIES];
    if (objProperties)
    {
        //                    new object
        NSNumber *num = [objectInfo objectForKey:DYNAMIC_VIEW_OBJECT_IS_DB_ENTITY];
        if (num)
        {
            object = [NSEntityDescription insertNewObjectForEntityForName:objName inManagedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
        }
        else
        {
            object = [[NSClassFromString(objName) alloc] init];;
        }
        for (int j = 0; j < objProperties.count; j++) {
            SEL objSetter = NSSelectorFromString([objProperties objectAtIndex:j++]);
            id param = [objProperties objectAtIndex:j];
            if ([param isKindOfClass:[NSDictionary class]])
            {
                param = [self getOjectFromInfo:param];
            }
            if ([object respondsToSelector:objSetter])
            {
                [object performSelector:objSetter withObject:param];
            }
        }
    }
    else
    {
        objProperties = [objectInfo objectForKey:DYNAMIC_VIEW_OBJECT_GETTER];
        if (objProperties && [objProperties isKindOfClass:[NSArray class]] && objProperties.count == 2)
        {
            //                        object exist
            SEL getter = NSSelectorFromString([objProperties objectAtIndex:0]);
            id param = [objProperties objectAtIndex:1];
            if ([self respondsToSelector:getter])
            {
                object = [self performSelector:getter withObject:param];
            }
        }
    }
    return object;
}

-(NSDictionary *)getDynamicViewInfoForViewController:(UIViewController *)vc
{
    if (!_lstDymamicViewInfo)
    {
//        return nil;
        [self loadListDynamicViewInfo];
    }
    
    for (NSDictionary *info in _lstDymamicViewInfo) {
        NSArray *arr = [info objectForKey:DYNAMIC_VIEW_LIST_VIEW_CONTROLLER];
        if (arr)
        {
            for (NSString *objName in arr) {
                Class theClass = NSClassFromString(objName);
                if (theClass == [vc class])
                {
                    return [info objectForKey:DYNAMIC_VIEW_INFO];
                }
            }
        }
    }
    return nil;
}

-(void)loadListDynamicViewInfo
{
    return;
    NSString *filePath = [NSString stringWithFormat:@"%@/dynamicView_showSelectSession.txt", BUNDLE_PATH];

    _lstDymamicViewInfo = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
}


#pragma mark Film liked

- (void)saveFilmFavoriteToFile:(int)film_id withStatus:(BOOL)isLike
{
    if (isLike) {
        [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Film"
                                                        withAction:@"PhimPhaiXem"
                                                         withLabel:@"Like"
                                                         withValue:[NSNumber numberWithInt:107]];
    } else {
        [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Film"
                                                        withAction:@"PhimPhaiXem"
                                                         withLabel:@"UnLike"
                                                         withValue:[NSNumber numberWithInt:107]];
    }
    
    NSMutableArray *sawDetailFilm = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:STRING_KEY_LIST_FILM_FAVORITE]];

    if (!sawDetailFilm) {
        sawDetailFilm = [[NSMutableArray alloc] init];
    }
    BOOL idExist = NO;
    for (NSNumber* existId in sawDetailFilm) {
        if ([existId intValue] == film_id)
        {
            idExist = YES;
//            [sawDetailFilm removeObject:existId]; // Why do we remove existed film ID?
            break;
        }
    }
    if (!idExist)
    {
        [sawDetailFilm addObject:[NSNumber numberWithInt:film_id]];
        // save changes
        [[NSUserDefaults standardUserDefaults] setObject:sawDetailFilm forKey:STRING_KEY_LIST_FILM_FAVORITE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)handleFilmLikedTouched:(FavoriteButton*)sender
{
    int film_id_touched = sender.filmId;
    BOOL isLiked = sender.isLiked;
    [self saveFilmFavoriteToFile:film_id_touched withStatus:isLiked];
    Film *film = [self getFilmWithID:[NSNumber numberWithInt:film_id_touched]];
    [self updateFavouriteFilmListWithFilm:film isFavourite:isLiked fromStatus:2];
}
/**
 * update favourite film list
 * fromStatus: 0=>server 1=>loc 2=>dynamic
 */
- (void)updateFavouriteFilmListWithFilm:(Film *)film isFavourite:(BOOL)isFavourite fromStatus:(NSInteger)fromStatus
{
    if (film == nil)
    {
        return;
    }
    if (!_updatedFavouriteFilmList)
    {
        _updatedFavouriteFilmList = [[NSMutableDictionary alloc]init];
    }
    NSString *key = [NSString stringWithFormat:@"%d", film.film_id.integerValue];
    BOOL changed = NO;
    switch (fromStatus) {
        case 1:
        {
            NSNumber *saved = [_updatedFavouriteFilmList objectForKey:key];
            changed = (saved == nil);
        }
            break;
        case 2:
        {
            NSNumber *saved = [_updatedFavouriteFilmList objectForKey:key];
            changed = YES;
            if (saved)
            {
                changed = !saved.boolValue;
            }
        }
            break;
            
        default:
            break;
    }
    NSNumber *ptChanged = [NSNumber numberWithBool:changed];
    [_updatedFavouriteFilmList setObject:ptChanged forKey:key];
    [film setIs_like:[NSNumber numberWithBool:isFavourite]];
    if (isFavourite)
    {
        if (self.arrayFilmFavorite == nil)
        {
            arrayFilmFavorite = [[NSMutableArray alloc] init];
        }
        if (![self.arrayFilmFavorite containsObject:film])
        {
            [self.arrayFilmFavorite addObject:film];
        }
    }
    else
    {
        [self.arrayFilmFavorite removeObject:film];
    }
}

-(void)updateFavouriteFilmListWithArrayID:(NSArray *)filmIDList isFromServer:(BOOL)isFromServer
{
    if (!_updatedFavouriteFilmList)
    {
        _updatedFavouriteFilmList = [[NSMutableDictionary alloc]init];
    }
    if (isFromServer)
    {
        if (!self.arrayFilmShowing || [self.arrayFilmShowing count] == 0)
        {
            // wait to load film list
            _svFavouriteFilmIDList = [[NSArray alloc] initWithArray:filmIDList];
            return;
        }
        [_updatedFavouriteFilmList setObject:[NSNumber numberWithBool:YES] forKey:@"GOT_SERVER_FAVOURITE_FILM_LIST"];
    }
    if (!filmIDList)
    {
        return;
    }
    for (NSNumber* item in filmIDList)
    {
        Film *film = [self getFilmWithID:item];
        [self updateFavouriteFilmListWithFilm:film isFavourite:YES fromStatus:(isFromServer? 0 : 1)];
    }
    if (!isFromServer && _svFavouriteFilmIDList)
    {
        [self updateFavouriteFilmListWithArrayID:_svFavouriteFilmIDList isFromServer:YES];
        SAFE_RELEASE(_svFavouriteFilmIDList)
    }
}

-(void)saveFavouriteFilmList;
{
    // save film liked to file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:FILE_NAME_LIST_FILM_FAVORITE];
    NSMutableArray* fFilmIDList = [[NSMutableArray alloc] init];
    for (Film* fFilm in self.arrayFilmFavorite)
    {
        NSNumber* film_id = fFilm.film_id;
        [fFilmIDList addObject:film_id];
    }
    [fFilmIDList writeToFile:path atomically:YES];
    SAFE_RELEASE(_svFavouriteFilmIDList)
    _svFavouriteFilmIDList = [[NSArray alloc] initWithArray:[[APIManager sharedAPIManager] sendFavouriteFilmListIfNeedWithResponseID:self]];
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[SDWebImageManager sharedManager].imageCache clearMemory];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

-(void)cinemaWithDistanceDidLoad:(NSNotification *)notification
{
    if ([notification object])
    {
        [self checkToStartManualViewController];
    }
}

-(void)filmListDidLoad:(NSNotification *)notification
{
    [self checkToStartManualViewController];
}

-(void)promotionListDidLoad:(NSNotification *)notification
{
    [self checkToStartManualViewController];
}

// will fire if get any list: promotion list, showing film list, coming film list
-(void)checkToStartManualViewController
{
    // check film list
    if (self.startWithPromotionID > 0 && [PromotionViewController sharedPromotionViewController].myArrayNews && [PromotionViewController sharedPromotionViewController].myArrayNews.count > 0)
    {
        [self.tabBarController setSelectedIndex:2];
        News *promotion = nil;
        for (News *promt in [PromotionViewController sharedPromotionViewController].myArrayNews)
        {
            if (promt.news_id == self.startWithPromotionID) {
                promotion = promt;
                break;
            }
        }
        self.startWithPromotionID = 0;
        // launch promotion detail
        if (promotion)
        {
            [[PromotionViewController sharedPromotionViewController] pushPromotionDetailViewFor:promotion];
        }
    }
    else if (self.startWithFilmID > 0 || self.startWithCinemaID > 0)
    {
        if (self.arrayFilmShowing && self.arrayFilmComing && self.arrayFilmComing.count > 0)
        {
            // check cinema list
            if (self.arrayCinemaDistance && self.arrayCinemaDistance.count > 0)
            {
                Film *film = nil;
                CinemaWithDistance *cinemaWithDistance = nil;
                NSInteger stepDay = -1;
                if (self.startWithFilmID > 0)
                {
                    film = [self getFilmWithID:[NSNumber numberWithInteger:self.startWithFilmID]];
                    self.startWithFilmID = 0;
                }
                if (self.startWithCinemaID > 0)
                {
                    cinemaWithDistance = [self getCinemaWithDistanceWithCinemaID:[NSNumber numberWithInteger:self.startWithCinemaID]];
                    self.startWithCinemaID = 0;
                }
                if (self.startWithDateString && self.startWithDateString.length > 0)
                {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    [dateFormatter setCalendar:calendar];
                    [dateFormatter setDateFormat:@"d-M-yyyy"];
                    NSDate *date = [dateFormatter dateFromString:self.startWithDateString];
                    if (date)
                    {
                        stepDay = [NSDate daysBetween:[NSDate date] and:date];
                        if (stepDay < 0)
                        {
                            stepDay = 0;
                        }
                    }
                }
                if (film)
                {
                    // launch film detail view controller
                    if (film)
                    {
                        [self.tabBarController setSelectedIndex:1];
                        if (stepDay >= 0)
                        {
                            // launch film cinema view controller
                            FilmCinemaViewController *cinemaFilmController = [[FilmCinemaViewController alloc] init];
                            [cinemaFilmController setFilm:film];
                            cinemaFilmController.stepNextDayShowSession = stepDay;
                            [cinemaFilmController requestAPIGetListCinemaSession];
                            [[MainViewController sharedMainViewController].navigationController pushViewController:cinemaFilmController animated:YES];
                        }
                        else
                        {
                            [[MainViewController sharedMainViewController] pushVCFilmDetailWithFilm:film isFavorite:NO];
                        }
                    }
                }
                else if (cinemaWithDistance)
                {
                    [self.tabBarController setSelectedIndex:0];
                    if (stepDay >= 0)
                    {
                    }
                    // launch cinema view controller
                    [[CinemaViewController sharedCinemaViewController] pushFilmListCinemaView:cinemaWithDistance];

                }
            }
        }
    }
}

-(void)handleLaunchOpenUrl:(NSURL *) idUrl
{
    if (idUrl)
    {
        // web template
//        NSString *web = @"123phim://123phim.vn/?filmId=317&date=08-08-2013";
//        web = @"123phim://123phim.vn/?cinemaId=8&date=8-8-2013";
//    launchOptions = [NSDictionary dictionaryWithObjectsAndKeys:web, @"UIApplicationLaunchOptionsURLKey", nil];
    
        //fb template
//        NSString *fb = @"fb116326268554352://authorize/#access_token=CAABpzFHqTHABAMy66IrFtDqcL5VHBiYzx0PVZBbL583rzB1B9dkWolFhum7RZBTADJVWAFxGb0syNn0ZB6M1AC55n1MAOF1wtwfAwIljvGuA0ZBtoZAQZATg5AgSR9Nyt1yHW8R8kxG79XdHPpLK31i7hNcjGrVKJG6E9PkzknHJdZBoinGRk2u&expires_in=3600&target_url=http://www.123phim.vn/abc/294-nguoi-soi-wolverine-the-wolverine.html?fb_action_ids=162349943955654&fb_action_types=vng_phim%3Ashare&fb_source=other_multiline&action_object_map=%5B396963443747910%5D&action_type_map=%5B%22vng_phim%3Ashare%22%5D&action_ref_map=%5B%5D&filmId=317";
//        launchOptions = [NSDictionary dictionaryWithObjectsAndKeys:fb, @"UIApplicationLaunchOptionsURLKey", nil];
        NSString *url = nil;
        if ([idUrl isKindOfClass:[NSURL class]])
        {
            url = [((NSURL*)idUrl) absoluteString];
        }
        else if([idUrl isKindOfClass:[NSString class]])
        {
            url = (NSString *)idUrl;
        }
        else
        {
            if ([idUrl respondsToSelector:@selector(stringValue)])
            {
                url = [(id)idUrl stringValue];
            }
            else
            {
                return;
            }
        }
        int loop = 1;
        do {
            NSArray *arr = [url componentsSeparatedByString:@"&target_url="];
            if (arr.count > 0)
            {
                url = [arr lastObject];
                NSString *targetUrl = url;
                URLParser *urlParser = [[URLParser alloc] initWithURLString:targetUrl];
                NSString *value = nil;
                
                value = [urlParser valueForKey:@"date"];
                if (value)
                {
                    [self setStartWithDateString:value];
                }
                value = [urlParser valueForKey:@"promotionId"];
                if (value)
                {
                    [self setStartWithPromotionID:[value integerValue]];
                }
                // from web
                if (arr.count == 1)
                {
                    value = nil;
                    value = [urlParser valueForKey:@"filmId"];
                    if (value)
                    {
                        [self setStartWithFilmID:[value integerValue]];
                    }
                    value = nil;
                    value = [urlParser valueForKey:@"cinemaId"];
                    if (value)
                    {
                        [self setStartWithCinemaID:[value integerValue]];
                    }
                }
                // from fb
                else
                {
                    NSString *idCinema = @"/rap-chieu-phim/";
                    arr = [targetUrl componentsSeparatedByRegex:idCinema];
                    if (arr && arr.count == 1)
                    {
                        idCinema = @"/chi-tiet-rap/";
                        arr = [targetUrl componentsSeparatedByRegex:idCinema];
                    }
                    if (arr && arr.count > 1)
                    {
                        NSString *str = [arr lastObject];
                        NSArray *array = [str componentsSeparatedByString:@"-"];
                        if (array && array.count > 1)
                        {
                            [self setStartWithCinemaID:[[array objectAtIndex:0] integerValue]];
                        }
                    }
                    else
                    {
                        NSString *idFilm = @"/phim/";
                        arr = [targetUrl componentsSeparatedByRegex:idFilm];
                        if (arr && arr.count > 1)
                        {
                            NSString *str = [arr lastObject];
                            NSArray *array = [str componentsSeparatedByString:@"-"];
                            if (array && array.count > 1)
                            {
                                [self setStartWithFilmID:[[array objectAtIndex:0] integerValue]];
                            }
                        }
                    }
                    
                    if (arr && arr.count == 1)
                    {
                        loop ++;
                    }
                }
            }
            loop--;
        } while (loop > 0);
            
        [self checkToStartManualViewController];
    }
}

#pragma mark show and hide view notification for tabbar item
//- (void) showNotificationViewFor:(NSUInteger)tabIndex
//{
//    // To get the vertical location we start at the bottom of the window, go up by height of the tab bar and go up again by the notification view
//    CGFloat verticalLocation = self.view.window.frame.size.height - self.tabBar.frame.size.height - notificationView.frame.size.height - 2.0;
//    notificationView.frame = CGRectMake([self horizontalLocationFor:tabIndex], verticalLocation, notificationView.frame.size.width, notificationView.frame.size.height);
//    
//    if (!notificationView.superview)
//        [self.view.window addSubview:notificationView];
//    
//    notificationView.alpha = 0.0;
//    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.5];
//    notificationView.alpha = 1.0;
//    [UIView commitAnimations];
//}
//
//- (IBAction)hideNotificationView:(id)sender
//{
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.5];
//    notificationView.alpha = 0.0;
//    [UIView commitAnimations];
//}

@end
