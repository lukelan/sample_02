//
//  Cinema_FilmDetailViewController.h
//  MovieTicket
//
//  Created by phuonnm on 1/4/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilmCinemaViewController.h"
#import "FilmDetailViewController.h"
#import "AppDelegate.h"
#import "Film.h"

@interface Cinema_FilmDetailViewController : UIViewController <FilmDetailDelegate,FilmDelegate, CinemaListDelegate,CinemaSessionDelegate>
{
    FilmCinemaViewController *cinemaViewController;
    FilmDetailViewController *filmDetailViewController;
    Film *film;
    UIButton * btnFilmDetail;
    UIImageView *footer;
    UIButton * btnMuave;
    NSInteger yPosStart;
    NSInteger yPosLastSample;
    NSInteger yPosCurrent;
    NSInteger yPosEnd;
    UIView *viewRecieve;
    UIImage *imageFooter;
    UIImage *imageHeader;
}
@property BOOL isLoadingCinemaSessionBefore;
@property BOOL isLoadingCinemaSessionComplete;
@property (nonatomic, assign) Boolean showDetailView;
@property (nonatomic ,retain) UIButton * btnMuave;
@property (nonatomic ,retain) UIButton * btnFilmDetail;
@property (nonatomic ,retain)  UIImageView *footer;
@property (nonatomic)  NSInteger yPosStart;
@property (nonatomic)  NSInteger yPosLastSample;
@property (nonatomic)  NSInteger yPosCurrent;
@property (nonatomic)  NSInteger yPosEnd;
@property (nonatomic ,retain) UIView *viewRecieve;
@property (nonatomic, retain) NSMutableArray *cinemaGroupList;
@property (nonatomic, retain) NSMutableArray *arrCinemaSessionDistance;
//-(void) setCinemaGroupList: (NSMutableArray *) cinemaGroupList;
-(void) setFilm: (Film *) theFilm;
-(void)setCinemaSessionDistanceList:(int)cinema_id andSessionVersionID:(int)versionid;
-(void)setIndexForCurrentCienmaDistance:(int) index;//dung cho flow tu rap chon film vao lich chieu

@end
