//
//  NSDictionary+FileHandler.h
//  123Phim
//
//  Created by phuonnm on 9/18/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (FileHandler)

-(NSError *)saveTofile:(NSString *)fileName path: (NSString*) path;

@end
