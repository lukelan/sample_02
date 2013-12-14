//
//  ImageIconViewController.m
//  MovieTicket
//
//  Created by Nhan Mai on 3/1/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "ImageIconViewController.h"

#import "AppDelegate.h"
#import <malloc/malloc.h>
#import "GalleryViewController.h"

@interface ImageIconViewController ()

@end

@implementation ImageIconViewController
@synthesize listOfImageURL, listOfOrigionImage, scrollView, filmTitle;
@synthesize idFilm, listOfImageName;

- (void)dealloc
{
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
    }
    [listOfOrigionImage removeAllObjects];
    [listOfImageName removeAllObjects];
    httpRequest = nil;
    _film = nil;
    listOfImageURL = nil;
    scrollView = nil;
    filmTitle = nil;
    idFilm = 0;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        listOfImageURL = [[NSArray alloc] init];
        listOfOrigionImage = [[NSMutableArray alloc] init];
        scrollView  = [[UIScrollView alloc] initWithFrame:CGRectMake(2, 0, 318, [[UIScreen mainScreen] bounds].size.height - TITLE_BAR_HEIGHT - TAB_BAR_HEIGHT)];
        scrollView.userInteractionEnabled = YES;
        [scrollView setBackgroundColor:[UIColor blackColor]];
        filmTitle   = @"";
        listOfImageName = [[NSMutableArray alloc] init];
        viewName = GALAXY_THUMNAIL_VIEW_NAME;
    }
    return self;
}

-(void)setHTTPRequest: (ASIHTTPRequest *) theRequest
{
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
    }
    httpRequest = theRequest;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
	// Do any additional setup after loading the view.
    //set navigation tittle
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:self.filmTitle];
    
    [self initLayoutImageGalary];
    self.trackedViewName = viewName;
}

-(void)initLayoutImageGalary
{
    //load thumbnails
    NSInteger col = 0;
    NSInteger row = 0;
    
    // Get documents folder
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documentsDirectory = [paths objectAtIndex:0];
    [listOfImageName removeAllObjects];
    for (int i = 0; i < [self.listOfImageURL count]; i++)
    {
        if (col > 3) {
            col = 0;
            row++;
        }
        CGPoint pointToAdd = CGPointMake(col*THUMBNAIL_W +(col*5), row*THUMBNAIL_H +(row*5)); // 5 is space between images
        col++;
        
        CGRect buttonFrame = CGRectMake(pointToAdd.x, pointToAdd.y,  THUMBNAIL_W, THUMBNAIL_H) ;
        UIButton* imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        imageButton.frame = buttonFrame;
        imageButton.tag = i;
        [imageButton addTarget:self action:@selector(handleThumbnailTouch:) forControlEvents:UIControlEventTouchUpInside];

        SDImageView* customimageView = [[SDImageView alloc] initWithFrame:CGRectMake(0, 0, THUMBNAIL_W, THUMBNAIL_H)];
        [customimageView setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
        [customimageView setImageWithURL:[NSURL URLWithString:[self.listOfImageURL objectAtIndex:i]]];
        [customimageView.layer setBorderColor:[[UIColor grayColor] CGColor]];
        customimageView.layer.borderWidth = 0.5;
        [customimageView setUserInteractionEnabled:NO];
        [imageButton addSubview:customimageView];
        [self.scrollView addSubview:imageButton];
    }
    [self.scrollView setContentSize:CGSizeMake(318, (row+1)*THUMBNAIL_H + row*5)];
    [self.view addSubview:self.scrollView];
}

- (void)handleThumbnailTouch: (UIButton*)sender
{
    GalleryViewController *galaryViewController = [[GalleryViewController alloc] init];
    galaryViewController.currentIndex = sender.tag;
    galaryViewController.film = self.film;
    [self.navigationController pushViewController:galaryViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
