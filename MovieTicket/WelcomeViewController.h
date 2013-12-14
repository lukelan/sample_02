//
//  WellcomeViewController.h
//  123Phim
//
//  Created by phuonnm on 3/13/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPageScrollView.h"
#import "CustomViewController.h"

@interface WelcomeViewController : CustomViewController <UIPageScrollDataSource, UIAlertViewDelegate>
{
    NSArray *dataList;
    UILabel *lb;
    UIButton* facebookButton;
    UIButton *btnSkip;
}

@property (nonatomic) BOOL canLaunchApp;
-(void)setLoadingStateString: (NSString *) str;

@end
