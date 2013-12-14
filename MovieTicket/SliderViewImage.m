//
//  SliderViewImage.m
//  MovieTicket
//
//  Created by Nhan Ho Thien on 2/6/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "SliderViewImage.h"
#import "AppDelegate.h"
#import "DefineConstant.h"
@interface SliderViewImage ()

@end

@implementation SliderViewImage
@synthesize scroolView,customimageView,film,arrImageFilm,pageControl,tapGesture;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      //  [self setBackGroundImage:@"header-bar.png" forNavigationBar:navCinema.navigationBar];

      
          }
    return self;
}
#pragma mark Value Change
-(void)pageControlScroll{
//    NSLog(@"helo page value change");
    int page=pageControl.currentPage;
    CGRect frame=scroolView.frame;
    frame.origin.x=frame.size.width=page;
    frame.origin.y=0;
    [scroolView scrollRectToVisible:frame animated:YES];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x/scrollView.frame.size.width;
    pageControl.currentPage=page;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray* imageArray = self.film.arrayImageThumbnailReviews;
    NSInteger numberOfPic = [imageArray count];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForPresentModalNavigationItem:self.navigationItem];
    [delegate setBackGroundImage:@"header-bar.png" forNavigationBar:self.navigationController.navigationBar];
    [delegate setTitleLabelForNavigationController:self withTitle:film.film_name];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.navigationController.navigationBar.hidden=YES;
    [self.view setBackgroundColor:[UIColor blackColor]];
    scroolView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height-HEIGHT_IMAGE)/2, 320, HEIGHT_IMAGE)];
    [self.view addSubview:scroolView];
    pageControl =[[UIPageControl alloc] initWithFrame:CGRectMake(0, 340, 320, 30)];
    [pageControl setBackgroundColor:[UIColor redColor]];
    [pageControl setNumberOfPages:[imageArray count]];
    [pageControl addTarget:self action:@selector(pageControlScroll) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview: pageControl];
    [scroolView setBackgroundColor:[UIColor grayColor]];
  
    scroolView.delegate=self;

    for(int i=0;i< [film.arrayImageThumbnailReviews count];i++)
    {
        CGRect frameImg=CGRectMake(i*320,0, 320,HEIGHT_IMAGE) ;
        customimageView= [[CustomImageView alloc] initWithFrame:frameImg];
        [customimageView setBackgroundColor:[UIColor clearColor]];
        [customimageView getImageViewFromURLByQueue:[NSURL URLWithString:[film.arrayImageThumbnailReviews objectAtIndex:i]]];
        [scroolView  addSubview:customimageView];
        [customimageView release];
    }
    [scroolView setContentSize:CGSizeMake((320*(numberOfPic)), HEIGHT_IMAGE)];
    [scroolView setIndicatorStyle:UIScrollViewIndicatorStyleBlack];
    scroolView.pagingEnabled=YES;
    self.scroolView.showsHorizontalScrollIndicator = NO;
    self.scroolView.showsVerticalScrollIndicator = NO;
    self.scroolView.scrollsToTop = NO;
  //  pageControl.numberOfPages=9;
    pageControl.hidden=YES;
    pageControl.currentPage=0;
	// Do any additional setup after loading the view.
    UITapGestureRecognizer *myTapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ShowHideNavigation)];
    [self.view addGestureRecognizer:myTapGesture];
    [myTapGesture release];
   self.tapGesture=1;

}
-(void)ShowHideNavigation{
    
    if(tapGesture %2==1){
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        self.navigationController.navigationBar.hidden=NO;
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        self.navigationController.navigationBar.hidden=YES;
    }
    tapGesture++;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
