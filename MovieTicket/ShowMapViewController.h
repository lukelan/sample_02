//
//  ShowMapViewController.h
//  MovieTicket
//
//  Created by nhanmt on 1/25/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Position.h"
#import "CinemaWithDistance.h"
#import "RegexKitLite.h"
#import "Place.h"
#import "PlaceMark.h"
#import "CustomGAITrackedViewController.h"

@protocol ShowMapViewControllerDelegate <NSObject>
-(void)receiveLocationData:(Position*)locationData andMapStatusOfCenter:(CLLocationCoordinate2D)center andMapStatusOfSpan:(MKCoordinateSpan)span;
-(void)pushFilmListCinemaView: (CinemaWithDistance *)cinemaWithDistance;
@end

enum MapType {
    MapTypeCinemaGroup = 0,
    MapTypeCinemaIndividual = 1
    };


@interface ShowMapViewController : CustomGAITrackedViewController<UIGestureRecognizerDelegate, MKMapViewDelegate, UIAlertViewDelegate>
{
    __weak id<ShowMapViewControllerDelegate>delegate;
    __weak id<ShowMapViewControllerDelegate>cinemaFilmViewDelegate;
    
    UIImageView* routeView;
	
	NSArray* routes;
	
	UIColor* lineColor;
}

@property (nonatomic, assign) enum MapType typeOfMap;
@property (nonatomic, strong) CinemaWithDistance* currentCinemaDistance;
@property (nonatomic, strong) MKMapView* myMap;
@property (nonatomic, strong) UIButton* backButton;
@property (nonatomic, strong) NSArray* cinemaListWithDistance;

@property (nonatomic, assign) BOOL currentLocationState;
@property (nonatomic, strong) Position* startLocation;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;
@property (nonatomic, assign) CLLocationCoordinate2D mapCenterCinemaGroup;
@property (nonatomic, assign) MKCoordinateSpan mapSpanCinemaGroup;
@property (nonatomic, assign) CLLocationCoordinate2D mapCenterUserChoice;
@property (nonatomic, assign) MKCoordinateSpan mapSpanUserChoice;


@property (nonatomic, weak) id<ShowMapViewControllerDelegate>delegate;
@property (nonatomic, weak) id<ShowMapViewControllerDelegate>cinemaFilmViewDelegate;

@property (nonatomic, strong) UIColor* lineColor;
@property (nonatomic, assign) BOOL isDirecting;

-(void) showRouteFrom: (Place*) f to:(Place*) t;
//-(void)setFullScreen;
@end
