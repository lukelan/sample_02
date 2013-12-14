//
//  CinemaInfoCell.m
//  123Phim
//
//  Created by Nhan Mai on 5/27/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CinemaInfoCell.h"

@implementation CinemaInfoCell
@synthesize button0, button1, button2, button3;
@synthesize imageView2;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //make cell transparent
        UIView* transparent = [[UIView alloc] init];
        transparent.backgroundColor = [UIColor clearColor];
        self.backgroundView = transparent;
        self.selectedBackgroundView = transparent;
        //make backgound image
        UIImageView* background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cinema_info.png"]];
        background.frame = CGRectMake(0, 0, 300, 56.5);
        imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(162, 2, 52, 43)];
        imageView2.backgroundColor = [UIColor clearColor];
        button0 = [[UIButton alloc] init];
        button0.frame = CGRectMake(0, 3, 75, 50);
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            background.frame = CGRectMake(10, 0, 300, 56.5);
            button0.frame = CGRectMake(10, 3, 75, 50);
            imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(172, 2, 52, 43)];
            self.backgroundColor = [UIColor clearColor];
        }
        button0.backgroundColor = [UIColor clearColor];
        [button0 setTitle:@"Gọi rạp" forState:UIControlStateNormal];
        [button0 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [button0 setTitleColor:[self cinema_color_normal] forState:UIControlStateNormal];
        button0.titleLabel.font = [UIFont getFontNormalSize12];
        button0.showsTouchWhenHighlighted = YES;
        button0.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        button1 = [[UIButton alloc] init];
        button1.frame = CGRectMake(button0.frame.origin.x + button0.frame.size.width, 3, 75, 50);
        
        button1.backgroundColor = [UIColor clearColor];
        [button1 setTitle:@"Bản đồ" forState:UIControlStateNormal];
        [button1 setTitleColor:[self cinema_color_normal] forState:UIControlStateNormal];
        button1.titleLabel.font = button0.titleLabel.font;
        button1.showsTouchWhenHighlighted = YES;
        button1.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        [button1 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];

        button2 = [[UIButton alloc] init];
        button2.frame = CGRectMake(button1.frame.origin.x + button1.frame.size.width, 3, 75, 50);
       
        button2.backgroundColor = [UIColor clearColor];
        [button2 setTitle:@"Wifi" forState:UIControlStateNormal];
        [button2 setTitleColor:[self cinema_color_normal] forState:UIControlStateNormal];
        button2.titleLabel.font = button0.titleLabel.font;
        button2.showsTouchWhenHighlighted = YES;
        button2.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        
        button3 = [[UIButton alloc] init];
        button3.frame = CGRectMake(button2.frame.origin.x + button2.frame.size.width, 3, 75, 50);
        button3.backgroundColor = [UIColor clearColor];
        [button3 setTitle:@"Check in" forState:UIControlStateNormal];
        [button3 setTitleColor:[self cinema_color_normal] forState:UIControlStateNormal];
        button3.titleLabel.font = button0.titleLabel.font;
        button3.showsTouchWhenHighlighted = YES;
        button3.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        
        [self.contentView addSubview:background];
        [self.contentView addSubview:imageView2];
        [self.contentView addSubview:button0];
        [self.contentView addSubview:button1];
        [self.contentView addSubview:button2];
        [self.contentView addSubview:button3];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (UIColor*)cinema_color_normal
{
    return [UIColor colorWithWhite:0.7 alpha:1.0];
}
- (void)layoutSubviews {
    [super layoutSubviews];
  
    self.textLabel.frame = CGRectMake(0, self.textLabel.frame.origin.y, self.contentView.frame.size.width, self.textLabel.frame.size.height);
    
}
@end
