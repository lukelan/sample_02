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
#define SECTION_CARD_HOLDER 2
#define SECTION_CARD_NUMBER 3
#define SECTION_CHECKBOX_UI 4
#define SECTION_PAY_ACTION  5

#define TAG_ALERT_REBLOCK_SEAT_FAIL 500
#define TAG_ALERT_TRANSACTION_FAIL  501
#define TAG_ALERT_SELECT_BANKING    502
#define TAG_ALERT_CONFIRM_WAITING   503

#import "SelectTypeATMViewController.h"
#import "VerifyATMByOTPViewController.h"
#import "MainViewController.h"
#import "CinemaNoteCell.h"
#import "CellInfoThanhToan.h"
#import "UIDevice+IdentifierAddition.h"
#import "VNGSegmentedControl.h"
#import "SelectSeatViewController.h"
#import "CheckoutResultViewController.h"
#import "SeatInfo.h"

@interface SelectTypeATMViewController ()

@end

@implementation SelectTypeATMViewController
@synthesize layoutTable;
@synthesize tvAccountNo, tvAccountName, tvAccountCardPass, cbRemember;
//@synthesize redirectLinkCreateOrderM;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _inputCardType = 804;//default type ATM
        viewName = SELECT_ATM_TYPE_VIEW_NAME;
        self.isSkipWarning = YES;
    }
    return self;
}

-(BOOL)isNeedToShowInputCardPass
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate._BankCode && [delegate._BankCode isEqualToString:@"123PBIDV"]) {
        return YES;
    }
    return NO;
}

-(BOOL)isShowWebViewToThanhToan
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate._BankCode && ([delegate._BankCode isEqualToString:@"123PVCB"] || [delegate._BankCode isEqualToString:@"123PDAB"])) {
        return YES;
    }
    return NO;
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
    [self setTabBarDisplayType:TAB_BAR_DISPLAY_HIDE];
	// Do any additional setup after loading the view.
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.method = @"ATM";
    BankInfo *bank = [APIManager loadObjectForKey:KEY_STORE_LOCAL_BANKING_OBJECT];
    if (bank) {
        delegate._BankCode = bank.bank_code;
        delegate._BankCodeInternal = bank.bank_code_mobile;
        delegate._BankName = bank.bank_name;
    }
    
//    [self setCustomBackButtonForNavigationItem];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:_buyInfo.chosenFilm.film_name];
    [self initLayoutTable];
    
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    [self.view addSubview:layoutTable];
    self.trackedViewName = viewName;
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureTapOnView:)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    [tap release];    
}

-(void)viewDidUnload
{
    //xu ly release resource khi nhan warning didReceiveMomoryWarning
    [super viewDidUnload];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestThanhToanInBackGround) object:nil];
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
    [self.layoutTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SECTION_PAY_ACTION] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)dealloc
{
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
        [httpRequest release];
    }
    [_segmentBIDVInfo release];
//    [redirectLinkCreateOrderM release];
    [layoutTable release];
    [tvAccountNo release];
    [tvAccountName release];
    [tvAccountCardPass release];
    [cbRemember release];
    cbRemember = nil;
    tvAccountNo = nil;
    tvAccountName = nil;
    tvAccountCardPass = nil;
    
    [_webView cleanForDealloc];
    _webView = nil;
    [super dealloc];
}

#pragma mark tableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self isNeedToShowInputCardPass]) {
        return (SECTION_PAY_ACTION + 2);
    }
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
    if (section == SECTION_BANK) {
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
    else if(section == SECTION_CARD_NUMBER && [self isNeedToShowInputCardPass])
    {
        UIView* ret = [[[UIView alloc] init] autorelease];
        if (!_segmentBIDVInfo)
        {
            _segmentBIDVInfo = [[VNGSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"ATM", @"CNMD", @"Phone", @"CustCode", nil]];
            [_segmentBIDVInfo addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
            _segmentBIDVInfo.crossFadeLabelsOnDrag = YES;
            _segmentBIDVInfo.font = [UIFont getFontNormalSize13];
            _segmentBIDVInfo.textColor = [UIColor lightGrayColor];
            _segmentBIDVInfo.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
            _segmentBIDVInfo.height = 40;
            [_segmentBIDVInfo setSelectedSegmentIndex:0 animated:NO];
            [_segmentBIDVInfo setBackgroundTintColor:[UIColor whiteColor]];
            _segmentBIDVInfo.thumb.tintColor = [UIColor orangeColor];
            _segmentBIDVInfo.thumb.textColor = [UIColor whiteColor];
            _segmentBIDVInfo.thumb.textShadowColor = [UIColor clearColor];
            _segmentBIDVInfo.thumb.textShadowOffset = CGSizeMake(0, 1);
            _segmentBIDVInfo.center = CGPointMake(160, 18);
        }
        [ret addSubview:_segmentBIDVInfo];
        return ret;
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isBIDV = [self isNeedToShowInputCardPass];
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell_thanhToan_%d_%d", indexPath.section, indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cellIdentifier = @"cinema_note_cell_id";
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (indexPath.section > SECTION_CARD_NUMBER) {
        cellIdentifier = [NSString stringWithFormat:@"cell_thanhToan_%d_%d_%d", indexPath.section, indexPath.row, isBIDV];
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
                    [(CinemaNoteCell *)cell layoutNoticeView:_buyInfo.chosenFilm];
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
                [tvAccountName layoutWithRadius:CORNER_RADIUS_TEXT_BOX_ACCOUNT andImageIcon:nil hoderText:TEXT_LABLE_TIP_INPUT_CARD_HOLDER_ATM];
                [tvAccountName setKeyBoardType:UIKeyboardTypeAlphabet];
                [tvAccountName setKeyBoardReturnKeyType:UIReturnKeyDone];
                [tvAccountName setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
                [tvAccountName setAcceptAnsciiCharacterOnly:YES];
                [cell.contentView addSubview:tvAccountName];
                break;
            }
            case SECTION_CARD_NUMBER:
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
                [self layoutTextBoxCardNumber:cell withHeight:height];
                break;
            }
            case SECTION_BANK:
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                cell.textLabel.font = [UIFont getFontNormalSize13];
                break;
            }
            case SECTION_CHECKBOX_UI:
            {
                if (isBIDV) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                    CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
                    [self layoutTextViewInputCardPass:cell withHeight:height];
                } else {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                    [self layoutCheckBoxRemememberAccount:cell];
                }
                break;
            }
            case SECTION_PAY_ACTION:
            {
                if (isBIDV)
                {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
//                    CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
                    [self layoutCheckBoxRemememberAccount:cell];
//                    [self layoutTextViewInputCardPass:cell withHeight:height];
                } else {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                    [self layoutButtonAction:cell];
                }
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
    
    if (indexPath.section != SECTION_BANK) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (indexPath.section == SECTION_CARD_HOLDER)
        {
            delegate._CardHolder = [APIManager getStringInAppForKey:[NSString stringWithFormat:@"%@_%@",KEY_STORE_CARD_HOLDER_ATM,delegate._BankCode]];
            if (delegate._CardHolder) {
                [tvAccountName setText:delegate._CardHolder];
            }
        }
        else if(indexPath.section == SECTION_CARD_NUMBER)
        {
            delegate._CardNumber = [APIManager getStringInAppForKey:[NSString stringWithFormat:@"%@_%@",KEY_STORE_CARD_NUMBER_ATM,delegate._BankCode]];
            if (delegate._CardNumber) {
                [tvAccountNo setText:delegate._CardNumber];
            }
        }
        else if (indexPath.section == SECTION_CHECKBOX_UI)
        {
            [cbRemember setIsChecked:[APIManager getValueAsBoolForKey:[NSString stringWithFormat:@"%@_%@",KEY_STORE_IS_REMEMBER_ACCOUNT_THANHTOAN_ATM, delegate._BankCode]]];
        }
    } else {
        if (delegate._BankCode && delegate._BankCode.length > 0) {
            cell.textLabel.text = delegate._BankName;
        } else {
            cell.textLabel.text = @"Chọn ngân hàng";
        }
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    return cell;
}

#pragma mark layout for cell Content
-(void)layoutTextViewInputCardPass:(UITableViewCell *)cell withHeight:(CGFloat) height
{
    if (!tvAccountCardPass) {
        tvAccountCardPass = [[CustomTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 2*MARGIN_EDGE_TABLE_GROUP, height) inputType:INPUT_TYPE_PASSWORD];
        [tvAccountCardPass setDelegate:[MainViewController sharedMainViewController]];
        [tvAccountCardPass layoutWithRadius:CORNER_RADIUS_TEXT_BOX_ACCOUNT andImageIcon:nil hoderText:@"Mật khẩu"];
        [tvAccountCardPass setKeyBoardType:UIKeyboardTypeDefault];
    }
//    [tvAccountCardPass setText:@"123456"];
    [cell.contentView addSubview:tvAccountCardPass];
}

-(void)layoutButtonAction:(UITableViewCell *)cell
{
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"segment_selected_hl" ofType:@"png"];
    UIImage *imageLeft = [[UIImage alloc] initWithContentsOfFile:thePath];
    UIButton *btnThanhToan = [[UIButton alloc]init];
    CGRect frame = CGRectMake((cell.frame.size.width - imageLeft.size.width)/2, 0, imageLeft.size.width, imageLeft.size.height);
    btnThanhToan.frame = frame;
    [btnThanhToan setImage:imageLeft forState:UIControlStateNormal];
    [btnThanhToan addTarget:self action:@selector(processActionGetOTP) forControlEvents:UIControlEventTouchUpInside];
    [btnThanhToan setBackgroundColor:[UIColor clearColor]];
    
    UILabel *lblTitle = [[UILabel alloc] init];
    [lblTitle setFont:[UIFont getFontBoldSize14]];
    [lblTitle setText:@"Lấy mã OTP"];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    CGSize size = [lblTitle.text sizeWithFont:lblTitle.font];
    [lblTitle setFrame:CGRectMake((imageLeft.size.width - size.width)/2, (imageLeft.size.height - size.height)/2, size.width, size.height)];
    [imageLeft release];
    [btnThanhToan addSubview:lblTitle];
    [lblTitle release];
    [cell.contentView  addSubview:btnThanhToan];
    [btnThanhToan release];
    //background for row
    UIView *viewBG = [[UIView alloc] init];
    [viewBG setBackgroundColor:[UIColor clearColor]];
    [viewBG setFrame:cell.frame];
    [cell setBackgroundView:viewBG];
    [viewBG release];
}

-(void)layoutSegMentSelectCardTypeBIDV:(UITableViewCell *)cell withHeight:(CGFloat)height
{
    if (!_segmentBIDVInfo)
    {
        _segmentBIDVInfo = [[VNGSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"ATM", @"CNMD", @"Phone", @"CustCode", nil]];
        [_segmentBIDVInfo addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
        _segmentBIDVInfo.crossFadeLabelsOnDrag = YES;
        _segmentBIDVInfo.font = [UIFont getFontNormalSize13];
        _segmentBIDVInfo.textColor = [UIColor whiteColor];
        _segmentBIDVInfo.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
        _segmentBIDVInfo.height = height;
        [_segmentBIDVInfo setSelectedSegmentIndex:0 animated:NO];
        _segmentBIDVInfo.thumb.tintColor = [UIColor colorWithRed:0.999 green:0.889 blue:0.312 alpha:1.000];
        _segmentBIDVInfo.thumb.textColor = [UIColor whiteColor];
        _segmentBIDVInfo.thumb.textShadowColor = [UIColor colorWithWhite:1 alpha:1];
        _segmentBIDVInfo.thumb.textShadowOffset = CGSizeMake(0, 1);
        _segmentBIDVInfo.center = CGPointMake(150, 18);
        [_segmentBIDVInfo.layer setBorderWidth:0];
    }
    [cell.contentView addSubview:_segmentBIDVInfo];
}

-(void)layoutSectionCardNumber:(UITableViewCell *)cell withHeight:(CGFloat)height
{
    if ([self isNeedToShowInputCardPass]) {
        [self layoutSegMentSelectCardTypeBIDV:cell withHeight:(height - 2)];
    }
    else
    {
        [self layoutTextBoxCardNumber:cell withHeight:height];
    }
}

-(void)layoutTextBoxCardNumber:(UITableViewCell *)cell withHeight:(CGFloat)height
{
    if (!tvAccountNo)
    {
        tvAccountNo = [[CustomTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 2*MARGIN_EDGE_TABLE_GROUP, height) inputType:INPUT_TYPE_SEPERATION];
        [tvAccountNo setDelegate:[MainViewController sharedMainViewController]];
        [tvAccountNo layoutWithRadius:CORNER_RADIUS_TEXT_BOX_ACCOUNT andImageIcon:nil hoderText:@"Số thẻ"];
        [tvAccountNo setKeyBoardType:UIKeyboardTypeNumberPad];
        tvAccountNo.tag = 2;
        [tvAccountNo setMinCharacter:[MIN_CHARACTER_CARD_NUMBER intValue]];
        [tvAccountNo setMaxCharacter:[MAX_CHARACTER_CARD_NUMBER intValue]];
    }
    [cell.contentView addSubview:tvAccountNo];
}


-(void)layoutCheckBoxRemememberAccount:(UITableViewCell *)cell
{
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (cbRemember) {
        [cbRemember release];
        cbRemember = nil;
    }
    cbRemember = [[UICheckBox alloc] initWithTitle:STRING_SAVE_ACCOUNT_ATM colorTitle:[UIColor grayColor]];
//    [cbRemember setUserInteractionEnabled:NO];
    [cell.contentView  addSubview:cbRemember];
    UIView *viewBG = [[UIView alloc] init];
    [viewBG setBackgroundColor:[UIColor clearColor]];
    [viewBG setFrame:cell.frame];
    [cell setBackgroundView:viewBG];
    [viewBG release];
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

#pragma mark - UIControlEventValueChanged
- (void)segmentedControlChangedValue:(VNGSegmentedControl*)segmentedControl
{
    switch (segmentedControl.selectedSegmentIndex)
    {
        case 0:
            [tvAccountNo setMinCharacter:[MIN_CHARACTER_CARD_NUMBER intValue]];
            [tvAccountNo setMaxCharacter:[MAX_CHARACTER_CARD_NUMBER intValue]];
            [tvAccountNo setInputType:INPUT_TYPE_SEPERATION];
            [tvAccountNo setHolderText:@"Số thẻ"];
			_inputCardType = 804;
            break;
        case 1:
            [tvAccountNo setMinCharacter:[MIN_CHARACTER_CMND intValue]];
            [tvAccountNo setMaxCharacter:[MAX_CHARACTER_CMND intValue]];
            [tvAccountNo setInputType:INPUT_TYPE_NORMAL];
            [tvAccountNo setHolderText:@"Số CMND"];
			_inputCardType = 812;
            break;
        case 2:
            [tvAccountNo setMinCharacter:[MIN_CHARACTER_PHONE_NUMBER intValue]];
            [tvAccountNo setMaxCharacter:[MAX_CHARACTER_PHONE_NUMBER intValue]];
            [tvAccountNo setInputType:INPUT_TYPE_NORMAL];
            [tvAccountNo setHolderText:@"Số điện thoại"];
			_inputCardType = 811;
            break;
        case 3:
            [tvAccountNo setMinCharacter:[MIN_CHARACTER_CUSTOMER_CODE intValue]];
            [tvAccountNo setMaxCharacter:[MAX_CHARACTER_CUSTOMER_CODE intValue]];
            [tvAccountNo setInputType:INPUT_TYPE_NORMAL];
            [tvAccountNo setHolderText:@"Mã khách hàng"];
			_inputCardType = 806;
            break;
        default:
            break;
    }
}

#pragma makr tableView Delegate
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
    else if(section == SECTION_CARD_HOLDER && [self isNeedToShowInputCardPass])
    {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_INFO) {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    else if (section == SECTION_BANK)
    {
        CGFloat height = [@"ABC" sizeWithFont:[UIFont getFontBoldSize18]].height;
        return (height + MARGIN_EDGE_TABLE_GROUP);
    }
    else if (section == SECTION_CARD_NUMBER && [self isNeedToShowInputCardPass])
    {
        return 40 + MARGIN_EDGE_TABLE_GROUP;
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
    if (tvAccountName) {
        [tvAccountName resignFirstResponder];
    }
    if (tvAccountNo) {
        [tvAccountNo resignFirstResponder];
    }
    if (tvAccountCardPass) {
        [tvAccountCardPass resignFirstResponder];
    }
}

#pragma mark handle action Thanh Toan
-(void)processActionGetOTP
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (!delegate._BankCode || delegate._BankCode.length <= 0)
    {
        [self showMessageDialogInfo:THANHTOAN_FORCE_CHOOSE_BANKING withTag:TAG_ALERT_SELECT_BANKING];
        return;
    }
    if (![self isShowWebViewToThanhToan])//neu khong phai la ngan hang Dong a, VCB phai nhap cardHolder & cardNumber
    {
        if (![tvAccountName hasText]) {
            [tvAccountName becomeFirstResponder];
            return;
        }
        else if (![tvAccountNo hasText] || ![self isValidCardNumber])
        {
            if (![self isValidCardNumber])
            {
                NSString *des = [NSString stringWithFormat:ERROR_DESCRIPTION_WRONG_RANGE_LENGTH_INPUT, tvAccountNo.holderText,[NSString stringWithFormat:@"%d",tvAccountNo.minCharacter], [NSString stringWithFormat:@"%d", tvAccountNo.maxCharacter]];
                if(tvAccountNo.minCharacter == tvAccountNo.maxCharacter)
                {
                    des = [NSString stringWithFormat:ERROR_DESCRIPTION_WRONG_FORCE_LENGTH_INPUT, tvAccountNo.holderText,[NSString stringWithFormat:@"%d",tvAccountNo.minCharacter]];
                }
                [self showMessageDialogInfo:des withTag:-1];
            }
            [tvAccountNo becomeFirstResponder];
            return;
        }
    }
    
    if ([self isNeedToShowInputCardPass])
    {
        if (!tvAccountCardPass)
        {
            //     NSLog(@"Chua khoi tao textbox nhap passWord");
            return;
        }
        if (![tvAccountCardPass hasText])
        {
            [tvAccountCardPass becomeFirstResponder];
            return;
        }
    }
    // send log to 123phim server
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:@""
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_TICKET_GET_OTP
                                                     currentFilmID:self.buyInfo.chosenSession.film_id
                                                   currentCinemaID:self.buyInfo.chosenSession.cinema_id
                                                         sessionId:self.buyInfo.chosenSession.session_id
                                                   returnCodeValue:0
                                                           context:nil];

    //save value card
    delegate._CardHolder = [tvAccountName getText];
    delegate._CardNumber = [tvAccountNo getText];
    
    if ([self isNeedToShowInputCardPass])
    {
        delegate._CardPass = [tvAccountCardPass getText];
        delegate._CardType = [NSString stringWithFormat:@"%d", _inputCardType];
    }
    
//    [self checkAndSaveInfo];
    //Duyln kiem tra step da lam roi thi khong lam nua tranh error thanhToan khi back
    [self executeRequestThanhToanBaseOnStep];
}

-(void)checkAndSaveInfo
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (cbRemember.isChecked) {
        if ([tvAccountName hasText]) {
            //save value card
            delegate._CardHolder = [tvAccountName getText];
        }
        if ([tvAccountNo hasText]) {
            delegate._CardNumber = [tvAccountNo getText];
        }
        //Send info to save on server
        [APIManager setBoolValue:YES ForKey:[NSString stringWithFormat:@"%@_%@",KEY_STORE_IS_REMEMBER_ACCOUNT_THANHTOAN_ATM, delegate._BankCode]];
        BankInfo *defaultBank = [[BankInfo alloc] init];
        [defaultBank setBank_name:delegate._BankName];
        [defaultBank setBank_code:delegate._BankCode];
        [defaultBank setBank_code_mobile:delegate._BankCodeInternal];
        [APIManager saveObject:defaultBank forKey:KEY_STORE_LOCAL_BANKING_OBJECT];
        [defaultBank release];
        //save card number and card holder
        [APIManager setStringInApp:delegate._CardNumber ForKey:[NSString stringWithFormat:@"%@_%@",KEY_STORE_CARD_NUMBER_ATM,delegate._BankCode]];
        [APIManager setStringInApp:delegate._CardHolder ForKey:[NSString stringWithFormat:@"%@_%@",KEY_STORE_CARD_HOLDER_ATM,delegate._BankCode]];
    } else {
        [APIManager setBoolValue:NO ForKey:[NSString stringWithFormat:@"%@_%@",KEY_STORE_IS_REMEMBER_ACCOUNT_THANHTOAN_ATM, delegate._BankCode]];
        //save card number and card holder
        [APIManager setStringInApp:@"" ForKey:[NSString stringWithFormat:@"%@_%@",KEY_STORE_CARD_NUMBER_ATM,delegate._BankCode]];
        [APIManager setStringInApp:@"" ForKey:[NSString stringWithFormat:@"%@_%@",KEY_STORE_CARD_HOLDER_ATM,delegate._BankCode]];
        [APIManager deleteObjectForKey:KEY_STORE_LOCAL_BANKING_OBJECT];
    }
}

- (BOOL) isValidCardNumber
{
    if ([tvAccountNo getText].length < [tvAccountNo minCharacter] || [tvAccountNo getText].length > [tvAccountNo maxCharacter])
    {
        return NO;
    }
    return YES;
}

-(void)executeRequestThanhToanBaseOnStep
{
    [self showLoadingScreenWithType:LOADING_TYPE_FULLSCREEN];
    [[APIManager sharedAPIManager] thanhToanRequestVerifyCardM:self.buyInfo.chosenSeatInfoList sessionID:self.buyInfo.chosenSession.session_id.intValue context:self];
}

#pragma mark get InforCitySelect
#if (USING_ATM_INPUT_VIEW_CONTROLLER)
-(void)didSelectBank:(BankInfo *)bankInfo atIndex:(NSInteger)index
#else
-(void)receiveBankData:(BankInfo *)bankInfo
#endif
{
    if (bankInfo) {
//        isBackFromSelectBanking = YES;
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate._BankName = bankInfo.bank_name;
        delegate._BankCode = bankInfo.bank_code;
        delegate._BankCodeInternal = bankInfo.bank_code_mobile;
        if ([self isShowWebViewToThanhToan])
        {
            delegate._CardNumber = @"";
            [self executeRequestThanhToanBaseOnStep];
        }
        [layoutTable reloadData];
    }
}

#pragma mark - ASIHttpRequestDelegate
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    if(request.tag == ID_REQUEST_THANHTOAN_VERIFY_ATM)
    {
//        NSLog(@"responseString verify ATM from 123PAY = %@", [request responseString]);
        [self parseToGetResultVerifyCardM:[request responseString]];
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

#pragma mark parse to get result
-(void)parseToGetResultVerifyCardM:(NSString *)response
{
//    NSLog(@"-------------------------------------\n");
//    NSLog(@"--result verify cardM = %@", response);
    NSDictionary *dicObject = [[APIManager sharedAPIManager].parser objectWithString:response error:nil];
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
//            "totalAmount":null,
//            "redirectURL":null,
//            "redirectURL_method":"GET|POST",
//            "input_code_native":1,
//            "code_name":"OTP"// --> tên của code cần nhập
//        }
//    }
//    Api verifyCard khi trả về bổ sung thêm một trường dữ liệu là input_code_native --> sẽ cho biết client sẽ mở màn hình native để user nhập code hay không, code_name --> tên của code cần nhập, hiện tại thông dụng là OTP, và quy định nếu redirectURL có nội dung thì client sẽ phải mở URL lên, nếu không có thì sẽ bỏ qua, nếu có redirectURL thì kèm theo redirectURL_method có 2 giá trị là GET hoặc POST để client biết phương thức sẽ gọi URL (hiện tại credit bên client đang hardcoded là POST, ATM là GET, việc hardcoded này không ổn vì các ngân hàng khác nhau có thể có thêm những qui định xác nhận khác nhau)

    NSDictionary *dicVerify = [resultObject objectForKey:@"verify"];
    id dataTemp = [dicVerify objectForKey:@"responseCode"];
    if ([[APIManager sharedAPIManager] isValidData:dataTemp])
    {
        if([dataTemp intValue] == 1)
        {
            //get infor transaction to verify
            NSDictionary *dicTransaction = [resultObject objectForKey:@"transaction"];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if ([[APIManager sharedAPIManager] isValidData:dicTransaction]) {
                appDelegate.Invoice_No = [dicTransaction objectForKey:@"invoice_no"];
                appDelegate.ticket_code = [dicTransaction objectForKey:@"ticket_code"];
                appDelegate._TransactionID = [dicTransaction objectForKey:@"transaction_id"];
            }
            appDelegate._OrderNo = [dicVerify objectForKey:@"orderNo"];
            [self hideLoadingView];
            int value = 0;
            dataTemp = [dicVerify objectForKey:@"useOTP"];//key moi input_code_native
            if ([[APIManager sharedAPIManager] isValidData:dataTemp] && [dataTemp isKindOfClass:[NSNumber class]])
            {
                value = [dataTemp intValue];
            }
            
            if (value == 0)
            {
                dataTemp = [dicVerify objectForKey:@"redirectURL"];
                if ([[APIManager sharedAPIManager] isValidData:dataTemp] && [dataTemp isKindOfClass:[NSString class]])
                {
                    NSString *request_type = @"GET";
                    id test = [dicVerify objectForKey:@"redirectURL_method"];
                    if ([[APIManager sharedAPIManager] isValidData:test] && [test isKindOfClass:[NSString class]]) {
                        request_type = test;
                    }
                    [self executeRequestOpenWebView:dataTemp requestMethod:request_type];
                }
            } else {
                [self pushViewVerifyThanhToanAccount];
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

#pragma mark ultility action after get result
-(void) pushViewVerifyThanhToanAccount
{
    //Chuyen sang view verify ATM and OTP
    VerifyATMByOTPViewController *verifyView = [[VerifyATMByOTPViewController alloc] init];
    [verifyView setBuyInfo:self.buyInfo];
    [verifyView setIsTypeBIDV:[self isNeedToShowInputCardPass]];
    [self.navigationController pushViewController:verifyView animated:YES];
    [verifyView release];
}

-(void) pushCheckOutViewController
{
    CheckoutResultViewController *resultSucessViewController = [[CheckoutResultViewController alloc] init];
    [resultSucessViewController setBuyInfo:self.buyInfo];
    [self.navigationController pushViewController:resultSucessViewController animated:YES];
    [resultSucessViewController release];
}

-(void) pushViewSelectBanking
{
    //process select type account to pay
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SelectBankViewController *selectBankView = [[SelectBankViewController alloc] init];
    BankInfo *defaultBank = [[BankInfo alloc] init];
    [defaultBank setBank_name:delegate._BankName];
    [defaultBank setBank_code:delegate._BankCode];
    [defaultBank setBank_code_mobile:delegate._BankCodeInternal];
    [selectBankView setCurrentBank:defaultBank];
    [defaultBank release];
    [selectBankView setFullScreen];
    [selectBankView setChooseBankDelegate:self];
    [self.navigationController pushViewController:selectBankView animated:YES];
    [selectBankView release];
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
//        if (buttonIndex == 0) {
//            [[APIManager sharedAPIManager] thanhToanRequestCancelBooking:nil];
//        } else {
//            return;
//        }
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        [appDelegate popToViewController:[SelectSeatViewController class] animated:YES];
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

-(void)showMessageDialog:(NSString *)des
{
    [self hideLoadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:des delegate:nil cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark handle for VCB, DONGA bank must pay on web
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

- (void)executeRequestOpenWebView:(NSString *)redirectLinkCreateOrderM requestMethod:(NSString *)request_method
{
    [self initWebView];
    [self hideLoadingView];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_webView];
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
    NSString *sPatternSuccess = THANH_TOAN_PATTERN_SUCESS_123PAY;
	
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
        delegate._BankCode = @"";
        [APIManager setStringInApp:delegate.Invoice_No ForKey:KEY_STORE_TRANSACTION_ID_PENDING];
        [self performSelector:@selector(requestThanhToanInBackGround) withObject:nil afterDelay:MAX_TIME_WAITING_VERIFY_OTP.intValue];
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
@end
