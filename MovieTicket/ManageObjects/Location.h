//
//  Location.h
//  MovieTicket
//
//  Created by Le Ngoc Duy on 1/17/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location:NSObject<NSCoding>

@property int location_id;
@property (nonatomic, strong) NSString * location_name;
@property (nonatomic, strong) NSString * center_name;
@property float latitude;
@property float longtitude;
-(void) setValueLocationID:(int)locationid withLocationName:(NSString *)locationname;
-(void) setLocationObject:(Location *)source;
@end
