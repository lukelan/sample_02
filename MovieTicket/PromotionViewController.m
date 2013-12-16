//
//  PromotionViewController.m
//  123Phim
//
//  Created by Le Ngoc Duy on 3/20/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "PromotionViewController.h"
#import "PromotionInfoCell.h"
#import "MainViewController.h"
#import "APIManager.h"
#import "PromotionDetailViewController.h"
#import "APIManager.h"

@interface PromotionViewController ()

@end

@implementation PromotionViewController
@synthesize tableview = _tableview;
@synthesize myArrayNews = _myArrayNews;

-(void)dealloc
{
    _tableview = nil;
    _myArrayNews = nil;
}

#pragma mark Create singleton
static PromotionViewController* _sharedMyPromotionView = nil;
+(PromotionViewController*)sharedPromotionViewController
{
    if(_sharedMyPromotionView != nil)
    {
        return _sharedMyPromotionView;
    }
    static dispatch_once_t _single_thread;//block thread
    dispatch_once(&_single_thread, ^ {
        _sharedMyPromotionView = [[super allocWithZone:nil] init];
    });//This code is called most once.
    return _sharedMyPromotionView;
}

#pragma implements these methods below to do the appropriate things to ensure singleton status.
//if you want a singleton instance but also have the ability to create other instances as needed through allocation and initialization, do not override allocWithZone: and the orther methods below
//We don't want to allocate a new instance, so return the current one
+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedPromotionViewController];
}


//We don't want to generate mutiple conpies of the singleton
-(id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"footer-button-promotion-active.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"footer-button-promotion.png"] ];
        self.title = @"Khuyến mãi";
        [self.tabBarItem setTitle:self.title];
        [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor whiteColor], UITextAttributeTextColor,
                                                    nil] forState:UIControlStateNormal];
        viewName = PROMOTION_VIEW_NAME;
        
        // TrongV - 08/12/2013 - Show Tab bar as default
        self.tabBarDisplayType = TAB_BAR_DISPLAY_SHOW;
        
        self.trackedViewName = viewName;
        // we check to load new data in viewdisappear, so no need to load when app comes active
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLoadDataIfNeed) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

-(void)checkLoadDataIfNeed
{
    if (![AppDelegate isNetWorkValiable])
    {
        return;
    }
    
    NSTimeInterval timeCurrent = [NSDate timeIntervalSinceReferenceDate];
    int timeLitmit = 36000;
    id temp = MAX_TIME_RETRY_GET_LIST_PROMOTION;
    if ([temp isKindOfClass:[NSNumber class]]) {
        timeLitmit = [temp intValue];
    }
    
    if (!self.myArrayNews || self.myArrayNews.count == 0)
    {
        [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR];
        [[APIManager sharedAPIManager] getListPromotionWithContext:self];
    }
    else if((timeCurrent - lastTimeLoading) > timeLitmit && lastTimeLoading != 0)
    {
        [[APIManager sharedAPIManager] getListPromotionWithContext:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setTitleLabelForNavigationController:self withTitle:self.title];
    
    self.tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableview.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - TITLE_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - TAB_BAR_HEIGHT) ;
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.backgroundView = nil;
    [self.view addSubview:self.tableview];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkLoadDataIfNeed];
}

#pragma mark Table Delegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.myArrayNews count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 115;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    News *currentNew = (News *)[self.myArrayNews objectAtIndex:indexPath.row];
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell_title"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PromotionInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [(PromotionInfoCell *)cell layoutPromotionCell:currentNew];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    if (cell != nil)
    {
        [(PromotionInfoCell *)cell reloadContentForProCell:currentNew];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:NSStringFromClass([PromotionDetailViewController class])
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_PROMOTION_VIEW
                                                     currentFilmID:[NSNumber numberWithInt:NO_FILM_ID]
                                                   currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID]
                                                   returnCodeValue:0 context:nil];
    News *promotion = [self.myArrayNews objectAtIndex:indexPath.row];
    [self pushPromotionDetailViewFor:promotion];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];   
}

-(void)pushPromotionDetailViewFor:(News*)promotion
{
    UINavigationController *navi = (UINavigationController *)[self.tabBarController selectedViewController];
    PromotionDetailViewController *promotionDetailController = [[PromotionDetailViewController alloc] init];
    [promotionDetailController setMyNews:promotion];
    [promotionDetailController setHidesBottomBarWhenPushed:YES];
    [navi pushViewController:promotionDetailController animated:YES];
}

#pragma mark We should process clean resource when get warning memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark RKManageDelegate
#pragma mark -
-(void)processResultResponseArray:(NSArray *)array requestId:(int)request_id;
{
    if (!array || array.count == 0) {
        return;
    }
    [self reloadDataView:array];
    [self hideLoadingView];
    lastTimeLoading = [NSDate timeIntervalSinceReferenceDate];
}

- (void)reloadDataView:(NSArray *)mappingResult
{
    if (!mappingResult) {
        return;
    }
    if (self.myArrayNews) {
        [self.myArrayNews removeAllObjects];
        self.myArrayNews = nil;
    }
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:mappingResult];
    self.myArrayNews = temp;
    [self.tableview reloadData];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NOTIFICATION_NAME_PROMOTION_LIST_DID_LOAD object:nil];
}

@end
