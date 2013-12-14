//
//  UserProfileViewController.m
//  123Phim
//
//  Created by Nhan Mai on 6/28/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "UserProfileViewController.h"
#import "AppDelegate.h"
#import "APIManager.h"
#import "DefineConstant.h"
#import "FriendInfoCell.h"
#import "MainViewController.h"
#import "CinemaListViewController.h"
#import "TicketListViewController.h"
#import "TicketListTableViewController.h"
#import "FavoriteFilmListViewController.h"

#define SECTION_NAME 0
#define SECTION_PROFILE 1
#define PROFILE_TITLE_LIKE_FILM @"Phim yêu thích"
#define PROFILE_TITLE_LIKE_CINEMA @"Rạp yêu thích"
#define PROFILE_TITLE_CHECKIN_CINEMA @"Rạp check in"
#define PROFILE_TITLE_BUY_TICKET @"Vé đã mua"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController
@synthesize user = _user;
@synthesize sectionList = _sectionList;
@synthesize profileList = _profileList;
@synthesize favoriteCinemaList, checkInCinemaList, favoriteFilmList, ticketList;

-(void) dealloc
{
    [favoriteCinemaList removeAllObjects];
    [checkInCinemaList removeAllObjects];
    [favoriteFilmList removeAllObjects];
    [ticketList removeAllObjects];
    
    table = nil;
    _user = nil;
    _sectionList = nil;
    _profileList = nil;
    favoriteCinemaList = nil;
    checkInCinemaList = nil;
    favoriteFilmList = nil;
    ticketList = nil;
}
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _profileList = [[NSArray alloc] initWithObjects:PROFILE_TITLE_LIKE_FILM, PROFILE_TITLE_BUY_TICKET, PROFILE_TITLE_LIKE_CINEMA, PROFILE_TITLE_CHECKIN_CINEMA, nil];
        _sectionList = [[NSArray alloc] initWithObjects:@" ",@" ", nil];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    [GoogleConversionPing pingRemarketingWithConversionId:@"983463027" label:@"jLppCIXKgAgQ8-j51AM" screenName:@"UserProfileViewController" customParameters:nil];
	// Do any additional setup after loading the view.
    favoriteCinemaList = [[NSMutableArray alloc] init];
    checkInCinemaList = [[NSMutableArray alloc] init];
    favoriteFilmList = [[NSMutableArray alloc] init];
    ticketList = [[NSMutableArray alloc] init];

    [[APIManager sharedAPIManager] getListTicketWithUser:self.user.user_id context:self];
//    [[APIManager sharedAPIManager] getListTicketWithUser:@"209698" context:self];
    [[APIManager sharedAPIManager] getListOfCheckedInCinema:self.user.user_id context:self];
    [[APIManager sharedAPIManager] getListFilmLikeOfUser:self.user.user_id context:self];
    
    //set view appearence
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    
    //set navigation bar
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [appDelegate setTitleLabelForNavigationController:self withTitle:@"Bạn bè"];
    
    //set tableview
    NSInteger tableHeight = [[UIScreen mainScreen] bounds].size.height - TITLE_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT;
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, tableHeight) style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundView = nil;
    [self.view addSubview:table];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_NAME) {
        return 1;
    }else if (section == SECTION_PROFILE)
    {
        return self.profileList.count;
    }else{}
    
    return 0;    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_NAME) {
        static NSString* cellId = @"info";
        FriendInfoCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[FriendInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId andHeight:[self tableView:tableView heightForRowAtIndexPath:indexPath]];
            if (self.user.friend_avatar != nil) {
                cell.avatar.image = self.user.friend_avatar;
            }
            cell.name.text = self.user.friend_name;            
        }
        return cell;
    }else if (indexPath.section == SECTION_PROFILE)
    {
        NSString* cellId = [NSString stringWithFormat:@"frofile_%d", indexPath.row];
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.font = [UIFont getFontBoldSize14];
            cell.textLabel.text = [self.profileList objectAtIndex:indexPath.row];
        }
        return cell;
    }else{}
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_NAME) {
        return 60;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_PROFILE) {
        
        NSString* cellTitle = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        if ([cellTitle isEqualToString: PROFILE_TITLE_LIKE_CINEMA]) {
            CinemaListViewController* cinemaList = [[CinemaListViewController alloc] init];
            cinemaList.naviTitle = [NSString stringWithFormat:@"%@ của %@", PROFILE_TITLE_LIKE_CINEMA, self.user.friend_name];
//            cinemaList.user = self.user;
            cinemaList.dataList = self.favoriteCinemaList;
            [self.navigationController pushViewController:cinemaList animated:YES];
            
        }else if ([cellTitle isEqualToString:PROFILE_TITLE_BUY_TICKET]) {
//            TicketListViewController* buyTicketList = [[TicketListViewController alloc] init];
//            buyTicketList.user = self.user;
//            [self.navigationController pushViewController:buyTicketList animated:YES];
//            [buyTicketList release];
            
            TicketListTableViewController* buyTicketList = [[TicketListTableViewController alloc] init];
            buyTicketList.naviTitle = [NSString stringWithFormat:@"%@ của %@", PROFILE_TITLE_BUY_TICKET, self.user.friend_name];
            buyTicketList.dataList = self.ticketList;
            [self.navigationController pushViewController:buyTicketList animated:YES];
            
        }else if ([cellTitle isEqualToString:PROFILE_TITLE_CHECKIN_CINEMA]) {
            CinemaListViewController* cinemaList = [[CinemaListViewController alloc] init];
            cinemaList.naviTitle = [NSString stringWithFormat:@"%@ của %@", PROFILE_TITLE_CHECKIN_CINEMA, self.user.friend_name];
            cinemaList.dataList = self.checkInCinemaList;
            [self.navigationController pushViewController:cinemaList animated:YES];
            
        }else if ([cellTitle isEqualToString:PROFILE_TITLE_LIKE_FILM]) {
            FavoriteFilmListViewController* likeFilmList = [[FavoriteFilmListViewController alloc] init];
            likeFilmList.naviTitle = [NSString stringWithFormat:@"%@ của %@", PROFILE_TITLE_LIKE_FILM, self.user.friend_name];
            likeFilmList.dataList = self.favoriteFilmList;
            [self.navigationController pushViewController:likeFilmList animated:YES];
            
        }else{}
        
        
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
//    NSString* response = request.responseString;
//   if (request.tag == ID_REQUEST_GET_LIST_FILM_LIKE){
////        NSArray* temp = [[NSArray alloc] init];
//        NSArray* temp = [[APIManager sharedAPIManager] parseToUpdateListFilmLikeWithResponse:response];
//        [temp retain];
//        if (temp.count > 0) {
//            AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//            for (NSString* filmId in temp) {
//                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"film_id=%d", [filmId intValue]];
//                Film* fetchedFilm = (Film*)[appDelegate getManageObject:@"Film" withPredicate:predicate];
//                if (fetchedFilm != nil) {
//                    [self.favoriteFilmList addObject:fetchedFilm];
//                }
//            }
//        }
//        [temp release];
//        
//    }else if (request.tag == ID_REQUEST_GET_TICKET_LIST){
//        [[APIManager sharedAPIManager] parseListTicket:self.ticketList with:response];
//    
//    }else if (request.tag == ID_REQUEST_GET_LIST_CHECK_INS_OF_USER){        
//        NSArray* temp = [[APIManager sharedAPIManager] parseListOfCheckInWithRespone:response];
//        [temp retain];
//        if (temp.count > 0) {
//            AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//            for (NSString* cinemaId in temp) {
//                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"cinema_id=%d", [cinemaId intValue]];
//                Film* fetchedCinema = (Film*)[appDelegate getManageObject:@"Cinema" withPredicate:predicate];
//                if (fetchedCinema != nil) {
//                    [self.checkInCinemaList addObject:fetchedCinema];
//                }
//            }
//        }
//        [temp release];
//        
//    }else{}
}

@end
