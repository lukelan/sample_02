//
//  CheckoutResultViewController.m
//  123Phim
//
//  Created by Nhan Mai on 5/9/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#define HEIGHT_TICKET_ROW 110

#import "CheckoutResultViewController.h"
#import "MainViewController.h"
#import "CinemaNoteCell.h"
#import "CellInfoThanhToan.h"
#import "SeatInfo.h"
#import "AppDelegate.h"
#import "APIManager.h"
#import "FacebookManager.h"
#import "BarCodeViewController.h"

@interface CheckoutResultViewController ()

@end

@implementation CheckoutResultViewController

@synthesize layoutTable;
@synthesize buyInfo = _buyInfo;
@synthesize ticketInfo;
@synthesize isCommingFromTicketList;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        isCommingFromTicketList = NO;
        statusThanhToan = STATUS_RESULT_SUCCESS;
        id status = [APIManager getValueForKey:KEY_STORE_STATUS_THANH_TOAN];
        if (status && [status isKindOfClass:[NSNumber class]]) {
            if([status intValue]< STATUS_OUT_RANGE && [status intValue] >= STATUS_WAITING_RESULT)
            {
                statusThanhToan = [status intValue];
            }
        }
        self.isSkipWarning = YES;
    }
    return self;
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
    if (!isCommingFromTicketList) {
        //xu ly luu xuong database
        [self processActionSaveTicketToDatabase];
        [self saveTicketToDatabase];
        [self onPurchaseCompleted];
    }
    
    //quay ve trang main
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate popToViewController:[MainViewController class] animated:YES];
}

- (void)handleSupportButton
{
//    LOG_123PHIM(@"handleSupportButton");
    NSString *phoneNumber = [@"tel://" stringByAppendingString:@"1800585888"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

-(void)btnShareClick: (id) sender
{    
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:delegate.currentView
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_TICKET_SHARE
                                                     currentFilmID:self.buyInfo.chosenFilm.film_id
                                                   currentCinemaID:self.buyInfo.chosenCinema.cinema_id
                                                         sessionId:self.buyInfo.chosenSession.session_id
                                                   returnCodeValue:0 context:nil];
    
    CGSize size = CGSizeMake(320, self.view.frame.size.height - 216); // 216: keyboar height
    FBMessageView *shareView = [[FBMessageView alloc] initWithFrame:CGRectMake(320, - size.height, size.width, size.height)];
    shareView.backgroundColor = [UIColor darkGrayColor];
    NSString *cinemaName= ticketInfo.cinema_name;
    NSString *timedate = [NSDate getStringFormatedFromTimeTamp:ticketInfo.date_show.doubleValue clockPattern:@"HH:mm" datePattern:@"dd/MM/YYYY" seperatorString:@" ngày " replaceTodayString:nil];
    NSString *url = ticketInfo.film_url;
    if (!url || url.length == 0)
    {
        Film *film = [((AppDelegate*)[[UIApplication sharedApplication] delegate]) getFilmWithID:ticketInfo.film_id];
        if (film)
        {
            url = film.film_url;
        }
    }
    NSString *strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormatter setDateFormat:@"dd/MM/yyy"];
    NSDate *showDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[ticketInfo.date_show integerValue]];
    strDate = [dateFormatter stringFromDate:showDate];
    if (url && url.length > 0 && strDate && strDate.length > 0)
    {
        url = [url stringByAppendingFormat:@"&date=%@",strDate];
    }
    [shareView setFilmUrl:url];
    shareView.defaultString = [NSString stringWithFormat:@"Đã mua vé thành công qua 123Phim.\n- Suất chiếu lúc: %@\n- Tại rạp: %@", timedate, cinemaName];
    shareView.controller = self;
    [self.view addSubview:shareView];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = shareView.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        shareView.frame = frame;
    } completion:^(BOOL finished) {
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (isCommingFromTicketList) {
        [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    } else {
        [self setCustomBackButtonForNavigationItem];
    }
    [delegate setTitleLabelForNavigationController:self withTitle:self.buyInfo.chosenFilm.film_name];
    if ([delegate isUserLoggedIn])
    {
        UIImage *imageRight = [UIImage imageNamed:@"header-button-share.png"];
        UIButton *customButtonR = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(0, 0, imageRight.size.width, imageRight.size.height);
        customButtonR.frame = frame;
        [customButtonR setBackgroundImage:imageRight forState:UIControlStateNormal];
        [customButtonR addTarget:self action:@selector(btnShareClick:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *btnRight = [[UIBarButtonItem alloc] initWithCustomView:customButtonR];
        self.navigationItem.rightBarButtonItem = btnRight;
    }

    [self initLayoutTable];
    
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    
    [delegate setTitleLabelForNavigationController:self withTitle:@"Vé đã mua"];
    
    // add layout table
    [self.view addSubview:self.layoutTable];
    if (isCommingFromTicketList) {
        viewName = DETAIL_TICKET_VIEW_NAME;
    } else {
        viewName = SUCCESS_CHECK_OUT_VIEW_NAME;
    }
    self.trackedViewName = viewName;
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

#pragma mark tableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (statusThanhToan != STATUS_RESULT_SUCCESS) {
        return 1;
    }
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
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
        lblTitleThanhToan.text = MESSAGE_STATUS_RESULT_SUCCESS;
        if (statusThanhToan == STATUS_RESULT_FAILED) {
            lblTitleThanhToan.text = MESSAGE_STATUS_RESULT_FAILED;
        } else if (statusThanhToan == STATUS_WAITING_RESULT) {
            lblTitleThanhToan.text = ALERT_NOTICE_EXISTS_TRANSACTION_PENDING;
        }
        
        CGSize sizeTextTitle = [lblTitleThanhToan.text sizeWithFont:lblTitleThanhToan.font];
        CGFloat widthText = self.view.frame.size.width - 2*(MARGIN_EDGE_TABLE_GROUP + 5);
        [lblTitleThanhToan setFrame:CGRectMake(xStar, yStar, widthText, sizeTextTitle.height)];
        
        //layout tipe
//        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UILabel *lblTip = [[UILabel alloc] init];
        [lblTip setFont:[UIFont getFontNormalSize13]];
        [lblTip setTextColor:[UIColor colorWithWhite:0.1 alpha:0.4]];
//        if (isCommingFromTicketList) {
//            lblTip.text = [NSString stringWithFormat:TIP_THANHTOAN_INPUT_INFO1, self.ticketInfo.phone];
//        } else {
//            lblTip.text = [NSString stringWithFormat:TIP_THANHTOAN_INPUT_INFO1, delegate.phone];
//        }
        lblTip.text = TIP_THANHTOAN_INPUT_INFO1;
        [lblTip setBackgroundColor:[UIColor clearColor]];
        lblTip.numberOfLines = 2;
        CGSize sizeText = [@"ABC" sizeWithFont:lblTip.font];
        [lblTip setFrame:CGRectMake(xStar, yStar + sizeTextTitle.height, widthText, 2*sizeText.height)];
        
        [ret addSubview:lblTitleThanhToan];
        [ret addSubview:lblTip];
        return ret;
    }

    return nil;
}

- (UIView *) layoutLableFooterShowStatusPendingOrFailed
{
    //Layout title tip
    CGFloat xStar = MARGIN_EDGE_TABLE_GROUP + 5;
    CGFloat yStar = 0;
    UIView* ret = [[UIView alloc] init];
    UILabel *lblTitleThanhToan = [[UILabel alloc] init];
    [lblTitleThanhToan setFont:[UIFont getFontBoldSize18]];
    [lblTitleThanhToan setBackgroundColor:[UIColor clearColor]];
    [lblTitleThanhToan setNumberOfLines:0];
    [lblTitleThanhToan setLineBreakMode:UILineBreakModeCharacterWrap];
    [lblTitleThanhToan setTextColor:[UIColor blackColor]];
    lblTitleThanhToan.text = MESSAGE_STATUS_RESULT_SUCCESS;
    if (statusThanhToan == STATUS_RESULT_FAILED) {
        lblTitleThanhToan.text = MESSAGE_STATUS_RESULT_FAILED;
    } else if (statusThanhToan == STATUS_WAITING_RESULT) {
        lblTitleThanhToan.text = ALERT_NOTICE_EXISTS_TRANSACTION_PENDING;
    }
    
    CGSize sizeTextTitle = [lblTitleThanhToan.text sizeWithFont:lblTitleThanhToan.font];
    CGFloat widthText = self.view.frame.size.width - 2*(MARGIN_EDGE_TABLE_GROUP + 5);
    [lblTitleThanhToan setFrame:CGRectMake(xStar, yStar, widthText, 3*sizeTextTitle.height)];
    
    [ret addSubview:lblTitleThanhToan];
    return ret;
}

-(UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0 && statusThanhToan != STATUS_RESULT_SUCCESS) {
        return [self layoutLableFooterShowStatusPendingOrFailed];
    }
    
    if (section == 1) {
        CGFloat xStar = MARGIN_EDGE_TABLE_GROUP + 5;
        CGFloat yStar = 0;
        UIView* ret = [[UIView alloc] init];
        UILabel *lblTip = [[UILabel alloc] init];
        lblTip.text = TIP_THANHTOAN_INPUT_INFO2;
        CGSize sizeTextTitle = [lblTip.text sizeWithFont:lblTip.font];
        CGFloat widthText = self.view.frame.size.width - 2*(MARGIN_EDGE_TABLE_GROUP + 5);
        [lblTip setFrame:CGRectMake(xStar, yStar, widthText, sizeTextTitle.height*2)];
        [lblTip setFont:[UIFont getFontNormalSize13]];
        [lblTip setTextColor:[UIColor colorWithWhite:0.1 alpha:0.4]];
        [lblTip setBackgroundColor:[UIColor clearColor]];
        lblTip.numberOfLines = 2;
        [ret addSubview:lblTip];
        yStar += lblTip.frame.size.height;
        
//                button show bar code
        UIImage *img = [UIImage imageNamed:@"orange_wide_button.png"];
        UIButton *btnShowBarCode = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnShowBarCode setBackgroundImage:img forState:UIControlStateNormal];
        [btnShowBarCode addTarget:self action:@selector(showBarCode) forControlEvents:UIControlEventTouchUpInside];
        yStar += MARGIN_EDGE_TABLE_GROUP/2;
        btnShowBarCode.frame = CGRectMake(xStar, yStar, self.view.frame.size.width - 3*MARGIN_EDGE_TABLE_GROUP, img.size.height);

        UILabel *lblShowTitle = [[UILabel alloc] init];
        [lblShowTitle setFont:[UIFont getFontBoldSize14]];
        [lblShowTitle setText:BAR_CODE_SHOW];
        [lblShowTitle setTextColor:[UIColor whiteColor]];
        [lblShowTitle setBackgroundColor:[UIColor clearColor]];
        CGSize size = [lblShowTitle.text sizeWithFont:lblShowTitle.font];
        [lblShowTitle setFrame:CGRectMake((img.size.width - size.width)/2, (img.size.height - size.height)/2, size.width, size.height)];
        [btnShowBarCode addSubview:lblShowTitle];

        
        [ret addSubview:btnShowBarCode];
        
//        // add button ho tro
        UIImage* imageLeft = [UIImage imageNamed:@"free_call.png"];
        UIButton* suportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        yStar = btnShowBarCode.frame.origin.y + btnShowBarCode.frame.size.height + MARGIN_EDGE_TABLE_GROUP;
        suportButton.frame = CGRectMake(xStar, yStar, self.view.frame.size.width - 3*MARGIN_EDGE_TABLE_GROUP, imageLeft.size.height);
        [suportButton setImage:imageLeft forState:UIControlStateNormal];
        [suportButton addTarget:self action:@selector(handleSupportButton) forControlEvents:UIControlEventTouchUpInside];
        [suportButton setBackgroundColor:[UIColor clearColor]];
        
        UILabel *lblTitle = [[UILabel alloc] init];
        [lblTitle setFont:[UIFont getFontBoldSize14]];
        [lblTitle setText:THANHTOAN_TITLE_PHONE_SUPPORT];
        [lblTitle setTextColor:[UIColor whiteColor]];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        size = [lblTitle.text sizeWithFont:lblTitle.font];
        [lblTitle setFrame:CGRectMake((imageLeft.size.width - size.width)/2, (imageLeft.size.height - size.height)/2, size.width, size.height)];
        [suportButton addSubview:lblTitle];
        [ret addSubview:suportButton];
        
        return ret;
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
        switch (indexPath.section)
        {
            case 0:
            {
                if (indexPath.row == 0)
                {
                    NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"CinemaNoteCell" owner:self options:nil];
                    cell = [arr objectAtIndex:0];
                    if (isCommingFromTicketList)
                    {
                        //set string format publish date
                        NSString* dateString = self.ticketInfo.film_publish_date;
                        if (dateString && dateString.length >= 10) {
                            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
                            [dateFormat setDateFormat:@"yyyy-MM-dd"];
                            NSDate *curDate = [dateFormat dateFromString:self.ticketInfo.film_publish_date];
                            [dateFormat setDateFormat:@"d/M"];
                            dateString = [dateFormat stringFromDate:curDate];
                        }
                        
                        UIImage *imagePoster = [[UIImage alloc] initWithData:self.ticketInfo.ticket_data];
                        [(CinemaNoteCell *)cell layoutNoticeView:self.ticketInfo.film_name filmVersion:self.ticketInfo.film_version filmDuration:[self.ticketInfo.film_duration intValue] publishDate:dateString imagePoster:imagePoster posterURL:ticketInfo.film_poster_url];
                    } else {
                        [(CinemaNoteCell *)cell layoutNoticeView:self.buyInfo.chosenFilm];
                    }
                }
                else
                {
                    cell =  [[CellInfoThanhToan alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    if (isCommingFromTicketList)
                    {
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd H:mm:ss"];
                        NSDate *date = [dateFormatter dateFromString:self.ticketInfo.date_show];
                        double timeDouble = [date timeIntervalSinceReferenceDate];
                        NSString *session_time = [NSDate getForMatStringAsDateFromTimeTamp:timeDouble formatClock:@"H:mm" formatDate:@"d/M/y" desExtend:@"Hôm nay"];
                        [(CellInfoThanhToan *)cell layoutInfoCell:self.ticketInfo.listSeat sessionTime:session_time totalMoney:[self.ticketInfo.ticket_total_price intValue]];
                    }
                    else
                    {
                        [(CellInfoThanhToan *)cell layoutInfoCell:self.buyInfo];
                    }
                }
                break;
            }
            case 1:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
                UIView* stranView = [[UIView alloc] initWithFrame:CGRectZero];
                stranView.backgroundColor = [UIColor clearColor];
                cell.backgroundView = stranView;
                
                UIImageView* imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ticket.png"]];
                CGRect frame = imgView.frame;
                frame.size = CGSizeMake(300, 105);
                imgView.frame = frame;
                imgView.center = CGPointMake(150, HEIGHT_TICKET_ROW/2);
                imgView.backgroundColor = [UIColor clearColor];
                
                UILabel* label1 = [[UILabel alloc] init];
                label1.backgroundColor = [UIColor clearColor];
                CGRect frame2 = label1.frame;
                frame2.size = CGSizeMake(imgView.bounds.size.width, 30);
                frame2.origin.y = 15;
                label1.frame = frame2;
                label1.text = THANHTOAN_TITLE_TICKET_CODE;
                label1.textAlignment = UITextAlignmentCenter;
                label1.font = [UIFont getFontBoldSize18];
                label1.textColor = [self ticketColor];
                [imgView addSubview:label1];
                
                UILabel* label2 = [[UILabel alloc] init];
                label2.backgroundColor = [UIColor clearColor];
                CGRect frame3 = label1.frame;
                frame3.origin.y = label1.frame.origin.y + label1.frame.size.height + 10;
                label2.frame = frame3;

                NSMutableString *strTicketCode = [[NSMutableString alloc] initWithString:@""];
                if (isCommingFromTicketList) {
                    [self formatString:ticketInfo.ticket_code outString:strTicketCode];
                } else {
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [self formatString:app.ticket_code outString:strTicketCode];
                }
                label2.text = strTicketCode;
                label2.textAlignment = UITextAlignmentCenter;
                label2.font = [UIFont getFontBoldSize27];
                label2.textColor = [self ticketColor];
                
                [imgView addSubview:label2];
                [cell.contentView addSubview:imgView];
                
                break;
            }
            default:
                break;
        }
    }
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


#pragma makr tableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (statusThanhToan != STATUS_RESULT_SUCCESS) {
            return 4*MARGIN_EDGE_TABLE_GROUP;
        }
        return MARGIN_EDGE_TABLE_GROUP;
    }
    return 160;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    else if (section == 1) {
        CGFloat height = [@"ABC" sizeWithFont:[UIFont getFontBoldSize18]].height;
        height += [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]].height;
        return (height + 2*MARGIN_EDGE_TABLE_GROUP + MARGIN_EDGE_TABLE_GROUP/2);
    } else if (section == 3) {
        return ([@"ABC" sizeWithFont:[UIFont getFontBoldSize18]].height + MARGIN_EDGE_TABLE_GROUP);
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            CGFloat height = [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]].height;
            height += [@"ABC" sizeWithFont:[UIFont getFontBoldSize12]].height;
            return (height + 2*MARGIN_EDGE_TABLE_GROUP);
        }
        return 60 + 2*MARGIN_CELL_SESSION;
    }
    return HEIGHT_TICKET_ROW;
}

#pragma mark - font, color
-(UIColor*)ticketColor
{
    return [UIColor colorWithRed:49/255.0 green:99/255.0 blue:148/255.0 alpha:0.8];
}

- (void)formatString:(NSString*)inStr outString:(NSMutableString *)strOut
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(.{4})" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:inStr options:0 range:NSMakeRange(0, [inStr length])];
    NSMutableString *str = [[NSMutableString alloc] initWithString:inStr];;
    if (matches)
    {
        for (NSInteger i = matches.count - 1; i >= 0; i--)
        {
            NSTextCheckingResult *match = [matches objectAtIndex:i];
            if (match.range.location + match.range.length >= str.length)
            {
                continue;
            }
            NSString *substr = [str stringByReplacingCharactersInRange: NSMakeRange(match.range.location + match.range.length, 0) withString:@"-"];
            [str setString:substr];
        }
    }
    [strOut appendString:str];
}

#pragma mark using when sucessfull thanhToan and get ticket
-(void)processActionSaveTicketToDatabase
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    ticketInfo = [NSEntityDescription insertNewObjectForEntityForName:@"Ticket" inManagedObjectContext:context];
    [ticketInfo setTicket_code:delegate.ticket_code];
    [ticketInfo setTicket_total_price:[NSNumber numberWithInt:self.buyInfo.totalMoney]];
    [ticketInfo setPhone:delegate.phone];
    [ticketInfo setInvoice_no:delegate.Invoice_No];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd H:mm:ss"];
    NSString *date_buy = [dateFormatter stringFromDate:[NSDate date]];
    [ticketInfo setDate_buy:date_buy];
    
    NSDate *today = [NSDate dateWithTimeIntervalSinceReferenceDate:[self.buyInfo.chosenSession.session_time doubleValue]];
    NSString *date_show = [dateFormatter stringFromDate:today];
    [ticketInfo setDate_show:date_show];
    [ticketInfo setRoom_name:self.buyInfo.room_name];
    //set film_name
    NSString *film_version = @"2D";
    if ([self.buyInfo.chosenSession.version_id intValue] == 3) {
        film_version = @"3D";
    }
    [ticketInfo setFilm_name:[NSString stringWithFormat:@"%@ %@",self.buyInfo.chosenFilm.film_name, film_version]];
    [ticketInfo setFilm_poster_url:self.buyInfo.chosenFilm.poster_url];
    [ticketInfo setFilm_version:self.buyInfo.chosenFilm.film_version];
    [ticketInfo setFilm_duration:self.buyInfo.chosenFilm.film_duration];
    [ticketInfo setCinema_name:self.buyInfo.chosenCinema.cinema_name];
    [ticketInfo setFilm_url:self.buyInfo.chosenFilm.film_url];
    
    //set string format publish date
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d/M"];
    NSString* dateString = [dateFormat stringFromDate:self.buyInfo.chosenFilm.publish_date];
    [ticketInfo setFilm_publish_date:dateString];
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
    [ticketInfo setListSeat:strGhe];
    SDImageView *imageView = (SDImageView *)[[layoutTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:TAG_CUSTOM_IMAGE_POSTER];
    NSData *data = UIImagePNGRepresentation(imageView.image);
    [ticketInfo setTicket_data:data];
}

-(void)saveTicketToDatabase
{
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    if (ticketInfo == nil) {
        return;
    }
    NSError *error;
    if (context && ![context saveToPersistentStore:&error]) {
        LOG_123PHIM(@"Error when save %@", error.description);
    }
}

- (void)onPurchaseCompleted
{    
    GAITransaction *transaction = [GAITransaction transactionWithId:self.ticketInfo.ticket_code withAffiliation:@"123Phim"];
    transaction.revenueMicros = (int64_t)([self.ticketInfo.ticket_total_price floatValue] * 1000000);
    [transaction addItemWithCode:self.ticketInfo.listSeat name:self.ticketInfo.film_name category:[NSString stringWithFormat:@"%@ - %@",self.buyInfo.chosenCinema.cinema_name, self.ticketInfo.room_name] priceMicros:(int64_t)([self.ticketInfo.ticket_total_price floatValue] * 1000000) quantity:1];
    [[GAI sharedInstance].defaultTracker sendTransaction:transaction];
 }

-(void) showBarCode
{
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:delegate.currentView
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_TICKET_SHOW_BAR_CODE
                                                     currentFilmID:self.buyInfo.chosenFilm.film_id
                                                   currentCinemaID:self.buyInfo.chosenCinema.cinema_id
                                                         sessionId:self.buyInfo.chosenSession.session_id
                                                   returnCodeValue:0 context:nil];
    
    BarCodeViewController *barCodeController = [[BarCodeViewController alloc] init];
    if (isCommingFromTicketList) {
        barCodeController.encodeString = ticketInfo.ticket_code;
    } else {
        barCodeController.encodeString = delegate.ticket_code;
    }
    [self.navigationController pushViewController:barCodeController animated:YES];
}


@end
