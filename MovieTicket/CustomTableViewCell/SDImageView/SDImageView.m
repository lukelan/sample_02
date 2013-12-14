//
//  SDImageView.m
//  123Phim
//
//  Created by phuonnm on 7/18/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "SDImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation SDImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url completed:nil];
}

-(void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletedBlock)completedBlock
{
    NSString *cacheKey = [SDWebImageManager sharedManager].cacheKeyFilter(url);
    if (self.cahceKey && [cacheKey isEqualToString:self.cahceKey])
    {
        return;
    }
    [self cancelCurrentImageLoad];
    if (self.cahceKey)
    {
        [[SDWebImageManager sharedManager].imageCache removeImageForKey:self.cahceKey fromDisk:NO];
    }
    [self setCahceKey:cacheKey];
    __block void (^returnBlock)() = ^void(UIImage *image, NSError *error, SDImageCacheType cacheType)
    {
        [self setCahceKey:@""];
        if (completedBlock)
        {
            completedBlock(image, error, cacheType);
        }
    };
    [super setImageWithURL:url completed:returnBlock];
}

-(void)dealloc
{
    [self cancelCurrentImageLoad];
    if (self.cahceKey)
    {
        [[SDWebImageManager sharedManager].imageCache removeImageForKey:self.cahceKey fromDisk:NO];
    }
}

@end
