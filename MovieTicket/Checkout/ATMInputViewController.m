//
//  SelectTypeATMViewController.m
//  123Phim
//
//  Created by Le Ngoc Duy on 5/6/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
//Optimize Gop chung khi gui create order 123phim server se tu goi create orderM ben pay va tra ve cho app

//default all bank except some bank require pass for card
#define SECTION_INFO    0
#define SECTION_BANK    1
#define SECTION_INPUT_BEGIN 2
#define SECTION_INPUT_LAST_SUB 2
#define SEGMENT_HEIGHT 40
#define TAG_ALERT_REBLOCK_SEAT_FAIL 500
#define TAG_ALERT_TRANSACTION_FAIL  501
#define TAG_ALERT_SELECT_BANKING    502
#define TAG_ALERT_CONFIRM_WAITING   503

#define NUMBER_YEAR_TO_SHOW  10


#import "ATMInputViewController.h"
#import "ConfirmInputViewController.h"
#import "MainViewController.h"
#import "CinemaNoteCell.h"
#import "CellInfoThanhToan.h"
#import "UIDevice+IdentifierAddition.h"
#import "VNGSegmentedControl.h"
#import "SelectSeatViewController.h"
#import "CheckoutResultViewController.h"
#import "SeatInfo.h"
#import "NSDictionary+FileHandler.h"
#import "SelectTypeThanhToanViewController.h"
#import "URLParser.h"

@interface ATMInputViewController ()

@end

@implementation ATMInputViewController
@synthesize layoutTable;
@synthesize cbRemember;
@synthesize redirectLinkCreateOrderM;
@synthesize buyInfo = _buyInfo;
@synthesize bankInfo = _bankInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _inputCardType = 804;//default type ATM
//        viewName = SELECT_ATM_TYPE_VIEW_NAME;
//        self.isSkipWarning = YES;
//        self.trackedViewName = viewName;
    }
    return self;
}

- (void)initLayoutTable
{
    //init layouttable    
    CGFloat tableHeight = [[UIScreen mainScreen] bounds].size.height - NAVIGATION_BAR_HEIGHT - TITLE_BAR_HEIGHT;
    layoutTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, tableHeight) style:UITableViewStyleGrouped];
    layoutTable.dataSource = self;
    layoutTable.delegate = self;
    layoutTable.backgroundColor = [UIColor clearColor];
    layoutTable.backgroundView = nil;
    layoutTable.userInteractionEnabled = YES;
    [layoutTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}

#pragma mark method view delegate
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [self setCustomBackButtonForNavigationItem];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:_buyInfo.chosenFilm.film_name];
    [self initLayoutTable];
    
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    [self.view addSubview:layoutTable];
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureTapOnView:)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
}

-(void)viewDidUnload
{
    //xu ly release resource khi nhan warning didReceiveMomoryWarning
    [super viewDidUnload];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestThanhToanInBackGround) object:nil];
    [UIAlertView dimissCurrentAlertView];
    [self checkAndSaveInfo];
    if (_webView)
    {
        if ([_webView isLoading])
        {
            [_webView stopLoading];
        }
        [_webView setDelegate:nil];
    }
    [self hideLoadingView];
    [super viewWillDisappear:YES];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSInteger section = [self numberOfSectionsInTableView:self.layoutTable];
    if (section > SECTION_INPUT_BEGIN && IS_ENABLE_REMEMBER_FUNCTION)
    {
        [self.layoutTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection: SECTION_INPUT_BEGIN] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(void)dealloc
{
    SAFE_RELEASE(_viewInfo)
    [_webView cleanForDealloc];
    _webView = nil;
}

#pragma mark tableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *paramNameList = [self.bankInfo getParamNameListForConfirmView:NO];
    return [paramNameList count] + 4; // info: 0, BANK: 1 action : last, SAVE: LAST - 1
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((section == [self numberOfSectionsInTableView:tableView] - SECTION_INPUT_LAST_SUB) && !IS_ENABLE_REMEMBER_FUNCTION)//cell remember
    {
        return 0;
    }
    if (section == SECTION_INFO) {
        return 2;
    }
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_INFO || section >= [self numberOfSectionsInTableView:tableView] - SECTION_INPUT_LAST_SUB)
    {
        return nil;
    }
    if (section == SECTION_BANK)
    {
        //Layout title tip
        CGFloat xStar = MARGIN_EDGE_TABLE_GROUP + 5;
        CGFloat yStar = 0;
        UIView* ret = [[UIView alloc] init];
        UILabel *lblTitleThanhToan = [[UILabel alloc] init];
        [lblTitleThanhToan setFont:[UIFont getFontBoldSize18]];
        [lblTitleThanhToan setBackgroundColor:[UIColor clearColor]];
        [lblTitleThanhToan setTextColor:[UIColor blackColor]];
        lblTitleThanhToan.text = THANHTOAN_TITLE_INFO_ATM_CARD;
        CGSize sizeTextTitle = [lblTitleThanhToan.text sizeWithFont:lblTitleThanhToan.font];
        CGFloat widthText = self.view.frame.size.width - 2*(MARGIN_EDGE_TABLE_GROUP + 5);
        [lblTitleThanhToan setFrame:CGRectMake(xStar, yStar, widthText, sizeTextTitle.height)];
        [ret addSubview:lblTitleThanhToan];
        return ret;
    }
    
    UIView *segment = [self.bankInfo viewAtParamIndex:(section - SECTION_INPUT_BEGIN) forConfirmView:NO];
    if (segment)
    {
        UIView *v = [[UIView alloc] init];
        if (!_viewInfo)
        {
            _viewInfo = [[NSMutableDictionary alloc] init];
        }
        [v addSubview:segment];
        return v;
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell_thanhToan_%d_%d", indexPath.section, indexPath.row];
    if (indexPath.section == 0) {
        if (indexPath.row == 0)
        {
            cellIdentifier = @"cinema_note_cell_id";
        }
    }
    else if (indexPath.section == [self numberOfSectionsInTableView:tableView] - SECTION_INPUT_LAST_SUB )
    {
        // save checkbox
        cellIdentifier = @"cell_thanhtoan_checkbox";
    }
    else if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1)
    {
        cellIdentifier = @"cell_thanhtoan_button";
    }
    else if (indexPath.section >= SECTION_INPUT_BEGIN && indexPath.section < [self numberOfSectionsInTableView:tableView] - SECTION_INPUT_LAST_SUB)
    {
        cellIdentifier = [NSString stringWithFormat:@"cell_thanhToan"];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        if (indexPath.section == SECTION_INFO)
        {
            if (indexPath.row == 0)
            {
                NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"CinemaNoteCell" owner:self options:nil];
                cell = [arr objectAtIndex:0];
                [(CinemaNoteCell *)cell layoutNoticeView:_buyInfo.chosenFilm];
              
            
            }
            else
            {
                cell =  [[CellInfoThanhToan alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [(CellInfoThanhToan *)cell layoutInfoCell:self.buyInfo];
            }
        }
        else if (indexPath.section == SECTION_BANK)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.font = [UIFont getFontNormalSize13];
        }
        else if (indexPath.section == [self numberOfSectionsInTableView:tableView] - SECTION_INPUT_LAST_SUB)
        {
            // save checkbox
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [self layoutCheckBoxRemememberAccount:cell];
        }
        else if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [self layoutButtonAction:cell];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            {
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            }
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    }
    
    
    // load info
    if (indexPath.section == SECTION_BANK)
    {
        cell.textLabel.text = _bankInfo.bank_name;
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    else if (indexPath.section >= SECTION_INPUT_BEGIN && indexPath.section < [self numberOfSectionsInTableView:tableView] - SECTION_INPUT_LAST_SUB)
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        CustomTextView *input = [self.bankInfo inputViewAtParamIndex:(indexPath.section - SECTION_INPUT_BEGIN) forConfirmView:NO];
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [cell.contentView addSubview: input];
    }
    return cell;
}

#pragma mark layout for cell Content
-(void)layoutButtonAction:(UITableViewCell *)cell
{
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"segment_selected_hl" ofType:@"png"];
    UIImage *imageLeft = [[UIImage alloc] initWithContentsOfFile:thePath];
    UIButton *btnThanhToan = [[UIButton alloc]init];
    CGRect frame = CGRectMake((cell.frame.size.width - imageLeft.size.width)/2, 0, imageLeft.size.width, imageLeft.size.height);
    btnThanhToan.frame = frame;
    [btnThanhToan setImage:imageLeft forState:UIControlStateNormal];
    [btnThanhToan addTarget:self action:@selector(btnThanhToan_Click:) forControlEvents:UIControlEventTouchUpInside];
    [btnThanhToan setBackgroundColor:[UIColor clearColor]];
    
    UILabel *lblTitle = [[UILabel alloc] init];
    [lblTitle setFont:[UIFont getFontBoldSize14]];
    [lblTitle setText:@"Lấy mã OTP"];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    CGSize size = [lblTitle.text sizeWithFont:lblTitle.font];
    [lblTitle setFrame:CGRectMake((imageLeft.size.width - size.width)/2, (imageLeft.size.height - size.height)/2, size.width, size.height)];
    [btnThanhToan addSubview:lblTitle];
    [cell.contentView  addSubview:btnThanhToan];
    //background for row
    UIView *viewBG = [[UIView alloc] init];
    [viewBG setBackgroundColor:[UIColor clearColor]];
    [viewBG setFrame:cell.frame];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        viewBG.frame = CGRectMake(0, 0, 320, 40);
        cell.backgroundColor = [UIColor clearColor];
    }
    [cell setBackgroundView:viewBG];
}


-(void)layoutCheckBoxRemememberAccount:(UITableViewCell *)cell
{
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.cbRemember = nil;
    cbRemember = [[UICheckBox alloc] initWithTitle:STRING_SAVE_ACCOUNT_ATM colorTitle:[UIColor grayColor]];
    [cbRemember setIsChecked:self.loadInfo != nil];
    [cell.contentView addSubview:cbRemember];
    UIView *viewBG = [[UIView alloc] init];
    [viewBG setBackgroundColor:[UIColor clearColor]];
    [viewBG setFrame:cell.frame];
    [cell setBackgroundView:viewBG];
}

-(void)setActiveInputView: (CustomTextView*) inputView
{
    if (inputView.tag == 2) {
        // send log to 123phim server
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:self.viewName
                                                              comeFrom:delegate.currentView
                                                          withActionID:ACTION_TICKET_PUT_CHECKOUT_INFO
                                                         currentFilmID:self.buyInfo.chosenSession.film_id
                                                       currentCinemaID:self.buyInfo.chosenSession.cinema_id
                                                             sessionId:self.buyInfo.chosenSession.session_id
                                                       returnCodeValue:0 context:nil];
    }
}

#pragma mark tableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == SECTION_BANK) {
        //process select type account to pay
        [self pushViewSelectBanking];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == SECTION_INFO) {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    if (section == SECTION_BANK)
    {
        return MARGIN_EDGE_TABLE_GROUP/2;
    }
    if ((section == [self numberOfSectionsInTableView:tableView] - SECTION_INPUT_LAST_SUB) && !IS_ENABLE_REMEMBER_FUNCTION)//cell remember
    {
        return 1.0f;
    }
    NSArray *paramNameList = [self.bankInfo getParamNameListForConfirmView:NO];
    if (section - SECTION_INPUT_BEGIN + 1 < [paramNameList count]) // check next input
    {
        id optionList = [paramNameList objectAtIndex:(section - SECTION_INPUT_BEGIN + 1)];
        if ([optionList isKindOfClass:[NSDictionary class]] || ([optionList isKindOfClass:[NSArray class]] && [optionList count] > 1))
        {
            // option list
            return MARGIN_EDGE_TABLE_GROUP;
        }
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_INFO) {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    if (section == SECTION_BANK)
    {
        CGFloat height = [@"ABC" sizeWithFont:[UIFont getFontBoldSize18]].height;
        return (height + MARGIN_EDGE_TABLE_GROUP);
    }
    if ((section == [self numberOfSectionsInTableView:tableView] - SECTION_INPUT_LAST_SUB) && !IS_ENABLE_REMEMBER_FUNCTION)//cell remember
    {
        return 1.0f;
    }
    float height = MARGIN_EDGE_TABLE_GROUP / 2;
    NSArray *paramNameList = [self.bankInfo getParamNameListForConfirmView:NO];
    if (section - SECTION_INPUT_BEGIN < [paramNameList count])
    {
        id optionList = [paramNameList objectAtIndex:(section - SECTION_INPUT_BEGIN)];
        if ([optionList isKindOfClass:[NSDictionary class]] || ([optionList isKindOfClass:[NSArray class]] && [optionList count] > 1))
        {
            height += SEGMENT_HEIGHT;
        }
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == [self numberOfSectionsInTableView:tableView] - SECTION_INPUT_LAST_SUB) && !IS_ENABLE_REMEMBER_FUNCTION)//cell remember
    {
        return 1.0f;
    }
    if (indexPath.section == SECTION_INFO) {
        if (indexPath.row == 1) {
            CGFloat height = [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]].height;
            height += [@"ABC" sizeWithFont:[UIFont getFontBoldSize12]].height;
            return (height + 2*MARGIN_EDGE_TABLE_GROUP);
        }
        return 60 + 2*MARGIN_CELL_SESSION;
    }
    return (2*MARGIN_EDGE_TABLE_GROUP + [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]].height);
}

#pragma mark handle touch event
-(void)handleGestureTapOnView:(UIGestureRecognizer*)gesture
{
    [_viewInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            CustomTextView *input = [obj objectForKey:@"INPUT_VIEW"];
            if ([input isKindOfClass:[CustomTextView class]])
            {
                [input resignFirstResponder];
            }
        }
    }];
}


-(void)getTransactionDetail
{
    if ([self.bankInfo getUsingWebType] == BANK_USING_WEB_TYPE_NONE)
    {
        [self verifyCard];
    }
    else
    {
        [self getTransactionDetailIncludeVerifyingCard:NO];
    }
}

-(void)verifyCard
{
    if ([self.bankInfo getUsingWebType] == BANK_USING_WEB_TYPE_NONE)
    {
        [self getTransactionDetailIncludeVerifyingCard:YES];
    }
    else
    {
        // call verify to SML server (parner)
        [self processInputInfoUsingWebView];
    }
}

#pragma mark handle action Thanh Toan
-(void)btnThanhToan_Click:(id)sender
{
    [self getTransactionDetail];
}


-(void)getTransactionDetailIncludeVerifyingCard:(BOOL)verifyCard
{
    NSMutableDictionary *payment_info = [self.bankInfo dictionaryInputForSending:YES forConfirmView:NO];
    if (!payment_info)
    {
        return;
    }
    if (!verifyCard)
    {
        payment_info = nil;
    }
    [[APIManager sharedAPIManager] thanhToanRequestVerifyCardForBankInfo:self.bankInfo bankData:payment_info buyInfo:self.buyInfo context:self];
    [self showLoadingScreenWithType:LOADING_TYPE_FULLSCREEN];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    // send log to 123phim server
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:@""
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_TICKET_GET_OTP
                                                     currentFilmID:self.buyInfo.chosenSession.film_id
                                                   currentCinemaID:self.buyInfo.chosenSession.cinema_id
                                                         sessionId:self.buyInfo.chosenSession.session_id
                                                   returnCodeValue:0
                                                           context:nil];
}

-(void)checkAndSaveInfo
{
    if (cbRemember.isChecked && [self.bankInfo getUsingWebType] != BANK_USING_WEB_TYPE_YES)
    {
        NSMutableDictionary *validInfo = [self.bankInfo dictionaryInputForSending:NO forConfirmView:NO];
        if (validInfo)
        {
            NSError *error = nil;
            if (!error)
            {
                [validInfo setObject:self.bankInfo.bank_code forKey:BANK_INFO_KEY_CODE];
                [APIManager saveBankInfoWithDictionary:validInfo isATM:YES];
            }
            return;
        }
    }
    else
    {
        [APIManager removeBankInfoForATM:YES];
    }
}

#pragma mark get InforCitySelect
-(void)didSelectBank:(BankInfo *)bankInfo atIndex:(NSInteger)index
{
    if (bankInfo)
    {
        NSString *loadBankCode = [self.loadInfo objectForKey:BANK_INFO_KEY_CODE];
        if (![loadBankCode isKindOfClass:[NSString class]] || ![loadBankCode isEqualToString:bankInfo.bank_code])
        {
            [self setLoadInfo:nil];
        }
        self.bankInfo = bankInfo;
    }
}

#pragma mark -
#pragma mark -RKManageDelegate
#pragma mark -
- (void)processResultResponseDictionaryMapping:(DictionaryMapping *)dictionary requestId:(int)request_id
{
    if (request_id == ID_REQUEST_THANHTOAN_VERIFY_ATM)
    {
        [self getResultOfVerifyCardFromDictionaryResponse:dictionary.curDictionary];
        [self hideLoadingView];
    }
    else if(request_id == ID_REQUEST_THANHTOAN_INFOR_TRANSACTION_DETAIL)
    {
        [self getResultTransactionDetailResponse:dictionary.curDictionary];
    }
    else if (request_id == ID_REQUEST_THANHTOAN_GET_BANK_INFO)
    {
        [self getResultBankInfoLayoutResponse:dictionary.curDictionary];
    }
}

#pragma mark parse to get result
- (void)getResultBankInfoLayoutResponse:(NSDictionary *)dict
{
    if (dict)
    {
        self.bankInfo.dicBankInfo = dict;
        [self performSelectorInBackground:@selector(saveBankInfo) withObject:nil];
    }
    [self initInputViews];
    [self.layoutTable reloadData];
    [self hideLoadingView];
}

-(void)saveBankInfo
{
    if (self.bankInfo && self.bankInfo.dicBankInfo)
    {
        NSString *fileName = [NSString stringWithFormat:BANK_INFO_NAME_USING_BANK_CODE, self.bankInfo.bank_code];
        [self.bankInfo.dicBankInfo saveTofile:fileName path:BANK_INFO_DIR];
    }
}

- (void)getResultOfVerifyCardFromDictionaryResponse:(NSDictionary *)dicObject
{
    int status = [[dicObject objectForKey:@"status"] intValue];
    id resultObject = [dicObject objectForKey:@"result"];
    NSString *strDes = THANHTOAN_ERROR_ACCOUNT_INVALID;
    if(status == 0 || ![resultObject isKindOfClass:[NSDictionary class]])
    {
        [self showMessageDialog:strDes];
        return;
    }
    //    "result":{
    //        "transaction":{
    //            "transaction_id":"15809",
    //            "invoice_no":"20130813144314988626",
    //            "ticket_code":"10113081370074",
    //            "total_revenue":70000},
    //        "verify":{
    //            "result_code": (-1, 1) trong đó 1 là xác nhận thành công, -1 là không thành công
    //            "result_description": "nội dung thông báo kèm theo nếu cần thiết"
    //            "orderNo":null,
    //            "redirectURL":null,
    //            "totalAmount":null,
    //        }
    //    }
    NSDictionary *dicVerify = [resultObject objectForKey:@"verify"];
    id dataTemp = [dicVerify objectForKey:@"responseCode"];
    if ([[APIManager sharedAPIManager] isValidData:dataTemp])
    {
        if([dataTemp intValue] == 1)
        {
            //get infor transaction to verify
            NSDictionary *dicTransaction = [resultObject objectForKey:@"transaction"];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if ([[APIManager sharedAPIManager] isValidData:dicTransaction])
            {
                appDelegate.Invoice_No = [dicTransaction objectForKey:@"invoice_no"];
                appDelegate.ticket_code = [dicTransaction objectForKey:@"ticket_code"];
                appDelegate._TransactionID = [dicTransaction objectForKey:@"transaction_id"];
            }
            [self.buyInfo setOrderNo:[dicVerify objectForKey:@"orderNo"]];
            [self hideLoadingView];
            
            // checking to verify or pushing confirm view
            if (self.bankInfo.getUsingWebType == BANK_USING_WEB_TYPE_NONE)
            {
                [self pushConfirmInputViewController];
            }
            else
            {
                self.redirectLinkCreateOrderM = [dicVerify objectForKey:@"redirectURL"];
                [self verifyCard];
            }
            return;
        }
        else
        {
            id dataDescription = [dicVerify objectForKey:@"responseDescription"];
            if ([dataDescription isKindOfClass:[NSString class]]) {
                strDes = dataDescription;
            }
            if ([dataTemp intValue] == -2) {
                [self showMessageDialogInfo:strDes withTag:TAG_ALERT_REBLOCK_SEAT_FAIL];
            }
            else
            {
                [self showMessageDialogInfo:strDes withTag:TAG_ALERT_TRANSACTION_FAIL];
            }
        }
    }
}

- (void)getResultTransactionDetailResponse:(NSDictionary *)dicObject
{
    //    LOG_123PHIM(@"-------------------------------------\n");
    //    LOG_123PHIM(@"gia tri detail = %@", response);
    int status = [[dicObject objectForKey:@"status"] intValue];
    if(status == 0)
    {
        return;
    }
    id getData = [dicObject objectForKey:@"result"];
    if([[APIManager sharedAPIManager] isValidData:getData] && [getData isKindOfClass:[NSDictionary class]])
    {
        //    {"transaction_id":"2049",
        //        "customer_id":"43",
        //        "invoice_no":"20130606103708157218",
        //        "responseCode": (0, 1, -1),  trong đó 0 là tiếp tục chờ, 1 là thành công (có ticket_code), -1 là thất bại
        //        "ticket_code":"10213060646870"}
        int thanhtoan_status = [[getData objectForKey:@"responseCode"] integerValue];
        if (thanhtoan_status == 0)//that bai
        {
            //request in background tiep tuc request
            return;
        }
        else if (thanhtoan_status == 1)//thanh cong
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            id temp = [getData objectForKey:@"ticket_code"];
            if (temp && [temp isKindOfClass:[NSString class]]) {
                if ([(NSString *)temp length]) {
                    appDelegate.ticket_code = temp;
                }
            }
            appDelegate.Invoice_No = [getData objectForKey:@"invoice_no"];
            
            //cap nhat status sang trai thai don hang thanh cong
            [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_RESULT_SUCCESS] ForKey:KEY_STORE_STATUS_THANH_TOAN];
            //Xoa gia tri pending cua transaction
            [APIManager setStringInApp:@"" ForKey:KEY_STORE_TRANSACTION_ID_PENDING];
            [self pushCheckOutViewController];
            [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_OUT_RANGE] ForKey:KEY_STORE_STATUS_THANH_TOAN];
        }
        else
        {
            //cap nhat status sang trai thai don hang failed
            [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_OUT_RANGE] ForKey:KEY_STORE_STATUS_THANH_TOAN];
            //Xoa gia tri pending cua transaction
            [APIManager setStringInApp:@"" ForKey:KEY_STORE_TRANSACTION_ID_PENDING];
            NSString *strDes = MESSAGE_STATUS_RESULT_FAILED;
            id dataTemp = [getData objectForKey:@"responseDescription"];
            if ([dataTemp isKindOfClass:[NSString class]]) {
                strDes = dataTemp;
            }
            [self showMessageDialogInfo:strDes withTag:-1];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

#pragma mark ultility action after get result
-(void) pushConfirmInputViewController
{
    //Chuyen sang view verify ATM and OTP
    ConfirmInputViewController *verifyView = [[ConfirmInputViewController alloc] init];
    [verifyView setBuyInfo:self.buyInfo];
    NSMutableDictionary *data = [self.bankInfo dictionaryInputForSending:NO forConfirmView:NO];
    [verifyView setBankData:data];
    [verifyView setBankInfo:self.bankInfo];
    [self.navigationController pushViewController:verifyView animated:YES];
}

-(void) pushCheckOutViewController
{
    CheckoutResultViewController *resultSucessViewController = [[CheckoutResultViewController alloc] init];
    [resultSucessViewController setBuyInfo:self.buyInfo];
    [self.navigationController pushViewController:resultSucessViewController animated:YES];
}

-(void) pushViewSelectBanking
{
    //process select type account to pay
    SelectBankViewController *selectBankView = [[SelectBankViewController alloc] init];
    [selectBankView setBankList:self.bankList];
    [selectBankView setCurrentBank:self.bankInfo];
    [selectBankView setFullScreen];
    [selectBankView setChooseBankDelegate:self];
    [self.navigationController pushViewController:selectBankView animated:YES];
}
#pragma mark alertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_REBLOCK_SEAT_FAIL)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate popToViewController:[SelectSeatViewController class] animated:YES];
    }
    else if (alertView.tag == TAG_ALERT_SELECT_BANKING)
    {
        //process select type account to pay
        [self pushViewSelectBanking];
    }
    else if(alertView.tag == TAG_ALERT_TRANSACTION_FAIL)
    {
    }
    else if (alertView.tag == TAG_ALERT_CONFIRM_WAITING)
    {
        if (buttonIndex == 0) {
            return;
        } else {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate popToViewController:[MainViewController class] animated:YES];
        }
    }
}

-(void)showMessageDialogInfo:(NSString *)des withTag:(int)tag
{
    [self hideLoadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:des delegate:nil cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil];
    alert.tag = tag;
    [alert setDelegate:self];
    [alert show];
}

-(void)showConfirmMessageDialogInfo:(NSString *)des withTag:(int)tag
{
    [self hideLoadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:des delegate:self cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:ALERT_BUTTON_NO,nil];
    alert.tag = tag;
    //    [alert setDelegate:self];
    [alert show];
}

-(void)showMessageDialog:(NSString *)des
{
    [self hideLoadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:des delegate:nil cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil];
    [alert show];
}

#pragma mark handle payment using web
-(void)initWebView
{
    if (_webView) {
        return;
    }
    //add webView
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _webView.delegate = self;
    _webView.tag = 100;
    [_webView setScalesPageToFit:YES];
    _webView.opaque = NO;
    _webView.userInteractionEnabled = YES;
    _webView.scrollView.scrollEnabled = YES;
    _webView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    [_webView setHidden:YES];
    [self.view addSubview:_webView];
}

-(NSMutableDictionary *) setCustomDataLocalBuyInfo
{
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
    [infoDict setObject:[self.buyInfo toDictionary] forKey:DICT_KEY_BUY_INFO];
    double timeCurrent = [NSDate timeIntervalSinceReferenceDate];
    [infoDict setValue:[NSNumber numberWithDouble:timeCurrent] forKey:DICT_KEY_DATE_BUYING];
    
    //luu gia tri xuong local de hien thi sau
    [APIManager setValueForKey:infoDict ForKey:KEY_STORE_INFO_THANH_TOAN];
    return infoDict;
}

- (void)processInputInfoUsingWebView
{
    [self setCustomDataLocalBuyInfo];
    [self initWebView];
    [self hideLoadingView];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_webView];
    if ([self.bankInfo getUsingWebType] == BANK_USING_WEB_TYPE_YES)
    {
        [_webView setHidden:NO];
    }
    else
    {
        [_webView setHidden:YES];
    }
    NSURL *url = [NSURL URLWithString:redirectLinkCreateOrderM];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest addValue: @"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPMethod:@"GET"];
    [_webView loadRequest:theRequest];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideLoadingView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSURLRequest* request = [_webView request];
	NSString *sURL = [request.URL absoluteString];
    NSString *sPatternSuccess = [self.bankInfo getPattern123PaySucess];
	if ([sURL rangeOfString:sPatternSuccess].location == 0)
    {
        if ([webView isLoading])
        {
            [webView stopLoading];
        }
        [layoutTable reloadData];
		_webView.hidden = YES;
        //xu ly request queryOrderM de check trang thai thanh toan tai 123pay truoc khi update status, confirm ghe
        [[APIManager sharedAPIManager] thanhToanRequestGetInforTransactionDetail:self];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [APIManager setStringInApp:delegate.Invoice_No ForKey:KEY_STORE_TRANSACTION_ID_PENDING];
        [self performSelector:@selector(requestThanhToanInBackGround) withObject:nil afterDelay:MAX_TIME_WAITING_VERIFY_OTP.intValue];
    }
    else
    {
        //Xu ly lay status cua ngan hang xem la Auto(verifyCard, verifyOTP tu app) hay semiAuto (chi cho verify tu appp, verify OTP phai dung web)
        //BankInfo se chua 1 status de biet trang thai nay
        if ([self.bankInfo getUsingWebType] == BANK_USING_WEB_TYPE_YES)//neu la VCB, DAB nhung ngan hang truc tiep qua smartlink thi khong lam gi ca default webView tu lam
        {
            return;
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSURLRequest* request = [_webView request];
        NSString *sURL = [request.URL absoluteString];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        //NSLog(@"%@",sURL);
        if ([sURL rangeOfString:[self.bankInfo getSMLPatternVerifyOTPSuccess]].location == 0)
        {
            [self showMessageDialog:@"Verify OTP Success"];
            //goi lenh truy van query order de lay status cua ve
        }
        
        if([sURL isEqual:[self.bankInfo getSMLPatternVerifyCardAgain]])
        {            
            NSString *html = [webView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
            NSRange range = [html rangeOfString:@"<p class=\"error\">"];
            if (range.location != NSNotFound)
            {
                NSUInteger firstIndex = range.location;
                NSString *param = [html substringFromIndex:firstIndex];
                //NSLog(@"%@",param);
                NSRange endrange = [param rangeOfString:@"</p>"];
                if (endrange.location != NSNotFound)
                {
                    NSString *result = [param substringToIndex:endrange.location];
                    result = [result stringByReplacingOccurrencesOfString:@"<p class=\"error\">" withString:@""];
                    result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:result  delegate:self cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil];
                    [alert show];
                }
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:ORDER_STATUS_ERROR_7200 delegate:self cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil];
                [alert show];
            }
        }
        if ([sURL rangeOfString:[self.bankInfo getSMLPattenVerifyCardSuccess]].location == 0){
            URLParser *parser = [[URLParser alloc] initWithURLString:sURL];
            
            appDelegate._SmartlinkOrderId = [parser valueForKey:@"orderid"];
            NSMutableDictionary *payment_info = [self.bankInfo dictionaryInputForSending:YES forConfirmView:NO];
            if (!payment_info)
            {
                return;
  
            }
            
            NSString *strDataBank = [payment_info convertDictionToStringParameter];
            NSString *content = [NSString stringWithFormat: @"%@orderid=%@&strMerchantAmount=%d&strMerchantName=%@&strMerchantOrderInfo=%@", strDataBank, appDelegate._SmartlinkOrderId, appDelegate._Amount, @"CTY CP TAP DOAN VINA", @"Mua Ve Tai 123Phim"];
            NSMutableData *body = [NSMutableData data];
            [body appendData: [content dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSURL *urlVerify = [NSURL URLWithString:[self.bankInfo getSMLVerifyCardURL]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlVerify];
            [request setHTTPMethod:@"POST"];
            NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request addValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:body];
            [_webView loadRequest:request];
        }
        if ([sURL rangeOfString:[self.bankInfo getSMLPattenError]].location == 0){
            [_webView stopLoading];
            [self hideLoadingView];
        }
        if ([sURL rangeOfString:[self.bankInfo getSMLPatternVerifyOTP]].location == 0)
        {
            //[[FileLogger sharedInstance] log:@"verifyCardM Success forward to otp:%@", sURL];            
            NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray *cookies = [sharedHTTPCookieStorage cookiesForURL:[request URL]];
            NSEnumerator *enumerator = [cookies objectEnumerator];
            NSHTTPCookie *cookie;
            
            while (cookie = [enumerator nextObject]) {
                if([[cookie name] isEqual: @"JSESSIONID"]){
                    appDelegate._SmartlinkSessionId = [cookie value];
                    break;
                }
            }
            
            //TODO: neu khac cac ngan hang duoc phep tu dong OTP thi hien thi webview
            /*
             Cac Ngan hang truc tiep
             EIB, BIDV, CC
             
             Cac Ngan Hang manual
             DAB, VCB
             
             Cac Ngan Hang duoc phep automatic OTP
             
             MSB - 9704260004427829 - MaritimeBank
             ACB - 9704162002320719 - SinhTM
             TCB - 9704078817338375 - HongPTA             
             */
            if([self.bankInfo getUsingWebType] > BANK_USING_WEB_TYPE_OVERLAY_LAYOUT)
            {
                [self hideLoadingView];
                [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_webView];
                _webView.hidden = NO;
            }
            else
            {
                [self hideLoadingView];
                [self pushConfirmInputViewController];
            }
            
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideLoadingView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) requestThanhToanInBackGround
{
    [self hideLoadingView];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[APIManager sharedAPIManager] thanhToanRequestGetInforTransactionDetail:appDelegate];
    [self showConfirmMessageDialogInfo:MESSAGE_CONFIRM_WAITING_RESULT withTag:TAG_ALERT_CONFIRM_WAITING];
}

-(void)setBankInfo:(BankInfo *)bankInfo
{
    SAFE_RELEASE(_bankInfo);
    if (bankInfo)
    {
        _bankInfo = bankInfo;
    }
    //get bank info from file
    NSString *fileName = [NSString stringWithFormat:BANK_INFO_NAME_USING_BANK_CODE, bankInfo.bank_code];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", BANK_INFO_DIR, fileName];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fullPath];
    NSInteger version = 0;
    if (dict)
    {
        version = [[dict objectForKey:BANK_INFO_KEY_VERSION] integerValue];
    }
    if (version == 0 || version != bankInfo.bank_version)
    {
        [[APIManager sharedAPIManager] getBankInfoWithCode:bankInfo.bank_code version:version responseTo:self];
        [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR];
        return;
    }
    else
    {
        _bankInfo.dicBankInfo = dict;
        [self initInputViews];
        [self.layoutTable reloadData];
    }
}

-(void)segmentControl:(VNGSegmentedControl *)segment didChangeAtParamIndex:(NSUInteger)paramIndex
{
    [self.layoutTable reloadSections:[NSIndexSet indexSetWithIndex:(paramIndex + SECTION_INPUT_BEGIN)] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)initInputViews
{
   SAFE_RELEASE(_viewInfo)
    if ([self.bankInfo getUsingWebType] == BANK_USING_WEB_TYPE_YES)
    {
        [self getTransactionDetail];
    }
    else
    {
        _viewInfo = [[NSMutableDictionary alloc] init];
        [self.bankInfo setViewInfo:_viewInfo];
        [self.bankInfo setDelegate:self];
        [self.bankInfo initInputViewsWithLoadInfo:self.loadInfo forConfirmView:NO];
    }
}

-(void)popToViewController
{
    AppDelegate *app = ((AppDelegate *)[[UIApplication sharedApplication]delegate]);
    [app popToViewController:[SelectTypeThanhToanViewController class] animated:YES];
}
@end
