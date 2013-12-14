//
//  DelegateDatasourceSawfilm.h
//  MovieTicket
//
//  Created by Nhan Mai on 2/21/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserViewController.h"

@interface DelegateDatasourceSawfilm : NSObject<UITableViewDataSource, UITableViewDelegate>
{
    
}

@property (nonatomic, retain) UserViewController* delegate;

@end
