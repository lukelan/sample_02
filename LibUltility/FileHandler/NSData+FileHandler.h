//
//  NSObject+FileHandler.h
//  123Phim
//
//  Created by phuonnm on 3/25/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (FileHandler)

-(NSError *)saveDataTofile:(NSString *)fileName path: (NSString*) path;

@end
