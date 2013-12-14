//
//  News.h
//  123Phim
//
//  Created by Le Ngoc Duy on 3/20/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface News : NSObject
@property int news_id;
@property (nonatomic, strong) NSString * news_description;
@property (nonatomic, strong) NSString * news_title;
@property (nonatomic, strong) NSString * image;
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSString * bannerURL;
@property (nonatomic, strong) NSNumber * cinemaGroupID;
@property (nonatomic, strong) NSNumber * cinemaID;
@property (nonatomic, strong) NSString * filmIDList;
@end
