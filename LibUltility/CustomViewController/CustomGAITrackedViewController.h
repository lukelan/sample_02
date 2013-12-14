//
//  CustomGAITrackedViewController.h
//  123Phim
//
//  Created by phuonnm on 5/28/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "ASIHTTPRequest.h"
#import "TabBarDisplayType.h"

@class DynamicViewController;

typedef NS_ENUM(NSInteger, TypeStatus)
{
    STATUS_WAITING_RESULT = 0,
    STATUS_RESULT_FAILED,
    STATUS_RESULT_SUCCESS,
    STATUS_WAITING_INPUT_OTP,
    STATUS_OUT_RANGE //dung gia tri nay de biet khong set den truong hop nay
};

@interface CustomGAITrackedViewController : GAITrackedViewController <UITableViewDelegate, ASIHTTPRequestDelegate>
{
    CGPoint _presentOffset;
    NSInteger _loadingScreenType;
    BOOL _autoShowHideTabBar;
    NSString* viewName;
    BOOL _skipUpdateTabBar;
    DynamicViewController *_dynamicVC;
    BOOL _tabBarHiden;
}
@property (nonatomic, assign) BOOL isSkipWarning;
@property (nonatomic, assign) TypeStatus typeStatus;
@property (nonatomic, assign) TabBarDisplayType tabBarDisplayType;
@property (nonatomic, strong) NSString* viewName;
@property (nonatomic, strong) UIButton *btnNote;

-(void)hideLoadingView;
-(void)showLoadingScreenWithType:(NSInteger)type;
-(void)showDynamicViewWithProperties: (NSDictionary *)properties;
- (void)cleanWarning;
@end
