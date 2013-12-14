//
//  FavoriteButton.h
//  123Phim
//
//  Created by Nhan Mai on 7/22/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#define NOTIFICATION_FAVORITE_CLICK_WITH_FILM_ID @"NOTIFICATION_FAVORITE_CLICK_WITH_FILM_ID%d"

#import <UIKit/UIKit.h>

@protocol FavoriteButtonDelegate <NSObject>

- (void)favoriteButtonTouched;

@end

@interface FavoriteButton : UIButton
{
}
@property (nonatomic, retain) NSString *strPathImage;
@property (nonatomic, assign) id<FavoriteButtonDelegate> delegate;
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) NSInteger filmId;

@end
