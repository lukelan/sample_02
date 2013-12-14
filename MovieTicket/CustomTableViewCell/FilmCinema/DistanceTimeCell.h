//
//  DistanceTimeCell.h
//  123Phim
//
//  Created by Nhan Mai on 4/5/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DistanceTimeCell : UITableViewCell
{
    
}
@property (nonatomic, strong) UILabel* distanceLabel;
@property (nonatomic, strong) UILabel* timeOnFootLabel;
@property (nonatomic, strong) UILabel* timeByCarLabel;
- (void)loadDataWithDistance:(NSString*)_distance timeOnFoot:(NSString*)_footTime timeByCar:(NSString*)_carTime;
- (id)initWithStyleCustom:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end
