//
//  VerifyATMByOTPViewController.m
//  123Phim
//
//  Created by Le Ngoc Duy on 5/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#define SECTION_INFO    0
#define SECTION_CARD_HOLDER 1
#define SECTION_CARD_NUMBER 2
#define SECTION_INPUT_OTP   3
#define SECTION_PAY_ACTION  4

#define TAG_ALERT_WRONG_OPT_CODE 499
#define TAG_ALERT_REBLOCK_SEAT_FAIL 500
#define TAG_ALERT_TRANSACTION_FAIL  501
#define TAG_ALERT_CONFIRM_WAITING   502

#import "VerifyATMByOTPViewController.h"
#import "MainViewController.h"
#import "CinemaNoteCell.h"
#import "CellInfoThanhToan.h"
#import "CheckoutResultViewController.h"
#import "SelectSeatViewController.h"
#import "SeatInfo.h"


@interface VerifyATMByOTPViewController ()

@end

@implementation VerifyATMByOTPViewController
@synthesize layoutTable;
@synthesize buyInfo = _buyInfo;
@synthesize tvAccountNo, tvAccountName, tvVerifyOTP;
@synthesize isTypeBIDV;
@synthesize webView = _webView;
//@synthesize redirectLinkCreditCard;

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
    if (localNotif == nil)
    {
        return;
    }
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
    [localNotif release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTabBarDisplayType:TAB_BAR_DISPLAY_HIDE];
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
        [btnRight addTarget:self action:@selector(cancelTransaction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *btnBarRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
        [self.navigationItem setRightBarButtonItem:btnBarRight];
        [btnBarRight release];
    }

    [delegate setTitleLabelForNavigationController:self withTitle:self.buyInfo.chosenFilm.film_name];
   
    [self initLayoutTable];   
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    [self.view addSubview:layoutTable];
    
    self.trackedViewName = viewName;
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureTapOnView:)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    [tap release];
    
    [self postLocalNotification];
    //cap nhat status sang trai thai don hang failed
    [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_WAITING_INPUT_OTP] ForKey:KEY_STORE_STATUS_THANH_TOAN];
    [delegate performSelector:@selector(checkAndSendCleanWarning) withObject:nil afterDelay:[MAX_TIME_WAITING_INPUT_OTP intValue]];
}

-(NSMutableDictionary *) setCustomDataToPostLocalNotification
{
    //set list ticket
    NSString *strGhe = @"";
    for (SeatInfo *seatInfo in self.buyInfo.chosenSeatInfoList)
    {
        if (strGhe.length > 0)
        {
            strGhe = [strGhe stringByAppendingFormat:@", %@", seatInfo.identify];
        }
        else
        {
            strGhe = [strGhe stringByAppendingFormat:@"%@", seatInfo.identify];
        }
    }
    NSString *sessionVersion = @"";
    if (!self.canCancelTransaction)
    {
        sessionVersion = @" - 2D";
        if ([self.buyInfo.chosenSession.version_id intValue] == 3) {
            sessionVersion = @" - 3D";
        }
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    BOOL isBIDV = [delegate._BankCodeInternal isEqualToString:@"BIDV"];
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:delegate.ticket_code,@"ticket_code",
                                     [NSNumber numberWithInt:self.buyInfo.totalMoney],@"ticket_total_price",
                                     delegate.Invoice_No ,@"Invoice_No",
                                     self.buyInfo.chosenSession.session_time,@"date_show",
                                     self.buyInfo.chosenFilm.film_version,@"film_version",
                                     self.buyInfo.chosenFilm.poster_url,@"film_poster_url",
                                     strGhe,@"listSeat",
                                     self.buyInfo.room_name,@"room_name",
                                     delegate.email,@"email",
                                     delegate.phone,@"phone",
                                     self.buyInfo.chosenFilm.film_duration,@"film_duration",
                                    self.buyInfo.chosenFilm.publish_date,@"film_publish_date",
                                     self.buyInfo.chosenFilm.film_url,@"film_url",
                                     self.buyInfo.chosenFilm.film_id,@"film_id",
                                     [NSString stringWithFormat:@"%@%@",self.buyInfo.chosenFilm.film_name, sessionVersion],@"film_name",
                                     self.buyInfo.chosenSession.session_id,@"session_id",
                                     self.buyInfo.chosenSession.cinema_id,@"cinema_id",
//                                     delegate._CardHolder, @"cardHolder",
//                                     delegate._CardNumber, @"cardNumber",
                                     delegate._BankCodeInternal,@"bankCode",
                                     [NSNumber numberWithBool:isBIDV], @"isBIDV",
                                     nil];
    double timeCurrent = [NSDate timeIntervalSinceReferenceDate];
    [infoDict setValue:[NSNumber numberWithDouble:timeCurrent] forKey:@"date_buy"];
    
    //------------------------------------------------------------//
    //-------holder-------//
    NSData *plain = [delegate._CardHolder dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipher = [plain AES256EncryptWithKey:@"!askbills@"];
    [infoDict setValue:cipher forKey:[NSString sha1:@"cardHolder"]];
    
    //--------number-----//
    plain = [delegate._CardNumber dataUsingEncoding:NSUTF8StringEncoding];
    cipher = [plain AES256EncryptWithKey:@"!askbills@"];
    [infoDict setValue:cipher forKey:[NSString sha1:@"cardNumber"]];
    
    //luu gia tri xuong local de hien thi sau
    [APIManager setValueForKey:infoDict ForKey:KEY_STORE_INFO_THANH_TOAN];
    return infoDict;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self showMessageDialogInfo:THANHTOAN_VERIFY_CARD_SUCCESS withTag:-1];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_webView cleanForDealloc];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestThanhToanInBackGround) object:nil];
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
        [httpRequest release];
    }
    [_buyInfo release];
    _buyInfo = nil;
    [layoutTable release];
    [tvAccountNo release];
    [tvAccountName release];
    [tvVerifyOTP release];
    [_segmentBIDVInfo release];
//    [redirectLinkCreditCard release];
    _webView = nil;
    [super dealloc];
}

-(void)initWebView
{
    //add webView
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _webView.delegate = self;
    _webView.tag = 100;
    _webView.opaque = NO;
    _webView.userInteractionEnabled = NO;
    _webView.scrollView.scrollEnabled = NO;
    _webView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [_webView setHidden:YES];
    [self.view addSubview:_webView];
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
    return (SECTION_PAY_ACTION + 1);
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
    if (section == SECTION_CARD_HOLDER) {
        //Layout title tip
        CGFloat xStar = MARGIN_EDGE_TABLE_GROUP + 5;
        CGFloat yStar = 0;
        UIView* ret = [[[UIView alloc] init] autorelease];
        UILabel *lblTitleThanhToan = [[UILabel alloc] init];
        [lblTitleThanhToan setFont:[UIFont getFontBoldSize18]];
        [lblTitleThanhToan setBackgroundColor:[UIColor clearColor]];
        [lblTitleThanhToan setTextColor:[UIColor blackColor]];
        lblTitleThanhToan.text = THANHTOAN_TITLE_INFO_ATM_CARD;
        CGSize sizeTextTitle = [lblTitleThanhToan.text sizeWithFont:lblTitleThanhToan.font];
        CGFloat widthText = self.view.frame.size.width - 2*(MARGIN_EDGE_TABLE_GROUP + 5);
        [lblTitleThanhToan setFrame:CGRectMake(xStar, yStar, widthText, sizeTextTitle.height)];
        [ret addSubview:lblTitleThanhToan];
        [lblTitleThanhToan release];
        return ret;
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell_thanhToan_%d_%d", indexPath.section, indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cellIdentifier = @"cinema_note_cell_id";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        switch (indexPath.section)
        {
            case SECTION_INFO:
            {
                if (indexPath.row == 0)
                {
                    NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"CinemaNoteCell" owner:self options:nil];
                    cell = [arr objectAtIndex:0];
                    [(CinemaNoteCell *)cell layoutNoticeView:self.buyInfo.chosenFilm];
                }
                else
                {
                    cell =  [[[CellInfoThanhToan alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                    [(CellInfoThanhToan *)cell layoutInfoCell:self.buyInfo];
                }
                break;
            }
            case SECTION_CARD_HOLDER:
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
                tvAccountName = [[CustomTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 2*MARGIN_EDGE_TABLE_GROUP, height)];
                [tvAccountName setDelegate:[MainViewController sharedMainViewController]];
                [tvAccountName layoutWithRadius:CORNER_RADIUS_TEXT_BOX_ACCOUNT andImageIcon:nil hoderText:@"Tên chủ tài khoản"];
                [tvAccountName setText:delegate._CardHolder];
                [tvAccountName setEnable:NO];
                [tvAccountName setBackgroundColor:[UIColor grayColor]];
                [tvAccountName setAcceptAnsciiCharacterOnly:YES];
                [cell.contentView addSubview:tvAccountName];
                break;
            }
            case SECTION_CARD_NUMBER:
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
                tvAccountNo = [[CustomTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 2*MARGIN_EDGE_TABLE_GROUP, height)];
                [tvAccountNo setDelegate:[MainViewController sharedMainViewController]];
                [tvAccountNo layoutWithRadius:CORNER_RADIUS_TEXT_BOX_ACCOUNT andImageIcon:nil hoderText:@"Số thẻ"];
                [tvAccountNo setText:delegate._CardNumber];
                [tvAccountNo setEnable:NO];
                [tvAccountNo setBackgroundColor:[UIColor grayColor]];
                [cell.contentView addSubview:tvAccountNo];
                break;
            }
            case SECTION_INPUT_OTP:
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
                [self layoutInputOTP:cell withHeight:height];
                break;
            }
            default:
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                [self layoutButtonAction:cell];
                break;
            }
        }
    }
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)layoutInputOTP:(UITableViewCell *)cell withHeight:(CGFloat)height
{
    CGFloat startX = 0;
    CGFloat widthTextView = self.view.frame.size.width - 2*MARGIN_EDGE_TABLE_GROUP;
    if (isTypeBIDV) {
        widthTextView = (self.view.frame.size.width - 2*MARGIN_EDGE_TABLE_GROUP)/2;
        //layout segment
        _segmentBIDVInfo = [[VNGSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"SMS", @"Token", nil]];
        [_segmentBIDVInfo addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
        _segmentBIDVInfo.crossFadeLabelsOnDrag = YES;
        _segmentBIDVInfo.font = [UIFont getFontNormalSize13];
        _segmentBIDVInfo.textColor = [UIColor lightGrayColor];
        _segmentBIDVInfo.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 14);
        _segmentBIDVInfo.height = (2*MARGIN_EDGE_TABLE_GROUP + [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]].height);
        [_segmentBIDVInfo setSelectedSegmentIndex:0 animated:NO];
        _segmentBIDVInfo.thumb.tintColor = [UIColor orangeColor];
        _segmentBIDVInfo.thumb.textColor = [UIColor whiteColor];
        _segmentBIDVInfo.thumb.textShadowColor = [UIColor clearColor];
        _segmentBIDVInfo.thumb.textShadowOffset = CGSizeMake(0, 1);
        _segmentBIDVInfo.center = CGPointMake(widthTextView/2 - MARGIN_EDGE_TABLE_GROUP, height/2);
        [cell.contentView addSubview:_segmentBIDVInfo];
        //background for row
        [self setBackGroundNilForCell:cell];
        startX += _segmentBIDVInfo.frame.size.width + 2*MARGIN_EDGE_TABLE_GROUP;
    }
    tvVerifyOTP = [[CustomTextView alloc] initWithFrame:CGRectMake(startX, 0, widthTextView, height)];
    [tvVerifyOTP setDelegate:[MainViewController sharedMainViewController]];
    [tvVerifyOTP layoutWithRadius:CORNER_RADIUS_TEXT_BOX_ACCOUNT andImageIcon:nil hoderText:@"Mã OTP"];
    [tvVerifyOTP setKeyBoardType:UIKeyboardTypeNumberPad];
    if (isTypeBIDV) {
        tvVerifyOTP.backgroundColor = [UIColor whiteColor];
        tvVerifyOTP.layer.borderWidth = 1.0;
        tvVerifyOTP.layer.borderColor = layoutTable.separatorColor.CGColor;
    }
    [cell.contentView addSubview:tvVerifyOTP];
}

#pragma mark - UIControlEventValueChanged
- (void)segmentedControlChangedValue:(VNGSegmentedControl*)segmentedControl
{
    switch (segmentedControl.selectedSegmentIndex)
    {
        case 0:
            [tvVerifyOTP setHolderText:@"Mã OTP"];
            break;
        case 1:
            [tvVerifyOTP setHolderText:@"Mã Token"];
            break;
        default:
            break;
    }
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
    [lblTitle release];
    [btnThanhToan release];
    [imageLeft release];
    
    //background for row
    [self setBackGroundNilForCell:cell];
}

-(void)layoutSegmentControlSelectTypeOTPForBIDV:(UITableViewCell *)cell
{
    _segmentBIDVInfo = [[VNGSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"SMS", @"Token", nil]];
	_segmentBIDVInfo.crossFadeLabelsOnDrag = YES;
	_segmentBIDVInfo.font = [UIFont getFontNormalSize13];
    _segmentBIDVInfo.textColor = [UIColor whiteColor];
	_segmentBIDVInfo.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 14);
	_segmentBIDVInfo.height = (2*MARGIN_EDGE_TABLE_GROUP + [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]].height);
    [_segmentBIDVInfo setSelectedSegmentIndex:0 animated:NO];
	_segmentBIDVInfo.thumb.tintColor = [UIColor colorWithRed:0.999 green:0.889 blue:0.312 alpha:1.000];
	_segmentBIDVInfo.thumb.textColor = [UIColor whiteColor];
	_segmentBIDVInfo.thumb.textShadowColor = [UIColor colorWithWhite:1 alpha:1];
	_segmentBIDVInfo.thumb.textShadowOffset = CGSizeMake(0, 1);
    _segmentBIDVInfo.center = CGPointMake(160, 20);
    [cell.contentView addSubview:_segmentBIDVInfo];
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
    [viewBG release];
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
    return MARGIN_EDGE_TABLE_GROUP/2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_INFO) {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    else if (section == SECTION_CARD_HOLDER)
    {
        CGFloat height = [@"ABC" sizeWithFont:[UIFont getFontBoldSize18]].height;
        return (height + MARGIN_EDGE_TABLE_GROUP);
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
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
    if (tvVerifyOTP) {
        [tvVerifyOTP resignFirstResponder];
    }
}

#pragma mark handle action Thanh Toan
-(void)processActionThanhToan
{
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:NSStringFromClass([VerifyATMByOTPViewController class])
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_TICKET_CLICK_CHECKOUT
                                                     currentFilmID:self.buyInfo.chosenSession.film_id
                                                   currentCinemaID:self.buyInfo.chosenSession.cinema_id
                                                         sessionId:self.buyInfo.chosenSession.session_id
                                                   returnCodeValue:0
                                                           context:nil];
    
    if (![tvVerifyOTP hasText]) {
        [tvVerifyOTP becomeFirstResponder];
        return;
    }
    [self showLoadingScreenWithType:LOADING_TYPE_FULLSCREEN];
    [self checkAndSendVerifyOTP];
}

- (void) checkAndSendVerifyOTP
{
    if (isTypeBIDV)
    {
        [[APIManager sharedAPIManager] thanhToanRequestVerifyOTP:[tvVerifyOTP getText] context:self withType:_segmentBIDVInfo.selectedSegmentIndex];
    }
    else
    {
        [[APIManager sharedAPIManager] thanhToanRequestVerifyOTP:[tvVerifyOTP getText] context:self withType:-1];
    }
}

- (void) requestThanhToanInBackGround
{
    [self hideLoadingView];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[APIManager sharedAPIManager] thanhToanRequestGetInforTransactionDetail:appDelegate];
    [self showConfirmMessageDialogInfo:MESSAGE_CONFIRM_WAITING_RESULT withTag:TAG_ALERT_CONFIRM_WAITING];
}

#pragma mark send request and parse result from server
-(void)parseToGetResultVerifyOTP:(NSString *)response
{
    NSDictionary *dicObject = [[APIManager sharedAPIManager].parser objectWithString:response error:nil];
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
//    NSLog(@"-------------------------------------\n");
//    NSLog(@"result verify OTP = %@", resultObject);
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
//                [self createRequestWebViewThanhToan:redirectLinkCreditCard];
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

-(void)parseToGetResultTransactionDetail:(NSString *)response
{
    NSDictionary *dicObject = [[APIManager sharedAPIManager].parser objectWithString:response error:nil];
//    NSLog(@"-------------------------------------\n");
//    NSLog(@"gia tri detail = %@", response);
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
    [resultSucessViewController release];
}

#pragma mark - ASIHttpRequestDelegate
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    if(request.tag == ID_REQUEST_THANHTOAN_VERIFY_OTP)
    {
        //        NSLog(@"Result verify OTp = %@", [request responseString]);
        [self parseToGetResultVerifyOTP:[request responseString]];
    }
    else if(request.tag == ID_REQUEST_THANHTOAN_INFOR_TRANSACTION_DETAIL)
    {
        //     NSLog(@"ID_REQUEST_THANHTOAN_INFOR_TRANSACTION_DETAIL = %@", [request responseString]);
        [self parseToGetResultTransactionDetail:[request responseString]];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request{
     [super requestFailed:request];
}

-(void)setHTTPRequest: (ASIHTTPRequest *) theRequest
{
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
        [httpRequest release];
    }
    httpRequest = [theRequest retain];
}

#pragma mark alertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_REBLOCK_SEAT_FAIL || alertView.tag == TAG_ALERT_TRANSACTION_FAIL)
    {
        if (alertView.tag == TAG_ALERT_TRANSACTION_FAIL)
        {
//            if (buttonIndex == 0) {
//                [[APIManager sharedAPIManager] thanhToanRequestCancelBooking:nil];
//            } else {
//                return;
//            }
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
    [alert release];
}

-(void)showConfirmMessageDialogInfo:(NSString *)des withTag:(int)tag
{
    [self hideLoadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:des delegate:self cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:ALERT_BUTTON_NO,nil];
    alert.tag = tag;
//    [alert setDelegate:self];
    [alert show];
    [alert release];
}
#pragma mark UIWebViewDelegate
- (void)executeRequestOpenWebView:(NSString *)redirectLinkCreateOrderM requestMethod:(NSString *)request_method
{
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
    [theRequest release];
}

- (void)createRequestWebViewThanhToan:(NSString *)dataTemp
{
    NSString *redirectURL = dataTemp;
    NSRange rangeIndex = [redirectURL rangeOfString:@"?"];
    NSString *migsURL = [redirectURL substringToIndex:(rangeIndex.location)];
    NSString *content = [redirectURL substringFromIndex:(rangeIndex.location + rangeIndex.length)];
    //                NSLog(@"migSURL = %@, content = %@", migsURL, content);
    
    NSMutableData *body = [NSMutableData data];
    [body appendData: [content dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Create request
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:[NSURL URLWithString: migsURL]];
    
    // Headers
    [request setHTTPMethod:@"POST"];
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    // Append body
    [request setHTTPBody:body];
    //                NSLog(@"-------------start load web-------------");
    [_webView loadRequest:request];
    [request release];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //	NSLog(@"%@ - %@",request.HTTPMethod, request.URL);
	NSString *sPattern123P = THANH_TOAN_VISA_PATTERN_123PAY;
    NSString *sURL = [request.URL absoluteString];
    
    NSRange range123P = [sURL rangeOfString:sPattern123P];
    NSRange rangeMIGS = [sURL rangeOfString:THANH_TOAN_VISA_PATTERN_MIGS];
	
    if(range123P.location != 0 && rangeMIGS.location != 0){
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
    NSString *sPatternSuccess = THANH_TOAN_PATTERN_SUCESS_123PAY;	
	if ([sURL rangeOfString:sPatternSuccess].location == 0)
    {
        [self thanhtoanRequestInfoQueryOrderM];
		_webView.hidden = YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)cancelTransaction:(id)sender
{
    [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_OUT_RANGE] ForKey:KEY_STORE_STATUS_THANH_TOAN];
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [app popViewController];
}

@end
