//
//  Location.m
//  MovieTicket
//
//  Created by Le Ngoc Duy on 1/17/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "Location.h"


@implementation Location

@synthesize location_id;
@synthesize location_name;
@synthesize latitude;
@synthesize longtitude;
@synthesize center_name;
-(void)setValueLocationID:(int)locationid withLocationName:(NSString *)locationname
{
    location_id = locationid;
    location_name = locationname;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeInt32:self.location_id forKey:@"location_id"];
    [encoder encodeObject:self.location_name forKey:@"location_name"];
    [encoder encodeObject:self.center_name forKey:@"center_name"];
    [encoder encodeFloat:self.latitude forKey:@"latitude"];
    [encoder encodeFloat:self.longtitude forKey:@"longtitude"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.location_id = [decoder decodeInt32ForKey:@"location_id"];
        self.location_name = [decoder decodeObjectForKey:@"location_name"];
        self.center_name = [decoder decodeObjectForKey:@"center_name"];
        self.longtitude = [decoder decodeFloatForKey:@"longtitude"];
        self.latitude = [decoder decodeFloatForKey:@"latitude"];
    }
    return self;
}
-(void) setLocationObject:(Location *)source
{
    if (!source) {
        return;
    }
    self.location_id = source.location_id;
    self.location_name = source.location_name;
    self.center_name = source.center_name;
    self.longtitude = source.longtitude;
    self.latitude = source.latitude;
}

@end
