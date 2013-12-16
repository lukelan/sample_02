//
//  BarCodeViewController.m
//  123Phim
//
//  Created by phuonnm on 6/14/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "BarCodeViewController.h"
#import "BarCodeGenerator.h"
#import "AppDelegate.h"
#import "DefineString.h"

@interface BarCodeViewController ()

@end

@implementation BarCodeViewController
@synthesize encodeString = _encodeString;

-(void) dealloc
{
    _encodeString = nil;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarDisplayType = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    viewName = BAR_CODE_VIEW_CONTROLLER;
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app setCustomBackButtonForNavigationItem:self.navigationItem];
    [app setTitleLabelForNavigationController:self withTitle:TICKET_BAR_CODE_VIEW_TITLE];
//    CGRect f = self.view.frame;
    NSInteger width = 300;
    NSInteger height = 150;
//    
//    f.origin.y = 0;
//    self.view.frame = f;
//    CGFloat total = width + heigh;
//    CGFloat seperator = (f.size.height - NAVIGATION_BAR_HEIGHT - total ) / 3;
//    if (!_encodeString || _encodeString.length == 0) {
//        return;
//    }
    BarCodeGenerator *encoder = [[BarCodeGenerator alloc] init];
    [encoder setupOneDimBarcode:_encodeString type:CODE_128];
    UIImage *imageBarCode = encoder.oneDimBarcode;
    [encoder setupQRCode:_encodeString];
    UIImage *imageQRCode = encoder.qRBarcode;
    UIImageView *imageViewQR = [[UIImageView alloc] initWithImage:imageQRCode];
    UIImageView *imageViewBar = [[UIImageView alloc] initWithImage:imageBarCode];
////    qr
//    f = imageViewQR.frame;
//    f.origin.x = (self.view.frame .size.width - width) / 2;
//    f.origin.y = seperator;
//    f.size.width = width;
//    f.size.height = width;
//    imageViewQR.frame = f;
////    bar
//    f = imageViewBar.frame;
//    f.origin.x = (self.view.frame .size.width - width) / 2;
//    f.origin.y = width + (seperator * 2);
//    f.size.width = width;
//    f.size.height = heigh;
//    imageViewBar.frame = f;
    imageViewQR.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    imageViewQR.backgroundColor = [UIColor whiteColor];
    imageViewBar.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    imageViewBar.backgroundColor = [UIColor whiteColor];
    //  [self.view addSubview:imageViewQR];
    //  [self.view addSubview:imageViewBar];
    CGRect scrollViewRect = self.view.frame;
    self.myScrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    self.myScrollView.pagingEnabled = YES;
    self.myScrollView.contentSize = CGSizeMake(scrollViewRect.size.width * 2.0f , scrollViewRect.size.height );
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        _myScrollView.frame= CGRectMake(_myScrollView.frame.origin.x , 0 , _myScrollView.frame.size.width, _myScrollView.frame.size.height);
    }
    [self.view addSubview:self.myScrollView];
    [[self myScrollView]setDelegate:self];
    
    //pageControl
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    _pageControl.frame = CGRectMake((scrollViewRect.size.width - _pageControl.frame.size.width)/2,self.view.frame.size.height - _pageControl.frame.size.height * 2, _pageControl.frame.size.height, _pageControl.frame.size.height);
    self.pageControl.numberOfPages = 2;
    self.pageControl.currentPage = 0;
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    
    //QRcode
    CGRect imageViewRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIView *viewLayoutQRcode = [[UIView alloc]initWithFrame:imageViewRect];
    UILabel *lbQRcode = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    lbQRcode.frame =CGRectMake((viewLayoutQRcode.frame.size.width - lbQRcode.frame.size.width)/2, self.view.frame.origin.y, lbQRcode.frame.size.width, lbQRcode.frame.size.height);
    [lbQRcode setTextAlignment:UITextAlignmentCenter];
    lbQRcode.text = @"QR Code";
    lbQRcode.font = [UIFont getFontNormalSize19];
    lbQRcode.backgroundColor = [UIColor clearColor];
    UIImageView *image1view = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, width)];
    image1view = [self newImageViewWithImage:imageQRCode frame:CGRectMake((imageViewRect.size.width - image1view.frame.size.width)/2,lbQRcode.frame.size.height, width, width)];;
    UILabel *lbQRcode1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 250, 40)];
    lbQRcode1.frame =CGRectMake((imageViewRect.size.width - lbQRcode1.frame.size.width)/2, image1view.frame.size.height + lbQRcode1.frame.size.height, lbQRcode1.frame.size.width, lbQRcode1.frame.size.height);
    [lbQRcode1 setTextAlignment:UITextAlignmentCenter];
    lbQRcode1.text = _encodeString;
    lbQRcode1.font = [UIFont getFontNormalSize27];
    lbQRcode1.backgroundColor = [UIColor clearColor];
    [viewLayoutQRcode addSubview:image1view];
     [viewLayoutQRcode addSubview:lbQRcode];
     [viewLayoutQRcode addSubview:lbQRcode1];
    [self.myScrollView addSubview:viewLayoutQRcode];
    
    //Barcode
    imageViewRect.origin.x += imageViewRect.size.width;
    UIView *viewLayoutBarcode = [[UIView alloc]initWithFrame:imageViewRect];
     UILabel *lbBarcode = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    lbBarcode = [[UILabel alloc]initWithFrame:CGRectMake((viewLayoutBarcode.frame.size.width - lbBarcode.frame.size.width)/2, self.view.frame.origin.y, lbBarcode.frame.size.width, lbBarcode.frame.size.height)];
    lbBarcode.text = @"Bar Code";
    [lbBarcode setTextAlignment:UITextAlignmentCenter];
    lbBarcode.font = [UIFont getFontNormalSize19];
     lbBarcode.backgroundColor = [UIColor clearColor];
    UIImageView *image2view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0 , width , height)];
    image2view= [self newImageViewWithImage:imageBarCode frame:CGRectMake((viewLayoutBarcode.frame.size.width - image2view.frame.size.width)/2,lbBarcode.frame.size.height * 2, width, height)];
    UILabel *lbBarcode1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 250, 50)];
    lbBarcode1.frame = CGRectMake((viewLayoutBarcode.frame.size.width - lbBarcode1.frame.size.width)/2, image2view.frame.origin.y + image2view.frame.size.height, lbBarcode1.frame.size.width, lbBarcode1.frame.size.height);
    lbBarcode1.text = _encodeString;
    [lbBarcode1 setTextAlignment:UITextAlignmentCenter];
    lbBarcode1.font = [UIFont getFontNormalSize27];
    lbBarcode1.backgroundColor = [UIColor clearColor];
    [viewLayoutBarcode addSubview:lbBarcode];
    [viewLayoutBarcode addSubview:image2view];
    [viewLayoutBarcode addSubview:lbBarcode1];
    [self.myScrollView addSubview:viewLayoutBarcode];
    
    [self.view addSubview:_pageControl];
    [self.view addSubview:_myScrollView];
}
- (UIImageView *) newImageViewWithImage:(UIImage *)paramImage
                                  frame:(CGRect)paramFrame{
    
    UIImageView *result = [[UIImageView alloc] initWithFrame:paramFrame];
    result.contentMode = UIViewContentModeScaleAspectFit;
    result.image = paramImage;
    return result;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if (previousPage != page) {
        self.pageControl.currentPage = page;
        previousPage = page;
    }
}

@end
