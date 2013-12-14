//
//  CinemaTitleCell.h
//  123Phim
//
//  Created by Le Ngoc Duy on 3/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@protocol CinemaShareDelegate <NSObject>
@optional
-(void)didSelectShareAction;
@end

@interface CinemaRatingCell : UITableViewCell
{
    __weak id<CinemaShareDelegate> _cinemaShareDelegate;
    __weak id<PushVCFilmDelegate> _commentDelegate;
}
@property (nonatomic, weak) id<PushVCFilmDelegate> commentDelegate;
@property (nonatomic, weak) id<CinemaShareDelegate> cinemaShareDelegate;
@property (nonatomic, weak) Film* myFilm;
-(void)layoutCellCinemaHeader:(Film *)film isViewShare:(BOOL)isShareScreen;
-(void)setContentForCell:(Film *)film;
@end
