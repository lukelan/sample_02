//
//  BuyingViewController.m
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/6/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#import "BuyingViewController.h"
#import "APIManager.h"
#import "AppDelegate.h"

@interface BuyingViewController ()

@end

@implementation BuyingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        viewName = BUYING_VIEW_NAME;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
