//
//  CommentCell.m
//  123Phim
//
//  Created by Le Ngoc Duy on 3/10/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withHeight:(CGFloat)height
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        cellHeight = height;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutComment:(Comment *)comment
{
    //add avatar
    SAFE_RELEASE(_lblTime)
    SAFE_RELEASE(_lblName)
    SAFE_RELEASE(_imageStar)
    SAFE_RELEASE(_lblRatingPoint)
    SAFE_RELEASE(_imgAvatar)
    SAFE_RELEASE(_lblContent)
    SAFE_RELEASE(_comment)
    _imgAvatar = [[SDImageView alloc] initWithFrame:CGRectMake(MARGIN_EDGE_TABLE_GROUP, MARGIN_EDGE_TABLE_GROUP, ACTOR_AVATAR_W, ACTOR_AVATAR_H)];
    [_imgAvatar.layer setBorderWidth:0.5];
    [_imgAvatar.layer setBorderColor:[UIColor grayColor].CGColor];
//    [avatar setImageWithURL:[NSURL URLWithString:comment.avatar]];
    
    CGSize sizeText = [@"ABC" sizeWithFont:[UIFont getFontBoldSize15]];
    _lblName = [[UILabel alloc] initWithFrame:CGRectMake(ACTOR_AVATAR_W + 2*MARGIN_EDGE_TABLE_GROUP, MARGIN_EDGE_TABLE_GROUP/2, 130, sizeText.height)];
    _lblName.backgroundColor = [UIColor clearColor];
    _lblName.font = [UIFont getFontBoldSize15];
//    lbUser.text = comment.user_name;
    
    
    //add comment time
    sizeText = [@"10" sizeWithFont:[UIFont getFontNormalSize13]];
    _lblTime = [[UILabel alloc] initWithFrame:CGRectMake(_lblName.frame.origin.x + _lblName.frame.size.width + MARGIN_EDGE_TABLE_GROUP/2, MARGIN_EDGE_TABLE_GROUP - 2, 85, sizeText.height)];
    _lblTime.backgroundColor = [UIColor clearColor];
    _lblTime.font = [UIFont getFontNormalSize13];
    _lblTime.textColor = [UIColor grayColor];
    
    //add text
    CGFloat heigtWeb = cellHeight - (2*MARGIN_EDGE_TABLE_GROUP + _lblName.frame.size.height);
    if ([comment.list_image isKindOfClass:[NSArray class]])
    {
        heigtWeb += IMAGE_COMMENT_H;
    }
    _lblContent = [[UILabel alloc] initWithFrame:CGRectMake(_lblName.frame.origin.x, _lblName.frame.origin.y + _lblName.frame.size.height, self.frame.size.width - 5*MARGIN_EDGE_TABLE_GROUP - _imgAvatar.frame.size.width, heigtWeb)];
    [_lblContent setBackgroundColor:[UIColor clearColor]];
    [_lblContent setFont:[UIFont getFontNormalSize13]];
    [_lblContent setTextColor:[UIColor colorWithWhite:0 alpha:0.7]];
    
    if ([comment.list_image isKindOfClass:[NSArray class]])
    {
        UIScrollView *svImage = [[UIScrollView alloc] initWithFrame:CGRectMake(LEFT_MARGIN_RATE_CONTENT + MARGIN_EDGE_TABLE_GROUP, cellHeight - MARGIN_EDGE_TABLE_GROUP - IMAGE_COMMENT_H, 300 - 3*MARGIN_EDGE_TABLE_GROUP - _imgAvatar.frame.size.width, IMAGE_COMMENT_H)];
        [self addSubview:svImage];
        _scrollViewListImage = svImage;
    }

//     rating
    _lblRatingPoint = [[UILabel alloc] init];
    [_lblRatingPoint setFont:[UIFont getFontBoldSize18]];
    [_lblRatingPoint setBackgroundColor:[UIColor clearColor]];
    [_lblRatingPoint setTextColor:[UIColor orangeColor]];
    sizeText = [@"10" sizeWithFont:_lblRatingPoint.font];
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"rate_star_1" ofType:@"png"];
    UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
    _imageStar = [[UIImageView alloc] init];
    [_imageStar setFrame:CGRectMake(MARGIN_EDGE_TABLE_GROUP, _imgAvatar.frame.size.height + _imgAvatar.frame.origin.y + MARGIN_EDGE_TABLE_GROUP, prodImg.size.width, prodImg.size.height)];

    int posY = _imageStar.frame.origin.y + _imageStar.frame.size.height - sizeText.height + MARGIN_EDGE_TABLE_GROUP / 2;
    int posX = _imageStar.frame.origin.x + _imageStar.frame.size.width + 3;
    [_lblRatingPoint setFrame:CGRectMake(posX, posY, sizeText.width, sizeText.height)];

    UILabel *lblTotalPoint = [[UILabel alloc] init];
    [lblTotalPoint setFont:[UIFont getFontNormalSize10]];
    [lblTotalPoint setBackgroundColor:[UIColor clearColor]];
    [lblTotalPoint setTextColor:[UIColor colorWithWhite:0 alpha:0.4]];
    lblTotalPoint.text = @"/10 ";
    sizeText = [lblTotalPoint.text sizeWithFont:lblTotalPoint.font];
    [lblTotalPoint setFrame:CGRectMake(_lblRatingPoint.frame.origin.x + _lblRatingPoint.frame.size.width, _lblRatingPoint.frame.origin.y + _lblRatingPoint.frame.size.height - sizeText.height - 2, sizeText.width, sizeText.height)];
    
    //set variable local
    viewLayout = [[UIView alloc]init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        viewLayout.frame = CGRectMake(viewLayout.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, viewLayout.frame.origin.y, viewLayout.frame.size.width, viewLayout.frame.size.height);
    }
    [viewLayout addSubview:_lblTime];
    [viewLayout addSubview:_lblName];
    [viewLayout addSubview:_imgAvatar];
    [viewLayout addSubview:_lblContent];
    [viewLayout addSubview:_imageStar];
    [viewLayout addSubview:_lblRatingPoint];
    [viewLayout addSubview:lblTotalPoint];
    [self.contentView addSubview:viewLayout];

}

-(void)setContentWithComment:(Comment *)comment withHeight:(CGFloat)height
{
    if (!comment)
    {
        return;
    }
    
    SAFE_RELEASE(_comment)
    _comment = comment;
    _iComment_id = comment.comment_id.intValue;
    
    [_imgAvatar setImageWithURL:[NSURL URLWithString:comment.avatar]];
    _lblName.text = comment.user_name;
    
    //add comment time
    NSDate *today = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd H:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:_comment.date_update];
    NSTimeInterval timeAgo = [today timeIntervalSinceDate:date]; //uinit: senconds
    
    NSInteger minute = timeAgo/60;
    NSInteger hour = minute/60;
    NSInteger day = hour/24;
    _lblTime.text = [NSString stringWithFormat:@"%@ trước", day>0?[NSString stringWithFormat:@"%d ngày", day]:hour>0?[NSString stringWithFormat:@"%d giờ", hour]:minute>0?[NSString stringWithFormat:@"%d phút", minute]:@"1 phút"];
    
    NSInteger pointValue = [[comment ratingFilm] intValue];
    [_lblRatingPoint setText:[NSString stringWithFormat:@"%d",pointValue]];
    //Image start according to point
    int index = roundf((pointValue + 1) /2);
    _imageStar.image = nil;
    NSString *thePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"rate_star_%d",index] ofType:@"png"];
    UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
    _imageStar.image = prodImg;

    cellHeight = height;
    CGFloat heightWeb = cellHeight - (2*MARGIN_EDGE_TABLE_GROUP + _lblName.frame.size.height);
    if ([comment.list_image isKindOfClass:[NSArray class]])
    {
        heightWeb += IMAGE_COMMENT_H;
    }
    CGRect frameC = _lblContent.frame;
    frameC.size.height = heightWeb;
    frameC.size.width = self.frame.size.width - 5*MARGIN_EDGE_TABLE_GROUP - ACTOR_AVATAR_W;
    [_lblContent setFrame:frameC];

    [_lblContent setText:comment.content];
    [_lblContent setNumberOfLines:0];
    [_lblContent sizeToFit];
    [_lblContent setLineBreakMode:UILineBreakModeWordWrap];
//    [_lblContent setBackgroundColor:[UIColor blueColor]];
    
    if ([comment.list_image isKindOfClass:[NSArray class]])
    {
        frameC = _scrollViewListImage.frame;
        frameC.origin.y = cellHeight - MARGIN_EDGE_TABLE_GROUP - IMAGE_COMMENT_H;
        [_scrollViewListImage setFrame:frameC];
//        NSInteger offset_x = 0;
        [comment.list_image enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            NSInteger offset_x = (IMAGE_COMMENT_H + 5) * idx;
            SDImageView *imgView = [[SDImageView alloc] initWithFrame: CGRectMake(offset_x, 0, IMAGE_COMMENT_W, IMAGE_COMMENT_H)];
            imgView.tag = idx;
            [_scrollViewListImage addSubview:imgView];
            [imgView setImageWithURL:[NSURL URLWithString:(NSString *)obj]];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            [imgView addGestureRecognizer:tap];
            [imgView setUserInteractionEnabled:YES];
            _scrollViewListImage.contentSize = CGSizeMake(offset_x, 0);
        }];
    }
}

-(void)handleTapGesture:(UITapGestureRecognizer *)tapGesture
{
    UIView *v = tapGesture.view;
    NSUInteger index = v.tag;
    UIView *view = [[UIView alloc]initWithFrame:self.window.bounds];
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseTapGesture:)]];
    NSUInteger height = view.frame.size.width;
    UIScrollView *sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, (view.frame.size.height - height) / 2, 320, height)];
    UIImage *closeImage = [UIImage imageNamed:@"delete_image.png"];
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setBackgroundImage:closeImage forState:UIControlStateNormal];
    btnClose.frame = CGRectMake(sv.frame.size.width - 41, sv.frame.origin.y - 41, 40, 40);
    btnClose.transform = CGAffineTransformMakeRotation(M_PI_2);
    [btnClose addTarget:self action:@selector(btnCloseClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnClose];
    [_comment.list_image enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSInteger offset_x = (IMAGE_COMMENT_H + 5) * idx;
         SDImageView *imgView = [[SDImageView alloc] initWithFrame: CGRectMake(offset_x, 0, height, height)];
         [sv addSubview:imgView];
         [imgView setImageWithURL:[NSURL URLWithString:(NSString *)obj]];
         sv.contentSize = CGSizeMake(offset_x, 0);
     }];
    [view addSubview:sv];
    [view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    [sv setContentOffset:CGPointMake(index * (IMAGE_COMMENT_H + 5), 0)];
    [self.window addSubview:view];
}

-(void)btnCloseClicked:(UIButton *)sender
{
    [sender.superview removeFromSuperview];
}

-(void)handleCloseTapGesture:(UITapGestureRecognizer*)tapGesture
{
    UIView *v = tapGesture.view;
    [v removeFromSuperview];
}

-(void)dealloc
{
    SAFE_RELEASE(_lblTime)
    SAFE_RELEASE(_lblName)
    SAFE_RELEASE(_imageStar)
    SAFE_RELEASE(_lblRatingPoint)
    SAFE_RELEASE(_imgAvatar)
    SAFE_RELEASE(_lblContent)
    SAFE_RELEASE(_comment)
}

-(void)hideAllSubViewFromView:(UIView *)contentView
{
    for (UIView *view in contentView.subviews) {
        [view setHidden:YES];
    }
}

-(void)prepareForReuse
{
    [self hideAllSubViewFromView:_scrollViewListImage];
}

@end
