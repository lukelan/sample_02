//
//  CinemaContentCell.h
//  123Phim
//
//  Created by Nhan Mai on 4/16/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CinemaContentCell : UITableViewCell
{
    
}
@property (nonatomic, strong) UILabel* distanceLabel;
@property (nonatomic, strong) UILabel* timeOnFootLabel;
@property (nonatomic, strong) UILabel* timeByCarLabel;
@property (nonatomic, strong) UIImageView* image;
@property (nonatomic, strong) UIView  *viewLayout;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)loadDataWithDistance:(NSString*)_distance timeOnFoot:(NSString*)_footTime timeByCar:(NSString*)_carTime;

@end

