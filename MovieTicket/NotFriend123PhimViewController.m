//
//  FavoriteFilmViewController.m
//  MovieTicket
//
//  Created by Nhan Mai on 2/26/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "NotFriend123PhimViewController.h"
#import "AppDelegate.h"

#import "Film.h"
#import "FacebookManager.h"
#import "Friend.h"
#import "SBJsonParser.h"
#import "APIManager.h"
#import "UIImageView+Action.h"
#import "DefineConstant.h"

@interface NotFriend123PhimViewController ()

@end

@implementation NotFriend123PhimViewController
@synthesize table, friendList = _friendList, friendImageList = _friendImageList;

-(void) dealloc
{
    [_friendImageList removeAllObjects];
    [_friendList removeAllObjects];
    
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
        viewName = NOT_FRIEND_VIEW_NAME;
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
    [delegate setTitleLabelForNavigationController:self withTitle:@"Mời bạn tham gia 123Phim"];
    
    [self.view  addSubview:self.table];
    self.trackedViewName = viewName;
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)getFriend123Phim
{
    
}

- (void)getFacebookFriends
{
    [self getFriendList:^(NSDictionary *friends) {
        NSArray *tmp = [friends valueForKey:@"data"];
        
        for (NSDictionary* item in tmp) {
            NSString* friendId = [item objectForKey:@"id"];
            NSString* friendName = [item objectForKey:@"name"];
            
            
            Friend* friend = [[Friend alloc] init];
            friend.fb_id = friendId;
            friend.friend_name = friendName;
            
            [self.friendList addObject:friend];
        }
//        LOG_123PHIM(@"number of friend: %d", [self.friendList count]);
//        for (int i = 0; i<[self.friendList count]; i++) {
//            LOG_123PHIM(@"friend id: %@", ((Friend*)[self.friendList objectAtIndex:i]).friend_id);
//            LOG_123PHIM(@"friend name: %@", ((Friend*)[self.friendList objectAtIndex:i]).friend_name);
//        }
        [self.table reloadData];
    }
     
     ];
}

- (void)getFriendList:(void (^)(NSDictionary *))completion {
    
    if (FBSession.activeSession.isOpen) {
        
        [FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            
            if (!error) {
                
                completion(result);
                
//                LOG_123PHIM(@"get friends done");
                
            } else {
                
                LOG_123PHIM(@"%@", error);
                
            }
        }];
    }
}

- (void)getFriendListNotIn123Phim: (NSString*)fbId accessToken: (NSString*)token
{
    NSURL* imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://service-123booking.123.vn/fbservice/friends/?facebook_id=%@&access_token=%@", fbId, token]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        SBJsonParser* parsor = [[SBJsonParser alloc] init];
        NSString* string = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionExternalRepresentation];
        NSDictionary* friend = [parsor objectWithString:string];
        NSArray* all  =[friend objectForKey:@"not_installed"];
        for (id item in all) {
            //            LOG_123PHIM(@"person");
            //            LOG_123PHIM(@"    id: %@", [item objectForKey:@"id"]);
            //            LOG_123PHIM(@"    name: %@", [item objectForKey:@"name"]);
            Friend* friend = [[Friend alloc] init];
            friend.user_id = [item objectForKey:@"user_id"];
            friend.fb_id = [item objectForKey:@"id"];
            friend.friend_name = [item objectForKey:@"name"];
            
            [self.friendList addObject:friend];
            
        }
        LOG_123PHIM(@"friend count in viewDidLoad: %d", [self.friendList count]);
        [self.table reloadData];
        
    }];
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
    //    NSString* cellFilm = @"cell";
    //    Friend* friend = (Friend*)[self.friendList objectAtIndex:indexPath.row];
    //
    //    UITableViewCell* filmCell = [tableView dequeueReusableCellWithIdentifier:cellFilm];
    //    if (nil == filmCell) {
    //        LOG_123PHIM(@"create new cell");
    //        filmCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellFilm] autorelease];
    //        filmCell.selectionStyle = UITableViewCellSelectionStyleNone;
    //        filmCell.textLabel.font = [self mainFont];
    //        filmCell.textLabel.text = [NSString stringWithFormat:@"             %@", friend.friend_name];
    //        UIImageView* avatar = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 48, 48)];
    //        avatar.tag = 123;
    //        [avatar.layer setBorderWidth:0.5];
    //        [avatar.layer setBorderColor:[UIColor grayColor].CGColor];
    //        [filmCell.contentView addSubview:avatar];
    //        [avatar release];
    //    }
    //    filmCell.textLabel.text = [NSString stringWithFormat:@"             %@", friend.friend_name];
    //    UIImageView* imageView = (UIImageView*)[filmCell.contentView viewWithTag:123];
    //    if (friend.friend_avatar) {
    //        imageView.image = friend.friend_avatar;
    //    }else{
    //        NSURL* imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", friend.friend_id]];
    //        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:indexPath.section], @"section", [NSNumber numberWithInteger:indexPath.row], @"row", imageURL, @"imageURL" , nil];
    //        [NSThread detachNewThreadSelector:@selector(downloadImageByStringOnNewThread:) toTarget:self withObject:dict];
    //    }
    
    NSString* cellFilm = [NSString stringWithFormat:@"cell_%d_%d", indexPath.section, indexPath.row];
    Friend* friend = (Friend*)[self.friendList objectAtIndex:indexPath.row];
    
    UITableViewCell* filmCell = [tableView dequeueReusableCellWithIdentifier:cellFilm];
    if (nil == filmCell) {
//        LOG_123PHIM(@"create new cell");
        filmCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellFilm];
        filmCell.selectionStyle = UITableViewCellSelectionStyleNone;
        filmCell.textLabel.font = [UIFont getFontBoldSize14];
        filmCell.textLabel.text = [NSString stringWithFormat:@"             %@", friend.friend_name];
        
//        SDImageView* avatar = [[SDImageView alloc] initWithFrame:CGRectMake(5, 5, 48, 48)];
//        avatar.tag = 123;
//        [avatar.layer setBorderWidth:1.0];
//        [avatar.layer setBorderColor:[UIColor whiteColor].CGColor];
//        NSURL* imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", friend.friend_id]];
//        [avatar setImageWithURL:imageURL];
//        [filmCell.contentView addSubview:avatar];
//        [avatar release];
//        
        
        UIImageView* avatar = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 48, 48)];
        avatar.tag = 123;
        [avatar.layer setBorderWidth:1.0];
        [avatar.layer setBorderColor:[UIColor whiteColor].CGColor];
        NSURL* imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", friend.fb_id]];
        NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            UIImage* cropedImage = [avatar croppedImageWithImage:[UIImage imageWithData:data] scale:YES];
            avatar.image = cropedImage;
        }];
        [filmCell.contentView addSubview:avatar];
        
        UIButton* inviteButton  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        inviteButton.tag = indexPath.row;
        inviteButton.frame = CGRectMake(260, 8, 50, 30);
        [inviteButton setTitle:@"Mời" forState:UIControlStateNormal];
        [inviteButton addTarget:self action:@selector(handleInviteFriend:) forControlEvents:UIControlEventTouchUpInside];
        [filmCell.contentView addSubview:inviteButton];
    }
    
    
    return filmCell;
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

#pragma mark Handle button
- (void) handleInviteFriend:(id)sender
{
    
}

@end
