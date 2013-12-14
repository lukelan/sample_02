//
//  UIImageView+Action.m
//  MovieTicket
//
//  Created by phuonnm on 3/1/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "UIImageView+Action.h"

@implementation UIImageView(Action)

- (UIImage *) croppedImageWithImage: (UIImage *) theImage scale: (BOOL) scale
{
    UIImage *image = theImage;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    // Get size of current image
    CGSize size = [image size];
    
    // Frame location in view to show original image
    [imageView setFrame:CGRectMake(0, 0, size.width, size.height)];
    [self.window addSubview:imageView];
    
    // Create rectangle that represents a cropped image
    // from the middle of the existing image
    CGSize toSize = self.frame.size;
    if (scale)
    {
        toSize = [self unionSizeOfSize:size andSize:toSize];
    }
    CGRect rect = CGRectMake((size.width - toSize.width) / 2, (size.height - toSize.height) / 2 ,
                             toSize.width, toSize.height);
    
    // Create bitmap image from original image data,
    // using rectangle to specify desired crop area
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    [imageView removeFromSuperview];
    CGImageRelease(imageRef);
    return img;
}

- (UIImage*)reduceImage: (UIImage*)origionImage toRect: (CGSize)newRect{
    UIGraphicsBeginImageContext(newRect);
    CGRect targetRect = CGRectMake(0, 0, newRect.width, newRect.height);
    [origionImage drawInRect:targetRect];
    UIImage* newSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newSizeImage;
}

- (CGSize) unionSizeOfSize: (CGSize) imageSize andSize: (CGSize) toSize
{
    CGFloat wf = imageSize.width / toSize.width;
    CGFloat hf = imageSize.height / toSize.height;
    CGSize size = imageSize;
    if (wf > hf)
    {
        size.width = hf * toSize.width;
    }
    else
    {
        size.height = wf * toSize.height;
    }
    return size;
}

@end
