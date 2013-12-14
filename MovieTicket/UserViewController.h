//
//  UserViewController.h
//  MovieTicket
//
//  Created by Nhan Mai on 2/18/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Position.h"
#import "ShowMapViewController.h"
#import "Film.h"
#import "GAI.h"
#import "UserProfile.h"
#import "AppDelegate.h"

@interface UserViewController : GAITrackedViewController<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, ShowMapViewControllerDelegate>
{
    CLLocationManager* lm;
    NSMutableDictionary* localAddressAndDistance;
    int newestSawFilmId;
    UserProfile *userProfile;
//    __weak id<FilmDelegate> _delegate;
}
//@property (nonatomic, weak) id<FilmDelegate> delegate;

@property (nonatomic, retain) UITableView* table;
@property (nonatomic, retain) Position* yourPosition;
@property (nonatomic, retain) NSMutableArray* accountList;
@property (nonatomic, retain) NSString* about;

@property (nonatomic, retain) ShowMapViewController* showMapViewController;
@property (nonatomic, assign) CLLocationCoordinate2D centerOfCinemaGroupMap;
@property (nonatomic, assign) MKCoordinateSpan spanOfCinemaGroupMap;
@property (nonatomic, assign) CLLocationCoordinate2D centerOfPositionChoiceMap;
@property (nonatomic, assign) MKCoordinateSpan spanOfPositionChoiceMap;
@property (nonatomic, assign) BOOL userSeeingCinemaGroup;

@property (nonatomic, retain) NSMutableArray* sawFilmId;
@property (nonatomic, retain) NSMutableArray* sawFilm;
@property (nonatomic, retain) UITableView* sawFilmTable;

@end
