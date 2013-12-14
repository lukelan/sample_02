//
//  Event.h
//  123Phim
//
//  Created by Nhan Mai on 6/21/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* link;
@property (nonatomic, strong) NSString* webLink;
@property (nonatomic, strong) NSArray *lstButtons;

@end
