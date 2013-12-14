//
//  WellcomeViewController.m
//  123Phim
//
//  Created by phuonnm on 3/13/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "WelcomeViewController.h"
#import "FacebookManager.h"
#import "AppDelegate.h"
#import "APIManager.h"
#import "MainViewController.h"
#import "UIImageView+Action.h"

#define ALERT_LOGIN_SUCCESFUL 10
#define ALERT_LOGIN_FAIL 11

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

-(void) dealloc
{
    dataList = nil;
    lb = nil;
    facebookButton = nil;
    btnSkip = nil;
    _canLaunchApp = nil;
}

@synthesize canLaunchApp = _canLaunchApp;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dataList = [[NSArray alloc] initWithObjects:@"splash.png", nil];
        viewName = WELCOME_VIEW_NAME;
        _canLaunchApp = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    UIPageScrollView *pageScrollView = [[UIPageScrollView alloc] initWithFrame:frame];
    pageScrollView.dataSource = self;
    [pageScrollView setUsePageControl:NO];
    [self.view addSubview:pageScrollView];
    [self addButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleSignInFacebook
{
    FacebookManager *fbHandler = [FacebookManager shareMySingleton];
    [fbHandler loginFacebook:self selector:@selector(getFacebookProfile)];
}

- (void)getFacebookProfile
{
    FacebookManager *fbHandler = [FacebookManager shareMySingleton];
    [fbHandler getFacebookAccountInfoWithResponseContext:self selector:@selector(finishGetFacebookAccountInfo:)];
    
    // turn on loading
    [self showLoadingScreenWithType:LOADING_TYPE_FULLSCREEN];
}

- (void)finishGetFacebookAccountInfo:(id<FBGraphUser>)fbUser
{
    if (fbUser)
    {
        NSString *content = [NSString stringWithFormat:@"Chào mừng %@ đến với 123Phim", [fbUser name]];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"123Phim"
                                                       message:content
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"OK", nil];
        alert.delegate = self;
        alert.tag = ALERT_LOGIN_SUCCESFUL;
        [alert show];
        
        [[APIManager sharedAPIManager] getRequestLoginFaceBookAccountWithContext:[APIManager sharedAPIManager]];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"123Phim"
                                                       message:LOG_IN_FACEBOOK_NOT_SUCESS
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"OK", nil];
        alert.delegate = self;
        alert.tag = ALERT_LOGIN_FAIL;
        [alert show];
    }
    [self hideLoadingView];
}

-(NSInteger)numberPageInPageScrollView:(UIPageScrollView *)pageScrollView
{
    return dataList.count;
}

-(PageView *)pageScrollView:(UIPageScrollView *)pageScrollView viewForPageAtIndex:(NSInteger)index
{
    NSString *reuseIdentifier = [NSString stringWithFormat:@"pageView"];
    PageView *page = [pageScrollView dequeueReusablePageWithIdentifier:reuseIdentifier];
    if (page == nil)
    {
        CGRect pageFrame = pageScrollView.frame;
        page = [[PageView alloc] initWithFrame:pageFrame];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:pageFrame];
        UIImage *image = [UIImage imageNamed:[dataList objectAtIndex:index]];
        imageView.image = image; //[imageView croppedImageWithImage:image scale:YES];
        [page addSubview:imageView];
    }
    return page;
}

-(void) startApp: (id) object
{
    int count = 0;
    if (object == btnSkip) {
        count = [[APIManager getValueForKey:KEY_STORE_NUMBER_LOGIN_SKIP] integerValue];
        count++;
    }
    [APIManager setValueForKey:[NSNumber numberWithInt:count] ForKey:KEY_STORE_NUMBER_LOGIN_SKIP];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.view.window setRootViewController:app.tabBarController];
    if(object && [object respondsToSelector:@selector(dismissAnimated:)])
    {
        [object dismissAnimated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case ALERT_LOGIN_SUCCESFUL:
        {
            [self startApp:alertView];
        }
            break;
        case ALERT_LOGIN_FAIL:
        {
            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        }
            break;
        default:
            break;
    }
    
    // turn off loading
    [self hideLoadingView];
}

-(void)addButtons
{
    NSInteger buttonHeight = 40;
    if (_canLaunchApp)
    {
//        facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        facebookButton.frame = CGRectMake(0, self.view.frame.size.height - buttonHeight, self.view.frame.size.width / 2, buttonHeight);
//        [facebookButton setBackgroundImage:[UIImage imageNamed:@"sign_in_facebook_button.png"] forState:UIControlStateNormal];
//        [facebookButton addTarget:self action:@selector(handleSignInFacebook) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:facebookButton];
//        btnSkip = [UIButton buttonWithType: UIButtonTypeRoundedRect];
//        [btnSkip setBackgroundImage:[UIImage imageNamed:@"sign_in_button.png"] forState:UIControlStateNormal];
//        //    [btnSkip setTitle:@"Trải nghiệm" forState:UIControlStateNormal];
//        CGRect frame = facebookButton.frame;
//        frame.origin.x = frame.size.width;
//        [btnSkip addTarget:self action:@selector(startApp:) forControlEvents:UIControlEventTouchUpInside];
//        btnSkip.frame = frame;
//        [self.view addSubview:btnSkip];
    }
    else
    {
        if (!lb.superview)
        {
            [self.view addSubview:lb];
        }
    }
}

-(void)setLoadingStateString:(NSString *)str
{
    if (!lb)
    {
        CGRect frame = self.view.frame;
        frame.size.height = 40;
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        lb = [[UILabel alloc] initWithFrame:frame];
        lb.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.3];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.textColor = [UIColor whiteColor];
        lb.font = [UIFont getFontNormalSize13];
        [self.view addSubview:lb];
    }
    lb.text = str;
}

@end
