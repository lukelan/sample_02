//
//  ChooseCityViewController.m
//  MovieTicket
//
//  Created by Nhan Mai on 3/4/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "ChooseCityViewController.h"
#import "APIManager.h"
#import "AppDelegate.h"
#import "CinemaViewController.h"

@interface ChooseCityViewController ()
//@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController; <NSFetchedResultsControllerDelegate>
@end

@implementation ChooseCityViewController
@synthesize table, listOfCity, chosenCity;
@synthesize fromView;

-(void) dealloc
{
    [listOfCity removeAllObjects];
    table = nil;
    chosenCity = nil;
    fromView = nil;
    listOfCity = nil;
}

- (void)reloadDataView:(NSArray *)mappingResult
{
    if (!mappingResult) {
        return;
    }
    if (self.listOfCity) {
        [self.listOfCity removeAllObjects];
    } else {
        self.listOfCity = [[NSMutableArray alloc] initWithArray:mappingResult ];
    }
    [self.table reloadData];
}


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - TITLE_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
        table.dataSource = self;
        table.delegate = self;
        table.backgroundView = nil;
        viewName = CHOOSE_CITY_VIEW_NAME;
        fromView = ((AppDelegate*)[[UIApplication sharedApplication]delegate]).currentView;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!self.listOfCity || self.listOfCity.count == 0) {
        [[APIManager sharedAPIManager] getListLocationWithContext:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
	// Do any additional setup after loading the view.
    
    //set navigation bar title    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:@"Xem rạp chiếu tại"];
    
//    self.navigationController.navigationBar.clipsToBounds = NO;
    // add table
    [self.view setBackgroundColor:[UIFont colorBackGroundApp]];
    [self.view addSubview:self.table];
    self.trackedViewName = @"UIChangeCity";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableViewDataSource vs TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.listOfCity count] == 0) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listOfCity count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    LOG_123PHIM(@"cellForRowAtIndexPath");
    Location* seletecLocation = [self.listOfCity objectAtIndex:indexPath.row];
    NSString* cellIdentifier = @"cell";
    UITableViewCell* retCell = [table dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == retCell) {
        retCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    //set selected checkbox
    if (seletecLocation.location_id == self.chosenCity.location_id) {
        retCell.accessoryType = UITableViewCellAccessoryCheckmark;
        retCell.textLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:101.0/255.0 blue:102.0/255.0 alpha:1.0];
        [retCell.textLabel setFont:[UIFont getFontNormalSize13]];
    }
    
    retCell.textLabel.text = [NSString stringWithFormat:@"%@", seletecLocation.location_name];
    return  retCell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Chọn thành phố";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Location *selectLocation = [self.listOfCity objectAtIndex:indexPath.row];
    BOOL isNeedReload = (selectLocation.location_id != self.chosenCity.location_id);
    if (isNeedReload) {
        [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Cinema" withAction:@"Change" withLabel:@"city" withValue:[NSNumber numberWithInteger:109]];
        
        self.chosenCity = selectLocation;
        [APIManager saveLocationObject:self.chosenCity];
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        //clean list cinema
        [delegate setArrayCinema:nil];
        
        // clean list cinema with distance
        [delegate setArrayCinemaDistance:nil];
        
        //send nofification
        NSNotificationCenter* notificationSender = [NSNotificationCenter defaultCenter];
        [notificationSender postNotificationName: NOTIFICATION_NAME_NEW_CITY object:nil];
        
        // send log to 123phim server
        [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:delegate.currentView
                                                              comeFrom:delegate.currentView
                                                          withActionID:ACTION_LOCATION_CHANGE_CITY
                                                         currentFilmID:[NSNumber numberWithInt:NO_FILM_ID]
                                                       currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID]
                                                       returnCodeValue:0 context:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)chooseCityDone
{
//    LOG_123PHIM(@"chooseCityDone");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark RKManageDelegate
#pragma mark -
-(void)processResultResponseArray:(NSArray *)array requestId:(int)request_id;
{
    [self reloadDataView:array];
}
@end
