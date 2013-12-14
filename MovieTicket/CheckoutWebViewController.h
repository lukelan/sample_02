//
//  CheckoutWebViewController.h
//  123Phim
//
//  Created by phuonnm on 4/23/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "Film.h"
#import "CinemaWithDistance.h"
#import "CustomGAITrackedViewController.h"

@interface CheckoutWebViewController : CustomGAITrackedViewController <UIWebViewDelegate>
{
    UIWebView *_webView;
    BOOL _finishLoading;
    UILabel *_lbCinemaTitle;
}
@property (nonatomic, strong) Session *currentSession;
@property (nonatomic, weak) Film *currentFilm;
@property (nonatomic, weak) CinemaWithDistance *currentCinemaWithDistance;
@end