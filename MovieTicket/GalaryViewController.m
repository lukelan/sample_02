//
//  GalaryViewController.m
//  123Phim
//
//  Created by phuonnm on 3/18/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "GalaryViewController.h"
#import "AppDelegate.h"
#import "CustomImageView.h"

@interface GalaryViewController ()

@end

@implementation GalaryViewController
@synthesize dataList = dataList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForViewController:self];
    [delegate setTitleLabelForNavigationController:self withTitle:_film.film_name];
    self.view.backgroundColor = [UIColor blackColor];
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    frame.size.height = frame.size.height - self.navigationController.navigationBar.frame.size.height;
    UIPageScrollView *pageScroll = [[UIPageScrollView alloc] initWithFrame:frame];
    pageScroll.dataSource = self;
    [pageScroll setStartIndex:_currentIndex];
    pageScroll.pageControlUsed = NO;
    [self.view addSubview:pageScroll];
    [pageScroll release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberPageInPageScrollView:(UIPageScrollView *)pageScrollView
{
    return dataList.count;
}

-(PageView *)pageScrollView:(UIPageScrollView *)pageScrollView viewForPageAtIndex:(NSInteger)index
{
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%d", index];
    PageView *page = [pageScrollView dequeueReusablePageWithIdentifier:reuseIdentifier];
    if (page == nil)
    {
        NSString *imageNameURL = [self.film.arrayImageReviews objectAtIndex:index];
         NSString* imageName = [NSString stringWithFormat:@"%@", [[imageNameURL componentsSeparatedByString:@"/"] lastObject]];
        NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"/film_id_%d/%@", [self.film.film_id intValue], imageName]];
        
        CGRect pageFrame = pageScrollView.frame;
        page = [[[PageView alloc] initWithFrame:pageFrame] autorelease];
        UIImage *image = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        {
            image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        }
        if (image)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:pageFrame];
            if (image.size.height > image.size.width)
            {
                imageView.image = [imageView croppedImageWithImage:image scale:YES];
            }
            else
            {
                imageView.image = image;
                imageView.contentMode = UIViewContentModeScaleAspectFit;
            }
            [page addSubview:imageView];
            [imageView release];
        }
        else
        {
            CustomImageView* customimageView = [[CustomImageView alloc] initWithFrame:pageFrame];
            customimageView.filmId = self.film.film_id.intValue;
            customimageView.userInteractionEnabled = NO;
            [customimageView setBackgroundColor:[UIColor clearColor]];
            [customimageView getImageViewFromURLByQueue:[NSURL URLWithString:imageNameURL]];
            [customimageView.layer setBorderColor:[[UIColor grayColor] CGColor]];
            customimageView.layer.borderWidth = 0.5;
            [page addSubview:customimageView];
            [customimageView release];
        }
    }
    return page;
}

-(void)dealloc
{
    [dataList release];
    [_film release];
    [super dealloc];
}

-(void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
}

@end
