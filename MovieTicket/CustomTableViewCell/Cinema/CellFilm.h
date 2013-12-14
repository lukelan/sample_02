//
//  CellFilm.h
//  MovieTicket
//
//  Created by Nhan Ho Thien on 1/25/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Film.h"
#import "FilmSession.h"
#import "AutoScrollLabel.h"
#import "AppDelegate.h"

@interface CellFilm : UITableViewCell{
    __weak id<CinemaSessionDelegate> _sessionDelegate;
    int curIndexSelect;
}
@property (nonatomic, weak) id<CinemaSessionDelegate> sessionDelegate;
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet SDImageView *filmImg;
@property (nonatomic,weak) IBOutlet UILabel *tvDesc;
@property (strong, nonatomic) IBOutlet UIView *uiViewDiscount;
@property(nonatomic,weak) IBOutlet AutoScrollLabel *autoLable;
@property (strong, nonatomic) IBOutlet UILabel *lbDiscount;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorLoading;
@property (nonatomic, assign) BOOL isIOS7;
@property (strong, nonatomic) IBOutlet UIImageView *imageDiscount;
- (void)setDataFilmCell:(FilmSession *)filmsesion withHeight:(CGFloat)heighCell currentRow:(int)curSelect;
- (void) layoutCellSession: (NSMutableArray *)arraySessions;
- (void) configLayout;
@end
