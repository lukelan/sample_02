//
//  AppDelegate.h
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/5/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#define NOTIFICATION_NAME_CINEMA_WITH_DISTANCE_DID_LOAD @"NOTIFICATION_NAME_CINEMA_WITH_DISTANCE_DID_LOAD"
#define NOTIFICATION_NAME_CINEMA_DID_LOAD @"NOTIFICATION_NAME_CINEMA_DID_LOAD"
#define NOTIFICATION_NAME_LOGIN_SUCCESS @"NOTIFICATION_NAME_LOGIN_SUCCESS"

#ifndef APP_DELEGATE_H
#define APP_DELEGATE_H
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "UserProfile.h"
#import <MapKit/MapKit.h>
#import "CustomUIResponder.h"
#import "Position.h"
#import "DefineDataType.h"
#import "WelcomeViewController.h"
#import "Cinema.h"
#import "APIManager.h"

@class FavoriteButton;



#if IS_DEBUG_LOG_MEM
    #import "Memory.h"
#endif
static BOOL _isBeingLogin = NO;
typedef NS_ENUM(NSInteger, AppState)
{
    APP_STATE_INIT = 0,
    APP_STATE_VERSION_CHECKING,
    APP_STATE_LOGIN_CHECKING,
    APP_STATE_START,
    APP_STATE_REQUEST_USER_INFO,
    APP_STATE_REQUEST_FILM_LIST,
    APP_STATE_REQUEST_CINEMA_LIST
};

typedef enum
{
    ENUM_DISCOUNT_NONE = 0,
    ENUM_DISCOUNT_PERCENT,
    ENUM_DISCOUNT_MONEY,
    ENUM_DISCOUNT_OTHER
}ENUM_DISCOUNT_TYPE;

@class Location;
@class Film;
@class Session;

@protocol PushVCFilmDelegate <NSObject>

-(void)pushVCFilmDetailWithFilm:(Film*)Film isFavorite:(BOOL)isFavorite;
-(void)pushVCFilmCommentWithFilm:(Film*)Film;

@end

@protocol CinemaSessionDelegate <NSObject>
@optional
-(void)didSelectCinemaSession:(int)indexOfSession;
-(void)didSelectCinemaSession:(int)indexOfSession curFilmInCinema:(int)curFilm;
-(void)didSelectCinemaSession:(int)indexOfSession curIndexCinema:(int)curCinema;
@end

typedef enum {
    DISCOUNT_TYPE_NONE = 0,
    DISCOUNT_TYPE_FILM,
    DISCOUNT_TYPE_CINEMA
} DISCOUNT_TYPE_EFFECT;

@interface AppDelegate : CustomUIResponder <UIAlertViewDelegate, CLLocationManagerDelegate, RKManagerDelegate>
{
    UIActivityIndicatorView *activityIndicator;
    AppState _appState;
    WelcomeViewController *loadingViewController;
    NSMutableArray *_lstDymamicViewInfo;
    NSDictionary *dicLocalNotification;
    NSArray *_svFavouriteFilmIDList;
}
@property (nonatomic, assign) int icountTryRequestTransaction;
//start with manual
@property (nonatomic, assign) NSInteger startWithFilmID;
@property (nonatomic, assign) NSInteger startWithCinemaID;
@property (nonatomic, strong) NSString *startWithDateString;
@property (nonatomic, assign) NSInteger startWithPromotionID;

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) Position* userPosition;

@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) NSMutableArray *arrayFilmShowing;
@property (nonatomic,strong) NSMutableArray *arrayFilmComing;
@property (nonatomic,strong) NSMutableArray *arrayFilmFavorite;
@property (nonatomic,strong) NSMutableArray *arrayCinema;
@property (nonatomic,readonly) NSMutableDictionary *dictCinemaGroup;
@property (nonatomic,strong) NSMutableArray *arrayCinemaDistance;
@property (nonatomic,readonly) NSMutableDictionary *updatedFavouriteFilmList;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) UINavigationController *navCinema;
@property (nonatomic,strong) UINavigationController *navUser;
@property (nonatomic,strong) UserProfile *userProfile;
@property (nonatomic, strong) NSString* currentView;

@property (nonatomic, strong) NSDictionary *dicObjectText;
//using for thanhToan account
@property NSInteger _Amount;
@property (nonatomic,strong) NSString *_TransactionID;
@property (nonatomic,strong) NSString *Invoice_No;
@property (nonatomic,strong) NSString *ticket_code;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *phone;
@property (nonatomic,strong) NSString *_SmartlinkOrderId;
@property (nonatomic,strong) NSString *_SmartlinkSessionId;

@property (nonatomic, assign) DISCOUNT_TYPE_EFFECT discountTypeEffect;
@property (nonatomic, assign) BOOL requestAppRating;

//end thanhToan account
- (NSURL *)applicationDocumentsDirectory;
-(NSMutableArray *)fetchRecords:(NSString *)entityName sortWithKey:(NSString *)keyName withPredicate:(NSPredicate *)predicate;
-(NSMutableArray *)fetchRecords:(NSString *)entityName sortWithKey:(NSString *)keyName ascending:(BOOL)isAscending withPredicate:(NSPredicate *)predicate;
-(NSManagedObject *)getManageObject:(NSString *)entityName withPredicate:(NSPredicate *)predicate;
-(void)deleteAllRecordsInTable:(NSString *)entityName sortWithKey:(NSString *)keyName;
-(void)setBackGroundImage:(NSString *) linkImage forNavigationBar:(UINavigationBar *)naviBar;
-(void)setTitleLabelForNavigationController:(UIViewController *)viewController  withTitle:(NSString *)title;
-(void)updateTitle:(NSString *)title forViewController:(UIViewController *)viewController;
-(void)setCustomBackButtonForNavigationItem:(UINavigationItem *) navigationItem;
- (void) popToViewController:(Class)viewController_ animated:(BOOL)animated_;
-(UIViewController *) getCurrentViewController;
-(void) popViewController;
-(void)pushViewControllerAccordingToStatus;
-(void)pushVerifyOTPFromPendingOnApp;
- (void)checkAndSendCleanWarning;

//Using to check network
+(NSDate *)getStartTime;
+(void)resetStartTime;
+(int) getMyLocationId;
+(void) setMyLocationId:(int)locationId;
+(void) setCurrentPostionON: (bool)on;
+(bool) getCurrentPostionON;
+(BOOL) isNetWorkValiable;
+(void)setNetWorkValiable:(BOOL)on;
+(NSString *)getVersionOfApplication;
+(CLLocationCoordinate2D)getPresentPoint;
+(void)setPresentPoint:(CLLocationCoordinate2D)point;
+ (NSString *)outParserConvertFormat:(NSString *)strKey;
#pragma mark handle check network
- (void) updateInterfaceWithReachability;

#pragma mark process for film and cinema
-(Film *)getNextFilmInFilmArrayOfFilmId:(int)film_id withStatus:(int)filmStatus;
-(Film*)getNextFilmInFavoutiteFilmArrayOfFilmId:(int)film_id;
- (Film*)getPreviousFilmInFilmArrayOfFilmId:(int)filmId withStatus:(int)filmStatus;
- (Film*)getPreviousFavoriteFilmInFilmArrayOfFilmId:(int)filmId;

-(int)getIndexOfCinemaInArrayCinemaDistance:(int)cinema_id;
-(Film*)getFilmWithID: (NSNumber*) filmID;
-(Cinema*)getCinemaWithID: (NSNumber*) cinemaID;

- (void)handleFilmLikedTouched:(FavoriteButton*)sender;
-(void)updateFavouriteFilmListWithArrayID:(NSArray *)filmIDList isFromServer:(BOOL)isFromServer;
#pragma mark handle login account
-(void) showAlert:(NSString *)title content:(NSString *)content;
- (BOOL)isUserLoggedIn;
- (void)handleLogout;
- (void)handleUserAccount;

//using to creat checksum and getipAddress
- (NSString *)getIPAddress;
#pragma mark - Location
- (void)updateUserLocationWithType:(UpdateLocationType)type;
@end
#endif
