//
//  FilmCinemaPageView.h
//  123Phim
//
//  Created by phuonnm on 8/20/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "PageView.h"
#import "AppDelegate.h"

@class Session;
@class Film;
@class CinemaWithDistance;
@class FilmCinemaPageView;

@protocol FilmCinemaPageViewDelegate <NSObject>
@optional
-(void)showSeletedDateViewController;
-(void)showChooseCityViewController;
-(void)didSelectCinemaSession:(Session*)session film:(Film*)film cinemaWithDistance:(CinemaWithDistance*)cinemaWithDistance;
-(void)filmCinemaPage:(FilmCinemaPageView *)page didSelectNews:(News*) news;

@end

@interface FilmCinemaPageView : PageView <UITableViewDataSource, UITableViewDelegate, CinemaSessionDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger numberOfBookingCinema;
@property(nonatomic, weak) Film *film;
@property(nonatomic, strong) NSMutableArray *cinemaListByGroupWithDistance;
@property(nonatomic, weak) id<FilmCinemaPageViewDelegate> delegate;
@property int stepNextDayShowSession;
@property (nonatomic, strong) News *news;
- (void) reloadData;

@end
