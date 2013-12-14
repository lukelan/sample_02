//
//  CinemaLocationCal.m
//  123Phim
//
//  Created by Phuc Phan on 4/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CinemaLocationCal.h"
#import "Cinema.h"
#import "Location.h"
#import "SBJsonParser.h"

@implementation CinemaLocationCal

- (void)getDistance:(NSArray *)cinemas withLocation:(Location *)location mode:(NSString *)mode callback:(void (^)(id))callback
{
    NSString *api = @"http://maps.googleapis.com/maps/api/distancematrix/json?origins=%@&destinations=%@&mode=%@&sensor=false";
    
    NSString *origin;
    NSString *destinations;
    NSMutableArray *destinationsArray = [[NSMutableArray alloc] init];
    
    for (Cinema *cinema in cinemas) {
        
        NSString *item = [NSString stringWithFormat:@"%@,%@", cinema.cinema_latitude, cinema.cinema_longtitude];

        [destinationsArray addObject:item];
        
    }
    
    origin = [NSString stringWithFormat:@"%f,%f", location.latitude, location.longtitude];
    
    destinations = [destinationsArray componentsJoinedByString:@"|"];
    api = [NSString stringWithFormat:api, origin, destinations, mode];
    api = [api stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     
    NSURL *url = [NSURL URLWithString:api];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 20];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                               if (!error) {

                                   NSMutableArray *list = [[NSMutableArray alloc] init];
                                   SBJsonParser *parsor = [[SBJsonParser alloc] init];
                                   NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSDictionary *rawData = [parsor objectWithString:string];
                                   
                                   if ([[rawData objectForKey:@"status"] isEqual:@"OK"]) {
                                       
                                       NSArray* rows = [rawData objectForKey:@"rows"];
                                       
                                       for (int x = 0; x < [rows count]; x++) {
                                           
                                           NSDictionary *row = rows[x];
                                           NSArray *elements = [row valueForKey:@"elements"];
                                           
                                           for (int y = 0; y < [elements count]; y++) {
                                               
                                               NSDictionary *element = elements[y];
                                               NSString *status = [element valueForKey:@"status"];
                                                                                        
                                               NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
                                               

                                               NSNumber *distance = [NSNumber numberWithInt:0];
                                               NSNumber *duration = [NSNumber numberWithInt:0];
                                               
                                               if ([status isEqualToString:@"OK"]) {
                                                   NSObject *dis = [element valueForKey:@"distance"];
                                                   NSObject *dur = [element valueForKey:@"duration"];

                                                   distance = [dis valueForKey:@"value"];
                                                   duration = [dur valueForKey:@"value"];

                                               }                                               
                                               [tmp setObject:distance forKey:@"distance"];
                                               [tmp setObject:duration forKey:@"duration"];
                                               
                                               [list addObject:tmp];
                                           }
                                           
                                       }
//                                       LOG_123PHIM(@"get location failed");
                                   }

                                   callback(list);
                               }
                               
                               
    }];
    

}

- (void)getDistance:(NSArray *)cinemas withLocation:(Location *)location context:(id)context selector:(SEL)selector
{
    [self getDistance:cinemas withLocation:location mode:@"driving" callback:^(NSArray *drivingList)
     {
        NSArray *list = [self prepareData:cinemas driving:drivingList];
        [context performSelectorOnMainThread:selector withObject:list waitUntilDone:NO];

    }];
}

- (NSArray *)prepareData:(NSArray *)cinemas driving:(NSArray *)driving
{
    BOOL isValid = ([driving count] == [cinemas count]);
    if (!isValid)
    {
        return nil;
    }
    NSMutableArray *new = [[NSMutableArray alloc] init];
    for (int i = 0; i < [cinemas count]; i++)
    {
        CinemaWithDistance *tmp = [[CinemaWithDistance alloc] init];
        Cinema *c = cinemas[i];
        tmp.cinema = c;
        NSObject *d = driving[i];
        tmp.distance     = [[d valueForKey:@"distance"] floatValue];
        tmp.driving_time = [[d valueForKey:@"duration"] intValue];
        
        [new addObject:tmp];
    }
    
    return new;
}

@end
