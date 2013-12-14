//
//  SelectDateViewController.m
//  MovieTicket
//
//  Created by Le Ngoc Duy on 3/28/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "SelectDateViewController.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "APIManager.h"

@interface SelectDateViewController ()

@end

@implementation SelectDateViewController
@synthesize myTableView;
@synthesize selectDateDelegate = _selectDateDelegate;
@synthesize indexSelectedDate;
@synthesize dateOfNearestSession = _dateOfNearestSession;

-(void)dealloc
{
    myTableView = nil;
    _selectDateDelegate = nil;
    indexSelectedDate = nil;
    _dateOfNearestSession = nil;
    _selectDateDelegate =nil;
    indexSelectedDate = 0;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - TITLE_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
        myTableView.dataSource = self;
        myTableView.delegate = self;
        indexSelectedDate = 0;
        myTableView.backgroundView = nil;
        _dateOfNearestSession = [[NSDate alloc] init];
        viewName = SELECT_DATE_VIEW_NAME;
    }
    return self;
}

-(void)setFullScreen
{
    CGRect frame = myTableView.frame;
    frame.size.height =  myTableView.frame.size.height + NAVIGATION_BAR_HEIGHT;
    [myTableView setFrame:frame];
}

- (void)viewWillAppear:(BOOL)animated
{
 }

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
	// add table
    [self.view setBackgroundColor:[UIFont colorBackGroundApp]];
    [self.view addSubview:self.myTableView];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:self.title];
    self.trackedViewName = viewName;
//    NSString* previewView = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).currentView;
//    NSString* currentView = viewName;
//    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:currentView comeFrom:previewView withActionID:LOG_ACTION_ID_VIEW currentFilmID:[NSNumber numberWithInt:NO_FILM_ID] currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID] returnCodeValue:0 context:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}
    
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *content = [NSDate getStringFormatFromDateByStepDay:indexPath.row date:self.dateOfNearestSession];
    NSString* cellIdentifier = [[NSString alloc] initWithFormat:@"Cell_%d_%@",indexPath.row,content];
    UITableViewCell* retCell = [myTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == retCell) {
        retCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        if (indexPath.row == self.indexSelectedDate) {
            retCell.accessoryType = UITableViewCellAccessoryCheckmark;
            retCell.textLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:101.0/255.0 blue:102.0/255.0 alpha:1.0];
        }
    }
    retCell.textLabel.text = content;
    return  retCell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Chọn ngày chiếu";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.indexSelectedDate != indexPath.row)
    {
        [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Cinema" withAction:@"Change" withLabel:@"Date" withValue:[NSNumber numberWithInteger:110]];
        
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:delegate.currentView
                                                              comeFrom:delegate.currentView
                                                          withActionID:ACTION_SESSION_CHANGE_DATE
                                                         currentFilmID:[NSNumber numberWithInt:NO_FILM_ID]
                                                       currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID]
                                                       returnCodeValue:0 context:nil];
        
        if(self.selectDateDelegate != nil && [self.selectDateDelegate respondsToSelector:@selector(receiveNumberStepDayFromNow:)])
        {
            [self.selectDateDelegate receiveNumberStepDayFromNow:indexPath.row];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
