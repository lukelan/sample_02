//
//  AdViewController.m
//  123Phim
//
//  Created by phuonnm on 9/23/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "AdViewController.h"
#import "AppDelegate.h"
@interface AdViewController ()

@end

@implementation AdViewController

- (void)dealloc {
    if (self.wvContent)
    {
        [self.wvContent stopLoading];
    }
   _contentUrl = nil;
   _wvContent = nil;
}

@synthesize wvContent = _wvContent;

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
    viewName = AD_VIEW_CONTROLLER;
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    AppDelegate *app = ((AppDelegate *)[[UIApplication sharedApplication]delegate]);
    [app setCustomBackButtonForNavigationItem:self.navigationItem];
    [self.navigationController setTitle:self.title];
    BOOL addParam = [self.contentUrl rangeOfString:@"?"].location != NSNotFound;
    NSString *url;
    if (addParam)
    {
        url = [NSString stringWithFormat:@"%@&skipapp=1", self.contentUrl];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@?skipapp=1", self.contentUrl];
    }
    
    [self.wvContent loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [self.wvContent setDelegate:self];
    [self.wvContent setScalesPageToFit:YES];
    [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWvContent:nil];
    [super viewDidUnload];
   
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideLoadingView];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideLoadingView];
}

@end
