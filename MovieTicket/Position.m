//
//  Position.m
//  MovieTicket
//
//  Created by nhanmt on 1/31/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "Position.h"

@implementation Position
@synthesize positionCoodinate2D, address;


- (id)init
{
    self = [super init];
    if (self) {
        address = [[NSString alloc] init];
    }
    return  self;
}

-(void)setCoordinateLongAndLat:(CLLocationCoordinate2D)coordinate2D
{
    self.positionCoodinate2D = coordinate2D;
}
@end
