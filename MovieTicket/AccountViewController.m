//
//  AccountViewController.m
//  123Phim
//
//  Created by Nhan Mai on 3/13/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "AccountViewController.h"
#import "AppDelegate.h"
#import "AboutViewController.h"
#import "FavoriteFilmViewController.h"
#import "MainViewController.h"
#import "FacebookManager.h"
#import "Friend123PhimViewController.h"
#import "NotFriend123PhimViewController.h"
#import "CinemaViewController.h"
#import "APIManager.h"
#import "Friend.h"
#import "VersionNotificationViewController.h"
#import "TicketListViewController.h"
#import "Ticket.h"
#import "DefineDataType.h"
#import "ProfileTableViewCell.h"
#import "AppDelegate.h"
#import "EventWebViewController.h"
#import "UIDevice+IdentifierAddition.h"

// cell postion definition
// Account view
#define CELL_INFO 0
#define CELL_EVENT 1
#define CELL_POSTION 2
#define CELL_FANPAGE 3
#define CELL_FRIEND 4
#define CELL_HISTORY 5
#define CELL_TICKET 6
#define CELL_NOTIFY 7
#define CELL_ABOUT 8
#define CELL_CLEAR_DATA 9
#define CELL_BUTTON 10

@interface AccountViewController ()<RKManagerDelegate>

@end

@implementation AccountViewController
@synthesize table, logined, userProfile;
@synthesize chosenLocation;
@synthesize locationDescription;
@synthesize friendList123Phim, friendList;
@synthesize isLocationUpdating, isNeedUpdateData;
@synthesize loginState;
@synthesize friend123PhimCount, friendNot123PhimCount;
@synthesize eventList;

static bool isEvent = NO;

-(void) dealloc
{
    [friendList123Phim removeAllObjects];
    [friendList removeAllObjects];
    [eventList removeAllObjects];
    isNeedSendUpdateNotify = nil;
    lastTimeLoading = 0;
    isNeedUpdateData = nil;
    isLocationUpdating = nil;
    friend123PhimCount = nil;
    friendNot123PhimCount =nil;
    loginState = nil;
    table = nil;
    logined = nil;
    userProfile = nil;
    chosenLocation = nil;
    locationDescription = nil;
    friendList123Phim = nil;
    friendList = nil;
    eventList = nil;
    _appdelegate = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization

        [self.tabBarItem setTitle:@"Cá nhân"];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"footer-button-personal-active.png"]
                      withFinishedUnselectedImage:[UIImage imageNamed:@"footer-button-personal.png"]];
        
        // TrongV - 08/12/2013 - Make the same style with others tabbar items.
        [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor whiteColor], UITextAttributeTextColor,
                                                   nil] forState:UIControlStateNormal];
        
        self.locationDescription = @"";
        self.isNeedUpdateData = NO;
        self.isLocationUpdating = NO;
        self.friend123PhimCount = @"0";
        self.friendNot123PhimCount = @"0";
        friendList123Phim = [[NSMutableArray alloc] init];
        self.friendList = [[NSMutableArray alloc] init];
        eventList = [[NSMutableArray alloc] init];
        
        // TrongV - 08/12/2013 - Show Tab bar as default
        self.tabBarDisplayType = TAB_BAR_DISPLAY_SHOW;
        
        viewName = ACCOUNT_VIEW_NAME;
        
        //register receiving new city notification
        NSNotificationCenter* receiveNotification = [NSNotificationCenter defaultCenter];
        [receiveNotification addObserver:self selector:@selector(handleNewCity) name:NOTIFICATION_NAME_NEW_CITY object:nil];
        [receiveNotification addObserver:self selector:@selector(didLoadFacebookAccount:) name:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_DID_LOAD_SUCCESFUL object:nil];
        [receiveNotification addObserver:self selector:@selector(didLoginFacebookFail:) name:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_DID_LOGIN_FAIL object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    //set locationDescription
    self.locationDescription = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).userPosition.address;
    
    self.appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];;

    [self.appdelegate setTitleLabelForNavigationController:self withTitle:@"Tài khoản"];
    
    chosenLocation = [[Location alloc] init];
    self.loginState = nil;
    
    
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - TITLE_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - TAB_BAR_HEIGHT) style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundView = nil;
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    [self.view addSubview:self.table];
    
//    if ([self.appdelegate isUserLoggedIn] && self.friendList123Phim.count == 0) {
//        [self downloadFriend];
//    }
    if ([self.appdelegate isUserLoggedIn])
    {
        [self downloadFriend];
    }
    self.trackedViewName = viewName;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkReloadEvent];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isNeedSendUpdateNotify = NO;
    
    Location* appLocation = [APIManager loadLocationObject];
    if (appLocation.location_id != self.chosenLocation.location_id && appLocation) {
        self.chosenLocation = appLocation;
        [self displayCity];
    }
    
    
    // account
    if (![self.appdelegate isUserLoggedIn])
    {
        self.loginState = nil;
    
    }
    else
    {
        if (loginState && [self.appdelegate.userProfile.username isEqualToString:loginState])
        {
            return;
        }
        [self reloadTableView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (isNeedSendUpdateNotify) {
        [[APIManager sharedAPIManager] notifyRequestUpdateStatusPhim:[APIManager getValueAsBoolForKey:KEY_STORE_IS_RECEIVE_NOTIFY_NEW_PHIM] promotionStatus:[APIManager getValueAsBoolForKey:KEY_STORE_IS_RECEIVE_NOTIFY_PROMOTION] dateGoldStatus:[APIManager getValueAsBoolForKey:KEY_STORE_IS_RECEIVE_NOTIFY_DATE_GOLD] context:nil];
    }
    
//    [self.lm stopUpdatingLocation];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didLoadFacebookAccount:(id)sender
{
//    LOG_123PHIM(@"didLoadFacebookAccount");
    [[APIManager sharedAPIManager] getRequestLoginFaceBookAccountWithContext:[APIManager sharedAPIManager]];
    [self downloadFriend];
    if ([self.appdelegate isUserLoggedIn])
    {
        [self downloadFriend];
    }
}

-(void)checkReloadEvent
{
    NSTimeInterval timeCurrent = [NSDate timeIntervalSinceReferenceDate];
    int timeLitmit = 36000;
    id temp = MAX_TIME_RETRY_GET_LIST_NEWS;
    if ([temp isKindOfClass:[NSNumber class]]) {
        timeLitmit = [temp intValue];
    }
    if ((timeCurrent - lastTimeLoading) > timeLitmit)
    {
        [[APIManager sharedAPIManager] getEvent:self];
    }
}

#pragma mark tableview datasource and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger ret = CELL_BUTTON + 1;
    return ret;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case CELL_INFO: //info
            return 1;
            
        case CELL_EVENT:
            if (isEvent) {
                return (1 + eventList.count);
            }
            break;
        
        case CELL_POSTION: //postion
            return 2;

        case CELL_FANPAGE:
#ifdef LOGIN_FB_BY_WEB
            if ([self.appdelegate isUserLoggedIn])
            {
                return 1;
            }
#endif
            break;
            
        case CELL_FRIEND: //friend
            if ([self.appdelegate isUserLoggedIn]) {
                return 3;
            }
            break;
        
        case CELL_HISTORY: //history
            return 1;
        
        case CELL_TICKET: //ticket
            return 1;
            
        case CELL_NOTIFY: //notify
            return 4;
            
        case CELL_ABOUT: // about, check version, rating app, reset data
            return 3;
        
        case CELL_BUTTON: //button
            if ([self.appdelegate isUserLoggedIn]) {
                return 1;
            }
            break;
        case CELL_CLEAR_DATA:
            return 1;
    }
    return 0;
    
}

#pragma mark UITableViewCell
- (UITableViewCell *)cellForUserProfile:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self getCellIdentify:indexPath];
    UITableViewCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[ProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        ((ProfileTableViewCell *)cell).text = ACCOUNT_LOGIN_DESC;
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didLoadUserProfile:) name:NOTIFICATION_NAME_PROFILE_CELL_USER_PROFILE_DID_LOAD object:nil];
    }
    [cell layoutIfNeeded];
    return cell;
}

- (UITableViewCell *)cellForNormal:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self getCellIdentify:indexPath];
    UITableViewCell *cell;

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (UITableViewCell *)cellInSection_0:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    return [self cellForUserProfile:tableView atIndexPath:indexPath];
}

- (UITableViewCell *)cellInSection_1:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForNormal:tableView atIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        
        UILabel *mainText = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 20)];
        mainText.backgroundColor = [UIColor clearColor];
        mainText.font = [UIFont getFontBoldSize14];
        mainText.text = @"Bật định vị";
        
        UITextView *secondText = [[UITextView alloc] initWithFrame:
                                  CGRectMake(2, mainText.frame.origin.y + mainText.frame.size.height + 4, 295, 45)];
        secondText.tag = 124;
        secondText.scrollEnabled = NO;
        secondText.editable = NO;
        secondText.font = [UIFont getFontNormalSize14];
        secondText.textColor = [UIColor grayColor];
        secondText.backgroundColor = [UIColor clearColor];
        secondText.text = [APIManager getBooleanInAppForKey:KEY_STORE_IS_SHOW_MY_LOCATION] ? self.locationDescription : @"";
        [cell.contentView addSubview:mainText];
        [cell.contentView addSubview:secondText];
        [cell setClipsToBounds:YES];
        
        
        UISwitch *locationSwitcher = [[UISwitch alloc] initWithFrame:CGRectZero];
        locationSwitcher.tag = 123;
        locationSwitcher.on = [APIManager getBooleanInAppForKey:KEY_STORE_IS_SHOW_MY_LOCATION];
        
        CGRect frame = locationSwitcher.frame;
        frame.origin.x = 211;
        frame.origin.y = 8;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
              frame.origin.x = 250;
        }
        locationSwitcher.frame = frame;
        [locationSwitcher addTarget:self action:@selector(handleOnOffCurrentPos:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:locationSwitcher];


    } else {
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Rạp tại";
        cell.textLabel.font = [UIFont getFontBoldSize14];
        UILabel* cityName = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 200, 20)];
        cityName.highlightedTextColor = [UIColor whiteColor];
        cityName.tag = 123;
        cityName.font = [UIFont getFontNormalSize13];
        cityName.textAlignment = UITextAlignmentRight;
        cityName.text = self.chosenLocation.location_name;
        cityName.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:cityName];
        cell.accessibilityLabel = @"1_1";
    }
    
    return cell;
}

- (UITableViewCell *)cellInFanPageSectionWithTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForNormal:tableView atIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"Fanpage 123Phim";
            cell.textLabel.font = [UIFont getFontBoldSize14];
            UIWebView *wv = [[UIWebView alloc] initWithFrame:CGRectMake(200, 12, 100, 20)];
            [wv setBackgroundColor:[UIColor clearColor]];
            [wv setOpaque:NO];
            wv.tag = 123;
            [cell.contentView addSubview:wv];
            [wv setDelegate:self];
        }
            break;
    }
    [self reloadCellInFanPageSectionWithCell:cell];
    [cell setClipsToBounds:YES];
    return cell;
}

-(void) reloadCellInFanPageSectionWithCell:(UITableViewCell*)cell
{
    UIWebView *wv = (UIWebView *)[cell.contentView viewWithTag:123];
    if ([wv isKindOfClass:[UIWebView class]])
    {
        NSString *url = @"http://www.facebook.com/plugins/like.php?href=https://facebook.com/123phim&width=100&height=20&colorscheme=light&layout=button_count&action=like&show_faces=true&send=false&appId=116326268554352&locale=en_US";
        [wv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *strUrl = [request.URL absoluteString];
    return ([strUrl rangeOfRegex:@"from_login"].location == NSNotFound);
}

- (UITableViewCell *)cellInSection_2:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForNormal:tableView atIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    switch (indexPath.row) {
        case 0:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = @"Bạn bè";
            cell.textLabel.font = [UIFont getFontBoldSize14];
        }
            break;
            
        case 1:
        {
            cell.textLabel.text = @"123Phim";
            cell.textLabel.font = [UIFont getFontNormalSize13];
            UILabel* numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            numberLabel.tag = 123;
            numberLabel.textColor = [UIColor whiteColor];
//            numberLabel.textAlignment = UITextAlignmentRight;
            numberLabel.backgroundColor = [UIColor grayColor];
            numberLabel.layer.cornerRadius = 7;
            numberLabel.layer.masksToBounds = YES;
            numberLabel.font = [UIFont getFontNormalSize13];
            [cell.contentView addSubview:numberLabel];
        }
            break;
            
        case 2:
        {
            cell.textLabel.text = @"Mời tham gia 123Phim";
            cell.textLabel.font = [UIFont getFontNormalSize13];
            UILabel* numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            numberLabel.tag = 123;
            numberLabel.textColor = [UIColor whiteColor];
           // numberLabel.textAlignment = UITextAlignmentRight;
            numberLabel.backgroundColor = [UIColor grayColor];
            numberLabel.layer.cornerRadius = 7;
            numberLabel.layer.masksToBounds = YES;
            numberLabel.font = [UIFont getFontNormalSize13];
            [cell.contentView addSubview:numberLabel];
        }
            break;
    }
    
    return cell;
}

- (UITableViewCell *)cellInSection_2_2:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForNormal:tableView atIndexPath:indexPath];    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    if (eventList.count >= indexPath.row) {
        Event *curEvent = [eventList objectAtIndex:(indexPath.row - 1)];
        if (curEvent) {
            cell.textLabel.text = curEvent.title;
        }
    }
    cell.textLabel.font = [UIFont getFontNormalSize13];
    return cell;
}

- (UITableViewCell *)cellInSection_Event_Title:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForNormal:tableView atIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = EVENT_TITLE;
    cell.textLabel.font = [UIFont getFontBoldSize14];
    return cell;
}


- (UITableViewCell *)cellInSection_3:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForNormal:tableView atIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"Phim phải xem";
    cell.textLabel.font = [UIFont getFontBoldSize14];
    return cell;
}

- (UITableViewCell *)cellInSection_4:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForNormal:tableView atIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"Vé đã mua";
    cell.textLabel.font = [UIFont getFontBoldSize14];
    return cell;
}


- (UITableViewCell *)cellInSection_5:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForNormal:tableView atIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"Nhận thông báo";
            cell.textLabel.font = [UIFont getFontBoldSize14];
        }
        break;
            
        case 1:
        {
            cell.textLabel.text = @"Phim mới";
            cell.textLabel.font = [UIFont getFontNormalSize13];
            UISwitch* onof = [[UISwitch alloc] initWithFrame:CGRectZero];
            [onof setOn:[APIManager getValueAsBoolForKey:KEY_STORE_IS_RECEIVE_NOTIFY_NEW_PHIM]];
            CGRect frame = onof.frame;
            frame.origin.x = 211;
            frame.origin.y = 8;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            {
                frame.origin.x = 250;
            }
            onof.frame = frame;
            [onof addTarget:self action:@selector(handleOnOffPhimmoiNotify:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:onof];
        }
            break;
            
        case 2:
        {
            cell.textLabel.text = @"Khuyến mãi hot";
            cell.textLabel.font = [UIFont getFontNormalSize13];
            UISwitch* onof = [[UISwitch alloc] initWithFrame:CGRectZero];
            [onof setOn:[APIManager getValueAsBoolForKey:KEY_STORE_IS_RECEIVE_NOTIFY_PROMOTION]];
            CGRect frame = onof.frame;
            frame.origin.x = 211;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            {
                frame.origin.x = 250;
            }
            frame.origin.y = 8;
            onof.frame = frame;
            [onof addTarget:self action:@selector(handleOnOffKhuyenmaihotNotify:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:onof];
        }
            break;
            
        case 3:
        {
            cell.textLabel.text = @"Ngày vàng khuyến mãi";
            cell.textLabel.font = [UIFont getFontNormalSize13];
            UISwitch* onof = [[UISwitch alloc] initWithFrame:CGRectZero];
            [onof setOn:[APIManager getValueAsBoolForKey:KEY_STORE_IS_RECEIVE_NOTIFY_DATE_GOLD]];
            CGRect frame = onof.frame;
            frame.origin.x = 211;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            {
                frame.origin.x = 250;
            }
            frame.origin.y = 8;
            onof.frame = frame;
            [onof addTarget:self action:@selector(handleOnOffNgayvangkhuyenmaiNotify:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:onof];
        }
            break;
    }

    return cell;
}

- (UITableViewCell *)cellInSection_6:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForNormal:tableView atIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont getFontBoldSize14];
    switch (indexPath.row) {
        case 0: // about
            cell.textLabel.text = TITLE_ABOUT;
            break;
        case 1: // update
            cell.textLabel.text = TITLE_CHECK_UPDATE;
            break;
        case 2: // rating app
            cell.textLabel.text = TITLE_RATING_APP;
            break;
        default:
            break;
    }
    return cell;
}

- (void)reloadCellClearLocalData:(UITableViewCell *)cell
{
    if (!cell) {
        return;
    }
    UIButton *button = (UIButton *)[cell viewWithTag:10];
    if ([button isKindOfClass:[UIButton class]]) {
        [button setEnabled:[APIManager isStoredLocalData]];
    }
}

- (UITableViewCell *)cellInSection_ClearData:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForNormal:tableView atIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.font = [UIFont getFontBoldSize14];
    
    UIView* trans = [[UIView alloc] init];
//    [trans setFrame:cell.frame];
    trans.backgroundColor = [UIColor clearColor];
    cell.backgroundView = trans;
    cell.backgroundColor = [UIColor clearColor];
    UIImage* imageLeft = [UIImage imageNamed:@"orange_wide_button.png"];
    UIButton* suportButton = [UIButton buttonWithType:UIButtonTypeCustom];
    suportButton.frame = CGRectMake(0, 0, 300, 40);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        suportButton.frame = CGRectMake(0, 0, 320, 40);
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    [suportButton setImage:imageLeft forState:UIControlStateNormal];
    [suportButton addTarget:self action:@selector(executeClearDataLocal) forControlEvents:UIControlEventTouchUpInside];
    [suportButton setBackgroundColor:[UIColor clearColor]];
    [suportButton setTag:10];
    UILabel *lblTitle = [[UILabel alloc] init];
    [lblTitle setFont:[UIFont getFontBoldSize14]];
    [lblTitle setText:TITLE_CLEAR_LOCAL_DATA];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    CGSize size = [lblTitle.text sizeWithFont:lblTitle.font];
    [lblTitle setFrame:CGRectMake((imageLeft.size.width - size.width)/2, (imageLeft.size.height - size.height)/2, size.width, size.height)];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        [lblTitle setCenter:cell.contentView.center];
    }
    
    [suportButton addSubview:lblTitle];
    [suportButton setEnabled:[APIManager isStoredLocalData]];
    
    [cell.contentView addSubview:suportButton];
    return  cell;
}

- (UITableViewCell *)cellInSection_7:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForNormal:tableView atIndexPath:indexPath];
    UIView* transView = [[UIView alloc] initWithFrame:CGRectZero];
    transView.backgroundColor = [UIColor clearColor];
    cell.backgroundView = transView;
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 300, 40);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        cell.backgroundColor = [UIColor clearColor];
        button.frame =  CGRectMake(10, 0, 300, 40);
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    [button setBackgroundImage:[UIImage imageNamed:@"sign_out.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(handleLogout) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:button];
    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self getCellIdentify:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell) {
        
        if (indexPath.section == CELL_INFO) {
            cell = [self cellForUserProfile:tableView atIndexPath:indexPath];
        }
        else if (indexPath.section == CELL_POSTION)
        {
            if (indexPath.row == 0)
            {            
                UISwitch *switcher = (UISwitch *)[cell viewWithTag:123];
                switcher.on = [APIManager getBooleanInAppForKey:KEY_STORE_IS_SHOW_MY_LOCATION];
                
                UITextView *description = (UITextView *)[cell viewWithTag:124];
                description.text = self.locationDescription;
            }
        }
        else if (indexPath.section == CELL_FANPAGE)
        {
            [self reloadCellInFanPageSectionWithCell:cell];
        }
        else if (indexPath.section == CELL_CLEAR_DATA)
        {
            [self reloadCellClearLocalData:cell];
        }
        else if (indexPath.section == CELL_FRIEND)
        {
            if ([self.appdelegate isUserLoggedIn])
            {
                if (indexPath.row == 1) {
                    
                    UILabel *label = (UILabel *)[cell viewWithTag:123];
                    label.text = [self.friendList123Phim count] > 0
                                ? [NSString stringWithFormat:@"  %d  ", [self.friendList123Phim count]]:@"";
                    [label sizeToFit];
                    CGFloat xPos = CGRectGetWidth(cell.frame) - CGRectGetWidth(label.frame) - 52;
                    label.frame = CGRectMake(ceilf(xPos), 12, label.frame.size.width, label.frame.size.height);
                
                } else if (indexPath.row == 2) {
                
                    UILabel* label = (UILabel*)[cell viewWithTag:123];
                    label.text = [self.friendList count] > 0
                                ? [NSString stringWithFormat:@"  %d  ", [self.friendList count]]:@"";
                    [label sizeToFit];
                    CGFloat xPos = CGRectGetWidth(cell.frame) - CGRectGetWidth(label.frame) - 52;
                    label.frame = CGRectMake(ceilf(xPos), 12, label.frame.size.width, label.frame.size.height);
                }
            }
        }
        
        return cell;
    }

    switch (indexPath.section) {
        case CELL_INFO: // profile
            cell = [self cellInSection_0:tableView atIndexPath:indexPath];
            break;
        case CELL_EVENT: // profile
        {
            if (indexPath.row == 0) {
                cell = [self cellInSection_Event_Title:tableView atIndexPath:indexPath];
            } else {
                cell = [self cellInSection_2_2:tableView atIndexPath:indexPath];
            }
            break;
        }
        case CELL_POSTION: // location
            cell = [self cellInSection_1:tableView atIndexPath:indexPath];
            break;

        case CELL_FANPAGE:
            cell = [self cellInFanPageSectionWithTable:tableView atIndexPath:indexPath];
            break;
        case CELL_FRIEND: // friend
            cell = [self cellInSection_2:tableView atIndexPath:indexPath];
            break;
            
        case CELL_HISTORY: // phim phai xem
            cell = [self cellInSection_3:tableView atIndexPath:indexPath];
            break;
            
        case CELL_TICKET: // ticket
            cell = [self cellInSection_4:tableView atIndexPath:indexPath];
            break;
            
        case CELL_NOTIFY: // thong bao
            cell = [self cellInSection_5:tableView atIndexPath:indexPath];
            break;
            
        case CELL_ABOUT: // huong dan
            cell = [self cellInSection_6:tableView atIndexPath:indexPath];
            break;
            
        case CELL_BUTTON: // thoat
            cell = [self cellInSection_7:tableView atIndexPath:indexPath];
            break;
        case CELL_CLEAR_DATA:
            cell = [self cellInSection_ClearData:tableView atIndexPath:indexPath];
            break;
        default:
            break;
    }
    return cell;
}

- (void)executeClearDataLocal
{
    [APIManager resetDefaults];
    UIAlertView *locationAlert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE
                                                            message:NOTICE_CLEAR_LOCAL_DATA_DONE
                                                           delegate:nil
                                                  cancelButtonTitle:ALERT_BUTTON_OK
                                                  otherButtonTitles:nil];
    [locationAlert show];
    [self.table beginUpdates];
    [self.table reloadSections:[NSIndexSet indexSetWithIndex:CELL_CLEAR_DATA] withRowAnimation:UITableViewRowAnimationFade];
    [self.table endUpdates];
    [self cleanWarning];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CELL_INFO:
            break;
        
        case CELL_EVENT:
        {
            if (indexPath.row != 0)
            {
                EventWebViewController* eventViewController = [[EventWebViewController alloc] init];
                if (eventList.count >= indexPath.row) {
                    Event *curEvent = [eventList objectAtIndex:(indexPath.row - 1)];
                    [eventViewController setEvent:curEvent];
                }
                [eventViewController setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:eventViewController animated:YES];
            }
        }
            break;
        case CELL_POSTION:
        {
            if (indexPath.row == 1) {
                ChooseCityViewController* chooseCityViewController = [[ChooseCityViewController alloc] init];
                chooseCityViewController.chosenCity = self.chosenLocation;
                [chooseCityViewController setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:chooseCityViewController animated:YES];
            }
        }
            break;
            
        case CELL_FANPAGE:
        {
#ifdef LOGIN_FB_BY_WEB
            if ([self.appdelegate isUserLoggedIn])
            {
                NSURL *urlApp = [NSURL URLWithString:@"fb://profile/123phim"];
                [[UIApplication sharedApplication] openURL:urlApp];
            }
#endif
        }
            break;
        case CELL_FRIEND:
        {
            if (indexPath.row == 1) {
                Friend123PhimViewController* friend123 = [[Friend123PhimViewController alloc] init];
                friend123.friendList = self.friendList123Phim;
                [self.navigationController pushViewController:friend123 animated:YES];
            } else if (indexPath.row == 2) {
                [self showInviteDialog];
                [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Account"
                                         withAction:@"Invite Friend"
                                          withLabel:@"FaceBook"
                                          withValue:[NSNumber numberWithInt:105]];
            }
        }
            break;
            
        case CELL_HISTORY:
        {
            FavoriteFilmViewController* favoriteFilmViewController = [[FavoriteFilmViewController alloc] init];
            [favoriteFilmViewController setDelegate:[MainViewController sharedMainViewController]];
            [favoriteFilmViewController setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:favoriteFilmViewController animated:YES];
        }
            break;
            
        case CELL_TICKET:
        {
            TicketListViewController* ticketController = [[TicketListViewController alloc] init];
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            Friend* user = [[Friend alloc] init];
            user.user_id = delegate.userProfile.user_id;
            user.friend_name = delegate.userProfile.username;
            [ticketController setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:ticketController animated:YES];
            
        }
            break;
            
        case CELL_ABOUT:
        {
            switch (indexPath.row) {
                case 0:
                {
                    AboutViewController* aboutViewController = [[AboutViewController alloc] init];
                    [aboutViewController setHidesBottomBarWhenPushed:YES];
                    [self.navigationController pushViewController:aboutViewController animated:YES];
                }
                    break;
                case 1:
                {
                    [[GAI sharedInstance].defaultTracker  sendEventWithCategory:@"Account"
                                             withAction:@"Check Update Ver."
                                              withLabel:@"ButtonPressed"
                                              withValue:[NSNumber numberWithInt:108]];
                    
                    // send log to 123phim server
                    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:delegate.currentView
                                                                          comeFrom:delegate.currentView
                                                                      withActionID:ACTION_UPDATE_VERSION
                                                                     currentFilmID:[NSNumber numberWithInt:NO_FILM_ID]
                                                                   currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID]
                                                                   returnCodeValue:0 context:nil];
                    [self checkVersion];
                }
                    break;
                case 2:
                {
                    [[GAI sharedInstance].defaultTracker  sendEventWithCategory:@"Account"
                                                                     withAction:@"Rate App."
                                                                      withLabel:@"ButtonPressed"
                                                                      withValue:[NSNumber numberWithInt:108]];
                    [self rateApp];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    switch (indexPath.section) {
        case CELL_INFO:
            if([self.appdelegate isUserLoggedIn])
            {
                return PROFILE_CELL_DID_LOAD_HEIGHT;
            }
            else
            {
                return PROFILE_CELL_NOT_LOAD_HEIGHT;
            }
            break;
            
        case CELL_POSTION:
            if (indexPath.row == 0
                && [APIManager getBooleanInAppForKey:KEY_STORE_IS_SHOW_MY_LOCATION]
                && [self.locationDescription length] > 0) {
                height = 88;
            }
            break;
        case CELL_FANPAGE:
//            if ([self.appdelegate isUserLoggedIn])
//            {
                height = 44;
//            }
//        #ifndef LOGIN_FB_BY_WEB
//            height = 0;
//        #endif
            break;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == CELL_FANPAGE)
    {
#ifdef LOGIN_FB_BY_WEB
        if ([self.appdelegate isUserLoggedIn]) {
            CGFloat height = [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]].height;
            return (2*height + MARGIN_EDGE_TABLE_GROUP/2);
        } else {
            return 1.0;
        }
#else
        return 1.0f;
#endif
    }
    if (section == CELL_FRIEND)
    {
        if (![self.appdelegate isUserLoggedIn]) {
            return 1.0;
        }
        return MARGIN_EDGE_TABLE_GROUP/2;
    }

    if ((section == CELL_EVENT && !isEvent) ||(section == CELL_BUTTON && ![self.appdelegate isUserLoggedIn])) {
        return 1;
    }
    
    if (section == CELL_INFO) {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == CELL_FANPAGE) {
#ifdef LOGIN_FB_BY_WEB
        if (![self.appdelegate isUserLoggedIn])
        {
            return 1.0;
        }
#else
        return 1.0f;
#endif
    }
    if (section == CELL_FRIEND)
    {
        if (![self.appdelegate isUserLoggedIn]) {
            return 1.0;
        }
        return MARGIN_EDGE_TABLE_GROUP/2;
    }    
    if (section == CELL_BUTTON - 1 && ![self.appdelegate isUserLoggedIn]) {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    
    if (section == CELL_BUTTON) {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    if (section == CELL_BUTTON && ![self.appdelegate isUserLoggedIn]) {
        return 1;
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
}

- (NSString *)getCellIdentify:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSString* key = nil;
    if (indexPath.section == CELL_EVENT)
    {
        key = [NSString stringWithFormat:@"%d_%d_%d", indexPath.section, row, isEvent];
        return key;
    }
    key = [NSString stringWithFormat:@"%d_%d", indexPath.section, row];
    return key;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
#ifdef LOGIN_FB_BY_WEB
    if (section == CELL_FANPAGE && [self.appdelegate isUserLoggedIn]) {
        //Layout title tip
        CGFloat xStar = MARGIN_EDGE_TABLE_GROUP;
        CGFloat yStar = 0;
        UIView* ret = [[UIView alloc] init];
        UILabel *lblTipLikeFanpage = [[UILabel alloc] init];
        [lblTipLikeFanpage setFont:[UIFont getFontNormalSize13]];
        [lblTipLikeFanpage setBackgroundColor:[UIColor clearColor]];
        [lblTipLikeFanpage setTextColor:[UIColor grayColor]];
        [lblTipLikeFanpage setLineBreakMode:UILineBreakModeWordWrap];
        lblTipLikeFanpage.numberOfLines = 0;
        lblTipLikeFanpage.text = TIP_LIKE_FANPAGE;
        
        CGSize sizeTextTitle = [lblTipLikeFanpage.text sizeWithFont:lblTipLikeFanpage.font];
        CGFloat widthText = self.view.frame.size.width - 2*MARGIN_EDGE_TABLE_GROUP;
        [lblTipLikeFanpage setFrame:CGRectMake(xStar, yStar, widthText, 2*sizeTextTitle.height)];
        
        [ret addSubview:lblTipLikeFanpage];
        return ret;
    }
#endif
    return nil;
}

#pragma mark - selector

- (void)handleNewCity{
    [self.chosenLocation setLocationObject:[APIManager loadLocationObject]];
    [self displayCity];
    
    //jump out to Cinema view if being in map view
    UINavigationController* navi = (UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:0];
    id tab = [[navi viewControllers] lastObject]; //top viewcontroller cinemaview navigation
    if ([tab isKindOfClass:[ShowMapViewController class]]) {
        [navi popToRootViewControllerAnimated:YES];
    }
    
}

#pragma mark Update cell
- (void)displayCity
{
    UITableViewCell* cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:CELL_POSTION]];
    UILabel* cityName = (UILabel*)[cell viewWithTag:123];
    cityName.text = self.chosenLocation.location_name;
}

#pragma mark Location delegate

- (void)newLocation:(CLLocation*)location address:(NSString*)address
{
    self.locationDescription = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).userPosition.address;
    if (self.isNeedUpdateData) {
        self.isNeedUpdateData = NO;
    }
    [self reloadCellLocation];
}

#pragma mark Handle button touch
- (void)handleLogout
{
    [[APIManager sharedAPIManager] sendFavouriteFilmListIfNeedWithResponseID:nil];
    [self.appdelegate handleLogout];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Account"
                             withAction:@"Logout"
                              withLabel:@"ButtonPressed"
                              withValue:[NSNumber numberWithInt:100]];
    
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:delegate.currentView
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_LOG_OUT
                                                     currentFilmID:[NSNumber numberWithInt:NO_FILM_ID]
                                                   currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID]
                                                   returnCodeValue:0 context:nil];
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    delegate.userProfile = nil;

    [self.table reloadData];
    [self.table setContentOffset:CGPointZero animated:YES];
}

- (void)handleOnOffCurrentPos:(UISwitch *)switcher
{
    [APIManager setBooleanInApp:switcher.on ForKey:KEY_STORE_IS_SHOW_MY_LOCATION];
    
    if (switcher.on) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            
            UIAlertView *locationAlert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE
                                                                    message:LOCATION_SERVICE_NOT_TURN_ON
                                                                   delegate:nil
                                                          cancelButtonTitle:ALERT_BUTTON_OK
                                                          otherButtonTitles:nil];
            [locationAlert show];
        
        } else {
            self.isNeedUpdateData = YES;
            [((AppDelegate*)[[UIApplication sharedApplication] delegate]) updateUserLocationWithType:UpdateLocationTypeForce];
        }
    } else {
        [[CinemaViewController sharedCinemaViewController] reloadDataDistancenMyCinema];
    }
    [self reloadCellLocation];
    [[CinemaViewController sharedCinemaViewController] updateDisplayLocation];
}

- (void) handleOnOffPhimmoiNotify:(id)sender
{
    if ([sender isKindOfClass:[UISwitch class]])
    {
         UISwitch *temp = (UISwitch *)sender;
        [APIManager setBoolValue:[temp isOn] ForKey:KEY_STORE_IS_RECEIVE_NOTIFY_NEW_PHIM];
        isNeedSendUpdateNotify = YES;
    }
}

- (void) handleOnOffKhuyenmaihotNotify:(id)sender
{
    if ([sender isKindOfClass:[UISwitch class]])
    {
        UISwitch *temp = (UISwitch *)sender;
        [APIManager setBoolValue:[temp isOn] ForKey:KEY_STORE_IS_RECEIVE_NOTIFY_PROMOTION];
        isNeedSendUpdateNotify = YES;
    }
}

- (void) handleOnOffNgayvangkhuyenmaiNotify:(id)sender
{
    if ([sender isKindOfClass:[UISwitch class]])
    {
        UISwitch *temp = (UISwitch *)sender;
        [APIManager setBoolValue:[temp isOn] ForKey:KEY_STORE_IS_RECEIVE_NOTIFY_DATE_GOLD];
        isNeedSendUpdateNotify = YES;
    }
}

#pragma mark -
#pragma mark RKManagerDelegate
#pragma mark -
-(void)processResultResponseArray:(NSArray *)array requestId:(int)request_id;
{
    if (request_id == ID_REQUEST_GET_EVENT)
    {
        if (eventList) {
            [eventList removeAllObjects];
        }
        if (array == nil || array.count == 0) {
            if (isEvent) {
                isEvent = NO;
                [self reloadCellEvent];
            }
            return;
        }
        self.eventList = [NSMutableArray arrayWithArray:array];
        if ([self.eventList count] > 0 )
        {
            isEvent = YES;
            [self reloadCellEvent];
        }
        lastTimeLoading = [NSDate timeIntervalSinceReferenceDate];
    }
}

-(void)reloadCellEvent
{
    [self.table beginUpdates];
    [self.table reloadSections:[NSIndexSet indexSetWithIndex:CELL_EVENT] withRowAnimation:UITableViewRowAnimationBottom];
    [self.table endUpdates];
}

-(void)processResultResponseDictionaryMapping:(DictionaryMapping *)dictionary requestId:(int)request_id
{
    if (request_id == ID_REQUEST_CHECK_VERSION)
    {
        [self getResultCheckVersionResponse:[[APIManager sharedAPIManager] parseToGetVersionInfo:dictionary.curDictionary]];
    }
    else if (request_id == ID_REQUEST_GET_123PHIM_FRIEND)
    {
        NSDictionary* friend = dictionary.curDictionary;
        if (![friend isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSArray* installed = [friend objectForKey:@"installed"];
        NSArray* notInstalled = [friend objectForKey:@"not_installed"];
        
        [self getFriendList123Phim:installed];
        [self getFriendListNotIn123Phim:notInstalled];
        [self reloadTableView];
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
        versionNotifiCation.dismissWhenSkip = YES;
        [self.navigationController presentViewController:versionNotifiCation animated:YES completion:^{
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:VERSION_NOTICE_LASTEST delegate:nil cancelButtonTitle:nil otherButtonTitles:ALERT_BUTTON_OK, nil];
        [alert show];
    }
}

#pragma mark - Friend
- (void)downloadFriend
{
//    LOG_123PHIM(@"downloadFriend");
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    BOOL isLogin = [appDelegate isUserLoggedIn];
    if (!isLogin) {
        return;
    }

    NSString* fbId = appDelegate.userProfile.facebook_id;
    NSString* token = FBSession.activeSession.accessTokenData.accessToken;
    [[APIManager sharedAPIManager] getFacebookFriendList:fbId accessToken:token context:self];
}

- (void)getFriendList123Phim:(NSArray *)all
{
    if (self.friendList123Phim) {
        [self.friendList123Phim removeAllObjects];
    }

    for (id item in all) {
        
        Friend* friend = [[Friend alloc] init];
        friend.user_id = [item objectForKey:@"user_id"];
        friend.fb_id = [item objectForKey:@"id"];
        friend.friend_name = [item objectForKey:@"name"];
        
        [self.friendList123Phim addObject:friend];
    }
}

- (void)getFriendListNotIn123Phim:(NSArray *)all
{
    if (self.friendList) {
        [self.friendList removeAllObjects];
    }

    for (id item in all) {
        
        Friend* friend = [[Friend alloc] init];
        friend.user_id = [item objectForKey:@"user_id"];
        friend.fb_id = [item objectForKey:@"id"];
        friend.friend_name = [item objectForKey:@"name"];
        
        [self.friendList addObject:friend];
    }
}

#pragma mark - Invite
- (void)showInviteDialog
{
    NSString *message = @"Xem phim thật dễ với 123Phim! Tải ứng dụng miễn phí.";
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil message:message title:@"123Phim" parameters:nil handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
        
        [self handleInviteCompleteWithUrl:resultURL];
    }];
}

- (void)handleInviteCompleteWithUrl:(NSURL *)url {
    if (![url query]) {
//        LOG_123PHIM(@"User canceled dialog or there was an error");
        return;
    }
    
    NSDictionary *params = [self parseURLParams:[url query]];
    // Successful requests return the id of the request
    // and ids of recipients.
    NSMutableArray *recipientIDs = [[NSMutableArray alloc] init];
    for (NSString *paramKey in params) {
        if ([paramKey hasPrefix:@"to["]) {
            [recipientIDs addObject:[params objectForKey:paramKey]];
        }
    }
    if ([params objectForKey:@"request"]){
//        LOG_123PHIM(@"Request ID: %@", [params objectForKey:@"request"]);
    }
    if ([recipientIDs count] > 0) {
        [self showMessage:@"Gửi thành công."];
//        LOG_123PHIM(@"Recipient ID(s): %@", recipientIDs);
    }

}

- (NSDictionary *)parseURLParams:(NSString *)query {
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
        
		[params setObject:[[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                   forKey:[[kv objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
    return params;
}

- (void)showMessage:(NSString*)msg
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Mời tham gia 123Phim" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


#pragma mark Reload Cell
- (void)reloadTableView
{
    [self.table reloadData];
}

- (void)reloadCellLocation
{
    [self.table beginUpdates];
    [self.table reloadSections:[NSIndexSet indexSetWithIndex:CELL_POSTION] withRowAnimation:UITableViewScrollPositionNone];
    [self.table endUpdates];
}

-(void)checkVersion
{
    [[APIManager sharedAPIManager] checkAppVersion:[AppDelegate getVersionOfApplication] responseContext:self request:nil];
    
}

-(void)didLoadUserProfile:(NSNotification *) notification
{
    if (loginState && [self.appdelegate.userProfile.username isEqualToString:loginState])
    {
        return;
    }
    [self reloadTableView];
}

-(void)rateApp
{
    NSString *iOSAppStoreURLFormat = APP_RATING_LINK;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iOSAppStoreURLFormat]];
}


-(void)didLoginFacebookFail: (NSNotification *) notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:FACEBOOK_LOGIN_FAIL_DESC delegate:nil cancelButtonTitle:nil otherButtonTitles:ALERT_BUTTON_OK, nil];
    [alert show];
}

@end
