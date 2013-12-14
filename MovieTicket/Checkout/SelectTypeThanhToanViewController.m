//
//  SelectTypeThanhToanViewController.m
//  123Phim
//
//  Created by Le Ngoc Duy on 4/25/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
typedef enum
{
    SECTION_INFO = 0,
    SECTION_EMAIL,
    SECTION_MOBILE,
    SECTION_TYPE_THANHTOAN,
    SECTION_LOGIN,
    MAX_SECTION_TABLE
}ENUM_TYPE_THANH_TOAN_SECTION;

#define TAG_ALERT_BLOCK_SEAT_FAIL 501

#import "SelectTypeThanhToanViewController.h"
#import "SelectTypeATMViewController.h"
#import "MainViewController.h"
#import "CinemaNoteCell.h"
#import "CellInfoThanhToan.h"
#import <AddressBook/AddressBook.h>
#import "ThanhToanVisaViewController.h"
#import "FacebookManager.h"
#import "ProfileTableViewCell.h"
#import "ATMInputViewController.h"
#import "SelectBankViewController.h"
#import "NSDictionary+FileHandler.h"
#import "VisaInputViewController.h"
#import "PlusViewController.h"
@interface SelectTypeThanhToanViewController ()

@end

@implementation SelectTypeThanhToanViewController
@synthesize layoutTable;
@synthesize buyInfo = _buyInfo;
@synthesize tvEmail, tvPhone;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        viewName = SELECT_THANHTOAN_TYPE_VIEW_NAME;
        self.isSkipWarning = YES;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self resetValueForAccount];
    [super viewWillAppear:animated];
    isRequestTypeATM = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollTable:layoutTable toRow:0 inSection:SECTION_MOBILE];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (tvEmail && [tvEmail hasText]) {
        [APIManager setStringInApp:[tvEmail getText] ForKey:KEY_STORE_USER_EMAIL];
    }
    if (tvPhone && [tvPhone hasText]) {
        [APIManager setStringInApp:[tvPhone getText] ForKey:KEY_STORE_USER_PHONE];
    }
}

- (void) resetValueForAccount
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.Invoice_No = @"";
    delegate.ticket_code = @"";
    delegate._TransactionID = @"";
}

-(void)scrollTable:(UITableView *)myTable toRow:(int)row inSection:(int)section
{
    if (myTable == nil) {
        return;
    }
    
    NSInteger num = [myTable numberOfRowsInSection:0];
    NSInteger height = 0;
    for (int i = 0; i < num; i++) {
        height += [self tableView:myTable heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [myTable setContentOffset:CGPointMake(0, height) animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:_buyInfo.chosenFilm.film_name];
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    // add layout table
    [self initLayoutTable];
    [self.view addSubview:self.layoutTable];
    self.trackedViewName = viewName;
    
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureTapOnView:)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
}

-(void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    SAFE_RELEASE(_bankListInfo)
    self.buyInfo = nil;
}

- (void)initLayoutTable
{
    //init layouttable
    CGFloat tableHeight = [[UIScreen mainScreen] bounds].size.height - NAVIGATION_BAR_HEIGHT - TITLE_BAR_HEIGHT;
    layoutTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableHeight) style:UITableViewStyleGrouped];
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
    return (SECTION_LOGIN + 1);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_INFO) {
        return 2;
    }
    if (section == SECTION_TYPE_THANHTOAN) {
#ifdef IS_SUPPORT_PLUS
        return 3;
#else
        return 2;
#endif
    }
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        //Layout title tip
        CGFloat xStar = MARGIN_EDGE_TABLE_GROUP + 5;
        CGFloat yStar = 0;
        UIView* ret = [[UIView alloc] init];
        UILabel *lblTitleThanhToan = [[UILabel alloc] init];
        [lblTitleThanhToan setFont:[UIFont getFontBoldSize18]];
        [lblTitleThanhToan setBackgroundColor:[UIColor clearColor]];
        [lblTitleThanhToan setTextColor:[UIColor blackColor]];
        lblTitleThanhToan.text = THANHTOAN_TITLE_INFO_USER;
        CGSize sizeTextTitle = [lblTitleThanhToan.text sizeWithFont:lblTitleThanhToan.font];
        CGFloat widthText = self.view.frame.size.width - 2*(MARGIN_EDGE_TABLE_GROUP + 5);
        [lblTitleThanhToan setFrame:CGRectMake(xStar, yStar, widthText, sizeTextTitle.height)];
        
        //layout tipe
        UILabel *lblTip = [[UILabel alloc] init];
        [lblTip setFont:[UIFont getFontNormalSize13]];
        [lblTip setTextColor:[UIColor colorWithWhite:0.1 alpha:0.4]];
        lblTip.text = TIP_THANHTOAN_INPUT_INFO;
        [lblTip setBackgroundColor:[UIColor clearColor]];
        lblTip.numberOfLines = 2;
        CGSize sizeText = [@"ABC" sizeWithFont:lblTip.font];
        [lblTip setFrame:CGRectMake(xStar, yStar + sizeTextTitle.height, widthText, 2*sizeText.height)];
        
        [ret addSubview:lblTitleThanhToan];
        [ret addSubview:lblTip];
        return ret;
    }
    else if(section == SECTION_TYPE_THANHTOAN)
    {
        UIView* ret = [[UIView alloc] init];
        UILabel *lblTitleType = [[UILabel alloc] init];
        [lblTitleType setFont:[UIFont getFontBoldSize18]];
        [lblTitleType setBackgroundColor:[UIColor clearColor]];
        [lblTitleType setTextColor:[UIColor blackColor]];
        lblTitleType.text = THANHTOAN_TITLE_INFO_TYPE;
        CGSize sizeText = [lblTitleType.text sizeWithFont:lblTitleType.font];
        [lblTitleType setFrame:CGRectMake(MARGIN_EDGE_TABLE_GROUP + 5, MARGIN_EDGE_TABLE_GROUP/2, sizeText.width, sizeText.height)];
        [ret addSubview:lblTitleType];
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
                    cell =  [[CellInfoThanhToan alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [(CellInfoThanhToan *)cell layoutInfoCell:self.buyInfo];
                }
                break;
            }
            case SECTION_MOBILE:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
                tvPhone = [[CustomTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 2*MARGIN_EDGE_TABLE_GROUP, height) inputType:INPUT_TYPE_PHONE];
                [tvPhone setDelegate:[MainViewController sharedMainViewController]];
                [tvPhone layoutWithRadius:CORNER_RADIUS_TEXT_BOX_ACCOUNT andImageIcon:nil hoderText:@"Số điện thoại"];
                [tvPhone setKeyBoardType:UIKeyboardTypeNumberPad];
                tvPhone.tag = 0;
                [tvPhone setBackgroundColor:[UIColor clearColor]];
                [tvPhone setMinCharacter:[MIN_CHARACTER_PHONE_NUMBER intValue]];
                [tvPhone setMaxCharacter:[MAX_CHARACTER_PHONE_NUMBER intValue]];
                delegate.phone = [APIManager getStringInAppForKey:KEY_STORE_USER_PHONE];
                if (delegate.phone) {
                    [tvPhone setText:delegate.phone];
                }                
                [cell.contentView addSubview:tvPhone];
                break;
            }
            case SECTION_EMAIL:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
                tvEmail = [[CustomTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 2*MARGIN_EDGE_TABLE_GROUP, height) inputType:INPUT_TYPE_EMAIL];
                [tvEmail setDelegate:[MainViewController sharedMainViewController]];
                [tvEmail layoutWithRadius:CORNER_RADIUS_TEXT_BOX_ACCOUNT andImageIcon:nil hoderText:@"Email"];
                [tvEmail setKeyBoardType:UIKeyboardTypeEmailAddress];
                tvEmail.tag = 1;
                [tvEmail setAutocapitalizationType:UITextAutocapitalizationTypeNone];
                [tvEmail setKeyBoardReturnKeyType:UIReturnKeyDone];
                [tvEmail setAcceptAnsciiCharacterOnly:YES];
                
                delegate.email = [APIManager getStringInAppForKey:KEY_STORE_USER_EMAIL];
                if (delegate.userProfile.email && delegate.userProfile.email.length > 0) {
                    [tvEmail setText:delegate.userProfile.email];
                } else {
                    if (delegate.email) {
                        [tvEmail setText:delegate.email];
                    }
                }
                [cell.contentView addSubview:tvEmail];
                break;
            }
            case SECTION_TYPE_THANHTOAN:
            {
                if (indexPath.row <= 1)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    cell.textLabel.font = [UIFont getFontBoldSize12];
                    if (indexPath.row == 0)
                    {
                        cell.textLabel.text = @"Visa / Master";
                    }
                    else if (indexPath.row == 1)
                    {
                        cell.textLabel.text = @"Thẻ ATM";
                    }
                }
                else
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
                    cell.textLabel.font = [UIFont getFontBoldSize12];
                    [cell.textLabel setText:@"Thanh toán bằng điểm Plus"];
                    [cell.detailTextLabel setText:@"Tìm hiểu về điểm Plus tại plus.123pay.vn"];
                }
                break;
            }
            case SECTION_LOGIN:
            {
                cell = [[ProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                ((ProfileTableViewCell*)cell).text = SELECT_TYPE_THANH_TOAN_LOGIN_DESC;
                [cell layoutIfNeeded];
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center addObserver:self selector:@selector(didLoadUserProfile:) name:NOTIFICATION_NAME_PROFILE_CELL_USER_PROFILE_DID_LOAD object:nil];
            }
            default:
                break;
        }
    }
    if (indexPath.section == SECTION_TYPE_THANHTOAN) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return cell;
}

-(void)setActiveInputView:(CustomTextView *)inputView
{
    if (inputView.tag == 1) {
        // send log to 123phim server
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:self.viewName
                                                              comeFrom:delegate.currentView
                                                          withActionID:ACTION_TICKET_PUT_USER_INFO
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
    if (indexPath.section == 3) {
        if (tvEmail && ![tvEmail isInputValidationAndShowErrorAlert:YES])
        {
            [tvEmail becomeFirstResponder];
            return;
        }
        if (tvPhone && ![tvPhone isInputValidationAndShowErrorAlert:YES]) {
            [tvPhone becomeFirstResponder];
            return;
        }
        [APIManager setStringInApp:[tvEmail getText] ForKey:KEY_STORE_USER_EMAIL];
        [APIManager setStringInApp:[tvPhone getText] ForKey:KEY_STORE_USER_PHONE];
        if (indexPath.row == 1)
        {
            isRequestTypeATM = YES;
        }
        else if (indexPath.row == 0)
        {
            isRequestTypeATM = NO;
        }
        else
        {
            PlusViewController *plus = [[PlusViewController alloc] initWithNibName:@"PlusViewController" bundle:[NSBundle mainBundle]];
            [plus setBuyInfo:self.buyInfo];
            [self.navigationController pushViewController:plus animated:YES];
            return;
        }
        [self pushTypeThanhToanViewController];
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
    if (section == 1)
    {
        CGFloat height = [@"ABC" sizeWithFont:[UIFont getFontBoldSize18]].height;
        height += [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]].height;
        return (height + 2*MARGIN_EDGE_TABLE_GROUP + MARGIN_EDGE_TABLE_GROUP/2);
    }
    if (section == 3)
    {
        return ([@"ABC" sizeWithFont:[UIFont getFontBoldSize18]].height + MARGIN_EDGE_TABLE_GROUP);
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            CGFloat height = [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]].height;
            height += [@"ABC" sizeWithFont:[UIFont getFontBoldSize12]].height;
            return (height + 2*MARGIN_EDGE_TABLE_GROUP);
        }
        return 60 + 2*MARGIN_CELL_SESSION;
    }
    
    if (indexPath.section == SECTION_LOGIN)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([app isUserLoggedIn])
        {
            return PROFILE_CELL_DID_LOAD_HEIGHT;
        }
        return PROFILE_CELL_NOT_LOAD_HEIGHT;
    }
    if (indexPath.section == SECTION_TYPE_THANHTOAN) {
        return (3*MARGIN_EDGE_TABLE_GROUP + [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]].height);
    }
    
    return (2*MARGIN_EDGE_TABLE_GROUP + [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]].height);
}

#pragma mark handle touch event
-(void)handleGestureTapOnView:(UIGestureRecognizer*)gesture
{
    if (tvPhone) {
        [tvPhone resignFirstResponder];
    }
    if (tvEmail)
    {
        [tvEmail resignFirstResponder];
    }    
}

#pragma mark - get user contact list
- (NSArray*)getListOfUserContact
{
    NSMutableArray* retArray = [[NSMutableArray alloc] init];
    
    ABAddressBookRef addressBook = ABAddressBookCreate( );
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
    CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
    CFRelease(addressBook);
    NSString* phone = nil;
    for ( int i = 0; i < nPeople; i++ )
    {
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        if (phoneNumbers) {
            if (ABMultiValueGetCount(phoneNumbers) > 0) {
                phone = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, 0));
                [retArray addObject:phone];
            }
        }
        
    }
    return retArray;
}

#pragma mark Push ViewController depend on type of thanhtoan
-(void)pushThanhToanVisaViewController
{
    //             via Visa / Master card
    NSArray *bankList = [[APIManager sharedAPIManager]getBankListWithDictionary:_bankListInfo];
    NSDictionary *loadInfo = [APIManager getBankInfoForATM:NO];
    NSString *loadBankCode = BANK_CODE_VISA_MASTER;
    BankInfo *visaBank = nil;
    for (BankInfo *bankInfo in bankList)
    {
        if ([bankInfo.bank_code isEqualToString:loadBankCode])
        {
            visaBank = bankInfo;
            break;
        }
    }
    if (visaBank && [visaBank.bank_code isEqualToString:loadBankCode] && visaBank.bank_status == BANK_STATUS_VISA_AVAILABLE)
    {
        
        VisaInputViewController *inputView = [[VisaInputViewController alloc] init];
        [inputView setLoadInfo:loadInfo];
        [inputView setBuyInfo: self.buyInfo];
        [inputView setBankInfo:visaBank];
        [self.navigationController pushViewController:inputView animated:YES];
        return;
    }
    NSString *desc = @"Maintaining";
    if (visaBank && visaBank.bankStatusDesc)
    {
        desc = visaBank.bankStatusDesc;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:desc delegate:nil cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil];
    [alert show];
}

-(void)pushSelectTypeATMViewController
{
    //            via ATM card
    NSArray *bankList = [[APIManager sharedAPIManager]getBankListWithDictionary:_bankListInfo];
    NSDictionary *loadInfo = [APIManager getBankInfoForATM:YES];
    if (loadInfo)
    {
        NSString *loadBankCode = [loadInfo objectForKey:BANK_INFO_KEY_CODE];
        for (BankInfo *bankInfo in bankList)
        {
            if ([bankInfo.bank_code isEqualToString:loadBankCode] && bankInfo.bank_status == BANK_STATUS_ATM_AVAILABLE)
            {
                // check bankinfo
                ATMInputViewController *inputView = [[ATMInputViewController alloc] init];
                [inputView setBuyInfo: self.buyInfo];
                [inputView setLoadInfo:loadInfo];
                [inputView setBankInfo:bankInfo];
                [inputView setBankList:bankList];
                [self.navigationController pushViewController:inputView animated:YES];
                return;
            }
        }
    }
    SelectBankViewController *bankView = [[SelectBankViewController alloc] init];
    [bankView setBankList:bankList];
    [bankView setBuyInfo: self.buyInfo];
    [self.navigationController pushViewController:bankView animated:YES];
}

-(void)pushTypeThanhToanViewController
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setEmail:[tvEmail getText]];
    [appDelegate setPhone:[tvPhone getText]];
    
    if(isRequestTypeATM)
    {
        [self pushSelectTypeATMViewController];
    }
    else
    {
        [self pushThanhToanVisaViewController];
    }
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:@"SelectTypeThanhToanViewController"
                                                      comeFrom:delegate.currentView
                                                  withActionID:ACTION_TICKET_SELECT_CHECKOUT_TYPE
                                                 currentFilmID:self.buyInfo.chosenSession.film_id
                                               currentCinemaID:self.buyInfo.chosenSession.cinema_id
                                                     sessionId:self.buyInfo.chosenSession.session_id
                                               returnCodeValue:0 context:nil];
}


#pragma mark -
#pragma mark RKManagerDelegate
#pragma mark -
-(void)processResultResponseDictionaryMapping:(DictionaryMapping *)dictionary requestId:(int)request_id
{
    if (request_id == ID_REQUEST_THANHTOAN_GET_LIST_BANK) {
        [self getResultBankListResponse:dictionary.curDictionary];
    }
}

- (void)getResultBankListResponse:(NSDictionary *)newVersion
{
    if (newVersion)
    {
        BOOL upgrade = YES;
        if (_bankListInfo)
        {
            NSNumber *version = [newVersion objectForKey:@"version"];
            NSNumber *curVersion = [_bankListInfo objectForKey:@"version"];
            if (version && version.integerValue == curVersion.integerValue)
            {
                upgrade = NO;
            }
        }
        if (upgrade)
        {
            SAFE_RELEASE(_bankListInfo);
            _bankListInfo = newVersion;
            [self performSelectorInBackground:@selector(saveBankListInfo) withObject:nil];
        }
    }
    [self hideLoadingView];
}
#pragma mark process login Facebook
-(void)didLoadFacebookAccount:(NSNotification*) notificationInfo
{
    [[APIManager sharedAPIManager] getRequestLoginFaceBookAccountWithContext:[APIManager sharedAPIManager]];
}

-(void)didLoadUserProfile: (NSNotification*) notification
{
    [layoutTable reloadData];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (tvEmail)
    {
        [tvEmail setText:app.email];
    }
    if (tvPhone)
    {
        [tvPhone setText:app.phone];
    }
    [self hideLoadingView];
}

-(void)saveBankListInfo
{
    if (_bankListInfo)
    {
        [_bankListInfo saveTofile:BANK_LIST_INFO_NAME path:BANK_INFO_DIR];
    }
}

-(void)setBuyInfo:(BuyingInfo *)buyInfo
{
    SAFE_RELEASE(_buyInfo);
    if (buyInfo)
    {
        _buyInfo = buyInfo;
        NSString *fileName = [NSString stringWithFormat:@"%@/%@", BANK_INFO_DIR, BANK_LIST_INFO_NAME];
        _bankListInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:fileName];
        NSString * version = @"0";
        if (_bankListInfo)
        {
            version = [_bankListInfo objectForKey:@"version"];
        }
        [[APIManager sharedAPIManager] getListBankingWithVerion:version context:self];
        [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR];
    }
}
@end
