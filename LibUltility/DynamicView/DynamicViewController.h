//
//  DynamicViewController.h
//  123Phim
//
//  Created by phuonnm on 6/24/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DynamicView.h"
#import "CustomViewController.h"

@protocol DynamicViewResourceController <NSObject>

@optional

-(void) pushViewControllerWithActionInfo: (NSDictionary *)actionInfo;

@end

@interface DynamicViewController : UIViewController <DynamicViewDelegate, UIGestureRecognizerDelegate>
{
    DynamicView *_dynamicView;
}

@property(nonatomic, retain) NSDictionary *properties;
@property(nonatomic, assign) UINavigationController *navigationControllerToPush;
@property(nonatomic, assign) id<DynamicViewResourceController> resourceController;

-(void)sendActionWithView: (DynamicView *)view;

@end
