//
//  DistanceTimeCell.m
//  123Phim
//
//  Created by Nhan Mai on 4/5/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "DistanceTimeCell.h"
#import "MainViewController.h"

@implementation DistanceTimeCell

@synthesize distanceLabel = _distanceLabel;
@synthesize timeOnFootLabel = _timeOnFootLabel;
@synthesize timeByCarLabel = _timeByCarLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, MARGIN_EDGE_TABLE_GROUP/2, 296, 21)];
        imageView.image = [UIImage imageNamed:@"theater_distance_time.png"];
        _distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 2, 80, 30)];
        _distanceLabel.backgroundColor  = [UIColor clearColor];
        _timeOnFootLabel = [[UILabel alloc] initWithFrame:CGRectMake(_distanceLabel.frame.origin.x + _distanceLabel.frame.size.width + 13, 2, 70, 30)];
        _timeOnFootLabel.backgroundColor  = [UIColor clearColor];
        _timeByCarLabel = [[UILabel alloc] initWithFrame:CGRectMake(_timeOnFootLabel.frame.origin.x + _timeOnFootLabel.frame.size.width + 30, 2, 70, 30)];
        _timeByCarLabel.backgroundColor  = [UIColor clearColor];
        [self.contentView addSubview:imageView];
        [self.contentView addSubview:_distanceLabel];
        [self.contentView addSubview:_timeOnFootLabel];
        [self.contentView addSubview:_timeByCarLabel];        
    }
    return self;
}


- (id)initWithStyleCustom:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, MARGIN_EDGE_TABLE_GROUP/2, 296, 21)];
        imageView.image = [UIImage imageNamed:@"theater_distance_current.png"];
        [self.contentView addSubview:imageView];
        
        UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 200, 20)];
        text.backgroundColor = [UIColor clearColor];
        text.font = [UIFont getFontNormalSize10];
        text.textColor = [UIColor orangeColor];
        text.text = @"Bạn đang ở tại rạp này";
        [self.contentView addSubview:text];
    }
    return self;
}

- (void)loadDataWithDistance:(NSString*)_distance timeOnFoot:(NSString*)_footTime timeByCar:(NSString*)_carTime
{
    
    self.distanceLabel.text = _distance;
    self.distanceLabel.backgroundColor = [UIColor clearColor];
    self.distanceLabel.textColor = [self color];
    self.distanceLabel.font = [UIFont getFontBoldSize10];
    
    self.timeOnFootLabel.text = _footTime;
    self.timeOnFootLabel.backgroundColor = [UIColor clearColor];
    self.timeOnFootLabel.textColor = [self color];
    self.timeOnFootLabel.font = self.distanceLabel.font;
    
    self.timeByCarLabel.text = _carTime;
    self.timeByCarLabel.backgroundColor = [UIColor clearColor];
    self.timeByCarLabel.textColor = [self color];
    self.timeByCarLabel.font = self.distanceLabel.font;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (UIColor*) color
{
    return [UIColor grayColor];
}
@end
