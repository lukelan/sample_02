//
//  LoadingView.h
//  123Phim
//
//  Created by Phuc Phan on 4/2/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GifImageView.h"

@interface LoadingView : UIView
{
    GifImageView *_imageView;
}

@property (nonatomic, strong) NSString *loadingImageAsGifName;
@property(nonatomic, weak) UIView *viewOnTop;

@end
