//
//  ConfirmInputViewController
//  123Phim
//
//  Created by Le Ngoc Duy on 5/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#define SECTION_INFO    0
#define SECTION_INPUT_BEGIN 1
#define SECTION_INPUT_LAST_SUB 1

#define SEGMENT_HEIGHT 40

#define TAG_ALERT_WRONG_OPT_CODE 499
#define TAG_ALERT_REBLOCK_SEAT_FAIL 500
#define TAG_ALERT_ABORT_TRANSACTION  501
#define TAG_ALERT_CONFIRM_WAITING   502

#import "ConfirmInputViewController.h"
#import "MainViewController.h"
#import "CinemaNoteCell.h"
#import "CellInfoThanhToan.h"
#import "CheckoutResultViewController.h"
#import "SelectSeatViewController.h"
#import "SeatInfo.h"


@interface ConfirmInputViewController ()

@end

@implementation ConfirmInputViewController
@synthesize layoutTable;
@synthesize buyInfo = _buyInfo;
@synthesize webView = _webView;
@synthesize mutableData;
@synthesize bankInfo = _bankInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        viewName = VERIFY_ATM_BY_OTP_VIEW_NAME;
//        redirectLinkCreditCard = @"";
        self.isSkipWarning = YES;
    }
    return self;
}

- (void)postLocalNotification
{
    //post local notification
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//    if (localNotif == nil)
//    {
//        return;
//    }
    localNotif.fireDate = [NSDate date];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
	
	// Notification details
    localNotif.alertBody = [NSString stringWithFormat:MESSAGE_PUSH_LOCAL_NOTIFICATION_INPUT_OTP,self.buyInfo.chosenFilm.film_name];
	// Set the action button
    localNotif.hasAction = NO;
    //    localNotif.alertAction = @"View";
	
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
	
	// Specify custom data for the notification
    localNotif.userInfo = [self setCustomDataToPostLocalNotification];
	
	// Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    if (self.canCancelTransaction)
    {
        UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *imageRight = [UIImage imageNamed:@"header-button-cancel.png"];
        CGRect frame = CGRectMake(0, 0, imageRight.size.width, imageRight.size.height);
        btnRight.frame = frame;
        [btnRight setImage:imageRight forState:UIControlStateNormal];
        [btnRight addTarget:self action:@selector(showConfirmCancelTransaction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *btnBarRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
        [self.navigationItem setRightBarButtonItem:btnBarRight];
    }

    [delegate setTitleLabelForNavigationController:self withTitle:self.buyInfo.chosenFilm.film_name];
   
    [self initLayoutTable];   
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    [self.view addSubview:layoutTable];
    
    self.trackedViewName = viewName;
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureTapOnView:)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
    //ban notification waiting input otp for client
//    [self postLocalNotification];

    // cap nhat status dang cho input OTP
//    [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_WAITING_INPUT_OTP] ForKey:KEY_STORE_STATUS_THANH_TOAN];
//    [delegate performSelector:@selector(checkAndSendCleanWarning) withObject:nil afterDelay:[MAX_TIME_WAITING_INPUT_OTP intValue]];

}

-(NSMutableDictionary *) setCustomDataToPostLocalNotification
{
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
    [infoDict setObject:[self.buyInfo toDictionary] forKey:DICT_KEY_BUY_INFO];
    [infoDict setObject:[APIManager encryptDictionaryWithDictionary:self.bankData] forKey:DICT_KEY_BANK_DATA];
    [infoDict setObject:[self.bankInfo toDictionary] forKey:DICT_KEY_BANK_INFO];
    double timeCurrent = [NSDate timeIntervalSinceReferenceDate];
    [infoDict setValue:[NSNumber numberWithDouble:timeCurrent] forKey:DICT_KEY_DATE_BUYING];
    
    //luu gia tri xuong local de hien thi sau
    [APIManager setValueForKey:infoDict ForKey:KEY_STORE_INFO_THANH_TOAN];
    return infoDict;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_webView cleanForDealloc];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    SAFE_RELEASE(_viewInfo)
}

-(void)initWebView
{
    //add webView
    if (!_webView)
    {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _webView.delegate = self;
        _webView.tag = 100;
        _webView.opaque = NO;
        _webView.userInteractionEnabled = NO;
        _webView.scrollView.scrollEnabled = NO;
        _webView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [_webView setScalesPageToFit:YES];
    }

    if (![_webView superview]) {
        [_webView setHidden:YES];
        [self.view addSubview:_webView];
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
    NSArray *paramNameList = [self.bankInfo getParamNameListForConfirmView:YES];
    return [paramNameList count] + 2; // info: 0, button: last
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    if (section == SECTION_INPUT_BEGIN)
    {
        //Layout title tip
        CGFloat xStar = MARGIN_EDGE_TABLE_GROUP + 5;
        CGFloat yStar = 0;
        UIView* ret = [[UIView alloc] init];
        UILabel *lblTitleThanhToan = [[UILabel alloc] init];
        [lblTitleThanhToan setFont:[UIFont getFontBoldSize18]];
        [lblTitleThanhToan setBackgroundColor:[UIColor clearColor]];
        [lblTitleThanhToan setTextColor:[UIColor blackColor]];
        if (self.isMasterConfirm)
        {
            lblTitleThanhToan.text = THANHTOAN_TITLE_INFO_VISA_CREDIT_CARD;
        }
        else
        {
            lblTitleThanhToan.text = THANHTOAN_TITLE_INFO_ATM_CARD;
        }
        CGSize sizeTextTitle = [lblTitleThanhToan.text sizeWithFont:lblTitleThanhToan.font];
        CGFloat widthText = self.view.frame.size.width - 2*(MARGIN_EDGE_TABLE_GROUP + 5);
        [lblTitleThanhToan setFrame:CGRectMake(xStar, yStar, widthText, sizeTextTitle.height)];
        [ret addSubview:lblTitleThanhToan];
        return ret;
    }
    UIView *view = [self.bankInfo viewAtParamIndex:(section - SECTION_INPUT_BEGIN) forConfirmView:YES];
    if (view)
    {
        UIView *v = [[UIView alloc] init];
        if (!_viewInfo)
        {
            _viewInfo = [[NSMutableDictionary alloc] init];
        }
        [v addSubview:view];
        return v;
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell_thanhToan_%d_%d", indexPath.section, indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cellIdentifier = @"cinema_note_cell_id";
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
        else if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1)
        {
            // button
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
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        CustomTextView *input = [self.bankInfo inputViewAtParamIndex:(indexPath.section - SECTION_INPUT_BEGIN) forConfirmView:YES];
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
//            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
//            input.frame = CGRectMake(input.frame.origin.x, input.frame.origin.y, input.frame.size.width, cell.contentView.frame.size.height);
        }
        [cell.contentView addSubview: input];
    }
    return cell;
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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        cell.backgroundColor = [UIColor clearColor];
    }

    [cell.contentView  addSubview:btnThanhToan];
    
    //background for row
    [self setBackGroundNilForCell:cell];
}

-(void)setBackGroundNilForCell:(UITableViewCell *)cell
{
    //background for row
    UIView *viewBG = [[UIView alloc] init];
    [viewBG setBackgroundColor:[UIColor clearColor]];
    [viewBG setFrame:cell.frame];
    [cell setBackgroundView:viewBG];
}

#pragma makr tableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == SECTION_INFO) {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    if (section == SECTION_INPUT_BEGIN)
    {
        return MARGIN_EDGE_TABLE_GROUP/2;
    }
    NSArray *paramNameList = [self.bankInfo getParamNameListForConfirmView:YES];
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
    if (section == SECTION_INPUT_BEGIN)
    {
        CGFloat height = [@"ABC" sizeWithFont:[UIFont getFontBoldSize18]].height;
        return (height + MARGIN_EDGE_TABLE_GROUP);
    }
    
    float height = MARGIN_EDGE_TABLE_GROUP / 2;
    NSArray *paramNameList = [self.bankInfo getParamNameListForConfirmView:YES];
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

#pragma mark handle action Thanh Toan
-(void)processActionThanhToan
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSMutableDictionary *payment_info = [self.bankInfo dictionaryInputForSending:YES forConfirmView:YES];
    if (!payment_info)
    {
        return;
    }
    [self showLoadingScreenWithType:LOADING_TYPE_FULLSCREEN];
    
    if ([self.bankInfo getUsingWebType] == BANK_USING_WEB_TYPE_OVERLAY_LAYOUT)
    {
        [self initWebView];
        NSString *stringParameter = [payment_info convertDictionToStringParameter];
        NSString *content = [NSString stringWithFormat: @"URL_LOGO=images/banner/01_Banner_VNG-Payment.jpg&%@&otpstatus=1&strMerchantAmount=%d&strMerchantName=%@&strMerchantOrderInfo=%@", stringParameter, delegate._Amount, @"CTY CP TAP DOAN VINA", @"Mua Ve Tai 123Phim"];
        NSMutableData *body = [NSMutableData data];
        [body appendData: [content dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURL *urlVerify = [NSURL URLWithString:[self.bankInfo getSMLPatternVerifyOTP]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlVerify];
        [request setHTTPMethod:@"POST"];
        NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request addValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:body];
        
        
        NSString *host = @"paymentcert.smartlink.com.vn";
        NSString *path = @"/";
        NSHTTPCookie *jsessionid = [NSHTTPCookie cookieWithProperties:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     host, NSHTTPCookieDomain,
                                     path, NSHTTPCookiePath,
                                     @"JSESSIONID",  NSHTTPCookieName,
                                     delegate._SmartlinkSessionId, NSHTTPCookieValue,
                                     nil]];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:jsessionid];
        
        [_webView loadRequest:request];
    }
    else if ([self.bankInfo getUsingWebType] == BANK_USING_WEB_TYPE_NONE)
    {
        [[APIManager sharedAPIManager] thanhToanRequestVerifyOTPForBankInfo:self.bankInfo bankData:payment_info buyInfo:self.buyInfo context:self];
    }
    // send log
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:NSStringFromClass([ConfirmInputViewController class])
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_TICKET_CLICK_CHECKOUT
                                                     currentFilmID:self.buyInfo.chosenSession.film_id
                                                   currentCinemaID:self.buyInfo.chosenSession.cinema_id
                                                         sessionId:self.buyInfo.chosenSession.session_id
                                                   returnCodeValue:0
                                                           context:nil];
}

- (void) requestThanhToanInBackGround
{
    [self hideLoadingView];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[APIManager sharedAPIManager] thanhToanRequestGetInforTransactionDetail:appDelegate];
    [self showConfirmMessageDialogInfo:MESSAGE_CONFIRM_WAITING_RESULT withTag:TAG_ALERT_CONFIRM_WAITING];
}

#pragma mark -RKManageDelegate
- (void)processResultResponseDictionaryMapping:(DictionaryMapping *)dictionary requestId:(int)request_id
{
    if (request_id == ID_REQUEST_THANHTOAN_VERIFY_OTP) {
        [self getResultVerifyOTPResponse:dictionary.curDictionary];
        [self hideLoadingView];
    }
    else if(request_id == ID_REQUEST_THANHTOAN_INFOR_TRANSACTION_DETAIL)
    {
        [self getResultTransactionDetailResponse:dictionary.curDictionary];
    }
}

#pragma mark send request and parse result from server
- (void)getResultVerifyOTPResponse:(NSDictionary *)dicObject
{
    NSString *strDes = THANHTOAN_ERROR_WRONG_CODE_OTP;    
    int status = [[dicObject objectForKey:@"status"] intValue];
    NSDictionary *resultObject = [dicObject objectForKey:@"result"];
    if(status == 0 || ![resultObject isKindOfClass:[NSDictionary class]])
    {
        [self showMessageDialogInfo:strDes withTag:TAG_ALERT_WRONG_OPT_CODE];
        return;
    }
    //khi da nhan duoc ket qua verify otp tra ve tu server thi cancel lenh yeu cau thanh toan ngam
    //        Api verifyOTP khi trả về cũng có qui định nếu redirectURL có nội dung thì client sẽ phải mở URL lên, nếu không có thì sẽ bỏ qua, nếu có redirectURL thì kèm theo redirectURL_method có 2 giá trị là GET hoặc POST để client biết phương thức sẽ gọi URL (hiện tại có một số loại thẻ sau khi nhập code xong thì cần phải mở URL)
    //    result verify OTP = {
    //        bankCode = EIB;
    //        description = "Mua ve 123Phim: Ky Nguyen Elysium - Elysium BHD - 3/2 room 2 2013-08-26 22:15:00 50000 A05";
    //        orderNo = 123P1308261628133;
    //        redirectURL = "https://123pay.vn/payport.php?vpc_MerchTxnRef=123P1308261628133";
    //        redirectURL_method:"GET|POST",
    //        totalAmount = 50000;
    //        responseCode (0, 1, -1) trong đó 0 là tiếp tục chờ, 1 là thành công, -1 là thất bại
    //    responseDescription: "Chuỗi nội dung kèm theo nếu cần thiết"
    //    }
    //    LOG_123PHIM(@"-------------------------------------\n");
    //    LOG_123PHIM(@"result verify OTP = %@", resultObject);
    id dataTemp = [resultObject objectForKey:@"responseCode"];
    if ([[APIManager sharedAPIManager] isValidData:dataTemp])
    {
        if([dataTemp intValue] == 1)
        {
            dataTemp = [resultObject objectForKey:@"redirectURL"];
            if ([[APIManager sharedAPIManager] isValidData:dataTemp] && [dataTemp isKindOfClass:[NSString class]])
            {
                NSString *request_type = @"POST";
                id test = [resultObject objectForKey:@"redirectURL_method"];
                if ([[APIManager sharedAPIManager] isValidData:test] && [test isKindOfClass:[NSString class]]) {
                    request_type = test;
                }
                [self executeRequestOpenWebView:dataTemp requestMethod:request_type];
            }
            else
            {
                [self thanhtoanRequestInfoQueryOrderM];
            }
        }
        else if ([dataTemp intValue] == 0)//tiep tuc cho
        {
            [self thanhtoanRequestInfoQueryOrderM];
        }
        else
        {
            dataTemp = [resultObject objectForKey:@"responseDescription"];
            if ([dataTemp isKindOfClass:[NSString class]]) {
                strDes = dataTemp;
            }
            [self showMessageDialogInfo:strDes withTag:TAG_ALERT_WRONG_OPT_CODE];
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
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [[APIManager sharedAPIManager] thanhToanRequestGetInforTransactionDetail:appDelegate];
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

-(void)thanhtoanRequestInfoQueryOrderM
{
    [[APIManager sharedAPIManager] thanhToanRequestGetInforTransactionDetail:self];
    [self performSelector:@selector(requestThanhToanInBackGround) withObject:nil afterDelay:MAX_TIME_WAITING_VERIFY_OTP.intValue];
    
    //add pending for transaction
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //set status sang trai thai doi ket qua xu ly
    [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_WAITING_RESULT] ForKey:KEY_STORE_STATUS_THANH_TOAN];
    [APIManager setStringInApp:appDelegate.Invoice_No ForKey:KEY_STORE_TRANSACTION_ID_PENDING];
}

-(void)pushCheckOutViewController
{
    CheckoutResultViewController *resultSucessViewController = [[CheckoutResultViewController alloc] init];
    [resultSucessViewController setBuyInfo:self.buyInfo];
    [self.navigationController pushViewController:resultSucessViewController animated:YES];
}

#pragma mark alertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_REBLOCK_SEAT_FAIL || alertView.tag == TAG_ALERT_ABORT_TRANSACTION)
    {
        if (alertView.tag == TAG_ALERT_ABORT_TRANSACTION)
        {
            if (buttonIndex == 0) {
                [self cancelTransaction];
                return;
            } else {
                return;
            }
        }
        [self performSelector:@selector(popToSelectSeatViewController) withObject:nil afterDelay:1];
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

- (void) popToSelectSeatViewController
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate popToViewController:[SelectSeatViewController class] animated:YES];
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
#pragma mark UIWebViewDelegate
- (void)executeRequestOpenWebView:(NSString *)redirectLinkCreateOrderM requestMethod:(NSString *)request_method
{
    [self initWebView];
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
    if (([self.bankInfo getUsingWebType] == BANK_USING_WEB_TYPE_OVERLAY_LAYOUT))
    {
        return YES;
    }
	NSString *sPattern123P = [self.bankInfo getPattern123Pay];
    NSString *sPatternMIGS = [self.bankInfo getPattern123PayMIGS];
    NSString *sURL = [request.URL absoluteString];
    
    NSRange range123P = [sURL rangeOfString:sPattern123P];
    NSRange rangeMIGS = [sURL rangeOfString:sPatternMIGS];
	
    if(range123P.location == NSNotFound && rangeMIGS.location == NSNotFound)
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
	if ([sURL rangeOfString:sPatternSuccess].location == 0)
    {
        [self thanhtoanRequestInfoQueryOrderM];
		_webView.hidden = YES;
        return;
    }
    
    if ([self.bankInfo getUsingWebType] == BANK_USING_WEB_TYPE_OVERLAY_LAYOUT)
    {
//        NSString *sPatternError = @"https://paymentcert.smartlink.com.vn:8181/otp.do?method=ws";//SmartlinkPatternErr (can check lai sao ko lay link nay)
        NSLog(@"%@",sURL);
        if ([sURL rangeOfString:[self.bankInfo getSMLPatternVerifyOTPSuccess]].location == 0)
        {
            [self hideLoadingView];
            [self thanhtoanRequestInfoQueryOrderM];
        }
        else if ([sURL rangeOfString:[self.bankInfo getSMLPatternVerifyOTP]].location == 0)
        {
            // fail: wrong opt or image text
            [self requestConfirmImage];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:ORDER_STATUS_ERROR_7222  delegate:self cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil];
            [alert show];
            [self hideLoadingView];
        }
        else
        {
            [_webView setHidden:NO];
            [self hideLoadingView];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)cancelTransaction
{
    [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_OUT_RANGE] ForKey:KEY_STORE_STATUS_THANH_TOAN];
    [APIManager deleteObjectForKey:KEY_STORE_INFO_THANH_TOAN];
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [app popViewController];
}

- (void)showConfirmCancelTransaction
{
    [self showConfirmMessageDialogInfo:NOTICE_CONFIRM_ABORT_INPUT_OTP withTag:TAG_ALERT_ABORT_TRANSACTION];
}

-(void)setBankInfo:(BankInfo *)bankInfo
{
    SAFE_RELEASE(_bankInfo);
    if (bankInfo)
    {
        _bankInfo = bankInfo;
    }
    [self initInputViews];
}

-(void)initInputViews
{
    SAFE_RELEASE(_viewInfo)
    _viewInfo = [[NSMutableDictionary alloc] init];
    [self.bankInfo setConfirmViewInfo:_viewInfo];
    [self.bankInfo setConfirmDelegate:self];
    [self.bankInfo initInputViewsWithLoadInfo:self.bankData forConfirmView:YES];
    [self requestConfirmImage];
}

-(void)segmentControl:(VNGSegmentedControl *) segment didChangeAtParamIndex:(NSUInteger)paramIndex
{
    [self.layoutTable reloadSections:[NSIndexSet indexSetWithIndex:(paramIndex + SECTION_INPUT_BEGIN)] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)requestConfirmImage
{
    NSString *urlString = [self.bankInfo getCaptchaURL];
    if (urlString && urlString.length > 0)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *host = @"paymentcert.smartlink.com.vn";
        NSString *path = @"/";

        NSHTTPCookie *jsessionid = [NSHTTPCookie cookieWithProperties:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     host, NSHTTPCookieDomain,
                                     path, NSHTTPCookiePath,
                                     @"JSESSIONID",  NSHTTPCookieName,
                                     app._SmartlinkSessionId, NSHTTPCookieValue,
                                     nil]];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:jsessionid];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
        
        [theRequest addValue: @"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [theRequest setHTTPMethod:@"GET"];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        SAFE_RELEASE(mutableData)
        mutableData = [[NSMutableData alloc] init];
        [connection start];
    }
}

#pragma mark -
#pragma mark NSURLConnection delegates
-(void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *)response
{
	[mutableData setLength:0];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[mutableData appendData:data];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"%@",error);
	return;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *image = [UIImage imageWithData:self.mutableData];
    NSArray *arr = [self.bankInfo getParamNameListForConfirmView:YES];
    if (arr && [arr isKindOfClass:[NSArray class]]) {
        for (int i = 0; i <[arr count]; i++) {
            id name = [arr objectAtIndex:i];
            if ([name isKindOfClass:[NSDictionary class]])
            {
                UIImageView *iv = (UIImageView *)[self.bankInfo viewAtParamIndex:i forConfirmView:YES];
                if ([iv isKindOfClass:[UIImageView class]])
                {
                    [iv setImage:image];
                }
            }
        }
    }
    [self hideLoadingView];
}

@end
