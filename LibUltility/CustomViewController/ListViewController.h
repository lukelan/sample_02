//
//  ListViewController.h
//  123Phim
//
//  Created by Nhan Mai on 7/3/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface ListViewController : CustomViewController<UITableViewDataSource, UITableViewDelegate>
{
    UITableView* _table;
}

@property (nonatomic, assign) NSString* naviTitle;
@property (nonatomic, assign) NSMutableArray* dataList;

@end
