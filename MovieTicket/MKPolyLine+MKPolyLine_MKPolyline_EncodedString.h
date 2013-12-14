//
//  MKPolyLine+MKPolyLine_MKPolyline_EncodedString.h
//  123Phim
//
//  Created by Nhan Mai on 4/18/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPolyline (MKPolyLine_MKPolyline_EncodedString)

+ (MKPolyline *)polylineWithEncodedString:(NSMutableString *)encodedString;

@end
