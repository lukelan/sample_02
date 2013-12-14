//
//  NSObject+FileHandler.m
//  123Phim
//
//  Created by phuonnm on 3/25/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "NSData+FileHandler.h"

@implementation NSData (FileHandler)

-(NSError *)saveDataTofile:(NSString *)fileName path: (NSString*) path
{
    NSString* dir = GALLERY_PATH;
    if (path && path.length != 0)
    {
        dir = path;
    }
    NSError* error = nil;
//    create path if need
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:&error];
        if (error)
        {
//            can not create dir
            return error;
        }
    }
//    save file
    NSString *fullPath = [dir stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
    [self writeToFile:fullPath options:NSDataWritingAtomic error:&error];
    return error;
}

@end
