//
//  PagePhotosView.h
//  PagePhotosDemo
//
//  Created by junmin liu on 10-8-23.
//  Copyright 2010 Openlab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageView.h"
@class UIPageScrollView;

@protocol UIPageScrollDataSource <NSObject>

- (NSInteger) numberPageInPageScrollView:(UIPageScrollView *) pageScrollView;

- (PageView *) pageScrollView:(UIPageScrollView *) pageScrollView viewForPageAtIndex: (NSInteger) index;

@end

@protocol UIPageScrollDelegate <NSObject>

- (void) pageScrollView:(UIPageScrollView *) pageScrollView didSelectPageAtIndex: (NSInteger) index;

@end

@interface UINewScrollView : UIScrollView

@end

@interface UIPageScrollView : UIView<UIScrollViewDelegate>
{
	UIScrollView *_scrollView;
	UIPageControl *pageControl;
	NSMutableDictionary *_reusablePages;
    NSMutableArray *_visiblePages;
	__weak id<UIPageScrollDataSource> _dataSource;
    __weak id<UIPageScrollDelegate> _delegate;
    NSTimer *timer;
    BOOL timerOnStopState;
    NSInteger _presentSelectedIndex;
    BOOL _needReloadData;
}

@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, assign) CGFloat autoUpdatedPageTime;
@property (assign) BOOL usePageControl; // default is YES
@property (nonatomic, weak) id<UIPageScrollDataSource> dataSource;
@property (nonatomic, weak) id<UIPageScrollDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *imageViews;
@property (nonatomic) NSInteger pageControlOffsetY;


- (id)initWithFrame:(CGRect)frame;
- (PageView *)dequeueReusablePageWithIdentifier:(NSString *)identifier;  // Used by the delegate to acquire an already allocated page, instead of allocating a new one
-(void)reloadData;
-(NSInteger)getCurrentIndex;

@end
