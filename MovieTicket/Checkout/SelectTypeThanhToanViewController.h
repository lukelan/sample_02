//
//  SelectTypeThanhToanViewController.h
//  123Phim
//
//  Created by Le Ngoc Duy on 4/25/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "BuyingInfo.h"
#import "Film.h"
#import "CustomTextView.h"
#import "APIManager.h"
#import "SelectSeatViewController.h"
#import "CustomGAITrackedViewController.h"


@interface SelectTypeThanhToanViewController : CustomGAITrackedViewController<UITableViewDataSource, UITableViewDelegate, RKManagerDelegate>
{
    BOOL isRequestTypeATM;
    UIImage *_facebookImage;
    NSDictionary *_bankListInfo;
}
@property (nonatomic, weak) id<SelectSeatViewDelegate> delegate;
@property (nonatomic, strong) UITableView *layoutTable;
@property (nonatomic, strong) BuyingInfo *buyInfo;
@property (nonatomic, strong) CustomTextView *tvEmail, *tvPhone;
@end
