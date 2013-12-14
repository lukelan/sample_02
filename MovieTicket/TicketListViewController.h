//
//  TicketListViewController.h
//  123Phim
//
//  Created by Nhan Mai on 5/16/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "ASIHTTPRequest.h"
#import "APIManager.h"

@interface TicketListViewController : CustomGAITrackedViewController<UITableViewDelegate, UITableViewDataSource>
{
}

@property (nonatomic, strong) UITableView* layoutTable;
@property (nonatomic, strong) NSMutableArray* listOfTicket;

@end
