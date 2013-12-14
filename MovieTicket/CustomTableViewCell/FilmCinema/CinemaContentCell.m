//
//  CinemaContentCell.m
//  123Phim
//
//  Created by Nhan Mai on 4/16/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CinemaContentCell.h"
#import "MainViewController.h"

@implementation CinemaContentCell

@synthesize distanceLabel = _distanceLabel;
@synthesize timeOnFootLabel = _timeOnFootLabel;
@synthesize timeByCarLabel = _timeByCarLabel;
@synthesize image = _image;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _viewLayout = [[UIView alloc] initWithFrame:self.contentView.frame];
        _image = [[UIImageView alloc] initWithFrame:CGRectMake(0, MARGIN_EDGE_TABLE_GROUP/2, 296, 21)];
        _image.image = [UIImage imageNamed:@"theater_distance_time.png"];
        
        _distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 2, 80, 30)];
        _distanceLabel.backgroundColor  = [UIColor clearColor];
        _distanceLabel.textColor = [UIColor grayColor];
        _distanceLabel.font = [UIFont getFontBoldSize10];
        
        _timeOnFootLabel = [[UILabel alloc] initWithFrame:CGRectMake(_distanceLabel.frame.origin.x + _distanceLabel.frame.size.width + 13, 2, 70, 30)];
        _timeOnFootLabel.backgroundColor  = [UIColor clearColor];
        _timeOnFootLabel.textColor = _distanceLabel.textColor;
        _timeOnFootLabel.font = _distanceLabel.font;
        
        _timeByCarLabel = [[UILabel alloc] initWithFrame:CGRectMake(_timeOnFootLabel.frame.origin.x + _timeOnFootLabel.frame.size.width + 29, 2, 70, 30)];
        _timeByCarLabel.backgroundColor  = [UIColor clearColor];
        _timeByCarLabel.textColor = _distanceLabel.textColor;
        _timeByCarLabel.font = _distanceLabel.font;
        [_viewLayout addSubview:_image];
        [_viewLayout addSubview:_distanceLabel];
        [_viewLayout addSubview:_timeOnFootLabel];
        [_viewLayout addSubview:_timeByCarLabel];
       
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            _viewLayout.frame = CGRectMake(_viewLayout.frame.origin.x + MARGIN_EDGE_TABLE_GROUP, _viewLayout.frame.origin.y, _viewLayout.frame.size.width, _viewLayout.frame.size.height);
        }
         [self.contentView addSubview: _viewLayout];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadDataWithDistance:(NSString*)_distance timeOnFoot:(NSString*)_footTime timeByCar:(NSString*)_carTime
{    
    self.distanceLabel.text = _distance;    
    self.timeOnFootLabel.text = _footTime;    
    self.timeByCarLabel.text = _carTime;
}


@end
