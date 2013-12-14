//
//  SliderViewImage.h
//  MovieTicket
//
//  Created by Nhan Ho Thien on 2/6/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomImageView.h"
#import "Film.h"
#import "AppDelegate.h"
@interface SliderViewImage : UIViewController<UIScrollViewDelegate>{
    UIScrollView *scroolView;
}
@property int tapGesture;
@property(retain,nonatomic)  UIScrollView *scroolView;
@property(retain,nonatomic)  UIPageControl *pageControl;
@property (nonatomic,retain) CustomImageView *customimageView;
@property (nonatomic, retain) Film* film;
@property(nonatomic,retain) NSMutableArray *arrImageFilm;
@end
