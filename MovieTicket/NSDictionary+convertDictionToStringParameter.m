//
//  NSDictionary+convertDictionToStringParameter.m
//  123Phim
//
//  Created by Le Ngoc Duy on 10/14/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "NSDictionary+convertDictionToStringParameter.h"

@implementation NSDictionary (convertDictionToStringParameter)
-(NSString *)convertDictionToStringParameter
{
    NSMutableString *result = [NSMutableString stringWithString:@""];
    for (id key in self)
    {
        id value = [self objectForKey:key];
        [result appendString:[NSString stringWithFormat:@"%@=%@&", key,value]];
    }
    return result;
}
@end
