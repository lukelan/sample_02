//
//  FavoriteFilmViewController.h
//  MovieTicket
//
//  Created by Nhan Mai on 2/26/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CustomGAITrackedViewController.h"

@interface NotFriend123PhimViewController : CustomGAITrackedViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* _friendList;
    NSMutableArray* _friendImageList;
}

@property (nonatomic, strong) UITableView* table;
@property (nonatomic, strong) NSMutableArray* friendList;
@property (nonatomic, strong) NSMutableArray* friendImageList;

@end
