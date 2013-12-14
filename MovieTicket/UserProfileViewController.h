//
//  UserProfileViewController.h
//  123Phim
//
//  Created by Nhan Mai on 6/28/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
#import "CustomViewController.h"
#import "APIManager.h"

@interface UserProfileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate>
{
    UITableView *table;
}

@property (nonatomic, strong) Friend* user;
@property (nonatomic, strong) NSArray* sectionList;
@property (nonatomic, strong) NSArray* profileList;
@property (nonatomic, strong) NSMutableArray* favoriteCinemaList;
@property (nonatomic, strong) NSMutableArray* checkInCinemaList;
@property (nonatomic, strong) NSMutableArray* favoriteFilmList;
@property (nonatomic, strong) NSMutableArray* ticketList;

@end
