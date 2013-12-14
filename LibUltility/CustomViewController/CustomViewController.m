//
//  CustomViewController.m
//  123Phim
//
//  Created by phuonnm on 5/28/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CustomViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomUIResponder.h"
#import "AppDelegate.h"
#import "DynamicViewController.h"
#import "CustomViewControllerDefines.h"
#import "UIViewController+TabBarAnimation.h"

@interface CustomViewController ()

@end

@implementation CustomViewController

@synthesize tabBarDisplayType = _tabBarDisplayType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _skipUpdateTabBar = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *array = self.navigationController.viewControllers;
    if (array.count > 1)
    {
        UIViewController *last = [array lastObject];
        if (last == self)
        {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            [app setCustomBackButtonForNavigationItem:self.navigationItem];
        }
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.currentView = viewName;
    [self showDynamicViewWithProperties:[appDelegate getDynamicViewInfoForViewController:self]];
    if (_loadingScreenType != 0)
    {
        //        show loading screen
        if (_loadingScreenType < 0)
        {
            _loadingScreenType = -_loadingScreenType;
        }
        [self showLoadingView];
    }
    else
    {
        //        hide loading screen
        [self hideLoadingView];
    }
    //        processing tab bar
    if (_tabBarDisplayType == TAB_BAR_DISPLAY_HIDE)
    {
        [self performHideTabBar];
    }
    else
    {
        [self performShowTabBar];
    }
    
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //        processing tab bar
    if (_tabBarDisplayType == TAB_BAR_DISPLAY_HIDE)
    {
        [self performHideTabBar];
    }
    else
    {
        [self performShowTabBar];
    }
}

-(void) showLoadingView
{
    CustomUIResponder *app = (CustomUIResponder *)[[UIApplication sharedApplication] delegate];
    [app showLoadingViewWithType:_loadingScreenType viewOnTop:self.view];
}

-(void) hideLoadingView
{
    _loadingScreenType = 0;
    CustomUIResponder *app = (CustomUIResponder *)[[UIApplication sharedApplication] delegate];
    [app hideLoadingViewForViewOnTop:self.view];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (_loadingScreenType > 0)
    {
        //        hide loading screen
        NSInteger tmp = -_loadingScreenType;
        [self hideLoadingView];
        _loadingScreenType = tmp;
    }
    if (_dynamicVC && _dynamicVC.view.superview)
    {
        [_dynamicVC.view removeFromSuperview];
    }
    [super viewWillDisappear:animated];
}

-(void)showLoadingScreenWithType:(NSInteger)type
{
    if (_loadingScreenType == type)
    {
        return;
    }
    
    _loadingScreenType = type;
    
    if (_loadingScreenType)
    {
        [self showLoadingView];
    }
    else
    {
        [self hideLoadingView];
    }
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_tabBarDisplayType != TAB_BAR_DISPLAY_AUTO)
    {
        return;
    }
    CGSize contentSize = scrollView.contentSize;
    if (contentSize.height < scrollView.frame.size.height * SIZE_RATE_TO_AUTO_SHOW_OR_HIDE_TAB_BAR)
    {
        _autoShowHideTabBar = NO;
        [self performHideTabBar];
        return;
    }
    _autoShowHideTabBar = YES;
    _presentOffset = scrollView.contentOffset;
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    _skipUpdateTabBar = NO;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_autoShowHideTabBar || _skipUpdateTabBar)
    {
        return;
    }
    CGPoint offset = scrollView.contentOffset;
    if (offset.y - _presentOffset.y < 0)
    {
        [self performShowTabBar];
    }
    else
    {
        [self performHideTabBar];
    }
    _presentOffset = scrollView.contentOffset;
    _skipUpdateTabBar = YES;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!_autoShowHideTabBar)
    {
        return;
    }
    _skipUpdateTabBar = NO;
    _presentOffset = scrollView.contentOffset;
}

-(void)setTabBarDisplayType:(TabBarDisplayType)hideTabBarDisplayType
{
    _tabBarDisplayType = hideTabBarDisplayType;
    if (hideTabBarDisplayType == TAB_BAR_DISPLAY_AUTO)
    {
        _autoShowHideTabBar = NO;
    }
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    //    NSData *data = request.responseData;
    //    NSString *pathFile = [NSString stringWithFormat:@"%@/request.csv", GALLERY_PATH];
    //    NSError *error = nil;
    //    NSString *dString = [NSString stringWithContentsOfFile:pathFile encoding:NSUTF8StringEncoding error:&error];
    //    if (error)
    //    {
    //        dString = @"";
    //    }
    //    NSString *info = [NSString stringWithFormat:@"\"%@\",%d\r", request.url, data.length];
    //    dString = [dString stringByAppendingString:info];
    //    [dString writeToFile:pathFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [self hideLoadingView];
    NSLog(@"Request Fail: %@, error: %@", request.url, request.error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:ALERT_CONNECTION_FAIL delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

-(void)showDynamicViewWithProperties: (NSDictionary *)properties
{
    if (!properties || (_dynamicVC
//                        && _dynamicVC.view.superview //remove to dont show when back
                        ))
    {
        return;
    }
    _dynamicVC = [[DynamicViewController alloc] init];
    _dynamicVC.resourceController = (CustomUIResponder *)[[UIApplication sharedApplication] delegate];
    _dynamicVC.properties = properties;
    [_dynamicVC setNavigationControllerToPush:self.navigationController];
    [self.view.window addSubview:_dynamicVC.view];
}

@end
