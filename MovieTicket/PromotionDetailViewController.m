//
//  PromotionViewController.m
//  123Phim
//
//  Created by Le Ngoc Duy on 3/20/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "PromotionDetailViewController.h"
#import "PromotionInfoCell.h"
#import "MainViewController.h"
#import "APIManager.h"

@interface PromotionDetailViewController ()
@property (nonatomic) CGFloat cellHeight;
@end

@implementation PromotionDetailViewController
@synthesize tableview = _tableview;
@synthesize cellHeight;
@synthesize myNews = _myNews;

-(void)dealloc
{
    _tableview = nil;
    _myNews =nil;
    cellHeight = 0;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.title = @"Khuyến mãi";
        viewName = PROMOTION_DETAIL_VIEW_NAME;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:self.title];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.tableview=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableview.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - TITLE_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) ;
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.backgroundView = nil;
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    self.tableview.scrollsToTop = YES;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tableview.separatorColor=[UIColor  grayColor] ;
    [self.view addSubview:self.tableview];

	// Do any additional setup after loading the view.
    self.trackedViewName = viewName;
    [self initHandleSwipeGestureRecognizer];
}

-(void)initHandleSwipeGestureRecognizer
{
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(handleSwipeFrom:)];
    [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [gesture setCancelsTouchesInView:NO];
    [self.view  addGestureRecognizer:gesture];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [delegate popViewController];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


#pragma mark Table Delegate
-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return MARGIN_EDGE_TABLE_GROUP;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return MARGIN_EDGE_TABLE_GROUP;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {    
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellHeight)
        return self.cellHeight;

    CGSize sizeText = [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]];
    CGFloat heighCell = (4*MARGIN_EDGE_TABLE_GROUP + IMAGE_PROMOTION_H) + sizeText.height;
    return heighCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell_%d",indexPath.section];
    PromotionInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[PromotionInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell setDelegate:self];
        [cell layoutWebView:_myNews];
    } else {
        
        UIView *view = [(PromotionInfoCell *)cell viewWithTag:TAG_AUTO_SCROLL_LABEL];
        if ([view isKindOfClass:[AutoScrollLabel class]]) {
            AutoScrollLabel *autoLable = (AutoScrollLabel *)view;
            [autoLable refreshLabels];
        }
    }

    return cell;
}

#pragma mark We should process clean resource when get warning memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateTableViewHeight:(CGFloat)height
{
    CGRect frame = self.tableview.frame;
    
    frame.size.height = height + 2 * MARGIN_EDGE_TABLE_GROUP;
    self.cellHeight = height;
    [self.tableview setContentSize:frame.size];
    [self.tableview reloadData];
}

-(void)setMyNews:(News *)myNews
{
    _myNews = myNews;
    if (!_myNews.content || _myNews.content.length == 0)
    {
        [self getPromotionContent];
    }
}

-(void)getPromotionContent
{
    [[APIManager sharedAPIManager] getNewsContentWithID:_myNews.news_id responseTo:self];
}
#pragma mark -
#pragma mark RKManageDelegate
#pragma mark -
-(void)processResultResponseDictionaryMapping:(DictionaryMapping *)dictionary requestId:(int)request_id
{
    if (request_id == ID_REQUEST_GET_PROMOTION_CONTENT) {
        [[APIManager sharedAPIManager] parseToUpdateNews:_myNews withResponse:dictionary.curDictionary];
        [self didLoadNewsContent];
    }
}

-(void)didLoadNewsContent
{
    PromotionInfoCell *cell = (PromotionInfoCell *)[_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell layoutWebView:_myNews];
}
@end
