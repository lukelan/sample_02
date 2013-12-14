//
//  CellFilmSaleOff.m
//  123Phim
//
//  Created by Le Ngoc Duy on 12/4/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CellFilmSaleOff.h"
#import "AppDelegate.h"

@implementation CellFilmSaleOff

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

- (void)loadDataOnView:(Film *)film
{
    [self.viewDiscount setHidden:NO];
    if (film.discount_type.intValue == ENUM_DISCOUNT_PERCENT)
    {
        [self.lblDiscount setText:[NSString stringWithFormat:@"-%d%@", film.discount_value.intValue,@"%"]];
    }
    else if (film.discount_type.intValue == ENUM_DISCOUNT_MONEY)
    {
        [self.lblDiscount setText:[NSString stringWithFormat:@"-%dK", film.discount_value.intValue/1000]];
    }
    else
    {
        [self.viewDiscount setHidden:YES];
    }
    
    [self.lblRemainTicket setText:[NSString stringWithFormat:@"Đã mua: %d/%d", film.buy.intValue, film.total.intValue]];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d/M/y"];
    [self.lblStartDate setText:[NSString stringWithFormat:@"Bắt đầu: %@",[dateFormat stringFromDate:film.date_start]]];
    [self.lblExpireDate setText:[NSString stringWithFormat:@"Kết thúc: %@",[dateFormat stringFromDate:film.date_end]]];
    [self.imgViewBanner setImageWithURL:[NSURL URLWithString:film.image]];
}
@end
