//
//  CustomTableViewCell.h
//  123Phim
//
//  Created by phuonnm on 10/7/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDImageView.h"

@interface CustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet SDImageView *sdImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end
