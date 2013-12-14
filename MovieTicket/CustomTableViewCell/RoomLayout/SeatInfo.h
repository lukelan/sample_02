//
//  SeatInfo.h
//  123Phim
//
//  Created by phuonnm on 5/9/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SeatInfo : NSObject

@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, assign) NSInteger groupType;
@property (nonatomic, strong) NSString *identify;
@property (nonatomic, assign) NSInteger collumnGroup;

@end
