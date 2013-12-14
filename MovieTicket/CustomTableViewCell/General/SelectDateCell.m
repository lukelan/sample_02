//
//  SelectDateCell.m
//  123Phim
//
//  Created by Le Ngoc Duy on 4/2/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "SelectDateCell.h"
#import "MainViewController.h"

@implementation SelectDateCell
@synthesize lblCityName, imgViewFavorite;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.imgViewFavorite = [[UIImageView alloc] init];
        NSString *thePath = [[NSBundle mainBundle] pathForResource:@"icon_date" ofType:@"png"];
        UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
        [self.imgViewFavorite setFrame:CGRectMake((self.frame.size.height - prodImg.size.height)/2, MARGIN_EDGE_TABLE_GROUP, prodImg.size.width, prodImg.size.height - 1)];
        [self.imgViewFavorite setImage:prodImg];
        
        self.lblCityName = [[UILabel alloc] init];
        self.lblCityName.highlightedTextColor = [UIColor whiteColor];
        self.lblCityName.tag = 124;
        self.lblCityName.font = [UIFont getFontNormalSize13];
        self.lblCityName.backgroundColor = [UIColor clearColor];
        self.lblCityName.textAlignment = UITextAlignmentRight;
                
        [self.contentView addSubview:imgViewFavorite];
        [self.contentView addSubview:lblCityName];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSelectDateCell:(NSString *)title
{
    lblCityName.text = title;
    CGSize sizeText = [lblCityName.text sizeWithFont:lblCityName.font];
    [lblCityName setFrame:CGRectMake(imgViewFavorite.frame.origin.x + imgViewFavorite.frame.size.width + MARGIN_EDGE_TABLE_GROUP, imgViewFavorite.frame.origin.y + (imgViewFavorite.frame.size.height - sizeText.height)/2, sizeText.width, sizeText.height)];

}

@end
