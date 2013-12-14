//
//  CheckoutWebViewController.m
//  123Phim
//
//  Created by phuonnm on 4/23/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CheckoutWebViewController.h"
#import "AppDelegate.h"
#import "APIManager.h"
#import "MainViewController.h"

@interface CheckoutWebViewController ()

@end

@implementation CheckoutWebViewController
@synthesize currentFilm = _currentFilm;
@synthesize currentCinemaWithDistance = _currentCinemaWithDistance;
@synthesize currentSession = _currentSession;

-(void)dealloc
{
    if (_webView && [_webView superview]) {
        [_webView removeFromSuperview];
    }
    _webView = nil;
    _finishLoading = nil;
    _lbCinemaTitle = nil;
    _currentSession = nil;
    _currentCinemaWithDistance = nil;
    _currentFilm = nil;
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
    viewName = [NSString stringWithFormat:@"UIWebView_%@",[self.currentCinemaWithDistance.cinema cinema_name]];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    [_webView setScalesPageToFit:YES];
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app setCustomBackButtonForNavigationItem:self.navigationItem];
    [app setTitleLabelForNavigationController:self withTitle:_currentFilm.film_name];
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    frame.size.height -= NAVIGATION_BAR_HEIGHT;
    _webView.frame = frame;
    _webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_webView];
    if (!_finishLoading)
    {
        frame.origin.y = frame.size.height - 40;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
             frame.origin.y = frame.size.height - 85;
        }
        frame.size.height -= frame.origin.y;
        
        _lbCinemaTitle = [[UILabel alloc] initWithFrame:frame];
        NSString *cinemaName= _currentCinemaWithDistance.cinema.cinema_name;
        _lbCinemaTitle.numberOfLines = 0;
        _lbCinemaTitle.textAlignment = UITextAlignmentCenter;
        _lbCinemaTitle.text = [NSString stringWithFormat:@"Đang tải dữ liệu từ rạp:\n%@", cinemaName];
        
        [self.view addSubview:_lbCinemaTitle];
        [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR_AND_TABBAR];
    }
    self.trackedViewName = viewName;
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
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app popViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCurrentSession:(Session *)currentSession
{
    _currentSession = currentSession;
    _webView = [[UIWebView alloc] init];
    NSString *url = nil;
    if (currentSession.session_link || currentSession.session_link.length > 0)
    {
        url = currentSession.session_link;
    }
    NSURLRequest *request= [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [_webView loadRequest:request];
    _webView.delegate = self;
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
        if ([_webView isLoading])
        {
            [_webView stopLoading];
        }
        [_webView setDelegate:nil];
    }
    [super viewWillDisappear:animated];
}



@end
