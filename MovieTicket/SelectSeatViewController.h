//
//  SelectSeatViewController.h
//  123Phim
//
//  Created by Phuc Phan on 4/5/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "APIManager.h"
#import "Film.h"
#import "CinemaWithDistance.h"
#import "BuyingInfo.h"
#import "CustomGAITrackedViewController.h"

@protocol SelectSeatViewDelegate <NSObject>

@required
@property (nonatomic, assign) BOOL cleanSelectedSeats;

@end

@interface SelectSeatViewController : CustomGAITrackedViewController<UIScrollViewDelegate, UIAlertViewDelegate, SelectSeatViewDelegate, RKManagerDelegate>
{
    UIScrollView *_scrollView;
    UIScrollView *_scrollViewLeftTitle;
    UIView *_roomView;
    NSMutableArray *_roomLayout;
    UIView *_leftTitleView;

//    normal seat
    UIImage *_normalSeatImage;
    UIImage *_unavailableNormalSeatImage;
    UIImage *_selectedNormalSeatImage;
    UIImage *_blockSeatImage;
    UIImage *_doorImage;
    
    UIImage *_vipSeatImage, *_selectedVipSeatImage, *_unavailableVipSeatImage;
    
    UIImage *_normalLeftCoupleSeatImage;
    UIImage *_selectedLeftCoupleSeatImage;
    UIImage *_unavailableLeftCoupleSeatImage;
    
    UIImage *_normalRightCoupleSeatImage;
    UIImage *_selectedRightCoupleSeatImage;
    UIImage *_unavailableRightCoupleSeatImage;
    
    NSMutableArray *_selectedSeats;
    UIScrollView *_lbSelectedSeats;
    UILabel *_lbSelectedSeatsDefault;
    NSInteger _dataLoadingStep;
    NSInteger _renderStatus;
    NSInteger _chosenSeatLimit;
    NSMutableDictionary *_seatGroupList;
    CGFloat _lastScale;
    NSArray *_listStatusOfSeat;
//    BOOL _isMaintained;
    NSString *_roomTitle;
}

@property (nonatomic, strong) Session *currentSession;
@property (nonatomic, strong) Film *currentFilm;
@property (nonatomic, strong) CinemaWithDistance *currentCinemaWithDistance;
@end
