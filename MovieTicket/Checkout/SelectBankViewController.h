//
//  SelectBankViewController.h
//  123Phim
//
//  Created by Le Ngoc Duy on 5/10/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIManager.h"
#import "BankInfo.h"
#import "GAI.h"
#import "BuyingInfo.h"

@protocol ChooseBankingViewControllerDelegate <NSObject>
-(void)didSelectBank:(BankInfo*)bankInfo atIndex: (NSInteger)index;
@end


@interface SelectBankViewController : CustomGAITrackedViewController <UITableViewDataSource, UITableViewDelegate>
{
    __weak id<ChooseBankingViewControllerDelegate> _choosebankDelegate;
    NSMutableArray *_showingBankList;
}
@property (nonatomic, strong) UITableView* table;
@property (nonatomic, strong) BankInfo* currentBank;
@property (nonatomic, strong) BuyingInfo* buyInfo;
@property (nonatomic, strong) NSArray* bankList;
@property (nonatomic, weak) id<ChooseBankingViewControllerDelegate> chooseBankDelegate;
-(void)setFullScreen;
@end
