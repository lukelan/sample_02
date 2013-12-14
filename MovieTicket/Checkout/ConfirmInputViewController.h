//
//  ConfirmInputViewController.h
//  123Phim
//
//  Created by Le Ngoc Duy on 5/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#define DICT_KEY_BUY_INFO @"DICT_KEY_BUY_INFO"
#define DICT_KEY_BANK_DATA @"DICT_KEY_BK_DATA"
#define DICT_KEY_BANK_INFO @"DICT_KEY_BK_INFO"
#define DICT_KEY_DATE_BUYING @"DICT_KEY_DATE_BUYING"

#import <UIKit/UIKit.h>
#import "APIManager.h"
#import "GAI.h"
#import "BuyingInfo.h"
#import "Film.h"
#import "AppDelegate.h"
#import "CustomTextView.h"
#import "UICheckBox.h"
#import "VNGSegmentedControl.h"
#import "CustomGAITrackedViewController.h"
#import "BankInfo.h"
@interface ConfirmInputViewController : CustomGAITrackedViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIWebViewDelegate, BankInfoDelegate, RKManagerDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate>
{
    NSMutableDictionary *_viewInfo;
}
@property (nonatomic, strong) UITableView *layoutTable;
@property (nonatomic, strong) BuyingInfo *buyInfo;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, assign) BOOL canCancelTransaction;
@property (nonatomic, strong) BankInfo *bankInfo;
@property (nonatomic, strong) NSDictionary *bankData;
@property (nonatomic, assign) BOOL isMasterConfirm;
@property (nonatomic, strong) NSMutableData *mutableData;
@end
