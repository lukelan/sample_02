//
//  URLParser.h
//  123Phim
//
//  Created by Le Ngoc Duy on 6/14/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLParser : NSObject{
    NSArray *variables;
}

@property (nonatomic, retain) NSArray *variables;

- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForKey:(NSString *)keyName;
@end
