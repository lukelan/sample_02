//
//  BarCodeViewController.h
//  123Phim
//
//  Created by phuonnm on 6/14/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface BarCodeViewController : CustomViewController<UIScrollViewDelegate>

@property (nonatomic, strong) NSString *encodeString;
@property (nonatomic, strong) UIImageView *myImageView;
@property (nonatomic, strong) UIScrollView *myScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@end
