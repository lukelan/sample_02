//
//  PlusViewController.h
//  123Phim
//
//  Created by Le Ngoc Duy on 12/11/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuyingInfo.h"
#import "CustomTextView.h"
#import "CustomGAITrackedViewController.h"
#import "APIManager.h"

@interface PlusViewController : CustomGAITrackedViewController <UITableViewDataSource, UITableViewDelegate, RKManagerDelegate>
@property (nonatomic, strong) BuyingInfo *buyInfo;
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (weak, nonatomic) IBOutlet UIButton *btnThanhToan;
@property (weak, nonatomic) IBOutlet UIView *viewOTP;
@property (weak, nonatomic) IBOutlet UIButton *btnOTP;
@property (weak, nonatomic) IBOutlet CustomTextView *textViewInputOTP;
- (IBAction)processThanhToan:(id)sender;
- (IBAction)processGetOTP:(id)sender;
@end
