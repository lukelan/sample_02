//
//  PromotionViewController.m
//  123Phim
//
//  Created by Le Ngoc Duy on 3/20/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"
#import "APIManager.h"
#import "PromotionInfoCell.h"
#import "GAI.h"

@interface PromotionDetailViewController : CustomGAITrackedViewController<UITableViewDelegate,UITableViewDataSource, PromotionDetailViewDelegate, RKManagerDelegate>
{
    UITableView *_tableview;
}
@property(nonatomic,strong) UITableView *tableview;
@property(nonatomic,strong) News * myNews;
@end
