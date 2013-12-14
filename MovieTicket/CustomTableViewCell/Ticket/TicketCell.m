//
//  TicketCell.m
//  123Phim
//
//  Created by Nhan Mai on 5/16/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "TicketCell.h"

#define CELL_MARGIN 10

@implementation TicketCell

@synthesize image, label1, label2, label3, label4;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        image = [[SDImageView alloc] initWithFrame:CGRectMake(CELL_MARGIN, CELL_MARGIN, 80, 100)];
        image.layer.cornerRadius = 5.0;
        image.layer.masksToBounds = YES;
        [image clipsToBounds];
        label1 = [[UILabel alloc] initWithFrame:CGRectMake(image.frame.origin.x + image.frame.size.width + CELL_MARGIN, image.frame.origin.y, 300 - CELL_MARGIN*3 - image.frame.size.width, image.frame.size.height/4)];
        label2 = [[UILabel alloc] initWithFrame:CGRectMake(label1.frame.origin.x, label1.frame.origin.y + label1.frame.size.height, label1.frame.size.width, label1.frame.size.height)];
        label3 = [[UILabel alloc] initWithFrame:CGRectMake(label1.frame.origin.x, label2.frame.origin.y + label2.frame.size.height, label1.frame.size.width, label1.frame.size.height)];
        label4 = [[UILabel alloc] initWithFrame:CGRectMake(label1.frame.origin.x, label3.frame.origin.y + label3.frame.size.height, label1.frame.size.width, label1.frame.size.height)];
        image.backgroundColor = [UIColor grayColor];
        
        label1.backgroundColor = [UIColor clearColor];
        label2.backgroundColor = [UIColor clearColor];
        label3.backgroundColor = [UIColor clearColor];
        label4.backgroundColor = [UIColor clearColor];
        
        label1.textColor = [self color];
        label2.textColor = [self color];
        label3.textColor = [self color];
        label4.textColor = [self color];
        
        label1.font = [self textFont];
        label2.font = [self textFont];
        label3.font = [self textFont];
        label4.font = [self textFont];
        
//        [_viewLayout addSubview:image];
//        [_viewLayout addSubview:label1];
//        [_viewLayout addSubview:label2];
//        [_viewLayout addSubview:label3];
//       [_viewLayout addSubview:label4];
        _viewLayout.backgroundColor = [UIColor clearColor];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        _viewLayout.frame = CGRectMake(_viewLayout.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, _viewLayout.frame.origin.y, _viewLayout.frame.size.width, _viewLayout.frame.size.height);
    }
  //  [self.contentView addSubview: _viewLayout];
    
    [self.contentView addSubview:label1];
    [self.contentView addSubview:label2];
    [self.contentView addSubview:label3];
    [self.contentView addSubview:label4];
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIFont*)textFont
{
    return [UIFont getFontBoldSize13];
}

- (UIColor*)color
{
    return [UIColor colorWithWhite:0 alpha:1.0];
}

@end
