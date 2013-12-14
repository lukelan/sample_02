//
//  NSString+SHA.h
//  123Phim
//
//  Created by Le Ngoc Duy on 9/3/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
@interface NSString (SHA)
+(NSString*) sha1:(NSString*)input;
@end
