//
//  ThanhToanVisaViewController.h
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
#import "ASIHTTPRequestDelegate.h"
#import "CustomGAITrackedViewController.h"

@interface ThanhToanVisaViewController : CustomGAITrackedViewController <UITableViewDataSource, UITableViewDelegate, APIManagerDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIWebViewDelegate>
{
    ASIHTTPRequest *httpRequest;
    int idErrorTypeCard;
}
@property (nonatomic, retain) UITableView *layoutTable;
@property (nonatomic, assign) BuyingInfo *buyInfo;
@property (nonatomic, assign) Film *film;
@property (nonatomic, retain) CustomTextView *tvAccountNo, *tvAccountName, *tvSecrectedCode, *tvExpiredDate;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSMutableArray* yearSelection;
@property (nonatomic, retain) UICheckBox *cbRemember;

@end
