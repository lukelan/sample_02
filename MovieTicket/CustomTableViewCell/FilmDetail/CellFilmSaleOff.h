//
//  CellFilmSaleOff.h
//  123Phim
//
//  Created by Le Ngoc Duy on 12/4/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDImageView.h"
#import "Film.h"

@interface CellFilmSaleOff : UITableViewCell
@property (weak, nonatomic) IBOutlet SDImageView *imgViewBanner;
@property (weak, nonatomic) IBOutlet SDImageView *imgViewSaleOf;
@property (weak, nonatomic) IBOutlet UILabel *lblStartDate;
@property (weak, nonatomic) IBOutlet UILabel *lblRemainTicket;
@property (weak, nonatomic) IBOutlet UILabel *lblExpireDate;
@property (weak, nonatomic) IBOutlet UIView *viewDiscount;
@property (weak, nonatomic) IBOutlet UILabel *lblDiscount;

- (void)loadDataOnView:(Film *)film;
@end
