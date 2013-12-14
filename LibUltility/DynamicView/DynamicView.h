//
//  DynamicView.h
//  123Phim
//
//  Created by phuonnm on 6/21/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_ID @"sub_view"
#define DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_FRAME @"frame"
#define DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_TITLE_TEXT @"title_text"
#define DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_TITLE_TEXT_COLOR @"title_text_color"
#define DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_BACKGROUND_COLOR @"background_color"
#define DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_BACKGROUND_IMAGE @"background_image"
#define DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_ACTION @"action"
#define DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_SUB_VIEW @"sub_view"
// ACTION INFO
#define DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_ACTION_VIEW_CONTROLLER_NAME @"action_view_controller_name"
#define DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_ACTION_VIEW_CONTROLLER_SELECTOR_LIST @"action_view_controller_selector_list"
#define DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_ACTION_VIEW_CONTROLLER_SELECTOR @"action_view_controller_selector"
#define DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_ACTION_VIEW_CONTROLLER_SELECTOR_PARAM @"action_view_controller_selector_param"
#define DYNAMIC_VIEW_LIST_VIEW_CONTROLLER @"view_controller_name_will_show"
#define DYNAMIC_VIEW_INFO @"dynamic_view_info"

@class DynamicView;

@protocol DynamicViewDelegate <NSObject>

-(void)sendActionWithView: (DynamicView *)view;

@end

@interface DynamicView : UIView
{
    NSOperationQueue *queue;
    UIImageView *_backgroundImageView;
}

@property (nonatomic, retain) NSDictionary *properties;
@property (nonatomic, assign) id<DynamicViewDelegate> delegate;

@end
