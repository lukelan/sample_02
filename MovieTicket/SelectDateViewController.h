//
//  SelectDateViewController.h
//  MovieTicket
//
//  Created by Le Ngoc Duy on 3/28/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "CustomGAITrackedViewController.h"

@protocol SelectDateViewControllerDelegate <NSObject>
-(void)receiveNumberStepDayFromNow:(int)stepDay;
@end

@interface SelectDateViewController : CustomGAITrackedViewController<UITableViewDataSource, UITableViewDelegate>
{
    __weak id<SelectDateViewControllerDelegate>_selectDateDelegate;
}
@property int indexSelectedDate;
@property (nonatomic, strong) NSDate* dateOfNearestSession;
@property (nonatomic, strong) UITableView* myTableView;
@property (nonatomic, weak) id<SelectDateViewControllerDelegate> selectDateDelegate;
-(void)setFullScreen;
@end
