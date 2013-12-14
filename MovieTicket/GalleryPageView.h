//
//  GallaryPageView.h
//  123Phim
//
//  Created by phuonnm on 3/19/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageView.h"


@interface GalleryPageView : PageView
{
    BOOL isDownloadingPoster;
    SDImageView *imageView;
    SDImageView *thumbnail;
}

-(void)setImageURL:(NSString *)imageURL imageThumbnailURL: (NSString *) imageThumbnailURL;

@end
