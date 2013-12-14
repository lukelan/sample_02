//
//  AViewController.h
//  MovieTicket
//
//  Created by nhanmt on 1/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
#import "Film.h"
#import "APIManager.h"
#import "AppDelegate.h"
#import "CommentFilmView.h"
#import "FPPopoverController.h"
#import "GAI.h"
#import "CinemaRatingCell.h"
#import "CustomGAITrackedViewController.h"
#import "FilmInfoCell.h"

@interface FilmDetailViewController : CustomGAITrackedViewController<UITableViewDataSource, UITableViewDelegate, CinemaShareDelegate, FilmInfoCellDelegate>
{
    NSInteger selectedShareType;
    __weak id<PushVCFilmDelegate> _delegate;
    BOOL isDislayingTempTable;
    NSUInteger total;
    Film *filmNext;
    CGFloat _filmInfoCellHeight;
}
@property (nonatomic, strong) NSString *timeSession;
@property (nonatomic, strong) NSDate *nearestSessionDate;

@property (nonatomic, weak) id<PushVCFilmDelegate> delegate;
@property (nonatomic, weak) Film* film;

@property (nonatomic, strong) IBOutlet UITableView* layoutTable, *tempTable;
@property (nonatomic, strong) NSMutableArray* arrComments;

@property (nonatomic, assign) BOOL isFromFavoriteList;
@property (nonatomic, strong) IBOutlet UIButton *btnSessionFilm;
@property (nonatomic, strong) IBOutlet UILabel *lblSessionFilm;
@property (nonatomic, strong) IBOutlet UIView *viewSessionTime;
@property (weak, nonatomic) IBOutlet UILabel *lbAlert;

@end
