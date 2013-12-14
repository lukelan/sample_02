//
//  ListViewController.m
//  123Phim
//
//  Created by Nhan Mai on 7/3/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "ListViewController.h"
#import "AppDelegate.h"
#import "DefineConstant.h"

@interface ListViewController ()

@end

@implementation ListViewController
@synthesize naviTitle, dataList;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //set navigation title
//    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication];
//    [appDelegate setCustomBackButtonForNavigationItem:self.navigationItem];
//    [appDelegate setTitleLabelForNavigationController:self withTitle:self.naviTitle];
    
    //set table view
    NSInteger tableH = [[UIScreen mainScreen] bounds].size.height - TITLE_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - TAB_BAR_HEIGHT;
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, tableH) style:UITableViewStylePlain];
    _table.dataSource = self;
    _table.delegate = self;
    [self.view addSubview:_table];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
