//
//  UIImage+Ultility.h
//  123Phim
//
//  Created by phuonnm on 5/27/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Ultility)

+ (UIImage*)reduceImage: (UIImage*)origionImage toRect: (CGSize)newRect;
+ (BOOL)isJPEGValid:(NSData *)jpeg;
- (UIImage *)fixOrientation;

@end
