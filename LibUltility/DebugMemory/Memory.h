//
//  Memory.h
//  123Phim
//
//  Created by phuonnm on 3/4/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Memory : NSObject

+(void) logMemUsage;
+(void) logMemUsage:(BOOL) allwayShow;

@end
