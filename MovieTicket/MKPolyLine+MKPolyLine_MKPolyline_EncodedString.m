//
//  MKPolyLine+MKPolyLine_MKPolyline_EncodedString.m
//  123Phim
//
//  Created by Nhan Mai on 4/18/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "MKPolyLine+MKPolyLine_MKPolyline_EncodedString.h"

@implementation MKPolyline (MKPolyLine_MKPolyline_EncodedString)

+ (MKPolyline *)polylineWithEncodedString:(NSMutableString *)encodedString
{
    [encodedString replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encodedString length])];
	NSInteger len = [encodedString length];
	NSInteger index = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encodedString characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encodedString characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
		NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
		[array addObject:loc];
        
    }
    
    CLLocationCoordinate2D coords[array.count];
    for (int i = 0; i < array.count; i++) {
        CLLocation* loc = [array objectAtIndex:i];
        CLLocationCoordinate2D point = CLLocationCoordinate2DMake(loc.coordinate.latitude, loc.coordinate.longitude);
        coords[i] = point;
    }

    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:array.count];
//    free(coords);

    return polyline;

}

@end
