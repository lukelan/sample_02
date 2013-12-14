//
//  VisaInputViewController.m
//  123Phim
//
//  Created by phuonnm on 5/9/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
//define step thanh toan
//#define STEP_BLOCK_SEATE_GET_TRANSACTION_ID 0
//#define STEP_CREATE_ORDER_123PHIM 1
//#define STEP_CREATE_ORDER_123PAY  2
//#define STEP_REBLOCK_SEAT_THANHTOAN 3
#define TAG_ALERT_REBLOCK_SEAT_FAIL 500
#define TAG_ALERT_TRANSACTION_FAIL  501
#define TAG_ALERT_CONFIRM_WAITING   502

#define TAG_BEGIN_DATE 1001
#define TAG_EXPIRED_DATE 1002

#define SECTION_INFO    0
#define SECTION_BANK    1
#define SECTION_INPUT_BEGIN 1
#define SECTION_INPUT_LAST_SUB 2
#define SEGMENT_HEIGHT 40

#define MAX_YEAR_EXPIRE_FROM_CURRENT  10

#import "VisaInputViewController.h"
#import "CheckoutResultViewController.h"
#import "MainViewController.h"
#import "CinemaNoteCell.h"
#import "CellInfoThanhToan.h"
#import "UIDevice+IdentifierAddition.h"
#import "ConfirmInputViewController.h"
#import "SelectSeatViewController.h"
#import "URLParser.h"
#import "NSDictionary+FileHandler.h"

@interface VisaInputViewController ()

@end

@implementation VisaInputViewController

@synthesize layoutTable;
@synthesize cbRemember;
@synthesize webView = _webView;
@synthesize buyInfo = _buyInfo;
@synthesize bankInfo = _bankInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        viewName = THANHTOAN_VISA_VIEW_NAME;
        self.isSkipWarning = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [self setCustomBackButtonForNavigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:_buyInfo.chosenFilm.film_name];

    self.view.backgroundColor = [UIFont colorBackGroundApp];
    //add table
    [self initLayoutTable];
    [self.view addSubview:layoutTable];
    
    //add webView
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _webView.delegate = self;
    _webView.tag = 100;
    _webView.scalesPageToFit = YES;
    _webView.opaque = NO;
    _webView.userInteractionEnabled = YES;
    _webView.scrollView.scrollEnabled = YES;
    _webView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [_webView setHidden:YES];
    [self.view addSubview:_webView];
    
    self.trackedViewName = viewName;
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureTapOnView:)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
}

-(void)setCustomBackButtonForNavigationItem
{
    UIImage *imageLeft = [UIImage imageNamed:@"header-button-go-back.png"];
    UIButton *customButtonL = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0, 0, imageLeft.size.width, imageLeft.size.height);
    customButtonL.frame = frame;
    [customButtonL setBackgroundImage:imageLeft forState:UIControlStateNormal];
    [customButtonL addTarget:self action:@selector(processActionBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnleft = [[UIBarButtonItem alloc] initWithCustomView:customButtonL];
    self.navigationItem.leftBarButtonItem = btnleft;
}

-(void)processActionBack
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (_webView && _webView.hidden == NO)
    {
        [appDelegate popToViewController:[SelectSeatViewController class] animated:YES];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSInteger section = [self numberOfSectionsInTableView:self.layoutTable];
    if (section > SECTION_INPUT_BEGIN && IS_ENABLE_REMEMBER_FUNCTION)
    {
        [self.layoutTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection: SECTION_INPUT_BEGIN] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [UIAlertView dimissCurrentAlertView];
    [self checkAndSaveInfo];
    if (_webView)
    {
        if ([_webView isLoading]) {
            [_webView stopLoading];
        }
        [_webView setDelegate:nil];
    }
    [self hideLoadingView];
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    SAFE_RELEASE(_viewInfo)
    if (_webView && [_webView superview]) {
        [_webView removeFromSuperview];
    }
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidUnload
{
    //xu ly release resource khi nhan warning didReceiveMomoryWarning
    [super viewDidUnload];
}

#pragma mark tableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *paramNameList = [self.bankInfo getParamNameListForConfirmView:NO];
    return [paramNameList count] + 3; // info: 0, action : last, SAVE: LAST - 1
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_INFO) {
        return 2;
    }
    if ((section == [self numberOfSectionsInTableView:tableView] - SECTION_INPUT_LAST_SUB) && !IS_ENABLE_REMEMBER_FUNCTION) {
        return 0;//tam thoi khong layout remember
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
        lblTitleThanhToan.text = THANHTOAN_TITLE_INFO_VISA_CREDIT_CARD;
        CGSize sizeTextTitle = [lblTitleThanhToan.text sizeWithFont:lblTitleThanhToan.font];
        CGFloat widthText = self.view.frame.size.width - 2*(MARGIN_EDGE_TABLE_GROUP + 5);
        [lblTitleThanhToan setFrame:CGRectMake(xStar, yStar, widthText, sizeTextTitle.height)];
        [ret addSubview:lblTitleThanhToan];
        return ret;
    }
    
    UIView *segment = [self.bankInfo viewAtParamIndex:section - SECTION_INPUT_BEGIN forConfirmView:NO];
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
        if ([optionList isKindOfClass:[NSArray class]] && [optionList count] > 1)
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
        if ([optionList isKindOfClass:[NSArray class]] && [optionList count] > 1)
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell_thanhToan_%d_%d", indexPath.section, indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cellIdentifier = @"cinema_note_cell_id";
    }
    if (indexPath.section >= SECTION_INPUT_BEGIN && indexPath.section < [self numberOfSectionsInTableView:tableView] - SECTION_INPUT_LAST_SUB)
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
    if (indexPath.section >= SECTION_INPUT_BEGIN && indexPath.section < [self numberOfSectionsInTableView:tableView] - SECTION_INPUT_LAST_SUB)
    {
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        CustomTextView *input = [self.bankInfo inputViewAtParamIndex:(indexPath.section - SECTION_INPUT_BEGIN) forConfirmView:NO];
        [cell.contentView addSubview:input];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)setActiveInputView: (CustomTextView*) inputView
{
    if (inputView.tag == 3) {
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

-(void)layoutCheckBoxRemememberAccount:(UITableViewCell *)cell
{
    self.cbRemember = nil;
    cbRemember = [[UICheckBox alloc] initWithTitle:STRING_SAVE_ACCOUNT_VISA colorTitle:[UIColor grayColor]];
    [cbRemember setIsChecked:self.loadInfo != nil];
    [cell.contentView  addSubview:cbRemember];
    UIView *viewBG = [[UIView alloc] init];
    [viewBG setBackgroundColor:[UIColor clearColor]];
    [viewBG setFrame:cell.frame];
    [cell setBackgroundView:viewBG];
}

-(void)layoutButtonAction:(UITableViewCell *)cell
{
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"segment_selected_hl" ofType:@"png"];
    UIImage *imageLeft = [[UIImage alloc] initWithContentsOfFile:thePath];
    UIButton *btnThanhToan = [[UIButton alloc]init];
    CGRect frame = CGRectMake((cell.frame.size.width - imageLeft.size.width)/2, 0, imageLeft.size.width, imageLeft.size.height);
    btnThanhToan.frame = frame;
    [btnThanhToan setImage:imageLeft forState:UIControlStateNormal];
    [btnThanhToan addTarget:self action:@selector(processActionThanhToan) forControlEvents:UIControlEventTouchUpInside];
    [btnThanhToan setBackgroundColor:[UIColor clearColor]];
    
    UILabel *lblTitle = [[UILabel alloc] init];
    [lblTitle setFont:[UIFont getFontBoldSize14]];
    [lblTitle setText:@"Thanh toán"];
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
    [cell setBackgroundView:viewBG];
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

#pragma mark handle action Thanh Toan
-(void)processActionThanhToan
{
    NSMutableDictionary *payment_info = [self.bankInfo dictionaryInputForSending:YES forConfirmView:NO];
    if (!payment_info)
    {
        return;
    }
    [[APIManager sharedAPIManager] thanhToanRequestVerifyCardForBankInfo:self.bankInfo bankData:payment_info buyInfo:self.buyInfo context:self];
    
    [self showLoadingScreenWithType:LOADING_TYPE_FULLSCREEN];

    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:@"VisaInputViewController"
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_TICKET_CLICK_CHECKOUT
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
                [APIManager saveBankInfoWithDictionary:validInfo isATM:NO];
            }
            return;
        }
    }
    else
    {
        [APIManager removeBankInfoForATM:NO];
    }
}

#pragma mark -
#pragma mark -RKManageDelegate
#pragma mark -
- (void)processResultResponseDictionaryMapping:(DictionaryMapping *)dictionary requestId:(int)request_id
{
    if (request_id == ID_REQUEST_THANHTOAN_VERIFY_ATM) {
        [self getResultOfVerifyCardFromDictionaryResponse:dictionary.curDictionary];
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

#pragma mark Parse to get result response from server
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
    //    LOG_123PHIM(@"--result verify cardM = %@", response);
    //    "transaction":{
    //        "transaction_id":"27296",
    //        "invoice_no":"20130916104115587265",
    //        "ticket_code":"10113091636005",
    //        "total_revenue":100000
    //    },
    //    "verify":{
    //        "orderNo":"123P1309161877070",
    //        "responseCode":1,
    //        "useOTP":"0",
    //        "redirectURL":"https:\/\/migs.mastercard.com.au\/vpcpay?vpc_AccessCode=AF4509B8&vpc_Command=pay&vpc_OrderInfo=BHD20130916104115587265&vpc_Gateway=ssl&vpc_CardSecurityCode=284&vpc_CardExp=1606&vpc_CardNum=4283105416220017&vpc_ReturnURL=https%3A%2F%2F123pay.vn%2Fccstep2%2Fmobile.php&vpc_Version=1&vpc_Card=Visa&vpc_Locale=VN&vpc_Merchant=VNG&vpc_Amount=100000&vpc_SecureHash=DD2A487191422BD81CFB1CBF545F7B00&vpc_Currency=VND&vpc_MerchTxnRef=123P13091618770700",
    //        "redirectURL_method":"GET|POST",
    //        "input_code_native":1,
    //        "code_name":"OTP"// --> tên của code cần nhập
    //        "responseDescription":"X\u00e1c nh\u1eadn th\u00f4ng tin th\u1ebb h\u1ee3p l\u1ec7."
    //    }
    //    Api verifyCard khi trả về bổ sung thêm một trường dữ liệu là input_code_native --> sẽ cho biết client sẽ mở màn hình native để user nhập code hay không, code_name --> tên của code cần nhập, hiện tại thông dụng là OTP, và quy định nếu redirectURL có nội dung thì client sẽ phải mở URL lên, nếu không có thì sẽ bỏ qua, nếu có redirectURL thì kèm theo redirectURL_method có 2 giá trị là GET hoặc POST để client biết phương thức sẽ gọi URL (hiện tại credit bên client đang hardcoded là POST, ATM là GET, việc hardcoded này không ổn vì các ngân hàng khác nhau có thể có thêm những qui định xác nhận khác nhau)
    int status = [[dicObject objectForKey:@"status"] intValue];
    id resultObject = [dicObject objectForKey:@"result"];
    NSString *strDes = THANHTOAN_ERROR_ACCOUNT_INVALID;
    if(status == 0 || ![resultObject isKindOfClass:[NSDictionary class]])
    {
        [self showMessageDialogInfo:strDes withTag:-1];
        return;
    }
    NSDictionary *dicVerify = [resultObject objectForKey:@"verify"];
    id dataTemp = [dicVerify objectForKey:@"responseCode"];
    if ([[APIManager sharedAPIManager] isValidData:dataTemp])
    {
        if([dataTemp intValue] == 1)
        {
            //get infor transaction to verify
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSDictionary *dicTransaction = [resultObject objectForKey:@"transaction"];
            if ([[APIManager sharedAPIManager] isValidData:dicTransaction])
            {
                appDelegate.Invoice_No = [dicTransaction objectForKey:@"invoice_no"];
                appDelegate.ticket_code = [dicTransaction objectForKey:@"ticket_code"];
                appDelegate._TransactionID = [dicTransaction objectForKey:@"transaction_id"];
            }
            
            [self.buyInfo setOrderNo:[dicVerify objectForKey:@"orderNo"]];
            int value = 0;
            dataTemp = [dicVerify objectForKey:@"useOTP"];
            if ([[APIManager sharedAPIManager] isValidData:dataTemp] && [dataTemp isKindOfClass:[NSNumber class]])
            {
                value = [dataTemp intValue];
            }
            if (value == 1)
            {
                NSString *fullPath = [NSString stringWithFormat:@"%@/masterInfo.txt", BUNDLE_PATH];
                NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fullPath];
                BankInfo *bankInfo = [[BankInfo alloc] init];
                bankInfo.dicBankInfo = dict;
                NSDictionary *bankData = [self.bankInfo dictionaryInputForSending:YES forConfirmView:NO];
                ConfirmInputViewController *vcConfirm = [[ConfirmInputViewController alloc] init];
                [vcConfirm setIsMasterConfirm:YES];
                [vcConfirm setBankData:bankData];
                [vcConfirm setBuyInfo:self.buyInfo];
                [vcConfirm setBankInfo:bankInfo];
                [self.navigationController pushViewController:vcConfirm animated:YES];
            }
            else
            {
                dataTemp = [dicVerify objectForKey:@"redirectURL"];
                if ([[APIManager sharedAPIManager] isValidData:dataTemp] && [dataTemp isKindOfClass:[NSString class]])
                {
                    NSString *request_type = @"POST";
                    id test = [dicVerify objectForKey:@"redirectURL_method"];
                    if ([[APIManager sharedAPIManager] isValidData:test] && [test isKindOfClass:[NSString class]]) {
                        request_type = test;
                    }
                    [self executeRequestOpenWebView:dataTemp requestMethod:request_type];
                }
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

- (void) requestThanhToanInBackGround
{
    [self hideLoadingView];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[APIManager sharedAPIManager] thanhToanRequestGetInforTransactionDetail:appDelegate];
    [self showConfirmMessageDialogInfo:MESSAGE_CONFIRM_WAITING_RESULT withTag:TAG_ALERT_CONFIRM_WAITING];
}

#pragma mark push viewController result
-(void)pushCheckOutViewController
{
    CheckoutResultViewController *resultSucessViewController = [[CheckoutResultViewController alloc] init];
    [resultSucessViewController setBuyInfo:self.buyInfo];
    [self.navigationController pushViewController:resultSucessViewController animated:YES];
}

#pragma mark alertView delegate
-(void)showMessageDialogInfo:(NSString *)des withTag:(int)tag
{
    [self hideLoadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:des delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_REBLOCK_SEAT_FAIL)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate popToViewController:[SelectSeatViewController class] animated:YES];
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

#pragma mark UIWebViewDelegate
//- (void)createRequestWebViewThanhToan:(id)dataTemp
//{
//    NSString *redirectURL = dataTemp;
//    NSRange rangeIndex = [redirectURL rangeOfString:@"?"];
//    NSString *migsURL = [redirectURL substringToIndex:(rangeIndex.location)];
//    NSString *content = [redirectURL substringFromIndex:(rangeIndex.location + rangeIndex.length)];
//    //    LOG_123PHIM(@"migSURL = %@, content = %@", migsURL, content);
//    
//    NSMutableData *body = [NSMutableData data];
//    [body appendData: [content dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    // Create request
//    NSMutableURLRequest *request = [NSMutableURLRequest new];
//    [request setURL:[NSURL URLWithString: migsURL]];
//    
//    // Headers
//    [request setHTTPMethod:@"POST"];
//    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
//    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [request addValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//    // Append body
//    [request setHTTPBody:body];
//    //    LOG_123PHIM(@"-------------start load web-------------");
//    [_webView loadRequest:request];
//    [request release];
//}

-(NSMutableDictionary *) setCustomDataLocalInfo
{
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
    [infoDict setObject:[self.buyInfo toDictionary] forKey:DICT_KEY_BUY_INFO];
    [infoDict setObject:[self.bankInfo toDictionary] forKey:DICT_KEY_BANK_INFO];
    double timeCurrent = [NSDate timeIntervalSinceReferenceDate];
    [infoDict setValue:[NSNumber numberWithDouble:timeCurrent] forKey:DICT_KEY_DATE_BUYING];
    
    //luu gia tri xuong local de hien thi sau
    [APIManager setValueForKey:infoDict ForKey:KEY_STORE_INFO_THANH_TOAN];
    return infoDict;
}

- (void)executeRequestOpenWebView:(NSString *)redirectLinkCreateOrderM requestMethod:(NSString *)request_method
{
    [self setCustomDataLocalInfo];
    [_webView setHidden:NO];
    // Create request
    NSMutableURLRequest *theRequest = [NSMutableURLRequest new];
    
    
    if ([request_method isEqualToString:@"GET"])
    {
        [theRequest setURL:[NSURL URLWithString:redirectLinkCreateOrderM]];
        
    }
    else
    {
        NSRange rangeIndex = [redirectLinkCreateOrderM rangeOfString:@"?"];
        NSString *migsURL = [redirectLinkCreateOrderM substringToIndex:(rangeIndex.location)];
        NSString *content = [redirectLinkCreateOrderM substringFromIndex:(rangeIndex.location + rangeIndex.length)];
        [theRequest setURL:[NSURL URLWithString: migsURL]];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData: [content dataUsingEncoding:NSUTF8StringEncoding]];
        
        // Headers
        NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
        [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        // Append body
        [theRequest setHTTPBody:body];
    }
    
    [theRequest addValue: @"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPMethod:request_method];
    [_webView loadRequest:theRequest];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//	LOG_123PHIM(@"%@ - %@",request.HTTPMethod, request.URL);
	NSString *sPattern123P = [self.bankInfo getPattern123Pay];
    NSString *sPatternMIGS = [self.bankInfo getPattern123PayMIGS];
    NSString *sURL = [request.URL absoluteString];
    
    NSRange range123P = [sURL rangeOfString:sPattern123P];
    NSRange rangeMIGS = [sURL rangeOfString:sPatternMIGS];
	
    if(range123P.location != 0 && rangeMIGS.location != 0)
    {
        [self hideLoadingView];
        _webView.hidden = NO;
    }
    else {
        _webView.hidden = YES;
	}
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSURLRequest* request = [_webView request];
	NSString *sURL = [request.URL absoluteString];
    NSString *sPatternSuccess = [self.bankInfo getPattern123PaySucess];
	
//    LOG_123PHIM(@"----- link tra ve = %@, sPatternSuccess = %@", sURL, sPatternSuccess);
    
	if ([sURL rangeOfString:sPatternSuccess].location == 0)
    {
        URLParser *parser = [[URLParser alloc] initWithURLString:sURL];
        NSString *orderStatus = [parser valueForKey:@"orderStatus"];
        if (orderStatus && [orderStatus isEqualToString:@"7232"])
        {
            [self showMessageDialogInfo:ORDER_STATUS_ERROR_7232 withTag:-1];
        }
        else
        {
            [[APIManager sharedAPIManager] thanhToanRequestGetInforTransactionDetail:self];
            [self performSelector:@selector(requestThanhToanInBackGround) withObject:nil afterDelay:MAX_TIME_WAITING_VERIFY_OTP.intValue];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_WAITING_RESULT] ForKey:KEY_STORE_STATUS_THANH_TOAN];
            [APIManager setStringInApp:appDelegate.Invoice_No ForKey:KEY_STORE_TRANSACTION_ID_PENDING];
        }
		_webView.hidden = YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)setBankInfo:(BankInfo *)bankInfo
{
    SAFE_RELEASE(_bankInfo);
    if (bankInfo)
    {
        _bankInfo = bankInfo;
        //get bank info from file
        NSString *fileName = [NSString stringWithFormat:BANK_INFO_NAME_USING_BANK_CODE, _bankInfo.bank_code];
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", BANK_INFO_DIR, fileName];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fullPath];
        NSInteger version = 0;
        if (dict)
        {
            version = [[dict objectForKey:BANK_INFO_KEY_VERSION] integerValue];
            _bankInfo.dicBankInfo = dict;
        }
        if (version == 0 || version != _bankInfo.bank_version)
        {
            [[APIManager sharedAPIManager] getBankInfoWithCode:bankInfo.bank_code version:version responseTo:self];
            [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR];
        }
        else
        {
            _bankInfo.dicBankInfo = dict;
            [self initInputViews];
            [self.layoutTable reloadData];
        }
    }
}

-(void)segmentControl:(VNGSegmentedControl *)segment didChangeAtParamIndex:(NSUInteger)paramIndex
{
    [self.layoutTable reloadSections:[NSIndexSet indexSetWithIndex:(paramIndex + SECTION_INPUT_BEGIN)] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)initInputViews
{
    SAFE_RELEASE(_viewInfo)
    _viewInfo = [[NSMutableDictionary alloc] init];
    [self.bankInfo setViewInfo:_viewInfo];
    [self.bankInfo setDelegate:self];
   [self.bankInfo initInputViewsWithLoadInfo:self.loadInfo forConfirmView:NO];
}

@end
