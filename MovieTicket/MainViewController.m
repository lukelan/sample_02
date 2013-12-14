//
//  DemoSlideControllerSubclass.m
//  CHSlideController
//
//  Created by Clemens Hammerl on 19.10.12.
//  Copyright (c) 2012 appingo mobile e.U. All rights reserved.
//

#import <Foundation/NSHTTPCookieStorage.h>
#import "AppDelegate.h"
#import "APIManager.h"
#import "MainViewController.h"
#import "FilmCinemaViewController.h"
#import "FilmDetailViewController.h"
#import "CinemaViewController.h"
#import "CommentFilmView.h"
#import "UserProfile.h"
#import "DefineDataType.h"
#import "SBJsonParser.h"
#import "AdViewController.h"
#import "PromotionViewController.h"
//#import "ADNViewController.h"

#define ALERT_TAG_NOTIFY_RATING_APP 1001

@interface MainViewController ()<NSFetchedResultsControllerDelegate, RKManagerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation MainViewController

@synthesize arrayFilmComming,arrayFilmShowing;//,modeView
@synthesize viewSeg;
@synthesize btnMyListFilm;
@synthesize filmPageShowing;
@synthesize curIndexPageComming, curIndexPageShowing;
@synthesize fetchedResultsController = _fetchedResultsController;

-(void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    btnMyListFilm = nil;
    viewSeg = nil;
    [arrayFilmShowing removeAllObjects];
    arrayFilmShowing = nil;
    [arrayFilmComming removeAllObjects];
    arrayFilmComming = nil;
    self.showingBannerList = nil;
    self.comingBannerList = nil;
    self.filmPageShowing = nil;
    curIndexPageShowing=0;
    curIndexPageComming=0;
    viewSeg = nil;
    btnMyListFilm = nil;
    filmPageShowing = nil;
}

- (NSFetchedResultsController *)fetchedResultsController{
    
    if (!_fetchedResultsController)
    {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Film class])];
//        [fetchRequest setSortDescriptors:nil];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"order_id" ascending:YES]];

        NSFetchedResultsController *myFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:@"film"];
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
    if (_isLoadingFilmList) {
        return;
    }
    _isSendingRequestGetListNew = NO;
    _isLoadingFilmList = YES;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([[delegate getCurrentViewController] isEqual:self])
    {
        [self loadLayoutFilm:NO];
    }
}

#pragma mark Create singleton
static MainViewController* _sharedMyMainView = nil;
+(MainViewController*)sharedMainViewController
{
    //This way guaranttee only a thread execute and other thread will be returned when thread was running finished process
    if(_sharedMyMainView != nil)
    {
        return _sharedMyMainView;
    }
    static dispatch_once_t _single_thread;//block thread
    dispatch_once(&_single_thread, ^ {
        _sharedMyMainView = [[super allocWithZone:nil] initWithNibName:@"MainViewController" bundle:nil];
    });//This code is called most once.
    return _sharedMyMainView;
}

#pragma implements these methods below to do the appropriate things to ensure singleton status.
//if you want a singleton instance but also have the ability to create other instances as needed through allocation and initialization, do not override allocWithZone: and the orther methods below
//We don't want to allocate a new instance, so return the current one
+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedMainViewController];
}

//We don't want to generate mutiple conpies of the singleton
-(id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"footer-button-movie-active.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"footer-button-movie.png"] ];
        [self.tabBarItem setTitle:@"Phim"];
        [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor whiteColor], UITextAttributeTextColor,
                                                   nil] forState:UIControlStateNormal];
        viewName = MAIN_VIEW_NAME;
        
        // TrongV - 08/12/2013 - Show Tab bar as default
        self.tabBarDisplayType = TAB_BAR_DISPLAY_SHOW;
        
        self.trackedViewName = viewName;
    }
    return self;
}

-(void)checkLoadDataIfNeed
{
    if (![AppDelegate isNetWorkValiable])
    {
        [self hideLoadingView];
        return;
    }
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([[delegate getCurrentViewController] isEqual:self])
    {
        NSTimeInterval timeCurrent = [NSDate timeIntervalSinceReferenceDate];
        int timeLitmit = 36000;
        id temp = MAX_TIME_RETRY_GET_LIST_FILM;
        if ([temp isKindOfClass:[NSNumber class]]) {
            timeLitmit = [temp intValue];
        }
        
        if ((!arrayFilmShowing || arrayFilmShowing.count == 0 || ((timeCurrent - lastTimeLoading) > timeLitmit && lastTimeLoading != 0)))
        {
            if ((timeCurrent - lastTimeLoading) < timeLitmit) {
                _isSendingRequestGetListNew = NO;
                [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_TABBAR];
            } else {
                if (_isSendingRequestGetListNew) {
                    return;
                }
                _isSendingRequestGetListNew = YES;
                _isLoadingFilmList = NO;
            }
            NSString *fileNameTextDefine = [NSString stringWithFormat:@"%@/%@",DOCUMENTS_PATH, FILE_NAME_TEXT_DEFINE];
            BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:fileNameTextDefine];
            if (isExists) {
                NSDictionary *offDic = [NSDictionary dictionaryWithContentsOfFile:fileNameTextDefine];
                [delegate setDicObjectText:offDic];
                [[APIManager sharedAPIManager] getBannerListWithResponseTo:[MainViewController sharedMainViewController]];
            } else {
                [[APIManager sharedAPIManager] getFileDefineTextWithContext:self];
            }
        }
        else
        {
            [self hideLoadingView];
        }
    }
}

#pragma mark ViewDidLoad & viewAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setVisibleLeftButtonFilmFavorite:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    check to request rating app
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([AppDelegate isNetWorkValiable] && app.requestAppRating)
    {
        app.requestAppRating = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:MESSAGE_RATING_APP delegate:self cancelButtonTitle:ALERT_BUTTON_NO otherButtonTitles:ALERT_BUTTON_OK_RATE, ALERT_BUTTON_REMIND, nil];
        alert.tag = ALERT_TAG_NOTIFY_RATING_APP;
        [alert show];
    }
    [self checkLoadDataIfNeed];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    [self initLayoutForView];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"launch_image.png"]]];
    [self.filmPageShowing setDelegate:self];
    [self selectedSegmentChanged];
    [self loadLayoutFilm:YES];
    
    // Disable ADN
//    UIBarButtonItem *btsearch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(actionDownload:)];
//    NSArray *myButtonArray = [[NSArray alloc] initWithObjects: btsearch, nil];
//    self.navigationItem.rightBarButtonItems = myButtonArray;
}

//-(void)actionDownload:(id)sender
//{
//    ADNViewController *adnController = [[ADNViewController alloc] initWithNibName:[[ADNViewController class] description] bundle:nil];
//    [self.navigationController pushViewController:adnController animated:YES];
//}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect f = self.view.frame;
    f.size.height = [[UIScreen mainScreen] bounds].size.height - TITLE_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - TAB_BAR_HEIGHT;
    f.origin.y = 0;
    [filmPageShowing.pageScrollView setFrame:f];
}

-(void)viewDidUnload
{
    self.filmPageShowing = nil;
    [super viewDidUnload];
}

-(void)initForContentPageScrollViewMyListFavorite
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.filmPageShowing setMyFilmDataArray:delegate.arrayFilmFavorite];
    [self.filmPageShowing reloadData];
}

-(void)processActionShowMyListFilm
{
    [self initForContentPageScrollViewMyListFavorite];
    [btnMyListFilm setSelected:YES];
    [viewSeg setSelectedSegmentIndex:-1];
}

-(void)initDataForFilmShow
{
    if (btnMyListFilm && btnMyListFilm.selected)
    {
        [self initForContentPageScrollViewMyListFavorite];
    }
    else
    {
        [self selectedSegmentChanged];
        [self setVisibleLeftButtonFilmFavorite:NO];
    }
    [self hideLoadingView];
}

-(void)initLayoutForView
{
    [self initToolBarView];
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationProcessingDidEnterBackGround) name:UIApplicationDidEnterBackgroundNotification object:app];
}

-(void)applicationProcessingDidEnterBackGround
{
    
}

- (void) initToolBarView
{
    UIImage *bgSegment = [UIImage imageNamed:@"segment_bg.png"];
    CGSize sizetext = [@"Đang Chiếu" sizeWithFont:[UIFont getFontBoldSize12]];
    float segH = bgSegment.size.height;
    float WidthText = sizetext.width;
    float margin = (segH - sizetext.height)/2;
    float segW = bgSegment.size.width < 2*(WidthText + 2*margin) ? bgSegment.size.width:2*(WidthText + 2*margin);
    viewSeg=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Đang Chiếu", @"Sắp Chiếu", nil]];
    [viewSeg setWidth:segW/2 forSegmentAtIndex:0];
    [viewSeg setWidth:segW/2 forSegmentAtIndex:1];
    [viewSeg setFrame:CGRectMake((self.view.frame.size.width - segW) / 2, (NAVIGATION_BAR_HEIGHT - segH) / 2, segW, segH)];
    [viewSeg setSegmentedControlStyle:UISegmentedControlStyleBordered];
    [self setPropertiesForSegmentControl];
    viewSeg.selectedSegmentIndex = 0;
    [viewSeg addTarget:self action:@selector(selectedSegmentChanged) forControlEvents:UIControlEventValueChanged];
//    [viewSeg setBackgroundImage:bgSegment forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [viewSeg setBackgroundImage:[UIImage imageNamed:@"segment_selected_hl.png"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    self.navigationItem.titleView = viewSeg;
    [self initForLeftButtonFilmFavorite];
}

-(void)initForLeftButtonFilmFavorite
{
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"button-60x30" ofType:@"png"];
    UIImage *imageLeft = [[UIImage alloc] initWithContentsOfFile:thePath];
    btnMyListFilm = [[UIButton alloc]init];
    CGRect frame = CGRectMake(0, 0, imageLeft.size.width, imageLeft.size.height);
    btnMyListFilm.frame = frame;
    [btnMyListFilm setBackgroundImage:imageLeft forState:UIControlStateNormal];
    thePath = [[NSBundle mainBundle] pathForResource:@"icon_bookmark" ofType:@"png"];
    imageLeft = [[UIImage alloc] initWithContentsOfFile:thePath];
    [btnMyListFilm setImage:imageLeft forState:UIControlStateNormal];
    thePath = [[NSBundle mainBundle] pathForResource:@"icon_bookmark_sl" ofType:@"png"];
    imageLeft = [[UIImage alloc] initWithContentsOfFile:thePath];
    [btnMyListFilm setImage:imageLeft forState:UIControlStateSelected];
    thePath = [[NSBundle mainBundle] pathForResource:@"button-60x30_sl" ofType:@"png"];
    imageLeft = [[UIImage alloc] initWithContentsOfFile:thePath];
    [btnMyListFilm setBackgroundImage:imageLeft forState:UIControlStateSelected];
    [btnMyListFilm addTarget:self action:@selector(processActionShowMyListFilm) forControlEvents:UIControlEventTouchUpInside];
    [self setVisibleLeftButtonFilmFavorite:NO];
}

-(void)setVisibleLeftButtonFilmFavorite:(BOOL)isReload
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.arrayFilmFavorite != nil && delegate.arrayFilmFavorite.count > 0) {
        if (self.btnMyListFilm == nil)
        {
            return;
        }
        UIBarButtonItem *btnleft = [[UIBarButtonItem alloc] initWithCustomView:btnMyListFilm];
        self.navigationItem.leftBarButtonItem = btnleft;
        
        if (isReload == YES && btnMyListFilm.selected)
        {
            [self initForContentPageScrollViewMyListFavorite];
        }

    }
    else
    {
        if (btnMyListFilm != nil && btnMyListFilm.selected)
        {
            btnMyListFilm.selected = NO;
            [viewSeg setSelectedSegmentIndex:0];
            [filmPageShowing setMyFilmDataArray:arrayFilmShowing];
            [filmPageShowing reloadData];
        }
        self.navigationItem.leftBarButtonItem = nil;
    }
}

-(void)setPropertiesForSegmentControl
{
    [[UISegmentedControl appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                              [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                                              [UIFont getFontBoldSize12], UITextAttributeFont,[UIColor colorWithWhite:1 alpha:0.7],UITextAttributeTextColor,[UIColor clearColor], UITextAttributeTextShadowColor,
                                                              nil] forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                              [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                                              [UIFont getFontBoldSize12], UITextAttributeFont,[UIColor whiteColor], UITextAttributeTextColor
                                                              ,[UIColor clearColor], UITextAttributeTextShadowColor,
                                                              nil] forState:UIControlStateSelected];
    
    UIImage *segUnselectedSelected = [UIImage imageNamed:@"segment_deselected_selected.png"];
    [[UISegmentedControl appearance] setDividerImage:segUnselectedSelected forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"segment_selected_deselected.png"];
    [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"segment_deselected_deselected.png"];
    [[UISegmentedControl appearance] setDividerImage:segmentUnselectedUnselected forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

    [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageNamed:@"segment_bg.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageNamed:@"segment_selected_hl.png"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
}

#pragma mark Action Button
- (void) selectedSegmentChanged
{
    [btnMyListFilm setSelected:NO];
    if(viewSeg.selectedSegmentIndex == 0)
    {
        curIndexPageComming = [filmPageShowing getCurrentSelectedPageIndex];
        [filmPageShowing setCurrentSelectedPage:curIndexPageShowing];
        [filmPageShowing setMyFilmDataArray:arrayFilmShowing];
        [filmPageShowing setBannerInfoList:(NSMutableArray*)self.showingBannerList];
        [filmPageShowing reloadData];
    }
    else
    {
        curIndexPageShowing = [filmPageShowing getCurrentSelectedPageIndex];
        [filmPageShowing setCurrentSelectedPage:curIndexPageComming];
        [filmPageShowing setMyFilmDataArray:arrayFilmComming];
        [filmPageShowing setBannerInfoList:(NSMutableArray*)self.comingBannerList];
        [filmPageShowing reloadData];
    }
}

#pragma mark film page scrollview delegate

-(void)filmPageScrollViewController:(FilmPagingScrollViewController *)vcFilmPageScrollView didSelectBanner:(NSDictionary *)dict atIndex:(NSUInteger)index
{
    if (dict)
    {
        NSNumber *promotionID = [dict objectForKey:@"url"]; // id or link
        if (promotionID && [promotionID isKindOfClass:[NSNumber class]] && [promotionID integerValue] != 0)
        {  
            News *promotion = nil;
            for (News *promt in [PromotionViewController sharedPromotionViewController].myArrayNews)
            {
                if (promt.news_id == [promotionID integerValue])
                {
                    promotion = promt;
                    break;
                }
            }
            if (promotion)
            {
                [[PromotionViewController sharedPromotionViewController] pushPromotionDetailViewFor:promotion];
            }
        }
        else if ([promotionID isKindOfClass:[NSString class]])
        {
            NSString *strURL = (NSString *)promotionID;
            if (strURL)
            {
                NSString *title = [dict objectForKey:@"title"];
                AdViewController *vcAd = [[AdViewController alloc] init];
                [vcAd setTitle:title];
                [vcAd setContentUrl:strURL];
                [vcAd setTabBarDisplayType:TAB_BAR_DISPLAY_HIDE];
                [self.navigationController pushViewController:vcAd animated:YES];
            }
        }
    }
}

-(void)filmPageScrollViewController:(FilmPagingScrollViewController *)vcFilmPageScrollView didSelectFilm:(Film *)film atIndex:(NSUInteger)index
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *arr = app.arrayFilmFavorite;
    [self pushVCFilmDetailWithFilm:film isFavorite:[vcFilmPageScrollView.myFilmDataArray isEqual:arr]];
}

#pragma mark film and comment delegate
-(void)pushVCFilmDetailWithFilm:(Film*)film isFavorite:(BOOL)isFavorite
{
    UINavigationController *currentView = (UINavigationController *)[self.tabBarController selectedViewController] ;
    FilmDetailViewController *filmDetail=[[FilmDetailViewController alloc] init];
    [filmDetail setIsFromFavoriteList:isFavorite];
    [filmDetail setFilm:film];
    [filmDetail setDelegate:self];
    [filmDetail setHidesBottomBarWhenPushed:YES];
    [filmDetail setTabBarDisplayType:TAB_BAR_DISPLAY_HIDE];
    [currentView pushViewController:filmDetail animated:YES];
}

-(void)pushVCFilmCommentWithFilm:(Film*)film{
    UINavigationController *currentView = (UINavigationController *)[self.tabBarController selectedViewController] ;
    CommentFilmView *cmt=[[CommentFilmView alloc] init];
    [cmt setTabBarDisplayType:TAB_BAR_DISPLAY_AUTO];
    [cmt setFilm:film];
    [currentView pushViewController:cmt animated:YES];
}

#pragma mark - ASIHttpRequestDelegate
- (void)loadLayoutFilm:(BOOL)isLocal
{
    if (isLocal && [AppDelegate isNetWorkValiable]) {
        [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR_AND_TABBAR];
    }
    if (arrayFilmShowing) {
        [arrayFilmShowing removeAllObjects];
    } else {
        arrayFilmShowing = [[NSMutableArray alloc] init];
    }
    
    if (arrayFilmComming) {
        [arrayFilmComming removeAllObjects];
    } else {
        arrayFilmComming = [[NSMutableArray alloc] init];
    }
    for (Film *film in [self.fetchedResultsController fetchedObjects]) {
        if (film.status_id.intValue == ID_REQUEST_FILM_LIST_SHOWING) {
            [arrayFilmShowing addObject:film];
        } else {
            [arrayFilmComming addObject:film];
        }
    }
    [self executeLoadFilmToLayout:isLocal];
    lastTimeLoading = [NSDate timeIntervalSinceReferenceDate];
}

-(void)executeLoadFilmToLayout:(BOOL)isLocal
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (arrayFilmShowing.count == 0)
    {
        if (!isLocal || ![AppDelegate isNetWorkValiable]) {
            [self hideLoadingView];
        }
        return;
    }
    
    NSDate *endDate = [NSDate date];
    NSDate *startDate = [AppDelegate getStartTime];
    NSTimeInterval timeDiff = [endDate timeIntervalSinceDate:startDate];
    [[GAI sharedInstance].defaultTracker sendTimingWithCategory:@"Loading" withValue:timeDiff withName:@"LoadFilm" withLabel:nil];
    appDelegate.arrayFilmShowing = self.arrayFilmShowing;//ENTRY
    appDelegate.arrayFilmComing = self.arrayFilmComming;//ENTRY
    //get list of film liked from file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:FILE_NAME_LIST_FILM_FAVORITE];
    NSArray *filmLikedList = nil;
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    //set showing/coming/favorite list
    if (fileExist)
    {
        filmLikedList = [NSArray arrayWithContentsOfFile:path];
        [appDelegate updateFavouriteFilmListWithArrayID:filmLikedList isFromServer:NO];
    }
    [self initDataForFilmShow];
    // AND TO DELETE A MODEL :
//    [[RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext deleteObject:myobject];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NOTIFICATION_NAME_FILM_LIST_DID_LOAD object:nil];
}

#pragma mark RKManagerDelegate implementation
-(void)processResultResponseDictionaryMapping:(DictionaryMapping *)dictionary requestId:(int)request_id
{
    if (request_id == ID_REQUEST_GET_LIST_FILM_LIKE)
    {
        [self combineFavouriteFilmListLocalAndServerArray:[dictionary.curDictionary objectForKey:@"result"]];
    }
    else if (request_id == ID_REQUEST_GET_FILE_DEFINE_TEXT)
    {
        [[APIManager sharedAPIManager] parseToGetFileTextDefine:dictionary.curDictionary];
        //se goi ham load banner o day
        [[APIManager sharedAPIManager] getBannerListWithResponseTo:self];
    }
}

-(void)processResultResponseArrayMapping:(ArrayMapping *)array requestId:(int)request_id
{
    if (request_id == ID_REQUEST_BANNER_LIST)
    {
//        [self loadLayoutFilm:YES];
        [[APIManager sharedAPIManager] getListAllFilmContext:[MainViewController sharedMainViewController]];
        [self loadBannerInfo:array];
    }
}

- (void)loadBannerInfo:(ArrayMapping *)array
{
    if (![array isKindOfClass:[ArrayMapping class]])
    {
        return;
    }
    self.showingBannerList = [NSMutableArray arrayWithArray:array.curArray];
    self.comingBannerList = self.showingBannerList;
}

- (void)combineFavouriteFilmListLocalAndServerArray:(NSArray *)svfavouriteFilmList
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [app updateFavouriteFilmListWithArrayID:svfavouriteFilmList isFromServer:YES];
    
    if (filmPageShowing != nil)//filmPageList
    {
        [self setVisibleLeftButtonFilmFavorite:YES];
    }
}

#pragma mark process when keyboard show and hide
-(void)registerForKeyboardNotifications
{
    if (_isRegisteredForKeyboardNotification)
    {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyBoard:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyBoard) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideKeyBoard) name:UIKeyboardDidHideNotification object:nil];
    _isRegisteredForKeyboardNotification = YES;
}

-(void)setActiveInputView:(CustomTextView *)inputView
{
    _activedInput = inputView;
}

- (BOOL)isScrollViewClass:(UIView *)v
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        return [v isKindOfClass:[UIScrollView class]];
    }
    else
    {
        if (v.superview && [v.superview isKindOfClass:[UITableViewCell class]]) {
            return NO;
        }
        return [v isKindOfClass:[UIScrollView class]];
    }
}

-(void)showKeyBoard:(NSNotification*)notification
{
    if (!_activedInput) {
        return;
    }
    CGRect keyboardRect = [[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *currentNavi = (UINavigationController *)[delegate.tabBarController selectedViewController] ;
    UIViewController *currentViewController = [currentNavi topViewController];
    
    
    CGRect frameTextView= _activedInput.frame;
    UIView *v = _activedInput;
    while (v.superview && v != currentViewController.view && ![self isScrollViewClass:v])
    {
        frameTextView = [v.superview convertRect:frameTextView fromView:v];
        v = v.superview;
    }
    currentViewController.view.window.clipsToBounds =YES;
    UIScrollView *sv = nil;
    if ([v isKindOfClass:[UIScrollView class]])
    {
        sv = (UIScrollView *) v;
        if ([sv isKindOfClass:[UITableView class]])
        {
//            fixing bug: can not get content size
            CGRect theFrame = sv.frame;
            sv.frame = CGRectZero;
            sv.frame = theFrame;
            [sv layoutIfNeeded];
        }
        CGSize size = sv.contentSize;
        _backupSize = size;
        size.height += keyboardRect.size.height;
        sv.contentSize = size;
    }
    NSInteger padding = 10;
    NSInteger _offset_y = frameTextView.origin.y + frameTextView.size.height - (currentViewController.view.frame.origin.y +currentViewController.view.frame.size.height - keyboardRect.size.height) + padding;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        _offset_y += TITLE_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT;
    }
    //    overlap
    if (_offset_y > 0)
    {
        if (sv)
        {
            CGPoint offset = sv.contentOffset;
            _backupOffset = offset;
            offset.y += _offset_y;
            [sv setContentOffset:offset animated:YES];
        }
        else
        {
            _backupOffset = CGPointMake(currentViewController.view.frame.origin.x, currentViewController.view.frame.origin.y);
            CGRect rect = CGRectMake(_backupOffset.x, _backupOffset.y - _offset_y, currentViewController.view.frame.size.width, currentViewController.view.frame.size.height);
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            currentViewController.view.frame = rect;
            [UIView commitAnimations];
        }
    }
}

-(void)hideKeyBoard
{
    if (!_activedInput) {
        return;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *currentNavi = (UINavigationController *)[delegate.tabBarController selectedViewController] ;
    UIViewController *currentViewController = [currentNavi topViewController];
    CGRect frameTextView= _activedInput.frame;
    UIView *v = _activedInput;
    while (v.superview && v != currentViewController.view && ![self isScrollViewClass:v])
    {
        frameTextView = [v.superview convertRect:frameTextView fromView:v];
        v = v.superview;
    }
    
    if ([v isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *sv = (UIScrollView *) v;
        [sv setContentOffset:_backupOffset animated:YES];
    }
    else
    {
        CGRect rect = CGRectMake(_backupOffset.x, _backupOffset.y, currentViewController.view.frame.size.width, currentViewController.view.frame.size.height);
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        currentViewController.view.frame = rect;
        [UIView commitAnimations];
    }
    _activedInput = nil;
}

-(void)doHideKeyboardAnimation: (UIScrollView *) sv
{
    [sv setContentSize:_backupSize];
}

-(void)didHideKeyBoard
{
    if (!_activedInput) {
        return;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *currentNavi = (UINavigationController *)[delegate.tabBarController selectedViewController] ;
    UIViewController *currentViewController = [currentNavi topViewController];
    CGRect frameTextView= _activedInput.frame;
    UIView *v = _activedInput;
    while (v.superview && v != currentViewController.view && ![self isScrollViewClass:v])
    {
        frameTextView = [v.superview convertRect:frameTextView fromView:v];
        v = v.superview;
    }
    
    if ([v isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *sv = (UIScrollView *) v;
        [sv setContentSize:_backupSize];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_TAG_NOTIFY_RATING_APP) {
        if (![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:ALERT_BUTTON_REMIND])
        {
//            will not remind
            [APIManager setValueForKey:[NSNumber numberWithInteger:-1] ForKey:KEY_STORE_NUMBER_APP_LAUNCHING];
//            rate app
            if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:ALERT_BUTTON_OK_RATE])
            {
                NSString *iOSAppStoreURLFormat = APP_RATING_LINK;
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iOSAppStoreURLFormat]];
            }
        }
    }
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
