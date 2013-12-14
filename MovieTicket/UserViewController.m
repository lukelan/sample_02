//
//  UserViewController.m
//  MovieTicket
//
//  Created by Nhan Mai on 2/18/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "UserViewController.h"
#import "DefineConstant.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "Film.h"
#import "APIManager.h"
#import "CustomImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "FilmDetailViewController.h"
#import "DelegateDatasourceSawfilm.h"
#import "DefineCategory.h"
#import "FavoriteFilmViewController.h"
#import "FacebookManager.h"
#import "MainViewController.h"

@interface UserViewController ()

@end

@implementation UserViewController
@synthesize table, yourPosition, accountList, about;
@synthesize showMapViewController;
@synthesize centerOfCinemaGroupMap, centerOfPositionChoiceMap, spanOfCinemaGroupMap, spanOfPositionChoiceMap;
@synthesize userSeeingCinemaGroup;
@synthesize sawFilmId, sawFilm, sawFilmTable;
@synthesize delegate = _delegate;

- (void)dealloc
{
    [table release];
    [yourPosition release];
    [accountList release];
    [about release];
    [showMapViewController release];
    [sawFilmId release];
    [sawFilm release];
    [sawFilmTable release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization        
        
        UIImage *selectedImage = [UIImage imageNamed:@"footer-button-personal-active.png"];
        [self.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:[UIImage imageNamed:@"footer-button-personal.png"]];
        [self.tabBarItem setTitle:@"Cá nhân"];        
        
        table = [[UITableView alloc ] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 20 -44 - 44) style:UITableViewStyleGrouped];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundView = nil;
        
        // init your position
        yourPosition = [[Position alloc] init];
        yourPosition.address = @"";
        
        showMapViewController = [[ShowMapViewController alloc] init];
        showMapViewController.delegate = self;
        spanOfCinemaGroupMap = MKCoordinateSpanMake(0.01, 0.01);

        sawFilmId = [[NSMutableArray alloc] init];
        sawFilm = [[NSMutableArray alloc] init];
        
        DelegateDatasourceSawfilm* sawFilmDelegateDatasource = [[DelegateDatasourceSawfilm alloc] init];
        sawFilmDelegateDatasource.delegate = self;
        sawFilmTable  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 300, 239) style:UITableViewStylePlain];
        sawFilmTable.tag = 123;
        sawFilmTable.delegate = sawFilmDelegateDatasource;
        sawFilmTable.dataSource = sawFilmDelegateDatasource;
        sawFilmTable.backgroundColor = [UIColor clearColor];
        sawFilmTable.layer.cornerRadius = 7.0;
        sawFilmTable.layer.masksToBounds = YES;
        
        newestSawFilmId = -1;
        self.delegate = [MainViewController sharedMySingleton];
    }
    return self;
}

- (void)viewDidLoad
{
//    NSLog(@"viewDidLoad");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [MainViewController colorBackGroundApp];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"launch_image.png"]];
    self.navigationController.navigationBar.clipsToBounds = YES;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setTitleLabelForNavigationController:self withTitle:@"Tài khoản"];
    userProfile = delegate.userProfile;
    [self.view addSubview:self.table];
}
- (void)viewWillAppear:(BOOL)animated
{
//    NSLog(@"viewWillAppear");
    // get current location
    lm = [[CLLocationManager alloc] init];
    lm.delegate = self;
    lm.desiredAccuracy = kCLLocationAccuracyBest;
    //    lm.distanceFilter = kCLDistanceFilterNone;
    lm.distanceFilter = 200;
    [lm startUpdatingLocation];
    
    // check location service, if on: load online data, off: load local data
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        //    NSLog(@"location_service is off");
        // load local data
        [self loadLocalLocation];
        UIAlertView* locationAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Bạn chưa kích hoạt tính năng định vị. Chúng tôi sẽ sử dụng vị trí lần cuối của bạn." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [locationAlert show];
        [locationAlert release];
    }
    
    // get saw filmid from file and store in sawDetailFilm
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"saw_detail_film_list.txt"];
    
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (fileExist) {
        self.sawFilmId = [NSMutableArray arrayWithContentsOfFile:path];
    }
    
    //get film object from database
    [self.sawFilm removeAllObjects];
    NSInteger i = 0;
    NSNumber* existId = 0;
    for (i = ([self.sawFilmId count] - 1); i >= 0; i--) {
        existId = [self.sawFilmId objectAtIndex:i];        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSPredicate* filmPredicate = [NSPredicate predicateWithFormat:@"film_id=%d", [existId intValue]];
        Film* film = (Film*)[delegate getManageObject:@"Film" withPredicate:filmPredicate];
        if (film) {
            [self.sawFilm addObject:film];
        }
        
    }
    
//    NSLog(@"existFilm_count: %d", [self.sawFilm count]);
//    for (Film* existFilm in self.sawFilm) {
//        NSLog(@"film(%@): %@", existFilm.film_id, existFilm.film_name);
//    }
    
    // adjust sawFilm table height for matching with number of films
    NSInteger heightOfSawFilmTabel = 0;
    if ([self.sawFilm count] > 5) {
        heightOfSawFilmTabel = 242; //5films x 44pixels + 0.5row
    }else{
        heightOfSawFilmTabel = [self.sawFilm count]*44;
    }
    CGRect frame = self.sawFilmTable.frame;
    frame.size.height = heightOfSawFilmTabel;
    self.sawFilmTable.frame = frame;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    self.trackedViewName = NSStringFromClass([self class]);
    [self.table reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveAddressAndDistance];
    if ([self.sawFilm count]) {
        Film* newestSawFilm = [self.sawFilm objectAtIndex:0];
        newestSawFilmId = [newestSawFilm.film_id integerValue];
    }
}

- (void)loadLocalLocation
{
    if (localAddressAndDistance) {
        [localAddressAndDistance release];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"myLastAddressAndDistance.txt"];
    
    localAddressAndDistance = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    self.yourPosition.positionCoodinate2D = CLLocationCoordinate2DMake([[localAddressAndDistance objectForKey:@"yourLatitude"] doubleValue], [[localAddressAndDistance objectForKey:@"yourLongitude"]doubleValue]);
}

- (void)saveAddressAndDistance
{
    //    NSLog(@"data_before_SAVE: %@", [localAddressAndDistance description]);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"myLastAddressAndDistance.txt"];
    //    NSLog(@"localAddressAndDistance_befor_write_to_file: %@", [localAddressAndDistance description]);
    if (localAddressAndDistance) {
        [localAddressAndDistance writeToFile:path atomically:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [lm stopUpdatingLocation];
    [lm release];
}

-(void)receiveLocationData:(Position*)locationData andMapStatusOfCenter:(CLLocationCoordinate2D)center andMapStatusOfSpan:(MKCoordinateSpan)span
{    
//    self.yourPosition.positionCoodinate2D = locationData.positionCoodinate2D;
//    self.yourPosition.houseNumber = locationData.houseNumber;
//    self.yourPosition.street = locationData.street;
//    self.yourPosition.ward = locationData.ward;
//    self.yourPosition.district = locationData.district;
//    self.yourPosition.city = locationData.city;
//    
//    if (YES == self.userSeeingCinemaGroup) {
//        self.centerOfCinemaGroupMap = center;
//        self.spanOfCinemaGroupMap = span;
//    }else{
//        self.centerOfPositionChoiceMap = center;
//        self.spanOfPositionChoiceMap = span;
//    }
}

#pragma mark - table callbacks

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"numberOfRowsInSection");
    NSInteger ret = 0;
    switch (section) {
        case 0:
            ret = 2;
            break;
        case 1:
//            ret = (1 + [accountList count]);
            ret = 1;
            break;
        case 2:
            ret = (0 == [self.sawFilm count]?1:[self.sawFilm count]);
//            ret = 1;
            break;
        case 3:
            ret = 1;
            break;
        case 4:
            ret = 1;
            break;
        case 5:
            ret = 1;
            break;
        default:
            break;
    }
    return ret;
    
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* ret = @"";
    switch (section) {
        case 2:
            ret = @"Vé đã mua";
            break;
        case 4:
            ret = @"Giới thiệu";
            break;
        default:
            break;
    }
    return ret;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"cellForRow (section: %d, row: %d) is call", indexPath.section, indexPath.row);
    
    UITableViewCell* retCell = nil;
    
    static NSString* cellLocation = @"cellId0";
    static NSString* cellAccountTitle = @"cellId1";
//    static NSString* cellFacebook = @"cellId2";
    static NSString* cellFilm = @"cellId3";
    static NSString* cellFilmNone = @"cellId4";
    static NSString* cellAbout = @"cellId5";
    static NSString* cellLogo = @"cellId6";
    static NSString* cellFavorite = @"cellId7";

    
    switch (indexPath.section) {
        case 0:
        {
            if (0 == indexPath.row) {
                UITableViewCell* accountTitleCell = [tableView dequeueReusableCellWithIdentifier:cellAccountTitle];
                if (nil == accountTitleCell) {
                    accountTitleCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellAccountTitle] autorelease];
//                    accountTitleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    accountTitleCell.textLabel.text = @"Tài khoản";
                    CGRect frame = accountTitleCell.contentView.frame;
                    frame.origin.x = 0;
                    frame.size.width = 290;
                    UILabel* label = [[UILabel alloc] initWithFrame:frame];
                    label.textAlignment = UITextAlignmentRight;
//                    label.highlightedTextColor = [UIColor whiteColor];
                    label.font = [self contentFont];
                    if (userProfile)
                    {
                        label.text = userProfile.username;
                    }
                    else
                    {
                        label.text = @"Đăng ký | Đăng nhập";
                    }
                    label.backgroundColor = [UIColor clearColor];
                    [accountTitleCell.contentView addSubview:label];
                    [label release];
                    accountTitleCell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                retCell = accountTitleCell;
            }
            else if (1 == indexPath.row)
            {

                UITableViewCell* logout = [tableView dequeueReusableCellWithIdentifier:cellAccountTitle];
                if (nil == logout) {
                    logout = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellAccountTitle] autorelease];
                    logout.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    logout.textLabel.text = @"Đăng nhập tài khoản khác";
                    logout.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                retCell = logout;
            }
        }
        break;
        case 1:
        {
            UITableViewCell* locationCell = [tableView dequeueReusableCellWithIdentifier:cellLocation];
            if (nil == locationCell) {
                locationCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellLocation] autorelease];
                locationCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            locationCell.textLabel.text = @"Vị trí";
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(70, 12, 202, 20)];
            label.highlightedTextColor = [UIColor whiteColor];
            label.textAlignment = UITextAlignmentRight;
            label.font = [self contentFont];
            //            label.text = @"459 Tô Hiến Thành, Q.10, TpHCM";
            label.text = [NSString stringWithFormat:@"%@ %@ %@",
                          ([self.yourPosition.street isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@", self.yourPosition.street]),
                          ([self.yourPosition.ward isEqualToString:@""]?@"":[NSString stringWithFormat:@", %@", self.yourPosition.ward]),
                          ([self.yourPosition.district isEqualToString:@""]?@"":[NSString stringWithFormat:@", %@", self.yourPosition.district])];
            
            
            label.backgroundColor = [UIColor clearColor];
            [locationCell.contentView addSubview:label];
            [label release];
            retCell = locationCell;
        }
            break;
        case 2:
            {                
                if (0 == [self.sawFilm count] && (0 == indexPath.row)) {
                    UITableViewCell* filmCellNone = [tableView dequeueReusableCellWithIdentifier:cellFilmNone];
                    if (nil == filmCellNone) {
                        filmCellNone = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellFilmNone] autorelease];
                        filmCellNone.selectionStyle = UITableViewCellSelectionStyleNone;
                        filmCellNone.userInteractionEnabled = NO;
                        filmCellNone.textLabel.font = [self contentFont];
                        filmCellNone.textLabel.text = @"Mời bạn mua vé";
                    }
                    return filmCellNone;
                }
                
                UITableViewCell* filmCell = [tableView dequeueReusableCellWithIdentifier:cellFilm];
                if (nil == filmCell) {
                    NSLog(@"create new cell");
                    filmCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellFilm] autorelease];
                    filmCell.textLabel.font = [self contentFont];
                    filmCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    CustomImageView* poster = [[CustomImageView alloc] initWithFrame:CGRectMake(5, 5, 25, 30)];
                    poster.layer.cornerRadius = 3.0;
                    poster.layer.masksToBounds = YES;
                    poster.tag = 123;
                    [filmCell.contentView addSubview:poster];
                    [poster release];
                }
                if ([self.sawFilm count]) {
                    Film* film = [self.sawFilm objectAtIndex:indexPath.row];
                    CustomImageView* imgView = (CustomImageView*)[filmCell.contentView viewWithTag:123];
                    [film setPosterImageForUIImageView:imgView.imgView];
                    filmCell.textLabel.text = [NSString stringWithFormat:@"        %@", film.film_name];
                }
                retCell = filmCell;
            }
            
            break;
            
        case 3:
            {
                UITableViewCell* favoriteFilmCell = [tableView dequeueReusableCellWithIdentifier:cellFavorite];
                if (nil == favoriteFilmCell) {
                    favoriteFilmCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellFavorite] autorelease];
                    favoriteFilmCell.textLabel.text = @"Phim yêu thích";
                    favoriteFilmCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                return favoriteFilmCell;
            }
            break;
        case 4:
            {
                UITableViewCell* aboutCell = [tableView dequeueReusableCellWithIdentifier:cellAbout];
                if (nil == aboutCell) {
                    aboutCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellAbout] autorelease];
    //                aboutCell.textLabel.text = @"about";
                    
                    // make cell no border
                    UIView* transparentView = [[UIView alloc] initWithFrame:CGRectZero];
                    transparentView.backgroundColor = [UIColor clearColor];
                    aboutCell.backgroundView = transparentView;
                    [transparentView release];
                    
                    aboutCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    UILabel* headerLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 1)];
                    headerLine.backgroundColor = [UIColor grayColor];
                    
                    UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(3, headerLine.frame.origin.y + headerLine.frame.size.height, 298, 120)];
                    text.backgroundColor = [UIColor clearColor];
                    text.numberOfLines = 0;
                    text.lineBreakMode = UILineBreakModeWordWrap;
                    text.font = [self contentFont];
                    text.text = @"123Phim là ứng dụng của công ty VNG Corporation, cung cấp thông tin phim, rạp chiếu, lịch chiếu tại tất cả các rạp lớn trên toàn quốc.\n\nThông tin phim chiếu rạp đầy đủ, mua vé an toàn, tiện lợi là những gì bạn sẽ có được khi tham gia 123Phim.";
                    
                    UILabel* footerLine = [[UILabel alloc] initWithFrame:CGRectMake(0, text.frame.origin.y + text.frame.size.height, 300, 1)];
                    footerLine.backgroundColor = [UIColor grayColor];
                    
                    [aboutCell.contentView addSubview:headerLine];
                    [aboutCell.contentView addSubview:text];
                    [aboutCell.contentView addSubview:footerLine];
                    [headerLine release];
                    [text release];
                    [footerLine release];               
                    
                }
                retCell = aboutCell;
            }
            break;
        case 5:
            {
                UITableViewCell* logoCell = [tableView dequeueReusableCellWithIdentifier:cellLogo];
                if (nil == logoCell) {
                    logoCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellLogo] autorelease];
                    
                    // make cell no border
                    UIView* transparentView = [[UIView alloc] initWithFrame:CGRectZero];
                    transparentView.backgroundColor = [UIColor clearColor];
                    logoCell.backgroundView = transparentView;
                    [transparentView release];
                    
                    logoCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    UIImageView* movieLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, -15, 80, 40)];
                    movieLogo.image = [UIImage imageNamed:@"123movie_logo.png"];
                    UIImageView* payLogo = [[UIImageView alloc] initWithFrame:CGRectMake(95, -11, 80, 40)];
                    payLogo.image = [UIImage imageNamed:@"123pay_logo.png"];
                    UIImageView* zingLogo = [[UIImageView alloc] initWithFrame:CGRectMake(190, 3, 50, 25)];
                    zingLogo.image = [UIImage imageNamed:@"zing_logo.png"];
                    UIImageView* vngLogo = [[UIImageView alloc] initWithFrame:CGRectMake(260, -10, 30, 40)];
                    vngLogo.image = [UIImage imageNamed:@"vng_logo.png"];
                    
                    [logoCell.contentView addSubview:movieLogo];
                    [logoCell.contentView addSubview:payLogo];
                    [logoCell.contentView addSubview:zingLogo];
                    [logoCell.contentView addSubview:vngLogo];
                    
                    [movieLogo release];
                    [payLogo release];
                    [zingLogo release];
                    [vngLogo release];
                    
                }
                retCell = logoCell;
            }
            break;
        default:
            break;
    }
    return retCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightRet = 44;
    
    if (4 == indexPath.section) {
        heightRet = 120;
    }
//    if (2 == indexPath.section && [self.sawFilm count] > 0) {
//        heightRet = self.sawFilmTable.frame.size.height+1;
//    }
    
    return  heightRet;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (1 == indexPath.section && 0 == indexPath.row) {
        self.userSeeingCinemaGroup = YES;
        self.showMapViewController.currentLocationState = self.userSeeingCinemaGroup;
        self.showMapViewController.mapCenterCinemaGroup = self.centerOfCinemaGroupMap;
        self.showMapViewController.mapSpanCinemaGroup = self.spanOfCinemaGroupMap;
        [self.navigationController pushViewController:self.showMapViewController animated:YES];
    }
    if (0 == indexPath.section && 1 == indexPath.row) {
        [[FBSession activeSession] closeAndClearTokenInformation];
        LoginViewController* loginViewController = [[LoginViewController alloc ]init];
        [self.navigationController pushViewController:loginViewController animated:YES];
        [loginViewController release];
    }
    if (2 == indexPath.section) {
        if ([self.sawFilm count] > 0) {
            Film* film = [self.sawFilm objectAtIndex:indexPath.row];
            if (film) {
                [self pushFilmDetailViewController:film showDetail:YES];
//                NSLog(@"self.sawFilm objectAtIndex:indexPath.row///////////: %@", [((Film*)[self.sawFilm objectAtIndex:indexPath.row]).filmPosterImage description]);
            }
        }
    }
    if (3 == indexPath.section) {
        FavoriteFilmViewController* favoriteFilmViewController = [[FavoriteFilmViewController alloc] init];
        [favoriteFilmViewController setDelegate:self.delegate];
        [self.navigationController pushViewController:favoriteFilmViewController animated:YES];
        [favoriteFilmViewController release];
    }
}

#pragma mark - location callback

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
//    NSLog(@"new locaion: %@", [newLocation description]);
    self.yourPosition.positionCoodinate2D = newLocation.coordinate;    
    CLGeocoder* geocoding = [[CLGeocoder alloc] init];
    [geocoding reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark* placeMark = [placemarks lastObject];
            if(placeMark)
            {
                [self.table reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                // update center position of showMap to this new location
                self.centerOfCinemaGroupMap = self.yourPosition.positionCoodinate2D;
            }
        }
    }];
    [geocoding release];
}

- (void)facebookButtonTouch
{
    NSLog(@"facebookButtonTouch is touch");
}

- (UIFont*) contentFont
{
    return [UIFont fontWithName:@"Helvetica" size:13];
}

- (void)pushFilmDetailViewController: (Film*)selectedFilm showDetail: (BOOL)detail
{
    [self.delegate didSelectFilm:selectedFilm];
//    Cinema_FilmDetailViewController *cinemaFilmController = [[Cinema_FilmDetailViewController alloc] init];
//    cinemaFilmController.cinemaGroupList = [[[NSMutableArray alloc] init] autorelease];
//    [cinemaFilmController setFilm:selectedFilm];
//    cinemaFilmController.showDetailView = detail;
//    [cinemaFilmController setHidesBottomBarWhenPushed:YES];
//    //    [cinemaFilmController setCinemaGroupList: self.cinemaGroupList];
//    [self.navigationController pushViewController:cinemaFilmController animated:YES];
//    [cinemaFilmController performPushViewControllerAndHideTaBar];
//    [cinemaFilmController release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
