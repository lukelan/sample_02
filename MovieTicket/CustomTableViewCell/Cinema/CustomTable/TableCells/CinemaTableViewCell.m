//
//  CinemaTableViewCell.m
//  123Phim
//
//  Created by Tai Truong on 12/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CinemaTableViewCell.h"

@implementation CinemaTableViewCell
@synthesize object = __object;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        // arrow
        UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(297, 16, 12, 18 )];
        [arrowImage setImage:[UIImage imageNamed:@"arrow_right"]];
        [self.contentView addSubview:arrowImage];
        
        // Initialization code
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelect)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    return 0;
}

- (id)object {
    return __object;
}

- (void)setObject:(id)object {
    __object = object;
}

-(void)didSelect
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cinemaTableViewCell:didSelect:atIndex:)]) {
        [self.delegate cinemaTableViewCell:self didSelect:self.object atIndex:0];
    }
}

@end
