//
//  PromotionInfoCell.m
//  123Phim
//
//  Created by Le Ngoc Duy on 3/20/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "PromotionInfoCell.h"

@implementation PromotionInfoCell

@synthesize delegate = _delegate;
@synthesize cellHeight;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutPromotionCell:(News *)promotion
{
    UIImageView *imgbg=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 115)];
    imgbg.image=[UIImage imageNamed:@"bg-cell-film.png"];
    [imgbg setContentMode:UIViewAutoresizingFlexibleHeight];
    [self.contentView addSubview:imgbg];
    
    SDImageView *filmImg =[[SDImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, self.contentView.frame.origin.y + MARGIN_EDGE_TABLE_GROUP, IMAGE_PROMOTION_W, IMAGE_PROMOTION_H)];
//    [filmImg setImageWithURL:[NSURL URLWithString:promotion.path]];
    [filmImg.layer setBorderColor:[[UIColor grayColor] CGColor]];
    filmImg.layer.borderWidth = 0.5;
    
    AutoScrollLabel *autoLable=[[AutoScrollLabel alloc] init];
    autoLable.backgroundColor=[UIColor clearColor];
    autoLable.font=[UIFont getFontBoldSize10];
    [autoLable setFrame:CGRectMake(filmImg.frame.origin.x + filmImg.frame.size.width + MARGIN_EDGE_TABLE_GROUP,filmImg.frame.origin.y,300 - 3*MARGIN_EDGE_TABLE_GROUP - filmImg.frame.size.width,[@"ABC" sizeWithFont:autoLable.font].height)];
    autoLable.textColor = [UIColor blackColor];
//    autoLable.text = promotion.news_title;
    autoLable.tag = TAG_AUTO_SCROLL_LABEL;
   
    UILabel *tvDesc=[[UILabel alloc] init];
    [tvDesc setBackgroundColor:[UIColor clearColor]];
    tvDesc.font=[UIFont getFontNormalSize13];
//    tvDesc.text = promotion.news_description;
    //tvDesc.editable=NO;
  //  tvDesc.scrollEnabled=NO;
    //tvDesc.contentInset = UIEdgeInsetsMake(-8, -8, 0, -8);
    tvDesc.numberOfLines = 4;
    tvDesc.textAlignment = UITextAlignmentLeft;
    CGSize sizeText = [tvDesc.text sizeWithFont:[UIFont getFontNormalSize13]];
    [tvDesc setFrame:CGRectMake(autoLable.frame.origin.x, autoLable.frame.origin.y + autoLable.frame.size.height + MARGIN_EDGE_TABLE_GROUP,autoLable.frame.size.width + MARGIN_EDGE_TABLE_GROUP, 4*sizeText.height)];
    [tvDesc setUserInteractionEnabled:NO];

    //set for my variable
    imgViewPos = filmImg;
    lblScroll = autoLable;
    textViewDescrip = tvDesc;
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
//    {
//        imgViewPos.frame = CGRectMake(imgViewPos.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, imgViewPos.frame.origin.y, imgViewPos.frame.size.width, imgViewPos.frame.size.height);
//         lblScroll.frame = CGRectMake(lblScroll.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, lblScroll.frame.origin.y, lblScroll.frame.size.width, lblScroll.frame.size.height);
//         textViewDescrip.frame = CGRectMake(textViewDescrip.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, textViewDescrip.frame.origin.y, textViewDescrip.frame.size.width, imgViewPos.frame.size.height);
//    }
    [self.contentView addSubview: filmImg];
    [self.contentView addSubview: autoLable];
    [self.contentView addSubview:tvDesc];
}

- (void) reloadContentForProCell:(News *)promotion
{
    [imgViewPos setImageWithURL:[NSURL URLWithString:promotion.image]];
    
    lblScroll.text = promotion.news_title;
    [lblScroll refreshLabels];
    
    textViewDescrip.text = promotion.news_description;
    CGSize sizeText = [textViewDescrip.text sizeWithFont:textViewDescrip.font];
    [textViewDescrip setFrame:CGRectMake(lblScroll.frame.origin.x, lblScroll.frame.origin.y + lblScroll.frame.size.height + MARGIN_EDGE_TABLE_GROUP,lblScroll.frame.size.width + MARGIN_EDGE_TABLE_GROUP, 4*sizeText.height)];
}

//- (void)prepareForReuse
//{
//    [imgViewPos setImage:nil];
//}

#pragma mark process for my promotion detail cell
-(void)layoutWebView:(News *)promotion
{
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGRect frame = CGRectMake(10, 0, 280, 40);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        frame = CGRectMake(10, 0, 300, 40);

    }

    // label
    AutoScrollLabel *autoLabel = [[AutoScrollLabel alloc] initWithFrame:frame];
    autoLabel.backgroundColor = [UIColor clearColor];
    autoLabel.textColor = [UIColor blackColor];
    autoLabel.font = [UIFont getFontBoldSize14];
    autoLabel.text = promotion.news_title;
    autoLabel.tag = TAG_AUTO_SCROLL_LABEL;
    
    
    // image
    frame = CGRectMake(10, frame.size.height + 2, IMAGE_PROMOTION_W, IMAGE_PROMOTION_H);
    SDImageView *filmImg = [[SDImageView alloc] initWithFrame:frame];
    filmImg.layer.borderWidth = 0.5;
    [filmImg.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [filmImg setImageWithURL:[NSURL URLWithString:promotion.image]];

    if (!self.cellHeight) {

        CGSize sizeText = [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]];
        int heightCell = 3*MARGIN_EDGE_TABLE_GROUP + autoLabel.frame.size.height - sizeText.height/2 + 2;
        CGSize maximumSize = CGSizeMake(300 - 3*MARGIN_EDGE_TABLE_GROUP - IMAGE_PROMOTION_W, 9999);
        CGSize sizeTextDynamic = [promotion.content sizeWithFont:[UIFont getFontNormalSize10]
                                               constrainedToSize:maximumSize
                                                   lineBreakMode:UILineBreakModeWordWrap];
        heightCell += sizeTextDynamic.height + 3*sizeText.height;
        
        self.cellHeight = heightCell;
    }
    
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, autoLabel.frame.size.height, 300, self.cellHeight)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        webView.frame =  CGRectMake(webView.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, webView.frame.origin.y, webView.frame.size.width, webView.frame.size.height);
    }
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    // Get the path of the resource file
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"PromotionInfoCell" ofType:@"html"];
    
    // Convert it to the NSURL
    NSURL* address = [NSURL fileURLWithPath:filePath];
    
    NSString *source = [NSString stringWithContentsOfURL:address
                                                encoding:NSStringEncodingConversionExternalRepresentation
                                                   error:nil];

    // assign variable
    source = [NSString stringWithFormat:source, promotion.content];    
    webView.tag = 100;
    webView.delegate = self;
    webView.scrollView.scrollEnabled = NO;
    webView.backgroundColor = [UIColor clearColor];
    
    [webView loadHTMLString:source baseURL:baseURL];
    [webView setUserInteractionEnabled:YES];
    [webView setOpaque:NO];

    [self.contentView addSubview:webView];
    [self.contentView addSubview:autoLabel];
    [self.contentView addSubview:filmImg];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.tag == 100) {
        [self updateCellHeight:(webView.scrollView.contentSize.height + MARGIN_EDGE_TABLE_GROUP)];
    }
}

-(void)updateCellHeight:(CGFloat)height
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(updateTableViewHeight:)])
    {
        CGRect frame = self.frame;
        frame.size.height = height;
        self.frame = frame;       
        
        UIWebView *webView = (UIWebView *) [self viewWithTag:100];
        frame = webView.frame;
        frame.size.height = height;
        webView.frame = frame;
        self.cellHeight = height;
//        [webView setBackgroundColor:[UIColor blueColor]];
        [self.delegate updateTableViewHeight:(height + frame.origin.y + MARGIN_EDGE_TABLE_GROUP)];
    }
}

-(void)dealloc
{
    self.delegate = nil;
    UIWebView *webView = (UIWebView *) [self viewWithTag:100];
    if ([webView isKindOfClass:[UIWebView class]])
    {
        [webView cleanForDealloc];
        webView = nil;
    }
}


@end
