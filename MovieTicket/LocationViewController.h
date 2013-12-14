//
//  LocationViewController.h
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/6/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "AppDelegate.h"
#import "DefineConstant.h"

@interface LocationTableView: UITableView


@end


@interface LocationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    __weak id<LocationDelegate> _locationDataController;
    NSMutableArray *locationArray;
    LocationTableView *tableView;
    
    int tableRow;
}

//@property CGRect frame;

@property (nonatomic, retain) NSMutableArray *locationArray;
@property (nonatomic, weak) id<LocationDelegate> locationDataController;





@end
