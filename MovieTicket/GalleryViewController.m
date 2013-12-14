//
//  GalaryViewController.m
//  123Phim
//
//  Created by phuonnm on 3/18/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "GalleryViewController.h"
#import "AppDelegate.h"
#import "GalleryPageView.h"
#import "UIViewController+TabBarAnimation.h"

@interface GalleryViewController ()

@end

@implementation GalleryViewController
@synthesize dataList = dataList;
@synthesize film = _film;
@synthesize currentIndex = _currentIndex;

-(void)dealloc
{
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
    }
    dataList = nil;
    httpRequest = nil;
    _naviBarHidden = nil;
    _currentIndex = nil;
    _film = nil;
    _naviBarHidden = 0;
    httpRequest = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        viewName = GALAXY_VIEW_NAME;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    [self handleGesture:nil];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:_film.film_name];
    self.view.backgroundColor = [UIColor blackColor];
    CGRect frame = self.view.frame;
    frame.origin.y = -self.navigationController.navigationBar.frame.size.height;
//    frame.size.height = frame.size.height + self.navigationController.navigationBar.frame.size.height;
    UIPageScrollView *pageScroll = [[UIPageScrollView alloc] initWithFrame:frame];
    pageScroll.dataSource = self;
    [pageScroll setStartIndex:_currentIndex];
    pageScroll.usePageControl = NO;
    [self.view addSubview:pageScroll];
    self.trackedViewName = viewName;
//    NSString* previewView = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).currentView;
//    NSString* currentView = viewName;
//    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:currentView comeFrom:previewView withActionID:LOG_ACTION_ID_VIEW currentFilmID:self.film.film_id currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID] returnCodeValue:0 context:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(NSInteger)numberPageInPageScrollView:(UIPageScrollView *)pageScrollView
{
    if (self.film.arrayImageReviews == nil || self.film.arrayImageReviews.count == 0) {
        self.film.arrayImageReviews = [self.film.list_image_review componentsSeparatedByString:@"∂"];
    }
    return _film.arrayImageReviews.count;
}

-(PageView *)pageScrollView:(UIPageScrollView *)pageScrollView viewForPageAtIndex:(NSInteger)index
{
    NSString *reuseIdentifier = [NSString stringWithFormat:@"page"];
    PageView *page = [pageScrollView dequeueReusablePageWithIdentifier:reuseIdentifier];
    if (!page)
    {
        page = [[GalleryPageView alloc] initWithFrame:pageScrollView.bounds];
    }
    NSString *imageURL = [self.film.arrayImageReviews objectAtIndex:index];
    NSString *imageThumbnailURL = [self.film.arrayImageThumbnailReviews objectAtIndex:index];
    [((GalleryPageView *) page) setImageURL:imageURL imageThumbnailURL:imageThumbnailURL];
    
    return page;
}

-(void)handleGesture:(UIGestureRecognizer*) gesture
{
    _naviBarHidden = !_naviBarHidden;
    if (_naviBarHidden)
    {
        [self performHideNavigatorBar];
    }
    else
    {
        [self performShowNavigatorBar];
    }
}

-(void)setHTTPRequest: (ASIHTTPRequest *) theRequest
{
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
    }
    httpRequest = theRequest;
}

-(void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
}

@end
