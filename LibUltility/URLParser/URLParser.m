//
//  URLParser.m
//  123Phim
//
//  Created by Le Ngoc Duy on 6/14/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "URLParser.h"

@implementation URLParser
@synthesize variables;

- (id) initWithURLString:(NSString *)url{
    self = [super init];
    if (self != nil) {
        NSString *string = url;
        NSScanner *scanner = [NSScanner scannerWithString:string];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
        NSString *tempString;
        NSMutableArray *vars = [NSMutableArray new];
        [scanner scanUpToString:@"?" intoString:nil];       //ignore the beginning of the string and skip to the vars
        while ([scanner scanUpToString:@"&" intoString:&tempString]) {
            [vars addObject:tempString];
        }
        self.variables = vars;
    }
    return self;
}

- (NSString *)valueForKey:(NSString *)keyName {
    for (NSString *var in self.variables) {
        if ([var length] > [keyName length]+1 && [[var substringWithRange:NSMakeRange(0, [keyName length]+1)] isEqualToString:[keyName stringByAppendingString:@"="]]) {
            NSString *varValue = [var substringFromIndex:[keyName length]+1];
            return varValue;
        }
    }
    return nil;
}

- (void) dealloc{
    self.variables = nil;
}
@end
