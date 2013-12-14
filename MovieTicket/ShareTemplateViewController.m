//
//  ShareTemplateViewController.m
//  123Phim
//
//  Created by Phuc Phan on 3/13/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#import "AppDelegate.h"
#import "MainViewController.h"
#import "ShareTemplateViewController.h"
#import "FilmDetailViewController.h"
#import "CinemaNoteCell.h"
#import "CinemaRatingCell.h"
#import "FacebookManager.h"
#import "AutoScrollLabel.h"

BOOL isUseInputInside = YES;
BOOL isMessageTextOn = NO;
BOOL isKeyboardOn = NO;
BOOL isCancelShare = NO;
BOOL isFinishShare = NO;
BOOL isSharing = NO;

@interface ShareTemplateViewController ()
{
    NSArray *dataList;
    NSInteger otherCellIndex;
    NSInteger timeCount;
}

@property (nonatomic, strong) UITableView *templateTableView;
@property (nonatomic, strong) UIView *messageInputView;
@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UITableViewCell *otherCell;
@property (nonatomic, strong) UIAlertView *alert;

@end


@implementation ShareTemplateViewController

@synthesize film;
@synthesize templateTableView;
@synthesize messageInputView;
@synthesize messageTextView;
@synthesize cancelButton;
@synthesize sendButton;
@synthesize otherCell;
@synthesize alert;

//-(void)dealloc
//{
//    alert.delegate = nil;
//    film = nil;
//    _navTitle = nil;
//    _source = nil;
//    dataList = nil;
//    otherCellIndex = nil;
//    timeCount = nil;
//    templateTableView = nil;
//    messageInputView = nil;
//    messageTextView = nil;
//    sendButton = nil;
//    cancelButton = nil;
//    otherCell = nil;
//    alert = nil;
//}

- (id)init
{
    self = [super init];
    if (self) {
        viewName = SHARE_TEMPLATE_VIEW_NAME;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    isCancelShare = YES;
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:@"Rủ bạn xem cùng"];
    
    timeCount = 30;
    isMessageTextOn = NO;
    dataList = [[NSArray alloc]initWithObjects:
                @"Nghe chừng phim này hay đây",
                @"Một lựa chọn không tồi chút nào, xem nhé!",
                @"Phim rất thích hợp để xả stress cuối tuần ^_^",
                @"Xem trailer đã thấy hấp dẫn rồi. Thế nào cũng phải rủ bạn bè cùng xem",
                @"Khác",
                nil];
    otherCellIndex = dataList.count - 1;
    
    templateTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - NAVIGATION_BAR_HEIGHT - TITLE_BAR_HEIGHT) style:UITableViewStyleGrouped];
    templateTableView.dataSource = self;
    templateTableView.delegate = self;
    templateTableView.backgroundView = nil;
    templateTableView.backgroundColor = [UIColor clearColor];

    self.view.backgroundColor = [UIFont colorBackGroundApp];
    [self.view addSubview:templateTableView];
    self.trackedViewName = @"UIShareDetail";
    
//    NSString* previewView = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).currentView;
//    NSString* currentView = viewName;
//    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:currentView comeFrom:previewView withActionID:LOG_ACTION_ID_VIEW currentFilmID:self.film.film_id currentCinemaID:[NSNumber numberWithInt: NO_CINEMA_ID] returnCodeValue:0 context:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark tableView Delegate
-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    //return MARGIN_EDGE_TABLE_GROUP/2;
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        
        NSString *description = @"Chọn nội dung có sẵn để chia sẻ với bạn bè hoặc chọn \"Khác\" để nhập nội dung của bạn.";
        UILabel *_lblContent = [[UILabel alloc] init];
        [_lblContent setFont:[UIFont getFontNormalSize13]];
        [_lblContent setTextColor:[UIColor colorWithWhite:0 alpha:0.4]];
        CGSize size = [@"ABC" sizeWithFont:_lblContent.font];
        [_lblContent setFrame:CGRectMake(MARGIN_EDGE_TABLE_GROUP, 0, self.view.frame.size.width - 2*MARGIN_EDGE_TABLE_GROUP, 2*size.height)];
        [_lblContent setText:description];
        [_lblContent setNumberOfLines:0];
        [_lblContent sizeToFit];
        [_lblContent setLineBreakMode:UILineBreakModeWordWrap];
        [_lblContent setBackgroundColor:[UIColor clearColor]];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
//        NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
//        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 8, 300, 36)];
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ShareTemplateViewDescription" ofType:@"html"];
//        NSString *source = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath]
//                                                    encoding:NSStringEncodingConversionExternalRepresentation
//                                                       error:nil];
//        
//        // assign variable
//        source = [NSString stringWithFormat:source, description];
//        
//        webView.backgroundColor = [UIColor clearColor];
//        webView.scrollView.scrollEnabled = NO;
//        [webView setUserInteractionEnabled:NO];
//        [webView setOpaque:NO];
//        [webView loadHTMLString:source baseURL:baseURL];
//        [view addSubview:webView];
//        [webView release];
        [view addSubview:_lblContent];
        return view;
    }
    return nil;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (isMessageTextOn)
    {
        if (section == 2) {
            return MARGIN_EDGE_TABLE_GROUP;
        }
    }
    else
    {
        if (section == 1) {
            return MARGIN_EDGE_TABLE_GROUP;
        }
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isMessageTextOn)
        return 3;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    else if (isMessageTextOn && section == 1)
    {
        return 1;
    }
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            NSString *thePath = [[NSBundle mainBundle] pathForResource:@"btnadd_to_watch_list" ofType:@"png"];
            UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
            return prodImg.size.height + MARGIN_EDGE_TABLE_GROUP;
            
        }
        return 60 + 2*MARGIN_CELL_SESSION;
    }
    else if (isMessageTextOn && indexPath.section == 2)
    {
        return 70;
    }
    else if (isMessageTextOn && indexPath.section == 1 && indexPath.row == 3)
    {
        return 122;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cellIdentifier = @"cinema_note_cell_id";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell)
    {
        if ([cell isKindOfClass:[CinemaNoteCell class]])
        {
            UIView *view = [(CinemaNoteCell *)cell viewWithTag:TAG_AUTO_SCROLL_LABEL];
            if ([view isKindOfClass:[AutoScrollLabel class]]) {
                AutoScrollLabel *autoLable = (AutoScrollLabel *)view;
                [autoLable refreshLabels];
            }
        }
        return cell;
    }
    
    // film info
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
//            cell = [[[CinemaNoteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
            NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"CinemaNoteCell" owner:self options:nil];
            cell = [arr objectAtIndex:0];
            [(CinemaNoteCell *)cell layoutNoticeView:self.film];
            cell.selectionStyle = UITableViewCellSeparatorStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        } else {
            cell = [[CinemaRatingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [(CinemaRatingCell *)cell layoutCellCinemaHeader:self.film isViewShare:YES];
            [(CinemaRatingCell *)cell setCommentDelegate:[MainViewController sharedMainViewController]];
            cell.selectionStyle = UITableViewCellSeparatorStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        }
        return  cell;
    }
    
    
    // list message
    NSString *title = [dataList objectAtIndex:indexPath.row];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    CGFloat cellWidth = (self.source == 2 && indexPath.section == 1) ? 220 : 265;
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, cellWidth, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont getFontNormalSize13];
    label.text = title;
    label.numberOfLines = 0;
    label.tag = 200;
    [cell.contentView addSubview:label];

    switch (self.source)
    {
        case 2: // facebookCellIndex
        {
            if (indexPath.section == 1)
            {
                // khac
                if (indexPath.row == otherCellIndex)
                {
                    if (isUseInputInside)
                    {                        
                        UIImage *arrow = [UIImage imageNamed:@"arrow"];
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(285, 15, 13, 13)];
                        
                        imageView.animationDuration = 0.5;
                        imageView.animationRepeatCount = 4;
                        imageView.tag = 100;
                        
                        [imageView setImage:arrow];
                        [cell addSubview:imageView];

                        // fake lalel
                        CGRect frame = cell.frame;
                        frame.origin.x = 10;
                        frame.origin.y = 0;
                
                        UILabel *label = [[UILabel alloc] initWithFrame:frame];
                        label.text = cell.textLabel.text;
                        label.font = cell.textLabel.font;
                        label.backgroundColor = [UIColor clearColor];

                        [cell.contentView addSubview:label];
                        cell.textLabel.text = @"";
                        
                        // input
                        if (!messageInputView) {
                            [self initMessageInputView];
                        }

                        [cell.contentView addSubview:messageInputView];

                    } else {
                        
                        UIImage *arrow = [UIImage imageNamed:@"arrow"];
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(285, 15, 13, 13)];
                        
                        imageView.animationDuration = 0.5;
                        imageView.animationRepeatCount = 4;
                        imageView.tag = 100;
                        
                        [imageView setImage:arrow];
                        [cell addSubview:imageView];
                    }

                }
                else
                {
                    UIButton *sendButtonFb = [[UIButton alloc] initWithFrame:CGRectMake(250, 10, 52, 24)];
                    sendButtonFb.userInteractionEnabled = NO;
                    [sendButtonFb setBackgroundImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
                    [cell addSubview:sendButtonFb];
                    
                    // cell label width
                    CGRect frame = cell.textLabel.frame;
                    frame.size.width = 210;
                    cell.textLabel.frame = frame;
                }
                otherCell = cell;
            }
            else
            {
                // message input
                cell.selectionStyle = UITableViewCellSeparatorStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
                cell.backgroundColor = [UIColor clearColor];
                cell.layer.borderWidth = 0;
                //[cell addSubview:messageInputView];
            }
        }
        break;
            
        default:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:200];
        NSString *message = label.text;
        
        switch (self.source) {
            // share via sms
            case CELL_SMS:
            {
                if (indexPath.row == otherCellIndex) message = @"";
                [self shareViaSMS:message];
                [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Film"
                                         withAction:@"Share"
                                          withLabel:@"SMS"
                                          withValue:[NSNumber numberWithInt:102]];
                
                // send log to 123phim server
                AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:@"[sms-program]"
                                                                      comeFrom:delegate.currentView
                                                                  withActionID:ACTION_FILM_SHARE_SMS
                                                                 currentFilmID:film.film_id
                                                               currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID]
                                                               returnCodeValue:0 context:nil];
            }
            break;
            
            // share via facebook
            case 2:
            {
                if (indexPath.row == otherCellIndex)
                {
                    [self toggleShareInput:cell];
                }
                else
                {
                    [self shareViaFacebook:message];   
                }
                [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Film"
                                         withAction:@"Share"
                                          withLabel:@"FaceBook"
                                          withValue:[NSNumber numberWithInt:103]];
                
                AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:delegate.currentView
                                                                      comeFrom:delegate.currentView
                                                                  withActionID:ACTION_FILM_SHARE_FB
                                                                 currentFilmID:film.film_id
                                                               currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID]
                                                               returnCodeValue:0 context:nil];
            }
            break;
               
            // share via email
            case 1:
            {
                if (indexPath.row == otherCellIndex)
                    message = @"";
                [self shareViaEmail:message];
                [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Film"
                                         withAction:@"Share"
                                          withLabel:@"Email"
                                          withValue:[NSNumber numberWithInt:104]];
                
                AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:@"[email-program]"
                                                                      comeFrom:delegate.currentView
                                                                  withActionID:ACTION_FILM_SHARE_EMAIL
                                                                 currentFilmID:film.film_id
                                                               currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID]
                                                               returnCodeValue:0 context:nil];
            }
            break;            
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark textField delegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0) {
        sendButton.enabled = YES;
    } else {
        sendButton.enabled = NO;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UIImage *imageRight = [UIImage imageNamed:@"button-60x30"];
    UIButton *customButtonR = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(220, 7, imageRight.size.width, imageRight.size.height);
    customButtonR.frame = frame;
    customButtonR.titleLabel.font = [UIFont getFontBoldSize12];
    customButtonR.layer.opacity = 0;
    customButtonR.tag = 300;
    [customButtonR setTitle:@"Cancel" forState:UIControlStateNormal];
    [customButtonR setBackgroundImage:imageRight forState:UIControlStateNormal];
    [customButtonR addTarget:self action:@selector(cancelShareClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc] initWithCustomView:customButtonR];
    double offset = 216;
    CGRect rect = CGRectMake(0, self.view.frame.origin.y - offset - messageTextView.frame.size.height - 2*MARGIN_EDGE_TABLE_GROUP, self.view.frame.size.width, self.view.frame.size.height + messageTextView.frame.size.height + 2*MARGIN_EDGE_TABLE_GROUP);
    CGRect rectTable = self.templateTableView.frame;
    rectTable.size.height += (messageTextView.frame.size.height + 2*MARGIN_EDGE_TABLE_GROUP);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.navigationItem.rightBarButtonItem = btnRight;
    [self.templateTableView setFrame:rectTable];
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - messageTextView.frame.size.height - 2*MARGIN_EDGE_TABLE_GROUP);   
    CGRect frame = self.navigationItem.rightBarButtonItem.customView.frame;
    frame.origin.x = 220;
    CGRect rectTable = self.templateTableView.frame;
    rectTable.size.height -= (messageTextView.frame.size.height + 2*MARGIN_EDGE_TABLE_GROUP);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationItem.rightBarButtonItem.customView.layer.opacity = 0;
        self.navigationItem.rightBarButtonItem.customView.frame = frame;
        self.view.frame = rect;
        self.templateTableView.frame = rectTable;
    } completion:^(BOOL finished) {
        self.navigationItem.rightBarButtonItem = nil;
    }];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return  YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return  YES;
}

- (void)scrollToBottom
{
    CGFloat y = 0;
    
    if (templateTableView.contentSize.height > templateTableView.bounds.size.height) {
        y = templateTableView.contentSize.height - templateTableView.bounds.size.height;
    }
    
    [templateTableView setContentOffset:CGPointMake(0, y) animated:YES];
}

- (void)cancelShareClick
{
    isKeyboardOn = NO;
    [self toggleShareInput:otherCell];
    [messageTextView resignFirstResponder];
}

-(void)sendButtonClick
{
    NSString *message = messageTextView.text;
    if (message.length > 0) {
        [self shareViaFacebook:message];
    }
}

- (void)toggleShareInput:(UITableViewCell *)cell
{
    isMessageTextOn = !isMessageTextOn;

    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];

    [UIView animateWithDuration:0.3 animations:^{
        imageView.transform = CGAffineTransformMakeRotation( isMessageTextOn ? M_PI_2 : 0 );
        
        CGRect frame = cell.frame;
        frame.size.height = isMessageTextOn ? 122 : 44;
        cell.frame = frame;
        
        if (isMessageTextOn) {
            messageInputView.hidden = NO;
        }
        messageInputView.layer.opacity = isMessageTextOn ? 1 : 0;
    
    } completion:^(BOOL finished) {
        messageInputView.hidden = !isMessageTextOn;
        if (isMessageTextOn) {
            [messageTextView becomeFirstResponder];
        }
    }];

    if (!isMessageTextOn) {
        [messageTextView resignFirstResponder];
    }
}

- (void)initMessageInputView
{
    if (!messageInputView) {

        messageInputView = [[UIView alloc] initWithFrame:CGRectMake(10, 40, 280, 100)];
        messageInputView.backgroundColor = [UIColor clearColor];
        messageInputView.layer.opacity = 0;
        messageInputView.hidden = YES;
       
        UIImage *commentBoxImage = [UIImage imageNamed:@"comment_box_full"];
        CGFloat tvcmtHeight = commentBoxImage.size.height;
        CGFloat tvcmtWidth = commentBoxImage.size.width;
        
        messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, tvcmtWidth, tvcmtHeight)];
        messageTextView.clipsToBounds = NO;
        messageTextView.contentInset = UIEdgeInsetsMake(-4, -4, -4, -4);
        messageTextView.delegate = self;
        messageTextView.textColor = [UIColor blackColor];
        messageTextView.layer.masksToBounds = YES;
        messageTextView.keyboardType = UIKeyboardTypeDefault;
        messageTextView.font = [UIFont getFontNormalSize13];
        //[messageTextView becomeFirstResponder];
        [messageTextView setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *tvView = [[UIImageView alloc] initWithImage:commentBoxImage];
        tvView.frame = messageTextView.frame;
        
        // addview
        [messageInputView addSubview:tvView];
        [messageInputView addSubview:messageTextView];
        
        // send button
        UIImage *sendImage = [UIImage imageNamed:@"send"];
        CGRect sendFrame = messageTextView.frame;
        sendFrame.size = sendImage.size;
        sendFrame.origin.x = messageTextView.frame.size.width  - sendFrame.size.width;
        sendFrame.origin.y = messageTextView.frame.size.height - sendFrame.size.height;
        
        
        sendButton = [[UIButton alloc] initWithFrame:sendFrame];
        sendButton.enabled = NO;
        [sendButton setBackgroundImage:sendImage forState:UIControlStateNormal];
        [sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];

        // addview
        [messageInputView addSubview:sendButton];
    }
}

- (void)shareViaFacebook:(NSString *)message
{
//    LOG_123PHIM(@"Sharing via Facebook with message: %@", message);

    if (isSharing) return;

    [self showAlertSharing:@"Đang chia sẻ..."];
    
    FacebookManager *fbManager = [FacebookManager shareMySingleton];
 
    [fbManager shareFilm:self.film withMessage:message onSuccess:^(id result) {
        [self showAlertDone:@"Bạn đã chia sẻ thành công."];
    } onError:^(NSError *error) {
        [self showAlertFail:@"Chia sẻ không thành công."];
    }];
    

    //[self performSelector:@selector(shareTimer) withObject:nil afterDelay:15];
}

- (void)shareTimer
{
    if (!isFinishShare) {
        alert.message = @"Kết nối chậm...";
        ((UIView *)[alert viewWithTag:1]).hidden = NO;
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(shareTimerLoop:) userInfo:nil repeats:YES];
    }
}

- (void)shareTimerLoop:(NSTimer *)timer
{
    if (--timeCount < 0) {

        timeCount = 0;
    
        [timer invalidate];
        
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    
    } else {

        alert.message = [NSString stringWithFormat:@"Kết nối chậm... (%ds)", (NSInteger)timeCount];
    }
}

- (void)shareViaSMS:(NSString *)message
{
    NSString *addedBody = [NSString stringWithFormat:@"\"%@\"\n%@\n\n%@",
                           self.film.film_name,
                           message,
                           self.film.film_url];

    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    [picker setBody:addedBody];
   
    if (picker) {
        [self presentModalViewController:picker animated:YES];
    }
    
}

- (void)shareViaEmail:(NSString *)message
{
    NSString *addedBody = [NSString stringWithFormat:@"\"<a href=\"%@?email\">%@</a>\"<br><br>%@",
                           self.film.film_url,
                           self.film.film_name,
                           message];
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:self.film.film_name];
    [picker setMessageBody:addedBody isHTML:YES];
    
    if (picker) {
        [self presentModalViewController:picker animated:YES];
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    // Notifies users about errors associated with the interface
	switch (result)
	{
		case MessageComposeResultCancelled:
        {
//            LOG_123PHIM(@"Result: SMS sending canceled");
        }
        break;
		
        case MessageComposeResultSent:
        {
//            LOG_123PHIM(@"Result: SMS sent");
            [self showAlertDone:@"SMS sent"];
        }
        break;
		
        case MessageComposeResultFailed:
        {
//            LOG_123PHIM(@"Result: SMS sending failed");
            [self showAlertDone:@"SMS sending failed"];
        }
        break;
		
        default:
        {
//            LOG_123PHIM(@"Result: SMS not sent");
            //[self showAlertDone:@"SMS not sent"];
        }
        break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
	{
		case MFMailComposeResultCancelled:
        {
//            LOG_123PHIM(@"Result: Mail sending canceled");
        }
        break;
            
        case MFMailComposeResultSent:
        {
//            LOG_123PHIM(@"Result: Mail sent");
            [self showAlertDone:@"Mail sent"];
        }
        break;
            
        case MFMailComposeResultFailed:
        {
//            LOG_123PHIM(@"Result: Mail sending failed");
            [self showAlertDone:@"Mail sending failed"];
        }
        break;
            
        default:
        {
//            LOG_123PHIM(@"Result: Mail not sent");
            //[self showAlertDone:@"Mail not sent"];
        }
        break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (void)showAlertSharing:(NSString *)message
{
    isFinishShare = NO;
    isSharing = YES;

//    alert = [[UIAlertView alloc] initWithTitle:@"123Phim" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
//
//    ((UIView *)[alert viewWithTag:1]).hidden = YES;
//    alert.tag = 101;
//    [alert show];
}

- (void)showAlertDone:(NSString *)message
{
    isFinishShare = YES;
    isSharing = NO;

    if (alert) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    }
    
    if (!isCancelShare) {
        alert = [[UIAlertView alloc] initWithTitle:@"123Phim" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        alert.tag = 102;
        [alert show];
        
        // auto close after 2.5s
//        [self performSelector:@selector(closeAlertDone) withObject:nil afterDelay:2.5];
    } else {
        isCancelShare = NO;
    }
    
}

- (void)showAlertFail:(NSString *)message
{
    isFinishShare = YES;
    isSharing = NO;

    alert.tag = 103;
    alert.message = message;
    ((UIButton *)[alert viewWithTag:1]).hidden = NO;
    [((UIButton *)[alert viewWithTag:1]) setTitle:@"Close" forState:UIControlStateNormal];
    [((UIButton *)[alert viewWithTag:1]) setTitle:@"Close" forState:UIControlStateSelected];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];

    if (alertView.tag == 102) {
        [self backToFilmDetailView];
    } else {
        isCancelShare = YES;
    }
}

- (void)closeAlertDone
{
    if (alert && alert.tag == 102) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        [self backToFilmDetailView];
    }
}
- (void)backToFilmDetailView
{
    for (UIViewController *vc in self.navigationController.viewControllers) {
        
        if (vc.class == [FilmDetailViewController class]) {
        
            [self.navigationController popToViewController:vc animated:YES];
            
            return;
        }
    }
}

@end
