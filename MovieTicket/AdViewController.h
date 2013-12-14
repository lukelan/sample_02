//
//  AdViewController.h
//  123Phim
//
//  Created by phuonnm on 9/23/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface AdViewController :CustomViewController <UIWebViewDelegate>

@property (copy, nonatomic) NSString *contentUrl;
@property (copy, nonatomic) NSString *title;
@property (weak, nonatomic) IBOutlet UIWebView *wvContent;

@end
