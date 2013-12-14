//
//  SelectDateCell.h
//  123Phim
//
//  Created by Le Ngoc Duy on 4/2/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectDateCell : UITableViewCell

@property (nonatomic, strong)UILabel* lblCityName;
@property (nonatomic, strong)UIImageView *imgViewFavorite;

-(void)layoutSelectDateCell:(NSString *)title;

@end
