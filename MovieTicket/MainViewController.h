//
//  DemoSlideControllerSubclass.h
//  CHSlideController
//
//  Created by Clemens Hammerl on 19.10.12.
//  Copyright (c) 2012 appingo mobile e.U. All rights reserved.
//
#ifndef MAIN_VIEW_CONTROLLER_H
#define MAIN_VIEW_CONTROLLER_H
#define SHOW_TYPE_SLIDE 0
#define SHOW_TYPE_LIST  1

#define NOTIFICATION_NAME_FILM_LIST_DID_LOAD @"NOTIFICATION_NAME_FILM_LIST_DID_LOAD"

#import "FilmPagingScrollViewController.h"
#import "GAI.h"
#import "CustomTextView.h"
#import "FilmPagingScrollViewController.h"

@interface MainViewController : CustomGAITrackedViewController <UIScrollViewDelegate, FilmPageScrollViewControllerDelegate, PushVCFilmDelegate, CustomTextViewDelegate, UIAlertViewDelegate>
{    
    UISegmentedControl *viewSeg;
    UIButton *btnMyListFilm;//*btnList
    BOOL _isRegisteredForKeyboardNotification;
    BOOL _isLoadingFilmList;
    BOOL _isSendingRequestGetListNew;
    CustomTextView *_activedInput;
    CGPoint _backupOffset;
    CGSize _backupSize;
    NSTimeInterval lastTimeLoading;
}

@property (assign)  int curIndexPageShowing, curIndexPageComming;//modeView
@property(nonatomic,strong) UISegmentedControl *viewSeg;
@property(nonatomic,strong) UIButton *btnMyListFilm;

@property (nonatomic, strong) IBOutlet FilmPagingScrollViewController *filmPageShowing;
//using for coredata
@property (nonatomic, strong) NSMutableArray *arrayFilmShowing;
@property (nonatomic, strong) NSMutableArray *arrayFilmComming;
@property (strong, nonatomic) NSArray *showingBannerList;
@property (strong, nonatomic) NSArray *comingBannerList;

//Method
-(void)initLayoutForView;
-(void)initDataForFilmShow;
-(void)applicationProcessingDidEnterBackGround;

+(MainViewController*)sharedMainViewController;
@end
#endif
