//
//  UserProfile.h
//  123Phim
//
//  Created by phuonnm on 3/6/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface UserProfile : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) UIImage  *avatarImage;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *zing_id;
@property (nonatomic, strong) NSString *facebook_id;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) Location * city;

@end
