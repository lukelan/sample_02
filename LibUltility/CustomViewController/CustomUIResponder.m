//
//  CustomUIResponder.m
//  123Phim
//
//  Created by phuonnm on 5/29/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CustomUIResponder.h"
#import "LoadingView.h"

@implementation CustomUIResponder
@synthesize tabBarController = _tabBarController;

- (void)showLoadingViewWithType: (NSInteger) type viewOnTop: (UIView*) view
{
//    if (![self checkNetWork])
//    {
//        return;
//    }
    CGSize window = [UIScreen mainScreen].bounds.size;
    CGRect frame = CGRectMake(0, 0, window.width, window.height);
    frame.origin.y = TITLE_BAR_HEIGHT;
    switch (type)
    {
        case LOADING_TYPE_WITHOUT_NAVIGATOR_AND_TABBAR:
        case LOADING_TYPE_WITHOUT_TABBAR:
            if (_tabBarController && !_tabBarController.tabBar.hidden)
            {
                frame.size.height -= TAB_BAR_HEIGHT;
            }
            if (type == LOADING_TYPE_WITHOUT_TABBAR)
            {
                break;
            }
        case LOADING_TYPE_WITHOUT_NAVIGATOR:
            frame.origin.y += NAVIGATION_BAR_HEIGHT;
        case LOADING_TYPE_FULLSCREEN:
            break;
        default:
            return;
    }
    frame.size.height -= frame.origin.y;
    if (!_loadingView)
    {
        _loadingView = [[LoadingView alloc] initWithFrame:frame];
        _loadingView.viewOnTop = view;
    }
    else
    {
        _loadingView.frame = frame;
    }
    [self.window addSubview:_loadingView];
}

- (void)hideLoadingViewForViewOnTop: (UIView*) view
{
    if (!_loadingView || !_loadingView.superview || (_loadingView.viewOnTop && view != _loadingView.viewOnTop))
    {
        return;
    }
    [_loadingView removeFromSuperview];
}


-(BOOL) checkNetWork{
    
    NetworkStatus networkStatus = [internetReach currentReachabilityStatus];
//    NSLog(@"network: %d", !(networkStatus == NotReachable));
    return !(networkStatus == NotReachable);
}


-(void)pushViewControllerWithActionInfo:(NSDictionary *)actionInfo
{
    NSLog(@"aaaa");
}

- (NSDictionary*)getDynamicViewInfoForViewController: (UIViewController *) vc
{
    return nil;
}

@end
