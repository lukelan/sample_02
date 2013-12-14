//
//  CheckoutWebViewController.m
//  123Phim
//
//  Created by phuonnm on 4/23/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#define EVENT_BUTTON_KEY_JOIN @"join"
#define EVENT_BUTTON_KEY_CAPTURE @"capture"
#define EVENT_BUTTON_KEY_SHARE @"share"
#define EVENT_BUTTON_KEY_PUSH_VIEW @"call_to_action"

#import "EventWebViewController.h"
#import "AppDelegate.h"
#import "APIManager.h"
#import "MainViewController.h"
#import "DefineString.h"
#import "DefineConstant.h"
#import "FacebookManager.h"
#import "InputTextForFBSharingViewController.h"
#import "UIViewController+CaptureSceen.h"
#import "UIDevice+IdentifierAddition.h"

@interface EventWebViewController ()

@end

@implementation EventWebViewController
@synthesize event = _event;

-(void)dealloc
{
    if (_webView && [_webView superview]) {
        [_webView removeFromSuperview];
    }
    _webView = nil;
    _finishLoading = nil;
    _lbCinemaTitle = nil;
    _actionViewIndex = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    viewName = @"UIEventWebViewController";
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    self.trackedViewName = viewName;
    
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app setCustomBackButtonForNavigationItem:self.navigationItem];
    [app setTitleLabelForNavigationController:self withTitle:_event.title];
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    _webView.frame = frame;
    _webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_webView];
    if (!_finishLoading)
    {
        frame.origin.y = frame.size.height - 40;
        frame.size.height -= frame.origin.y;
        _lbCinemaTitle = [[UILabel alloc] initWithFrame:frame];
        _lbCinemaTitle.numberOfLines = 0;
        _lbCinemaTitle.textAlignment = UITextAlignmentCenter;
        _lbCinemaTitle.text = [NSString stringWithFormat:@"Đang tải dữ liệu..."];
        [self.view addSubview:_lbCinemaTitle];        
        [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR_AND_TABBAR];
    }

    // add tool bar
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, TAB_BAR_HEIGHT)];
    CGRect frameT = toolbar.frame;
    frameT.origin.y = self.view.frame.size.height - toolbar.frame.size.height;
    toolbar.frame = frame;
    toolbar.barStyle = UIBarStyleBlack;
    if (_event.lstButtons)
    {
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSMutableArray* toolBarItems = [[NSMutableArray alloc] init];
        [toolBarItems addObject:flexibleSpace];
        for (int i = 0; i < _event.lstButtons.count; i++)
        {
            NSDictionary *btnInfo = [_event.lstButtons objectAtIndex:i];
            NSArray *btnInfoEnum = [[btnInfo keyEnumerator] allObjects];
            NSString *btnTitle = [btnInfoEnum objectAtIndex:0];
            if ([btnTitle isEqualToString:EVENT_BUTTON_KEY_JOIN] ) {
                
                UIBarButtonItem* joinButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"join.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleJoinEvent)];
                [toolBarItems addObject:joinButton];
                [toolBarItems addObject:flexibleSpace];
            }
            else if ([btnTitle isEqualToString:EVENT_BUTTON_KEY_CAPTURE]) {
                UIBarButtonItem* captureButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"capture.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleCapture)];
                [toolBarItems addObject:captureButton];
                [toolBarItems addObject:flexibleSpace];
            }
            else if ([btnTitle isEqualToString:EVENT_BUTTON_KEY_SHARE]) {
                UIBarButtonItem* shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleShare)];
                [toolBarItems addObject:shareButton];
                [toolBarItems addObject:flexibleSpace];
            }
            else if ([btnTitle isEqualToString:EVENT_BUTTON_KEY_PUSH_VIEW]) {
                UIBarButtonItem* pushView = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"action.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleActionClick:)];
                [toolBarItems addObject:pushView];
                [toolBarItems addObject:flexibleSpace];
                _actionViewIndex = i;
            }
        }
        [toolbar setItems:toolBarItems animated:YES];
        if (toolBarItems.count > 1) {
            CGRect frame = _webView.frame;
            frame.size.height -= toolbar.frame.size.height;
            _webView.frame = frame;
            [self.view addSubview:toolbar];
        }
        
    }
    
    // confige tab bar
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    _finishLoading = YES;
    [self hideLoadingView];
    if (_lbCinemaTitle)
    {
        [_lbCinemaTitle removeFromSuperview];
        _lbCinemaTitle = nil;
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (_webView)
    {
        if ([_webView isLoading]) {
            [_webView stopLoading];
        }
        [_webView setDelegate:nil];
    }
    [super viewWillDisappear:animated];
}

#pragma mark - Handle button
- (void)handleJoinEvent
{    
    CheckInViewController* checkInViewController = [[CheckInViewController alloc] init];
    checkInViewController.fbShareType = FBShareTypeJoinEvent;
    checkInViewController.eventTitle = _event.title;
    checkInViewController.link = [_webView.request.URL absoluteString];
    [self.navigationController pushViewController: checkInViewController animated:YES];    
}

- (void)handleShare
{
    UIActionSheet* shareType = [[UIActionSheet alloc] initWithTitle:@"Chia sẻ qua" delegate:self cancelButtonTitle:@"Huỷ" destructiveButtonTitle:nil otherButtonTitles:
                                @"Tin nhắn",
                                @"Email",
                                @"Facebook",
                                nil];
    shareType.tag = ACTION_SHEET_SHARE;
    [shareType showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)handleCapture
{
    [self captureScreen];
}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ACTION_SHEET_SHARE) {
        switch (buttonIndex) {
            case ACTION_SHEET_SHARE_SMS:
                [self smsShare:_event.title link:[_webView.request.URL absoluteString]];
                break;
                
            case ACTION_SHEET_SHARE_EMAIL:
                [self emailShare:_event.title link:[_webView.request.URL absoluteString]];
                break;
                
            case ACTION_SHEET_SHARE_FB:
                if (!FBSession.activeSession.isOpen) {
                    FacebookManager *fbHandler = [FacebookManager shareMySingleton];
                    [fbHandler loginFacebookWithResponseContext:self selector:@selector(facebookShare)];
                }else{
                    [self facebookShare];
                }
                break;
                
            default:
                break;
        }
    }
}


#pragma mark - sms share
- (void)smsShare:(NSString*)title link:(NSString*)link{
    LOG_123PHIM(@"smsShare:");
    LOG_123PHIM(@"   title: %@", title);
    LOG_123PHIM(@"   link: %@", link);
    
    NSString* sendTitle = [NSString stringWithoutCharacterFrom:title];
    NSString* messageBody = [NSString stringWithFormat:@"%@:\n%@\n\n", sendTitle, link];
    MFMessageComposeViewController* smsComposor = [[MFMessageComposeViewController alloc] init];
    smsComposor.messageComposeDelegate = self;
    smsComposor.body = messageBody;
    if (smsComposor) {
        [self presentModalViewController:smsComposor animated:YES];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result)
	{
		case MessageComposeResultCancelled:
            LOG_123PHIM(@"Result: SMS sending canceled");
            break;
            
        case MessageComposeResultSent:
            [self shareDoneWithMessage:@"Tin nhắn đã được gửi"];
            break;
            
        case MessageComposeResultFailed:
            [self shareDoneWithMessage:@"Tin nhắn lỗi !"];
            break;
            
        default:
            break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Email share
- (void)emailShare:(NSString*)title link:(NSString*)link
{
    LOG_123PHIM(@"smsShare:");
    LOG_123PHIM(@"   title: %@", title);
    LOG_123PHIM(@"   link: %@", link);
    
    
//    NSString *addedBody = [NSString stringWithFormat:@"\"<a href=\"%@\">%@</a>\"<br><br>%@<br><br><a href=\"%@\">%@</a><br><br>",
//                           [NSString stringWithFormat:@"http://123phim.vn/?film=%@", self.curFilm.film_id],
//                           self.curFilm.film_name,
//                           message,
//                           APP_ITUNE_LINK,
//                           APP_ITUNE_LINK];
    
    
    
    NSString* htLink = [NSString stringWithFormat:@"<a href=\"%@\">%@</a><br>", link, title];
    MFMailComposeViewController* mailComposor = [[MFMailComposeViewController alloc] init];
    mailComposor.mailComposeDelegate = self;
    [mailComposor setSubject: [NSString stringWithFormat:@"[123Phim] %@", title]];
    [mailComposor setMessageBody:htLink isHTML:YES];
    if (mailComposor) {
        [self presentModalViewController:mailComposor animated:YES];
    }
    

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
	{
		case MFMailComposeResultCancelled:
            LOG_123PHIM(@"Result: SMS sending canceled");
            break;
            
        case MFMailComposeResultSent:
            [self shareDoneWithMessage:@"Email đã được gửi"];
            break;
            
        case MFMailComposeResultFailed:
            [self shareDoneWithMessage:@"Email lỗi !"];
            break;
            
        default:
            break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - FB share
- (void)facebookShare
{   
    InputTextForFBSharingViewController* fbSharingViewController = [[InputTextForFBSharingViewController alloc] init];
    fbSharingViewController.link = [_webView.request.URL absoluteString];
    fbSharingViewController.fbShareType = FBShareTypeShareEvent;
    [self.navigationController pushViewController:fbSharingViewController animated:YES];
}

- (void)shareDoneWithMessage:(NSString*)msg
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"123Phim" message:msg delegate:nil cancelButtonTitle:@"Tiếp tục" otherButtonTitles: nil];
    [alert show];
}

-(void)setEvent:(Event *)event
{
    _event = event;
    
    _webView = [[UIWebView alloc] init];
    _webView.scalesPageToFit = YES;
    NSString *url = [NSString stringWithFormat:@"%@?device_id=%@",_event.link, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];;
    NSURLRequest *request= [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [_webView loadRequest:request];
    _webView.delegate = self;
}

-(void)handleActionClick:(id)sender
{
    NSDictionary *actionInfo = [[_event.lstButtons objectAtIndex:_actionViewIndex] objectForKey:EVENT_BUTTON_KEY_PUSH_VIEW];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [app pushViewControllerWithActionInfo:actionInfo];
}

@end
