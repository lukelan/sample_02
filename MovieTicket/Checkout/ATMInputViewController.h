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
#import "VNGSegmentedControl.h"
#import "CustomGAITrackedViewController.h"
#import "AppDelegate.h"

@interface ATMInputViewController : CustomGAITrackedViewController <UITableViewDataSource, UITableViewDelegate, ChooseBankingViewControllerDelegate, UIWebViewDelegate, UIAlertViewDelegate, BankInfoDelegate, RKManagerDelegate>
{
    int _inputCardType;
    NSMutableDictionary *_viewInfo;
    UIWebView *_webView;
}
@property (nonatomic, strong) NSString *redirectLinkCreateOrderM;
@property (nonatomic, strong) UITableView *layoutTable;
@property (nonatomic, strong) BuyingInfo *buyInfo;
@property (nonatomic, strong) BankInfo *bankInfo;
@property (nonatomic, strong) UICheckBox *cbRemember;
@property (nonatomic, strong) NSDictionary *loadInfo;
@property (nonatomic, strong) NSArray *bankList;

@end
