//
//  VisaInputViewController.m
//  123Phim
//
//  Created by phuonnm on 5/9/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "GAI.h"
#import "BuyingInfo.h"
#import "Film.h"
#import "CustomTextView.h"
#import "UICheckBox.h"
#import "APIManager.h"
#import "AppDelegate.h"
#import "CustomGAITrackedViewController.h"
#import "BankInfo.h"

@interface VisaInputViewController : CustomGAITrackedViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIWebViewDelegate, BankInfoDelegate, RKManagerDelegate>
{
    ASIHTTPRequest *httpRequest;
    int idErrorTypeCard;
    NSMutableDictionary *_viewInfo;
}

@property (nonatomic, strong) UITableView *layoutTable;
@property (nonatomic, strong) BuyingInfo *buyInfo;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UICheckBox *cbRemember;
@property (nonatomic, strong) BankInfo *bankInfo;
@property (nonatomic, strong) NSDictionary *loadInfo;

@end