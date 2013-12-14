//
//  CiemaViewController.h
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/7/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "APIManager.h"
#import "ASIHTTPRequestDelegate.h"
#import "SelectDateViewController.h"
#import "ChooseCityViewController.h"
#import "GAI.h"
#import "Cinema.h"
#import "Film.h"
#import "CinemaRatingCell.h"
#import "CustomGAITrackedViewController.h"
#import "CinemaHeaderCell.h"
#import "HMSegmentedControlContainerView.h"
#import "FilmCinemaPageView.h"
#import "MVSelectorScrollView.h"

@interface FilmCinemaViewController : CustomGAITrackedViewController<ASIHTTPRequestDelegate, SelectDateViewControllerDelegate, APIManagerDelegate,CinemaShareDelegate, CinemaSessionDelegate, FilmCinemaPageViewDelegate, MVSelectorScrollViewDelegate>//UIPageScrollDataSource
{
    ASIHTTPRequest *httpRequest;
}

@property int current_cinema_id_needUpdate;
@property int cinema_id_fromCinemaFilmView;
@property int session_version_id_fromCinemaFilmView;
@property int stepNextDayShowSession;
@property int indexOfCurrentCienmaDistance;
@property BOOL isLoadingCinemaSessionComplete;
@property(nonatomic, weak) Film *film;

@property (nonatomic, strong) NSMutableArray* listOfCinenaGroup;
@property (nonatomic, strong) NSMutableArray *cinemaListWithDistance;
@property (nonatomic, strong) NSMutableArray *bookingCinemaWithDistanceList;
@property (nonatomic, strong) NSMutableArray *nonBookingCinemaWithDistanceList;
@property (weak, nonatomic) IBOutlet MVSelectorScrollView *scrollViewGroupCinema;
@property (weak, nonatomic) IBOutlet FilmCinemaPageView *layoutGroupSessionView;
-(void)requestAPIGetListCinemaSession;

@end
