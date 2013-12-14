//
//  CinemaTableViewPlaceCell.h
//  123Phim
//
//  Created by Tai Truong on 12/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CinemaTableViewCell.h"
#import "CinemaTableViewPlaceItem.h"

@interface CinemaTableViewPlaceCell : CinemaTableViewCell
{
    UIImageView *_arrowImage;
    UIImageView *_youAreHereImage;
    UIImageView *_footerImage;
    UIImageView *_discountImgView;
}

@property (nonatomic, retain) UIImageView *statusImgView;
@property (nonatomic, retain) UILabel *discountLbl;
@property (nonatomic, retain) UILabel *titleLbl;
@property (nonatomic, retain) UILabel *addressLbl;
@property (nonatomic, retain) UILabel *distanceLbl;
@property (nonatomic, retain) UILabel *estimateTimeBikeLbl;
@property (nonatomic, retain) UILabel *estimateTimeCarLbl;
@property (nonatomic, retain) UILabel *youAreHereLbl;

@end
