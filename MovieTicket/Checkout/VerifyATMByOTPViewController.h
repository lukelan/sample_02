//
//  VerifyATMByOTPViewController.h
//  123Phim
//
//  Created by Le Ngoc Duy on 5/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIManager.h"
#import "ASIHTTPRequestDelegate.h"
#import "GAI.h"
#import "BuyingInfo.h"
#import "Film.h"
#import "AppDelegate.h"
#import "CustomTextView.h"
#import "UICheckBox.h"
#import "VNGSegmentedControl.h"
#import "CustomGAITrackedViewController.h"
@interface VerifyATMByOTPViewController : CustomGAITrackedViewController <UITableViewDataSource, UITableViewDelegate, APIManagerDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate, UIWebViewDelegate>
{
    ASIHTTPRequest *httpRequest;
    VNGSegmentedControl *_segmentBIDVInfo;
    CreditResult creditResult;
}
@property (nonatomic, assign) BOOL isTypeBIDV;
@property (nonatomic, retain) UITableView *layoutTable;
@property (nonatomic, retain) BuyingInfo *buyInfo;
@property (nonatomic, retain) CustomTextView *tvAccountNo, *tvAccountName, *tvVerifyOTP;
@property (nonatomic, retain) UIWebView *webView;
//@property (nonatomic, retain) NSString *redirectLinkCreditCard;
@property (nonatomic, assign) BOOL canCancelTransaction;
@end
