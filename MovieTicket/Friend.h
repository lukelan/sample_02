//
//  Friend.h
//  123Phim
//
//  Created by Nhan Mai on 3/15/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Friend : NSObject
{
}

@property (nonatomic, strong) NSString* user_id;
@property (nonatomic, strong) NSString* fb_id;
@property (nonatomic, strong) NSString* friend_name;
@property (nonatomic, strong) NSString* friend_email;
@property (nonatomic, strong) UIImage* friend_avatar;

@property (nonatomic, strong) NSArray* favoriteFilmList;
@property (nonatomic, strong) NSArray* boughtTicketList;
@property (nonatomic, strong) NSArray* favoriteCinemaList;
@property (nonatomic, strong) NSArray* checkInCinemaList;

@end
