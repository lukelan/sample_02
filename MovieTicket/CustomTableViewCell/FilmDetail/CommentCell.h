//
//  CommentCell.h
//  123Phim
//
//  Created by Le Ngoc Duy on 3/10/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "SDImageView.h"

@interface CommentCell : UITableViewCell
{
    CGFloat cellHeight;
    SDImageView *_imgAvatar;
    UIView *viewLayout;
    UILabel *_lblName, *_lblTime, *_lblContent, *_lblRatingPoint;
    UIImageView *_imageStar;
    UIScrollView *_scrollViewListImage;
    int _iComment_id;
    Comment *_comment;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withHeight:(CGFloat)height;
-(void)layoutComment:(Comment *)comment;
-(void)setContentWithComment:(Comment *)comment withHeight:(CGFloat)height;
@end
