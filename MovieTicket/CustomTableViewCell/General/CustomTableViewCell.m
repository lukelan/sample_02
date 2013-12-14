//
//  CustomTableViewCell.m
//  123Phim
//
//  Created by phuonnm on 10/7/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

@synthesize titleLabel = _titleLabel;
@synthesize subTitleLabel = _subTitleLabel;
@synthesize sdImageView = _sdImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)prepareForReuse
{
    [super prepareForReuse];
}

-(void)layoutIfNeeded
{
    [super layoutIfNeeded];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.sdImageView.frame;
    frame.size.height = self.frame.size.height - MARGIN_EDGE_TABLE_GROUP;
    frame.size.width = frame.size.height;
    frame.origin.y = MARGIN_EDGE_TABLE_GROUP / 2;
    frame.origin.x = MARGIN_EDGE_TABLE_GROUP / 2;
    self.sdImageView.frame = frame;
    
    frame.origin.x += frame.size.width + MARGIN_EDGE_TABLE_GROUP;
    frame.size.width = self.frame.size.width - (frame.origin.x + MARGIN_EDGE_TABLE_GROUP);
    frame.size.height /= 2;
    if (self.subTitleLabel.text && self.subTitleLabel.text.length > 0)
    {
        frame.origin.y = MARGIN_EDGE_TABLE_GROUP / 2;
        self.titleLabel.frame = frame;
        frame.origin.y += frame.size.height;
        self.subTitleLabel.frame = frame;
        self.subTitleLabel.hidden = NO;
    }
    else
    {
        frame.origin.y = (self.frame.size.height - frame.size.height) / 2;
        self.titleLabel.frame = frame;
        self.subTitleLabel.hidden = YES;
    }
}

-(UIImageView *)imageView
{
    return self.sdImageView;
}

-(UILabel *)detailTextLabel
{
    return self.subTitleLabel;
}

-(UILabel *)textLabel
{
    return self.titleLabel;
}

@end
