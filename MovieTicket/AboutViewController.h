//
//  AboutViewController.h
//  123Phim
//
//  Created by Nhan Mai on 3/13/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomGAITrackedViewController.h"

@interface AboutViewController : CustomGAITrackedViewController<UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>
{
    UITableView* _table;
    NSArray* _tableData; 
}
@property (nonatomic, strong) UITableView* table;
@property (nonatomic, strong) NSArray* tableData;

@end
