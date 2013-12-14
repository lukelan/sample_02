//
//  Position.h
//  MovieTicket
//
//  Created by nhanmt on 1/31/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Position : NSObject
{
    
}
@property (nonatomic, strong) NSString* address;
@property (nonatomic, assign) CLLocationCoordinate2D positionCoodinate2D;

-(void)setCoordinateLongAndLat:(CLLocationCoordinate2D)coordinate2D;
@end
