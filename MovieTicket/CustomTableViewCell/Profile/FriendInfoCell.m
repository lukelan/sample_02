//
//  FriendInfoCell.m
//  123Phim
//
//  Created by Nhan Mai on 7/2/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "FriendInfoCell.h"
#import "DefineConstant.h"
#import <QuartzCore/QuartzCore.h>

#define CELL_MARGIN_LEFT 10
#define CELL_MARGIN_RIGHT 10
#define CELL_MARGIN_TOP 10
#define CELL_MARGIN_BOTTOM 10


#define AVATAR_WIDTH 60
#define AVATAR_HEIGHT 60



@implementation FriendInfoCell

@synthesize avatar, name;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andHeight:(CGFloat)cellH
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        avatar = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_MARGIN_LEFT, CELL_MARGIN_TOP, cellH - 2*CELL_MARGIN_LEFT, cellH - 2*CELL_MARGIN_TOP)];
        avatar.layer.borderColor = [UIColor whiteColor].CGColor;
        avatar.layer.borderWidth = 2.0;
        avatar.layer.shadowColor = [UIColor grayColor].CGColor;
        avatar.layer.shadowOffset = CGSizeMake(1, 1);
        avatar.layer.masksToBounds = NO;
        avatar.layer.shadowOpacity = 15.0;        
        avatar.backgroundColor = [UIColor brownColor];
        avatar.image = [UIImage imageNamed:@"no_avatar.png"];
        
        name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 30)];
        CGRect frame = name.frame;
        frame.origin.x = 2*CELL_MARGIN_LEFT+avatar.bounds.size.width;
        frame.origin.y = (cellH - name.bounds.size.height)/2;
        name.frame = frame;
        name.backgroundColor = [UIColor clearColor];
        name.font = [UIFont getFontBoldSize14];
        name.text = @"user name";
        
        [self.contentView addSubview:avatar];
        [self.contentView addSubview:name];
        
    }
    return self;
}

//-(void)dealloc
//{
//    [avatar release];
//    [name release];
//    [super dealloc];
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
