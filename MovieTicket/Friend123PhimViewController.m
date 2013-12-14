//
//  FavoriteFilmViewController.m
//  MovieTicket
//
//  Created by Nhan Mai on 2/26/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "Friend123PhimViewController.h"
#import "AppDelegate.h"
#import "Film.h"
#import "FacebookManager.h"
#import "Friend.h"
#import "SBJsonParser.h"
#import "APIManager.h"
#import "UserProfileViewController.h"
#import "UIImageView+Action.h"
#import "DefineConstant.h"

@interface Friend123PhimViewController ()

@end

@implementation Friend123PhimViewController
@synthesize table, friendList = _friendList, friendImageList = _friendImageList;


-(void)dealloc
{
   // [_friendList removeAllObjects];
    //[_friendImageList removeAllObjects];
    table = nil;
    _friendImageList = nil;
    _friendList = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 20 -44 - 44) style:UITableViewStylePlain];
        table.delegate = self;
        table.dataSource = self;
        _friendList = [[NSMutableArray alloc] init];
        _friendImageList = [[NSMutableArray alloc] init];
        viewName = FRIEND_VIEW_NAME;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
	// Do any additional setup after loading the view.    
    
    // set navigation left and tittle
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:@"Bạn 123Phim"];

    [self.view  addSubview:self.table];
//    NSString* previewView = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).currentView;
//    NSString* currentView = viewName;
//    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:currentView comeFrom:previewView withActionID:LOG_ACTION_ID_VIEW currentFilmID:[NSNumber numberWithInt:NO_FILM_ID] currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID] returnCodeValue:0 context:self];
    self.trackedViewName = viewName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friendList count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    NSString* cellID = [NSString stringWithFormat:@"cell_%d_%d", indexPath.section, indexPath.row];
    Friend* friend = (Friend*)[self.friendList objectAtIndex:indexPath.row];
    
    UITableViewCell* filmCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (nil == filmCell) {
        filmCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        filmCell.selectionStyle = UITableViewCellSelectionStyleNone;
        filmCell.accessoryType = UITableViewCellAccessoryNone;
        filmCell.textLabel.font = [UIFont getFontBoldSize14];
        filmCell.textLabel.text = [NSString stringWithFormat:@"             %@", friend.friend_name];

        UIImageView* avatar = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 48, 48)];
        avatar.tag = 123;
        [avatar.layer setBorderWidth:1.0];
        [avatar.layer setBorderColor:[UIColor whiteColor].CGColor];
        NSURL* imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", friend.fb_id]];
        NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            UIImage* cropedImage = [avatar croppedImageWithImage:[UIImage imageWithData:data] scale:YES];
            avatar.image = cropedImage;
            friend.friend_avatar = cropedImage;
        }];
        [filmCell.contentView addSubview:avatar];
    }

    
    return filmCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return;
    
    Friend* friend = [self.friendList objectAtIndex:indexPath.row];
    UserProfileViewController* userProfileController = [[UserProfileViewController alloc] init];
//    friend.user_id = @"200193";
    userProfileController.user = friend;
    [self.navigationController pushViewController:userProfileController animated:YES];
}

- (void)downloadImageByStringOnNewThread:(NSDictionary*)dict
{
//    LOG_123PHIM(@"downloadImageByStringOnNewThread");
    @autoreleasepool {
    
        NSNumber* section   =   [dict objectForKey:@"section"];
        NSNumber* row       =   [dict objectForKey:@"row"];
        NSURL* imageURL     =   (NSURL*)[dict objectForKey:@"imageURL"];
//    LOG_123PHIM(@"    input:");
//    LOG_123PHIM(@"    imageURL: %@", imageURL);
        
        
        NSData* imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage* downloadedImage = [UIImage imageWithData:imageData];
//    LOG_123PHIM(@"    output:");
//    LOG_123PHIM(@"    image: %@", downloadedImage);
        
        NSDictionary* transferedDict = [NSDictionary dictionaryWithObjectsAndKeys:section, @"section", row, @"row", downloadedImage, @"image", nil];
        [self performSelectorOnMainThread:@selector(displayImageOfCell:) withObject:transferedDict waitUntilDone:YES];   
    
    }
}

- (void)displayImageOfCell:(NSDictionary*)dict
{
//    LOG_123PHIM(@"displayImageOfCell");
    NSInteger section   = [[dict objectForKey:@"section"] integerValue];
    NSInteger row       = [[dict objectForKey:@"row"]integerValue];
    UIImage* image      = (UIImage*)[dict objectForKey:@"image"];
//    LOG_123PHIM(@"Image: %@", image);
    
    UITableViewCell* cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    UIImageView* imageView = (UIImageView*)[cell viewWithTag:123];
    
    UIImage* cropedImage = [imageView croppedImageWithImage:image scale:YES];
    
    ((Friend*)[self.friendList objectAtIndex:row]).friend_avatar = cropedImage; //save after download
    
    imageView.image = cropedImage; //display on cell
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
