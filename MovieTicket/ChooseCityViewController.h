//
//  ChooseCityViewController.h
//  MovieTicket
//
//  Created by Nhan Mai on 3/4/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIManager.h"
#import "Location.h"
#import "GAI.h"
#import "CustomGAITrackedViewController.h"


@interface ChooseCityViewController : CustomGAITrackedViewController<UITableViewDataSource, UITableViewDelegate, RKManagerDelegate>
{
}
@property (nonatomic, strong) UITableView* table;
@property (nonatomic, strong) NSMutableArray* listOfCity;
@property (nonatomic, strong) Location* chosenCity;
@property (nonatomic, strong) NSString* fromView;
-(void)setFullScreen;
@end
