//
//  TicketListViewController.h
//  123Phim
//
//  Created by Nhan Mai on 5/16/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "ListViewController.h"
#import "Friend.h"


@interface TicketListTableViewController : ListViewController
{
}

@property (nonatomic, weak) Friend* user;

@end
