//
//  GifImageView.m
//  123Phim
//
//  Created by Phuc Phan on 4/2/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "GifImageView.h"
#import <ImageIO/ImageIO.h>

@implementation GifImageView

- (void)gifImageNamed:(NSString *)imageNamed
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:imageNamed ofType:nil];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    NSMutableArray *tmpArray = [NSMutableArray array];
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    size_t count = CGImageSourceGetCount(source);
    
    for (size_t i = 0; i < count; i++) {
        
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
        UIImage *image = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        [tmpArray addObject:image];
        CGImageRelease(imageRef);
    }
    
    CFRelease(source);
    
    if (tmpArray.count < 1) return;

    self.animationImages = tmpArray;
}

- (void)animationWithGif:(NSString *)imageNamed
{
    self.animationRepeatCount = 0;
    self.animationDuration = 1;
    [self gifImageNamed:imageNamed];
    [self stopAnimating];
    [self startAnimating];
}

@end
