//
//  NSString+App.h
//  123Phim
//
//  Created by Nhan Mai on 5/22/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSString (App)
+ (NSString*)stringWithoutCharacterFrom: (NSString*)inStr;
- (NSString*) reverseString;
- (BOOL) isAllDigits;
- (void)logMessage:(NSString *)format, ...;
+ (NSString *)outStringWithKey:(NSString *)strkey;
+ (NSString *)outParserConvertFormat:(NSString *)strFormat;
+ (NSString *)outParser:(NSString *)strFormat,...;
+ (NSString *)outParserWithPattern:(NSString *)strPattern withParam:(NSString *)strFormat,...;
+ (NSString *)outParserReplace:(NSString *)strFormat byKeyInDic:(NSDictionary *)dic;
+ (NSString *)outParserReplace:(NSString *)strFormat;
@end
