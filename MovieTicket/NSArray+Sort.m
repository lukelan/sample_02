//
//  NSArray+Sort.m
//  123Phim
//
//  Created by Nhan Mai on 7/9/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "NSArray+Sort.h"
#import "CinemaWithDistance.h"

@implementation NSArray (Sort)

+ (NSArray*)getCinemaSortDescriptor
{
    NSSortDescriptor* sortBookDescription = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO comparator:^(id obj1, id obj2){
        CinemaWithDistance* cinema1 = obj1;
        CinemaWithDistance* cinema2 = obj2;
        return ([cinema1.cinema.is_booking compare:cinema2.cinema.is_booking]);
        
    }];
//    NSSortDescriptor* sortDistanceDescription = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    NSSortDescriptor* sortDistanceDescription = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES comparator:^(id obj1, id obj2){
        CinemaWithDistance* cinema1 = obj1;
        CinemaWithDistance* cinema2 = obj2;
        return [[NSNumber numberWithFloat:cinema1.distance] compare:[NSNumber numberWithFloat:cinema2.distance]];
    }];
    
    NSArray* sortDescription = [[NSArray alloc] initWithObjects:sortBookDescription, sortDistanceDescription, nil];
    
    return sortDescription;
}

@end
