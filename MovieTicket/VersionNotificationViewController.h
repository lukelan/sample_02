//
//  VersionNotificationViewController.h
//  123Phim
//
//  Created by phuonnm on 4/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface VersionNotificationViewController : CustomViewController
{
    UIWebView *_webView;
    UIImageView *_imageView;
    NSOperationQueue *_queue;
}
@property (nonatomic, strong) NSString *imageLink;
@property (nonatomic, assign) BOOL canSkip;
@property (nonatomic, assign) BOOL dismissWhenSkip;

@end
