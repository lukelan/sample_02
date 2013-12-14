//
//  CheckoutResultViewController.h
//  123Phim
//
//  Created by Nhan Mai on 5/9/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "BuyingInfo.h"
#import "Ticket.h"
#import "CustomGAITrackedViewController.h"
#import "FBMessageView.h"

@interface CheckoutResultViewController : CustomGAITrackedViewController<UITableViewDataSource, UITableViewDelegate>
{
    int statusThanhToan;
}
@property (nonatomic, assign) BOOL isCommingFromTicketList;
@property (nonatomic, strong) UITableView *layoutTable;
@property (nonatomic, weak) BuyingInfo *buyInfo;
@property (nonatomic, weak) Ticket *ticketInfo;

@end
