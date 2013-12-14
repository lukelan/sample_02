//
//  FilmSession.h
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/6/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cinema.h"
#import "Film.h"

@interface FilmSession : NSObject

@property (nonatomic,weak) Film *film;
@property (nonatomic,strong) NSMutableArray *sessionArrays;

@end
