//
//  PagePhotosView.m
//  PagePhotosDemo
//
//  Created by junmin liu on 10-8-23.
//  Copyright 2010 Openlab. All rights reserved.
//

#define NUMBER_WILL_SCROLL_AROUND 2

#import "UIPageScrollView.h"
#import "PageView.h"

@implementation UINewScrollView

@end

@interface UIPageScrollView (PrivateMethods)

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

@end

@implementation UIPageScrollView
@synthesize dataSource = _dataSource, delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        // Initialization UIScrollView
        _pageControlOffsetY = frame.size.height;
        int pageControlHeight = 20;
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _pageControlOffsetY - pageControlHeight, self.frame.size.width, pageControlHeight)];
        _scrollView = [[UINewScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _usePageControl = YES;
        timerOnStopState = YES;
        _startIndex = 0;
        _visiblePages = [[NSMutableArray alloc] init];
        _reusablePages = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (int)validPageValue:(NSInteger)value {
    NSInteger totalPage = [self.dataSource numberPageInPageScrollView:self];
    if(value < 0)
    {
        return totalPage - 1;
    }
    if(value >= totalPage)
    {
        return 0;
    }
    return value;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // skip when set content size
    if (!_visiblePages  || [_visiblePages count] == 0)
    {
        return;
    }
    CGFloat pageWidth = _scrollView.frame.size.width;
    NSInteger curPage = pageControl.currentPage;
    NSInteger mul = pageControl.numberOfPages >= NUMBER_WILL_SCROLL_AROUND ? 2 : 1;
    if (_scrollView.contentOffset.x ==  mul * pageWidth)
    {
        if (pageControl.numberOfPages >= NUMBER_WILL_SCROLL_AROUND || curPage < NUMBER_WILL_SCROLL_AROUND - 1)
        {
            curPage = [self convertDataIndexFromViewIndex:curPage + 1];
            pageControl.currentPage = curPage;
            [self refreshScrollView:NO];
        }
    }
    if(_scrollView.contentOffset.x == 0)
    {
        if (pageControl.numberOfPages >= NUMBER_WILL_SCROLL_AROUND || curPage > 0)
        {
            curPage = [self convertDataIndexFromViewIndex:curPage-1];
            pageControl.currentPage = curPage;
            [self refreshScrollView:NO];
        }
    }
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)sender
{
    [self updateTimer2StopState:YES];
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender
{
    [self updateTimer2StopState:NO];
    CGFloat pageWidth = _scrollView.frame.size.width;
    NSInteger curPage = pageControl.currentPage;
    NSInteger mul = pageControl.numberOfPages >= NUMBER_WILL_SCROLL_AROUND ? 2 : 1;
    if (_scrollView.contentOffset.x >  mul * pageWidth)
    {
        curPage = [self convertDataIndexFromViewIndex:curPage + 1];
        pageControl.currentPage = curPage;
        [self refreshScrollView:NO];
    }
    if(_scrollView.contentOffset.x < 0) {
        curPage = [self convertDataIndexFromViewIndex:curPage-1];
        pageControl.currentPage = curPage;
        [self refreshScrollView:NO];
    }
}

- (void)dealloc
{
	[_scrollView release];
	[pageControl release];
    [_reusablePages release];
    [_visiblePages release];
    _visiblePages = nil;
    _scrollView = nil;
    pageControl = nil;
    _reusablePages = nil;
    _dataSource = nil;
    _delegate = nil;
    [super dealloc];
}

- (PageView *)dequeueReusablePageWithIdentifier:(NSString *)identifier  // Used by the delegate to acquire an already allocated page, instead of allocating a new one
{
	NSMutableArray *reusablePages = [_reusablePages objectForKey:identifier];
    if (reusablePages)
    {
        for (PageView *reusablePage in reusablePages)
        {
            if (![_visiblePages containsObject:reusablePage])
            {
                return reusablePage;
            }
        }
    }
	return nil;
}

- (void) reloadData
{
    if (!_scrollView.superview)
    {
        [self addSubview:_scrollView];
    }
    // reset data
    NSArray *subViews = _scrollView.subviews;
    if (subViews.count != 0)
    {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_visiblePages removeAllObjects];
    }
    
    _needReloadData = NO;
    if (self.usePageControl)
    {
        int pageControlHeight = 20;
        CGRect frame = pageControl.frame;
        frame.origin.y = _pageControlOffsetY - pageControlHeight;
        pageControl.frame = frame;
        pageControl.userInteractionEnabled = NO;
        if (!pageControl.superview)
        {
            [self addSubview:pageControl];
        }
    }
    int kNumberOfPages = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberPageInPageScrollView:)])
    {
        kNumberOfPages = [self.dataSource numberPageInPageScrollView: self];
    }
    
    // a page is the width of the scroll view
    _scrollView.pagingEnabled = YES;
    NSInteger mul = kNumberOfPages;
    if (kNumberOfPages > 1)
    {
        mul = 3;
    }
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * mul, 0);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.delegate = self;
    
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.currentPage = _startIndex;
//    pageControl.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.2];
    pageControl.backgroundColor = [UIColor clearColor];
    
    [self refreshScrollView:YES];
}

-(NSInteger) convertDataIndexFromViewIndex: (NSInteger) index
{
    if (index < 0)
    {
        index = pageControl.numberOfPages + index;
    }
    if (index >= pageControl.numberOfPages)
    {
        index = index - pageControl.numberOfPages;
    }
    return index;
}

//load visible pages

-(void)refreshScrollView:(BOOL) reload
{
    NSInteger selectedIndex = pageControl.currentPage;
    NSInteger numberOfPages = pageControl.numberOfPages;
    
    if (!reload && _visiblePages.count > 0)
    {
        if (numberOfPages >= NUMBER_WILL_SCROLL_AROUND)
        {
            NSInteger mul = 1, vIndex = 0;;
            PageView *page = nil;
            if (_presentSelectedIndex == selectedIndex + 1 || (selectedIndex == numberOfPages - 1 && _presentSelectedIndex == 0))
            {
                // right direction
                page = [_visiblePages lastObject];
            }
            else
            {
                // left direction
                page = [_visiblePages objectAtIndex:0];
                mul = -1;
                vIndex = 2;
            }
            [page removeFromSuperview];
            [_visiblePages removeObject:page];
            
            CGPoint offset = CGPointMake(_scrollView.frame.size.width, 0);
            [_scrollView setContentOffset:offset animated:NO];
            
            
            [_visiblePages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self shiftPage:obj withOffset:mul * _scrollView.frame.size.width];
            }];
            
            PageView *newPage = [self loadPageAtIndex:[self convertDataIndexFromViewIndex:selectedIndex - mul] insertIntoVisibleIndex:vIndex];
            [self setFrameForPage:newPage atIndex:vIndex];
            [_scrollView addSubview:newPage];
        }
        _presentSelectedIndex = selectedIndex;
        return;
    }
    
//    remove all page on scrollview
    NSArray *subViews = _scrollView.subviews;
    if (subViews.count != 0)
    {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_visiblePages removeAllObjects];
    }
    
    if (numberOfPages > 0)
    {
        for (int i = -1; i < 2; i++)
        {
            PageView *newPage = [self loadPageAtIndex:[self convertDataIndexFromViewIndex:selectedIndex + i] insertIntoVisibleIndex:i + 1];
            [self setFrameForPage:newPage atIndex:i + 1];
            //        add to scrollView

            [_scrollView addSubview:newPage];
        }
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
        _presentSelectedIndex = selectedIndex;
    }
}

-(void)setAutoUpdatedPageTime:(CGFloat)updateTime
{
    _autoUpdatedPageTime = updateTime;
    [self updateTimer2StopState:NO];
}

-(void) updateTimer2StopState: (BOOL) stop
{
    if (_autoUpdatedPageTime > 1.0)
    {
        if (stop)
        {
            if (!timerOnStopState)
            {
                timerOnStopState = YES;
                [timer invalidate];
                timer = nil;
            }
        }
        else if (timerOnStopState)
        {
//            start new timer
            timerOnStopState = NO;
            timer = [[NSTimer scheduledTimerWithTimeInterval:_autoUpdatedPageTime target:self selector:@selector(needUpdateScrollView) userInfo:nil repeats:YES] retain];
        }
    }
}

-(void)needUpdateScrollView
{
    NSInteger curPage = pageControl.currentPage + 1;
    NSInteger num = 0;
    if (self.dataSource && [self.dataSource numberPageInPageScrollView:self])
    {
        num = [self.dataSource numberPageInPageScrollView:self];
    }
    else
    {
        return;
    }
    if (curPage >= num)
    {
        curPage = 0;
    }
    pageControl.currentPage = curPage;
    [self refreshScrollView:NO];
}


-(oneway void)release
{
    [timer invalidate];
    timer = nil;
    [super release];
}

-(NSInteger)getCurrentIndex
{
    return pageControl.currentPage;
}

-(void) shiftPage : (UIView*) page withOffset : (CGFloat) offset
{
    CGRect frame = page.frame;
    frame.origin.x += offset;
    page.frame = frame;    
}

-(void)setFrameForPage:(UIView*) page atIndex:(NSInteger)index
{
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * (index);
    frame.origin.y = 0;
    page.frame = frame;
}

- (PageView*) loadPageAtIndex : (NSInteger) index insertIntoVisibleIndex : (NSInteger) visibleIndex
{
	PageView *visiblePage = [self.dataSource pageScrollView:self viewForPageAtIndex:index];
	if (visiblePage.reuseIdentifier) {
		NSMutableArray *reusables = [_reusablePages objectForKey:visiblePage.reuseIdentifier];
		if (!reusables) {
			reusables = [[[NSMutableArray alloc] initWithCapacity : 4] autorelease];
		}
		if (![reusables containsObject:visiblePage]) {
			[reusables addObject:visiblePage];
		}
		[_reusablePages setObject:reusables forKey:visiblePage.reuseIdentifier];
	}
	
	// add the page to the visible pages array
	[_visiblePages insertObject:visiblePage atIndex:visibleIndex];
    
    return visiblePage;
}

-(void)layoutSubviews
{
    if (_needReloadData)
    {
        [self reloadData];
    }
}

-(void)setDataSource:(id<UIPageScrollDataSource>)dataSource
{
    if (_dataSource != dataSource)
    {
        _dataSource = dataSource;
        _needReloadData = YES;
    }
}
@end
