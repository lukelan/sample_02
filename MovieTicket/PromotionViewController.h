//
//  PromotionViewController.m
//  123Phim
//
//  Created by Le Ngoc Duy on 3/20/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIManager.h"
#import "GAI.h"

#define NOTIFICATION_NAME_PROMOTION_LIST_DID_LOAD @"NOTIFICATION_NAME_PROMOTION_LIST_DID_LOAD"

@interface PromotionViewController : CustomGAITrackedViewController<UITableViewDelegate,UITableViewDataSource,RKManagerDelegate>{
    UITableView *_tableview;
    NSMutableArray * _myArrayNews;
    NSTimeInterval lastTimeLoading;
}
@property(nonatomic,strong) UITableView *tableview;
@property(nonatomic,strong) NSMutableArray * myArrayNews;

+(PromotionViewController*)sharedPromotionViewController;
-(void)pushPromotionDetailViewFor:(News*)promotion;

@end
