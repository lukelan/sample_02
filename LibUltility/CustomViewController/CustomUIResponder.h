//
//  CustomUIResponder.h
//  123Phim
//
//  Created by phuonnm on 5/29/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#define TITLE_BAR_HEIGHT 20
#define NAVIGATION_BAR_HEIGHT 44
#define TAB_BAR_HEIGHT 44
#define TOOL_BAR_HEIGHT 40

typedef NS_ENUM(NSInteger, LoadingType)
{
    LOADING_TYPE_FULLSCREEN = 1,
    LOADING_TYPE_WITHOUT_NAVIGATOR,
    LOADING_TYPE_WITHOUT_TABBAR,
    LOADING_TYPE_WITHOUT_NAVIGATOR_AND_TABBAR
};

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "Reachability.h"
#import "DynamicViewController.h"

@interface CustomUIResponder : UIResponder <UIApplicationDelegate, DynamicViewResourceController>
{
    LoadingView * _loadingView;
    Reachability* internetReach;
}

@property (nonatomic,strong) UITabBarController *tabBarController;

- (void)showLoadingViewWithType: (NSInteger) type viewOnTop: (UIView*) view;
- (void)hideLoadingViewForViewOnTop: (UIView*) view;
- (BOOL)checkNetWork;
- (NSDictionary*)getDynamicViewInfoForViewController: (UIViewController *) vc;

@end
