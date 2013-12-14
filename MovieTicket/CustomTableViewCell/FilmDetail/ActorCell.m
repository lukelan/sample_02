//
//  ActorCell.m
//  123Phim
//
//  Created by Le Ngoc Duy on 3/10/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "ActorCell.h"

@implementation ActorCell

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

- (void)setContentForCell:(NSString *)strContent
{
    if (!strContent || strContent.length < 1) {
        return;
    }
    NSArray *array = [strContent componentsSeparatedByString:@";"];
    if (array.count == 3)
    {
        [self.ivActorAvatar setImageWithURL:[NSURL URLWithString:[array objectAtIndex:2]]];
    }
    NSString *actorName = [[array objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.lbActorName setText:actorName];
    
    NSString* acttingNameString = @"...";
    if (array.count > 1) {
        acttingNameString = [array objectAtIndex:1];
    }
    NSString *acttingName = [NSString stringWithFormat:@"%@",[acttingNameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    [self.lbCharacterName setText:acttingName];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        _viewLayout.frame = CGRectMake(_viewLayout.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, _viewLayout.frame.origin.y, _viewLayout.frame.size.width, _viewLayout.frame.size.height);
    }
}

@end
