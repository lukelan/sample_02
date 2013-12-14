//
//  UIImageView+Action.h
//  MovieTicket
//
//  Created by phuonnm on 3/1/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Action)

- (UIImage *) croppedImageWithImage: (UIImage *) image scale: (BOOL) scale;
- (UIImage*)reduceImage: (UIImage*)origionImage toRect: (CGSize)newRect;

@end
