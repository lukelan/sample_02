//
//  PositionOffCell.m
//  123Phim
//
//  Created by Nhan Mai on 7/31/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "PositionOffCell.h"

@implementation PositionOffCell
@synthesize image, text;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        

    }
    return self;
}



-(void)setData:(NSString *)content
{
    [self.text setFont:[UIFont getFontNormalSize10]];
    [self.text setTextColor:[UIColor colorWithWhite:0 alpha:0.4]];
    self.text.text = content;
    [self.text setBackgroundColor:[UIColor clearColor]];   
    
}
-(void)configLayout
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
         _viewLayout.frame = CGRectMake(  _viewLayout.frame.origin.x + MARGIN_EDGE_TABLE_GROUP,   _viewLayout.frame.origin.y,_viewLayout.frame.size.width,   _viewLayout.frame.size.height);
        [self.image setImage:[UIImage imageNamed:@"location7.png"]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
