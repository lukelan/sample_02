//
//  AccountViewController.h
//  123Phim
//
//  Created by Nhan Mai on 3/13/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "UserProfile.h"
#import "ChooseCityViewController.h"
#import "GAI.h"
#import "Event.h"

@interface AccountViewController : CustomGAITrackedViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIWebViewDelegate, RKManagerDelegate>
{
    BOOL isNeedSendUpdateNotify;
    NSTimeInterval lastTimeLoading;
}

@property BOOL isNeedUpdateData;
@property BOOL isLocationUpdating;
@property (nonatomic, strong) NSString *friend123PhimCount;
@property (nonatomic, strong) NSString *friendNot123PhimCount;
@property (nonatomic, strong) NSString *loginState;
@property (nonatomic, strong) UITableView* table;
@property (nonatomic, assign) BOOL logined;
@property (nonatomic, strong) UserProfile* userProfile;
@property (nonatomic, strong) Location* chosenLocation;
@property (nonatomic, strong) NSString* locationDescription;
@property (nonatomic, strong) NSMutableArray* friendList123Phim;
@property (nonatomic, strong) NSMutableArray* friendList;
@property (nonatomic, strong) NSMutableArray *eventList;
@property (nonatomic, strong) AppDelegate* appdelegate;

- (void)reloadCellLocation;
- (void)newLocation:(CLLocation*)location address:(NSString*)address;


@end
