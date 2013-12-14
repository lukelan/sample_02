//
//  SeatView.h
//  123Phim
//
//  Created by phuonnm on 4/11/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeatInfo.h"

typedef NS_ENUM(NSInteger, SeatType)
{
    SEAT_TYPE_NORMAL = 0,
    SEAT_TYPE_VIP,
    SEAT_TYPE_COUPLE_1,
    SEAT_TYPE_COUPLE_2,
    SEAT_TYPE_DOOR = 11
};

typedef NS_ENUM(NSInteger, SeatStatus)
{
    SEAT_STATUS_AVAILABLE = 0,
    SEAT_STATUS_DISABLE,
    SEAT_STATUS_SELECTED,
    SEAT_STATUS_BLOCK
};

typedef NS_ENUM(NSInteger, SeatGroupType)
{
    SEAT_GROUP_TYPE_NORMAL = 0,
    SEAT_GROUP_TYPE_SELECT_ALL
};

@interface SeatView : UIImageView
{
}
@property (nonatomic, strong) SeatInfo *seatInfo;
@property (nonatomic, strong) UIImage* normalImage;
@property (nonatomic, strong) UIImage* selectedImage;
@property (nonatomic, strong) UIImage* disableImage;
@property (nonatomic, strong) UIImage* blockImage;

-(void)showImageWithState:(NSInteger)status;

@end
