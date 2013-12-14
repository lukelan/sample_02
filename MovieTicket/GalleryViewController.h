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
#import "GAI.h"
#import "APIManager.h"

@interface GalleryViewController : CustomGAITrackedViewController <UIPageScrollDataSource, APIManagerDelegate>
{
    NSArray *dataList;
    ASIHTTPRequest *httpRequest;
    BOOL _naviBarHidden;
}
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, strong) Film *film;

@end
