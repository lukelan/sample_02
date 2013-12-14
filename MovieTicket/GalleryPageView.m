//
//  GallaryPageView.m
//  123Phim
//
//  Created by phuonnm on 3/19/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "GalleryPageView.h"
#import "UIImageView+Action.h"

@implementation GalleryPageView

-(void)dealloc
{
    isDownloadingPoster = 0;
    imageView = nil;
    thumbnail = nil;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect bounds = self.bounds;
        imageView = [[SDImageView alloc] initWithFrame:bounds];
        imageView.clipsToBounds = YES;
        thumbnail = [[SDImageView alloc] initWithFrame:bounds];
        [thumbnail setContentMode:UIViewContentModeScaleAspectFit];
        thumbnail.backgroundColor = [UIColor blackColor];
        [self addSubview:imageView];
    }
    return self;
}

-(void)setImageURL:(NSString *)imageURL imageThumbnailURL: (NSString *) imageThumbnailURL
{
    [self addSubview:thumbnail];
    [thumbnail setImageWithURL:[NSURL URLWithString:imageThumbnailURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [imageView setImageWithURL:[NSURL URLWithString:imageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image)
            {
                [self didFinishDownloadImage:image];
            }
        }];
    }];
}

-(void)didFinishDownloadImage: (UIImage*) image
{

    imageView.contentMode = UIViewContentModeScaleAspectFit;

    if (self.superview &&  (self.frame.origin.x == self.frame.size.width))
    {
        [UIView transitionFromView:thumbnail toView:imageView duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            [thumbnail removeFromSuperview];
        }];
    }
    else
    {
        [self addSubview:imageView];
        [thumbnail removeFromSuperview];
    }
}

@end
