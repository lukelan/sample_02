//
//  ProfileTableViewCell.h
//  123Phim
//
//  Created by phuonnm on 5/24/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#define NOTIFICATION_NAME_PROFILE_CELL_USER_PROFILE_BEGIN_LOGIN @"NOTIFICATION_NAME_PROFILE_CELL_USER_PROFILE_BEGIN_LOGIN"
#define NOTIFICATION_NAME_PROFILE_CELL_USER_PROFILE_DID_LOAD @"NOTIFICATION_PROFILE_CELL_USER_PROFILE_DID_LOAD"
#define PROFILE_CELL_DID_LOAD_HEIGHT (55 + 2 * MARGIN_EDGE_TABLE_GROUP)
#define PROFILE_CELL_NOT_LOAD_HEIGHT 55
#import <UIKit/UIKit.h>
#import "APIManager.h"

@interface ProfileTableViewCell : UITableViewCell
{
    NSInteger _currentStatus;
}

@property (nonatomic, strong) NSString *text;
@end
