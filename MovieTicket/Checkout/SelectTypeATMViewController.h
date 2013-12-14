//
//  SelectTypeATMViewController.h
//  123Phim
//
//  Created by Le Ngoc Duy on 5/6/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectBankViewController.h"
#import "GAI.h"
#import "BuyingInfo.h"
#import "Film.h"
#import "CustomTextView.h"
#import "UICheckBox.h"
#import "APIManager.h"
#import "ASIHTTPRequestDelegate.h"
#import "VNGSegmentedControl.h"
#import "CustomGAITrackedViewController.h"
#import "AppDelegate.h"

@interface SelectTypeATMViewController : CustomGAITrackedViewController <UITableViewDataSource, UITableViewDelegate, ChooseBankingViewControllerDelegate, APIManagerDelegate, ASIHTTPRequestDelegate, UIWebViewDelegate, UIAlertViewDelegate>
{
    ASIHTTPRequest *httpRequest;
    int _inputCardType;
    VNGSegmentedControl *_segmentBIDVInfo;
    UIWebView *_webView;
}
//@property (nonatomic, retain) NSString *redirectLinkCreateOrderM;
@property (nonatomic, retain) UITableView *layoutTable;
@property (nonatomic, assign) BuyingInfo *buyInfo;
@property (nonatomic, retain) CustomTextView *tvAccountNo, *tvAccountName, *tvAccountCardPass;
@property (nonatomic, retain) UICheckBox *cbRemember;
@end
