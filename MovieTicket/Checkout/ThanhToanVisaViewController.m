//
//  ThanhToanVisaViewController.m
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

#define SECTION_INFO    0
#define SECTION_CARD_HOLDER 1
#define SECTION_CARD_NUMBER 2
#define SECTION_SECURITY    3
#define SECTION_CHECKBOX_UI 4
#define SECTION_PAY_ACTION  5

#define MAX_YEAR_EXPIRE_FROM_CURRENT  10

#import "ThanhToanVisaViewController.h"
#import "CheckoutResultViewController.h"
#import "MainViewController.h"
#import "CinemaNoteCell.h"
#import "CellInfoThanhToan.h"
#import "UIDevice+IdentifierAddition.h"
#if (USING_ATM_INPUT_VIEW_CONTROLLER)
#import "ConfirmInputViewController.h"
#else
#import "VerifyATMByOTPViewController.h"
#endif
#import "SelectSeatViewController.h"
#import "URLParser.h"

@interface ThanhToanVisaViewController ()

@end

@implementation ThanhToanVisaViewController

@synthesize layoutTable;
@synthesize tvAccountNo, tvAccountName, tvSecrectedCode, tvExpiredDate, cbRemember;
@synthesize yearSelection = _yearSelection;
@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _yearSelection = [[NSMutableArray alloc] init];
        NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *components = [calendar components:NSYearCalendarUnit fromDate:[NSDate date]];
        NSInteger year = [components year];
        for (int i = 0; i < MAX_YEAR_EXPIRE_FROM_CURRENT; i++) {
            [_yearSelection addObject:[NSString stringWithFormat:@"%d", year + i]];
        }        
        viewName = THANHTOAN_VISA_VIEW_NAME;
        self.isSkipWarning = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setTabBarDisplayType:TAB_BAR_DISPLAY_HIDE];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [self setCustomBackButtonForNavigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:_buyInfo.chosenFilm.film_name];
    delegate._BankCodeInternal = @"CREDITCARD";
    delegate.method = @"Credit/Visa Card";
    
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
    [tap release];
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
    [btnleft release];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
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
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
        [httpRequest release];
    }
    [layoutTable release];
    [tvAccountNo release];
    [tvAccountName release];
    [_yearSelection release];
    [cbRemember release];
    layoutTable = nil;
    tvAccountNo = nil;
    tvAccountName = nil;
    _yearSelection = nil;
    cbRemember = nil;
    
    if (_webView && [_webView superview]) {
        [_webView removeFromSuperview];
    }
    _webView = nil;
    
    [super dealloc];
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

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return 12;
    }else if (component == 1) {
        return [self.yearSelection count];
    } else {
    }
    return 0;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) { //month
        if (row < 9) {
            return [NSString stringWithFormat:@"0%d", row + 1];
        }
        return[ NSString stringWithFormat:@"%d",row + 1];
    }else if (component == 1) { //year
        return [self.yearSelection objectAtIndex:row];
    }else{}
    return nil;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0) {
        return 40.0;
    }else if (component == 1) {
        return 100.0;
    } else {
    }
    return 0;
    
}

- (void)handleChooseDate
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Chọn ngày hết hạn"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    CGRect pickerFrame = CGRectMake(0, 40, 320, 120);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.tag = 123;
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    
    [actionSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Chọn"]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260.0f, 7.0f, 50.0f, 30.0f);
    
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:closeButton];
    [closeButton release];
    
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [actionSheet setBounds:CGRectMake(0, 0, 320, 365)];
    [actionSheet release];
}

- (void)dismissActionSheet:(id)sender
{
    UIActionSheet* acsheet = (UIActionSheet*)[sender superview];
    UIPickerView* picker = (UIPickerView*)[acsheet viewWithTag:123];
    NSInteger month = [picker selectedRowInComponent:0] + 1;
    NSInteger year = [[self.yearSelection objectAtIndex:[picker selectedRowInComponent:1]] integerValue];
    if (month < 10) {
        [tvExpiredDate setText:[NSString stringWithFormat:@"0%d/%d", month, year]];
    }
    else
    {
         [tvExpiredDate setText:[NSString stringWithFormat:@"%d/%d", month, year]];
    }
    [acsheet dismissWithClickedButtonIndex:0 animated:YES];
    
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
        lblTitleThanhToan.text = THANHTOAN_TITLE_INFO_VISA_CREDIT_CARD;
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
                [tvAccountName layoutWithRadius:CORNER_RADIUS_TEXT_BOX_ACCOUNT andImageIcon:nil hoderText:TEXT_LABLE_TIP_INPUT_CARD_HOLDER_CC];
                [tvAccountName setKeyBoardType:UIKeyboardTypeAlphabet];
                [tvAccountName setKeyBoardReturnKeyType:UIReturnKeyDone];
                [tvAccountName setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
                [tvAccountName setAcceptAnsciiCharacterOnly:YES];
                delegate._CardHolder = [APIManager getStringInAppForKey:KEY_STORE_CARD_HOLDER_VISA];
                [cell.contentView addSubview:tvAccountName];
                break;
            }
            case SECTION_CARD_NUMBER:
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
                tvAccountNo = [[CustomTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 2*MARGIN_EDGE_TABLE_GROUP, height) inputType:INPUT_TYPE_SEPERATION];
                [tvAccountNo setDelegate:[MainViewController sharedMainViewController]];
                [tvAccountNo layoutWithRadius:CORNER_RADIUS_TEXT_BOX_ACCOUNT andImageIcon:nil hoderText:@"Số tài khoản"];
                [tvAccountNo setKeyBoardType:UIKeyboardTypeNumberPad];
                [tvAccountNo setMinCharacter:[MIN_CHARACTER_CARD_NUMBER intValue]];
                [tvAccountNo setMaxCharacter:[MAX_CHARACTER_CARD_NUMBER intValue]];
                delegate._CardNumber = [APIManager getStringInAppForKey:KEY_STORE_CARD_NUMBER_VISA];
                [cell.contentView addSubview:tvAccountNo];
                break;
            }
            case SECTION_SECURITY:
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                cell.backgroundView = [[[UIView alloc] init] autorelease];
                cell.backgroundColor = [UIColor clearColor];
                CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
                // text expire card
                tvExpiredDate = [[CustomTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 2 - (2 * MARGIN_EDGE_TABLE_GROUP), height)];
                [tvExpiredDate setDelegate:[MainViewController sharedMainViewController]];
                [tvExpiredDate layoutWithRadius:MARGIN_CELL_SESSION andImageIcon:nil hoderText:THANHTOAN_TITLE_TIP_EXPIRE_DATE];
                [tvExpiredDate setKeyBoardType:UIKeyboardTypeNumberPad];
                tvExpiredDate.backgroundColor = [UIColor whiteColor];
                tvExpiredDate.layer.borderWidth = 1.0;
                tvExpiredDate.layer.borderColor = layoutTable.separatorColor.CGColor;
                [tvExpiredDate setEnable: NO];                
                UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChooseDate)];
                [tvExpiredDate addGestureRecognizer:tapRecognizer];
                [cell.contentView addSubview:tvExpiredDate];
                [tapRecognizer release];
                // text enter secure code
                tvSecrectedCode = [[CustomTextView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2 - (2 * MARGIN_EDGE_TABLE_GROUP), height) inputType:INPUT_TYPE_PASSWORD];
                [tvSecrectedCode setDelegate:[MainViewController sharedMainViewController]];
                [tvSecrectedCode layoutWithRadius:MARGIN_CELL_SESSION andImageIcon:nil hoderText:@"CVV"];
                [tvSecrectedCode setKeyBoardType:UIKeyboardTypeNumberPad];
                tvSecrectedCode.tag = 3;
                tvSecrectedCode.backgroundColor = [UIColor whiteColor];
                tvSecrectedCode.layer.borderWidth = 1.0;
                tvSecrectedCode.layer.borderColor = layoutTable.separatorColor.CGColor;
                [tvSecrectedCode setMinCharacter:3];
                [tvSecrectedCode setMaxCharacter:3];
                [cell.contentView addSubview:tvSecrectedCode];
                break;

            }
            case SECTION_CHECKBOX_UI:
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                [self layoutCheckBoxRemememberAccount:cell];
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
    if (indexPath.section == SECTION_CARD_HOLDER)
    {
        if (delegate._CardHolder) {
            [tvAccountName setText:delegate._CardHolder];
        }
    }
    else if(indexPath.section == SECTION_CARD_NUMBER)
    {
        if (delegate._CardNumber) {
            [tvAccountNo setMaskRange:NSMakeRange(0, [delegate._CardNumber length] - 4)];
            [tvAccountNo setText:delegate._CardNumber];
        }
    }
    else if (indexPath.section == SECTION_SECURITY)
    {
        [tvExpiredDate setText:[APIManager getStringInAppForKey:KEY_STORE_EXPIRE_DATE_VISA]];
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
    if (cbRemember) {
        [cbRemember release];
        cbRemember = nil;
    }
    cbRemember = [[UICheckBox alloc] initWithTitle:STRING_SAVE_ACCOUNT_VISA colorTitle:[UIColor grayColor]];
    [cbRemember setIsChecked:[APIManager getValueAsBoolForKey:KEY_STORE_IS_REMEMBER_ACCOUNT_THANHTOAN_VISA]];
    [cell.contentView  addSubview:cbRemember];
    UIView *viewBG = [[UIView alloc] init];
    [viewBG setBackgroundColor:[UIColor clearColor]];
    [viewBG setFrame:cell.frame];
    [cell setBackgroundView:viewBG];
    [viewBG release];
}

-(void)layoutButtonAction:(UITableViewCell *)cell
{
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"segment_selected_hl" ofType:@"png"];
    UIImage *imageLeft = [[UIImage alloc] initWithContentsOfFile:thePath];
    UIButton *btnThanhToan = [[UIButton alloc]init];
    CGRect frame = CGRectMake((cell.frame.size.width - imageLeft.size.width)/2, 0, imageLeft.size.width, imageLeft.size.height);
    btnThanhToan.frame = frame;
    [btnThanhToan setImage:imageLeft forState:UIControlStateNormal];
    [imageLeft release];
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

#pragma makr tableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        //process select type account to pay
    }
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
    if (indexPath.section == SECTION_INFO)
    {
        if (indexPath.row == 1)
        {
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
    if (tvSecrectedCode) {
        [tvSecrectedCode resignFirstResponder];
    }
    if (tvExpiredDate) {
        [tvExpiredDate resignFirstResponder];
    }
}

#pragma mark handle action Thanh Toan
-(void)processActionThanhToan
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (![tvAccountName hasText]) {
        [tvAccountName becomeFirstResponder];
        return;
    }
    else if (![tvAccountNo hasText])
    {
        [tvAccountNo becomeFirstResponder];
        return;
    }
    else if (![tvSecrectedCode hasText])
    {
        [tvSecrectedCode becomeFirstResponder];
        return;
    }
    if (![tvExpiredDate hasText])
    {
        [tvExpiredDate becomeFirstResponder];
        return;
    }
    else
    {
        [self checkAndGetFormatExpireDate];
    }
    delegate._CardHolder = [tvAccountName getText];
    delegate._CardNumber = [tvAccountNo getText];
    delegate._CardCVV = [tvSecrectedCode getText];
    
    if (![self isDataValid]) {
        if (idErrorTypeCard == 0) {
            [self showMessageDialogInfo:ERROR_DESCRIPTION_WRONG_LENG_CARD withTag:-1];
        }
        else if(idErrorTypeCard == 1)
        {
            [self showMessageDialogInfo:ERROR_DESCRIPTION_WRONG_EXPIRE_DATE withTag:-1];
        }
        else
        {
        }
        return;
    }
    // send log to 123phim server
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:@""
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_TICKET_CLICK_CHECKOUT
                                                     currentFilmID:self.buyInfo.chosenSession.film_id
                                                   currentCinemaID:self.buyInfo.chosenSession.cinema_id
                                                         sessionId:self.buyInfo.chosenSession.session_id
                                                   returnCodeValue:0
                                                           context:nil];
    
//    [self checkAndSaveInfo];
    //Duyln kiem tra step da lam roi thi khong lam nua tranh error thanhToan khi back
    [self executeRequestThanhToanBaseOnStep];
}

-(void)checkAndGetFormatExpireDate
{
    if ([tvExpiredDate hasText])
    {
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        NSArray *array = [[tvExpiredDate getText] componentsSeparatedByString:@"/"];
        if (array.count == 2) {
            int month = [[array objectAtIndex:0] intValue];
            NSString *strMonth = [NSString stringWithFormat:@"%d",month];
            if (month < 10) {
                strMonth = [NSString stringWithFormat:@"0%d",month];
            }
            delegate._CardMonthExpire = strMonth;
            NSString *strYear = [array objectAtIndex:1];
            if (strYear.length == 4) {
                delegate._CardYearExpire = [strYear substringFromIndex:2];
            } else {
                delegate._CardYearExpire = strYear;
            }
            
        }
    }
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
        [self checkAndGetFormatExpireDate];
        
        //Send info to save on server
        [APIManager setBoolValue:YES ForKey:KEY_STORE_IS_REMEMBER_ACCOUNT_THANHTOAN_VISA];
        //save card number and card holder
        [APIManager setStringInApp:delegate._CardNumber ForKey:KEY_STORE_CARD_NUMBER_VISA];
        [APIManager setStringInApp:delegate._CardHolder ForKey:KEY_STORE_CARD_HOLDER_VISA];
        NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *components = [calendar components:NSYearCalendarUnit fromDate:[NSDate date]];
        NSInteger year = [components year];
        NSString *stringYear = [NSString stringWithFormat:@"%d", year];
        if (stringYear.length > 3) {
            [APIManager setStringInApp:[NSString stringWithFormat:@"%@/%@%@", delegate._CardMonthExpire,[stringYear substringToIndex:2],delegate._CardYearExpire] ForKey:KEY_STORE_EXPIRE_DATE_VISA];

        } else {
            [APIManager setStringInApp:[NSString stringWithFormat:@"%@/%@", delegate._CardMonthExpire,delegate._CardYearExpire] ForKey:KEY_STORE_EXPIRE_DATE_VISA];
        }
    } else {
        [APIManager setBoolValue:NO ForKey:KEY_STORE_IS_REMEMBER_ACCOUNT_THANHTOAN_VISA];
        //save card number and card holder
        [APIManager setStringInApp:@"" ForKey:KEY_STORE_CARD_NUMBER_VISA];
        [APIManager setStringInApp:@"" ForKey:KEY_STORE_CARD_HOLDER_VISA];
        [APIManager setStringInApp:@"" ForKey:KEY_STORE_EXPIRE_DATE_VISA];
    }
}

-(void)executeRequestThanhToanBaseOnStep
{
    [self showLoadingScreenWithType:LOADING_TYPE_FULLSCREEN];
    [[APIManager sharedAPIManager] thanhToanRequestVerifyCardM:self.buyInfo.chosenSeatInfoList sessionID:self.buyInfo.chosenSession.session_id.intValue context:self];
}

#pragma mark - ASIHttpRequestDelegate
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    if(request.tag == ID_REQUEST_THANHTOAN_VERIFY_ATM)
    {
//        NSLog(@"responseString verify ATM = %@", [request responseString]);
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

#pragma mark Parse to get result response from server
-(void)parseToGetResultVerifyCardM:(NSString *)response
{
//    NSLog(@"--result verify cardM = %@", response);
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
    NSDictionary *dicObject = [[APIManager sharedAPIManager].parser objectWithString:response error:nil];
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
            appDelegate._OrderNo = [dicVerify objectForKey:@"orderNo"];
            
            int value = 0;
            dataTemp = [dicVerify objectForKey:@"useOTP"];
            if ([[APIManager sharedAPIManager] isValidData:dataTemp] && [dataTemp isKindOfClass:[NSNumber class]])
            {
                value = [dataTemp intValue];
            }
            if (value == 1)
            {
#if (USING_ATM_INPUT_VIEW_CONTROLLER)
                NSString *fullPath = [NSString stringWithFormat:@"%@/masterInfo.txt", BUNDLE_PATH];
                NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fullPath];
                BankInfo *bankInfo = [[BankInfo alloc] init];
                bankInfo.dicBankInfo = dict;
                NSDictionary *bankData = [NSDictionary dictionaryWithObjectsAndKeys:[self.tvAccountName getText], @"cardHolderName", [self.tvAccountNo getText], @"cardNumber", nil];
                ConfirmInputViewController *vcConfirm = [[ConfirmInputViewController alloc] init];
                [vcConfirm setIsMasterConfirm:YES];
                [vcConfirm setBankData:bankData];
                [vcConfirm setBuyInfo:self.buyInfo];
                [vcConfirm setBankInfo:bankInfo];
                [bankInfo release];
                [self.navigationController pushViewController:vcConfirm animated:YES];
                [vcConfirm release];
#else
                //push view verify OTP
                VerifyATMByOTPViewController *verifyView = [[VerifyATMByOTPViewController alloc] init];
                [verifyView setBuyInfo:self.buyInfo];
//                    [verifyView setRedirectLinkCreditCard:dataTemp];
                [verifyView setIsTypeBIDV:NO];
                [self.navigationController pushViewController:verifyView animated:YES];
                [verifyView release];
#endif
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
        [self hideLoadingView];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        //    {"transaction_id":"2049",
        //        "customer_id":"43",
        //        "invoice_no":"20130606103708157218",
        //        "responseCode": (0, 1, -1),  trong đó 0 là tiếp tục chờ, 1 là thành công (có ticket_code), -1 là thất bại
        //        "ticket_code":"10213060646870"}
        int thanhtoan_status = [[getData objectForKey:@"responseCode"] integerValue];
        if (thanhtoan_status == 0)//cho xu ly
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
    [resultSucessViewController release];
}

#pragma mark alertView delegate
-(void)showMessageDialogInfo:(NSString *)des withTag:(int)tag
{
    [self hideLoadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:des delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
//    //    NSLog(@"migSURL = %@, content = %@", migsURL, content);
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
//    //    NSLog(@"-------------start load web-------------");
//    [_webView loadRequest:request];
//    [request release];
//}

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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//	NSLog(@"%@ - %@",request.HTTPMethod, request.URL);
	NSString *sPattern123P = THANH_TOAN_VISA_PATTERN_123PAY;
    NSString *sURL = [request.URL absoluteString];
    
    NSRange range123P = [sURL rangeOfString:sPattern123P];
    NSRange rangeMIGS = [sURL rangeOfString:THANH_TOAN_VISA_PATTERN_MIGS];
	
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
//    NSLog(@"----- link tra ve = %@", sURL);

    NSString *sPatternSuccess = THANH_TOAN_PATTERN_SUCESS_123PAY;
	
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
        [parser release];
		_webView.hidden = YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark check data valid
-(BOOL)isDataValid
{
    idErrorTypeCard = 0;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate._CardNumber.length < [MIN_CHARACTER_CARD_NUMBER intValue] || appDelegate._CardNumber.length > [MAX_CHARACTER_CARD_NUMBER intValue])
    {
        return NO;
    }
    idErrorTypeCard = 1;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components: NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    [calendar release];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSString *temp = [[NSString stringWithFormat:@"%d", year] substringFromIndex:2];
    
    
    if([appDelegate._CardYearExpire integerValue] < [temp integerValue])
    {
        return NO;
    }
    else if([appDelegate._CardYearExpire integerValue] == [temp integerValue])
    {
        if ([appDelegate._CardMonthExpire integerValue] < month)
        {
            return NO;
        }
    }
    return YES;
}
@end
