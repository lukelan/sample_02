//
//  CiemaViewController.h
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/7/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cinema.h"
#import "Film.h"
#import "AppDelegate.h"
#import "UserViewController.h"
#import "CinemaFilmViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ShowMapViewController.h"
#import "Position.h"
#import "ChooseCityViewController.h"
#import "GAI.h"
#import "CustomGAITrackedViewController.h"
#import "CinemaHeaderCell.h"

@interface CinemaViewController : CustomGAITrackedViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ShowMapViewControllerDelegate>
{
    NSMutableArray* _cinemaListWithDistance;
    NSString *strDes;
    BOOL isNeedReloadCell;
    NSTimeInterval lastTimeLoading;
    BOOL isChangeNewCity;
}
@property (nonatomic, strong) NSMutableArray* cinemaListWithDistance;
@property BOOL isLoadedCinemaComplete;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *cinemaList;

@property (nonatomic, assign) CLLocationCoordinate2D centerOfCinemaGroupMap;
@property (nonatomic, assign) MKCoordinateSpan spanOfCinemaGroupMap;
@property (nonatomic, assign) CLLocationCoordinate2D centerOfPositionChoiceMap;
@property (nonatomic, assign) MKCoordinateSpan spanOfPositionChoiceMap;
@property (nonatomic, strong) Location* yourCity;
@property (nonatomic, strong) Position* yourPosition;
@property (nonatomic, strong) Position* displayLocation;

//- (id)initWithStyle:(UITableViewStyle)style;
- (void)loadCinemaByLocationId: (NSInteger)locationId;
- (void)reloadDataDistancenMyCinema;
- (void)updateDisplayLocation;
- (BOOL)isDistanceFromYourPos;
- (void)newLocation:(CLLocation*)location address:(NSString*)address;
+ (CinemaViewController*)sharedCinemaViewController;
@end
