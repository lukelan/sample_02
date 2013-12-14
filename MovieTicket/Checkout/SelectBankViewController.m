//
//  SelectBankViewController.m
//  123Phim
//
//  Created by Le Ngoc Duy on 5/10/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "SelectBankViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "ATMInputViewController.h"
#import "CustomTableViewCell.h"

@interface SelectBankViewController ()

@end

@implementation SelectBankViewController
@synthesize table, chooseBankDelegate = _choosebankDelegate, currentBank;
@synthesize bankList = _bankList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - TITLE_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
        table.dataSource = self;
        table.delegate = self;
        table.backgroundView = nil;
        
        viewName = SELECT_BANK_VIEW_NAME;
        self.isSkipWarning = YES;
    }
    return self;
}

-(void)setFullScreen
{
    CGRect frame = table.frame;
    frame.size.height =  table.frame.size.height + NAVIGATION_BAR_HEIGHT;
    [table setFrame:frame];
}

-(void)dealloc
{
    self.bankList = nil;
    SAFE_RELEASE(_showingBankList)
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    //set navigation bar title
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:@"Chọn thẻ của ngân hàng"];
    
    // add table
    [self.view setBackgroundColor:[UIFont colorBackGroundApp]];
    [self.view addSubview:self.table];
    [self.table setBackgroundColor:[UIFont colorBackGroundApp]];
    [self.table setBackgroundView:nil];
    self.trackedViewName = viewName;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableDelegate, UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return MARGIN_EDGE_TABLE_GROUP;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int n = 0;
    if (_showingBankList)
    {
        n = [_showingBankList count];
    }
    return n;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BankInfo* bank = [_showingBankList objectAtIndex:indexPath.row];
    NSString* cellIdentifier = @"CustomTableViewCell";
    CustomTableViewCell* retCell = [table dequeueReusableCellWithIdentifier:cellIdentifier];
    if (retCell == nil)
    {
        NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil];
        retCell = [arr objectAtIndex:0];
    }
    //set selected checkbox
    retCell.detailTextLabel.text = @"";
    retCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    retCell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if (bank.bank_status == BANK_STATUS_ATM_DISABLE || [bank.bank_code isEqualToString:[self.currentBank bank_code]])
    {
        retCell.textLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:101.0/255.0 blue:102.0/255.0 alpha:1.0];
        if (bank.bank_status == BANK_STATUS_ATM_DISABLE)
        {
            retCell.detailTextLabel.textColor =  retCell.textLabel.textColor;
            NSString *desc = @"Maintaining";
            if (bank.bankStatusDesc)
            {
                desc = bank.bankStatusDesc;
            }
            retCell.detailTextLabel.text = desc;
            retCell.selectionStyle = UITableViewCellSelectionStyleNone;
            retCell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            retCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    retCell.textLabel.text = [NSString stringWithFormat:@"%@", bank.bank_name];
    [retCell.sdImageView setImageWithURL:[NSURL URLWithString:bank.bank_logo_URL]];
    return  retCell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Chọn ngân hàng";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BankInfo *bank = [_showingBankList objectAtIndex:indexPath.row];
    if (bank.bank_status == BANK_STATUS_ATM_DISABLE)
    {
        return;
    }
    if (self.buyInfo)
    {
        ATMInputViewController *inputView = [[ATMInputViewController alloc] init];
        [inputView setBankList:self.bankList];
        [inputView setBuyInfo:self.buyInfo];
        [inputView setBankInfo:bank];
        [self.navigationController pushViewController:inputView animated:YES];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.currentBank = bank;
        NSInteger index = [_showingBankList indexOfObject:self.currentBank];
        if (self.chooseBankDelegate && [self.chooseBankDelegate respondsToSelector:@selector(didSelectBank:atIndex:)])
        {
            [self.chooseBankDelegate didSelectBank:self.currentBank atIndex:index];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)setBankList:(NSArray *)bankList
{
    SAFE_RELEASE(_bankList)
    SAFE_RELEASE(_showingBankList)
    if (bankList)
    {
        _bankList = [[NSArray alloc] initWithArray:bankList];
        _showingBankList = [[NSMutableArray alloc]init];
        for (BankInfo *bank in _bankList)
        {
            if (bank.bank_status == BANK_STATUS_ATM_DISABLE || bank.bank_status == BANK_STATUS_ATM_AVAILABLE) {
                [_showingBankList addObject:bank];
            }
        }
    }
}

@end
