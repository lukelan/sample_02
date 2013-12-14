//
//  GalaryViewController.h
//  123Phim
//
//  Created by phuonnm on 3/18/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPageScrollView.h"
#import "Film.h"

@interface GalaryViewController : UIViewController <UIPageScrollDataSource>
{
    NSArray *dataList;
}
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, retain) NSArray *dataList;
@property (nonatomic, retain) Film *film;

@end
