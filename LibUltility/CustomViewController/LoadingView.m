//
//  LoadingView.m
//  123Phim
//
//  Created by Phuc Phan on 4/2/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "LoadingView.h"
#import "GifImageView.h"

@implementation LoadingView

@synthesize loadingImageAsGifName = _loadingImageAsGifName;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    CGSize window = frame.size;
    
    CGRect lFrame = CGRectMake(0, 0, 50, 50);
    lFrame.origin.x = (window.width  - lFrame.size.width)  / 2;
    lFrame.origin.y = (window.height - lFrame.size.height) / 2;
    _imageView = [[GifImageView alloc] initWithFrame:lFrame];
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:_imageView];
    
    return self;
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!_loadingImageAsGifName)
    {
        _loadingImageAsGifName = @"loading.gif";
    }
    [_imageView animationWithGif:_loadingImageAsGifName];
}


@end
