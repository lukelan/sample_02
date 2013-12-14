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
#import <MessageUI/MessageUI.h>
#import "CheckInViewController.h"

@interface EventWebViewController : CustomGAITrackedViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
{
    UIWebView *_webView;
    BOOL _finishLoading;
    UILabel *_lbCinemaTitle;
    NSInteger _actionViewIndex;
}
@property (nonatomic, strong) Event *event;

@end