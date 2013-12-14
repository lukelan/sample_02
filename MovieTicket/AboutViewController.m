//
//  AboutViewController.m
//  123Phim
//
//  Created by Nhan Mai on 3/13/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "AboutViewController.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "APIManager.h"

@interface AboutViewController ()

@property (nonatomic, assign) CGFloat cellHeight;
@end

@implementation AboutViewController
@synthesize table = _table;
@synthesize tableData = _tableData;
@synthesize cellHeight = _cellHeight;

-(void)dealloc
{
    _table = nil;
    _tableData = nil;
    _cellHeight = 0;
}
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        viewName = ABOUT_VIEW_NAME;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
	// Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.clipsToBounds = YES;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:TITLE_ABOUT];
    
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - TITLE_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    _table.delegate = self;
    _table.dataSource = self;
    _table.backgroundView = nil;
    NSString *file = [NSString stringWithFormat:@"%@/AboutContent.html", BUNDLE_PATH];
    NSError *error;
    NSString* aboutContent = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
    
    NSString* version = [NSString stringWithFormat: @"Version %@\nUpdate on Dec 10, 2013\nSize: 2.8 MB\nContent rating: Medium maturity", [AppDelegate getVersionOfApplication]];
    NSString* logo = @"";
    _tableData = [[NSArray alloc] initWithObjects:
                                            aboutContent,
                                            version,
                                            logo,
                                            nil];
    
    //set background
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    [self.view addSubview:self.table];
    self.trackedViewName = viewName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark datasource and delegate of table

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableData count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellId = [NSString stringWithFormat:@"cell_%d_%d", indexPath.section, indexPath.row];
    UITableViewCell* retCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (indexPath.section == 0) { //about
        if (indexPath.row == 0) {
            if (retCell == nil) {
                retCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
                retCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                NSString *contentString = [self.tableData objectAtIndex:indexPath.row];
                
                NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
                UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
                {
                   webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
                }
                webView.delegate = self;
                webView.tag = 100;
                webView.opaque = NO;
                webView.userInteractionEnabled = NO;
                webView.scrollView.scrollEnabled = NO;
                webView.backgroundColor = [UIColor clearColor];

                [webView loadHTMLString:contentString baseURL:baseURL];
                [retCell.contentView addSubview:webView];
                baseURL = nil;
                return retCell;
                
            }
        }
    }else if (indexPath.section == 1 ) { //version
        if (indexPath.row == 0) {
            if (retCell == nil) {
                retCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
                retCell.selectionStyle = UITableViewCellSelectionStyleNone;
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 320, 90)];
                label.font = [UIFont getFontNormalSize13];
                NSString* contentString =  [self.tableData objectAtIndex:indexPath.section];
                label.backgroundColor = [UIColor clearColor];
                label.text = contentString;
                label.numberOfLines = 0;
                [retCell.contentView addSubview:label];
                return retCell;
            }

        }
    }else if (indexPath.section == 2) {//add logo        
        if (retCell == nil) {
            retCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
            retCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView* transView = [[UIView alloc] initWithFrame:CGRectZero];
            transView.backgroundColor = [UIColor clearColor];
            retCell.backgroundView = transView;
            
            UIImageView* vngLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
            vngLogo.image = [UIImage imageNamed:@"vng_logo.png"];
            UIImageView* zingLogo = [[UIImageView alloc] initWithFrame:CGRectMake(65, 17, 50, 25)];
            zingLogo.image = [UIImage imageNamed:@"zing_logo.png"];
            UIImageView* payLogo = [[UIImageView alloc] initWithFrame:CGRectMake(150, 4, 80, 40)];
            payLogo.image = [UIImage imageNamed:@"123pay_logo.png"];
            UIImageView* movieLogo = [[UIImageView alloc] initWithFrame:CGRectMake(260, 0, 40, 40)];
            movieLogo.image = [UIImage imageNamed:@"icon.png"];
  
            [retCell.contentView addSubview:movieLogo];
            [retCell.contentView addSubview:payLogo];
            [retCell.contentView addSubview:zingLogo];
            [retCell.contentView addSubview:vngLogo];
            
        }

    }else{
        
    }
    return retCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        if (self.cellHeight)
            return self.cellHeight;
        
    }if (indexPath.section == 1) {
        return 90;
    }
    
    return 44;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.tag == 100) {
        CGRect frame = webView.frame;
        frame.size.height = webView.scrollView.contentSize.height;
        webView.frame = frame;
        
        [self updateCellHeight:webView.scrollView.contentSize.height];
    }
}

- (void)updateCellHeight:(NSInteger)height
{
    self.cellHeight = height;
    [self.table reloadData];
}

@end
