//
//  GifImageView.h
//  123Phim
//
//  Created by Phuc Phan on 4/2/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GifImageView : UIImageView

- (void)gifImageNamed:(NSString *)imageNamed;
- (void)animationWithGif:(NSString *)imageNamed;

@end
