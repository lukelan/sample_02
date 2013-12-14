//
//  SelectCityCell.m
//  123Phim
//
//  Created by Le Ngoc Duy on 4/2/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "SelectCityCell.h"
#import "MainViewController.h"


@implementation SelectCityCell

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

-(void)layoutSelectCityCell:(NSString *)locationName;
{
    UILabel* lblTitle = [[UILabel alloc] init];
    lblTitle.text = @"Suất chiếu tại";
    lblTitle.font = [UIFont getFontBoldSize12];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    CGSize sizeText = [lblTitle.text sizeWithFont:lblTitle.font];
    [lblTitle setFrame:CGRectMake(MARGIN_EDGE_TABLE_GROUP, MARGIN_EDGE_TABLE_GROUP, sizeText.width, sizeText.height)];
    UILabel* lblCityName = [[UILabel alloc] init];
    lblCityName.highlightedTextColor = [UIColor whiteColor];
    lblCityName.tag = 123;
    lblCityName.font = [UIFont getFontNormalSize13];
    lblCityName.text = locationName;
    lblCityName.backgroundColor = [UIColor clearColor];
    lblCityName.textAlignment = UITextAlignmentRight;
    sizeText = [lblCityName.text sizeWithFont:lblCityName.font];
    [lblCityName setFrame:CGRectMake(300 - 3*MARGIN_EDGE_TABLE_GROUP - sizeText.width, MARGIN_EDGE_TABLE_GROUP, sizeText.width, sizeText.height)];
    
    [self.contentView addSubview:lblTitle];
    [self.contentView addSubview:lblCityName];
}
@end
