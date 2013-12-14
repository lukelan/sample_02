//
//  CellInfoThanhToan.m
//  123Phim
//
//  Created by Le Ngoc Duy on 4/26/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CellInfoThanhToan.h"
#import "MainViewController.h"
#import "SeatView.h"

@implementation CellInfoThanhToan

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

-(void)layoutInfoCell:(BuyingInfo *)buyInfo
{
    NSString *strGhe = @"";
    for (SeatInfo *seatInfo in buyInfo.chosenSeatInfoList)
    {
        if (strGhe.length > 0)
        {
            strGhe = [strGhe stringByAppendingFormat:@", %@", seatInfo.identify];
        }
        else
        {
            strGhe = [strGhe stringByAppendingFormat:@"%@", seatInfo.identify];
        }
    }    
    NSString *session_time = [buyInfo.chosenSession getForMatStringAsDateFromTimeTamp];
    [self layoutInfoCell:strGhe sessionTime:session_time totalMoney:buyInfo.totalMoney];
    if ([(AppDelegate *)[UIApplication sharedApplication].delegate discountTypeEffect] == DISCOUNT_TYPE_NONE) {
        return;
    }
    if ([(AppDelegate *)[UIApplication sharedApplication].delegate discountTypeEffect] == DISCOUNT_TYPE_CINEMA) {
        if (buyInfo.chosenCinema.discount_value.intValue > 0) {
            [self showInfoDiscountOnPrice:buyInfo.chosenCinema.discount_type.intValue withPrice:buyInfo.totalMoney withDiscount:buyInfo.chosenCinema.discount_value.intValue];
        }
    }
    else
    {
        if (buyInfo.chosenFilm.discount_value.intValue > 0)
        {
            [self showInfoDiscountOnPrice:buyInfo.chosenFilm.discount_type.intValue withPrice:buyInfo.totalMoney withDiscount:buyInfo.chosenFilm.discount_value.intValue];
        }
    }
}

- (void)showInfoDiscountOnPrice:(ENUM_DISCOUNT_TYPE)type withPrice:(int)totalMoney withDiscount:(int)discount_value
{
    UILabel *lblTitleMoney = (UILabel *)[self viewWithTag:30];
    if (type == ENUM_DISCOUNT_PERCENT) {
        [lblTitleMoney setText:[NSString stringWithFormat:@"Tổng tiền (-%d%@)",discount_value,@"%"]];
    } else {
        [lblTitleMoney setText:[NSString stringWithFormat:@"Tổng tiền (-%dK)",discount_value/1000]];
    }
    CGSize sizeText = [lblTitleMoney.text sizeWithFont:lblTitleMoney.font];
    [lblTitleMoney setFrame:CGRectMake((self.contentView.frame.size.width - 2*MARGIN_EDGE_TABLE_GROUP - sizeText.width), lblTitleMoney.frame.origin.y, sizeText.width, sizeText.height)];
    
    UILabel *lblMoney = (UILabel *)[self viewWithTag:31];
    int iphanNguyen = totalMoney/1000;
    int iPhanDu = totalMoney%1000;
    NSString *strMoney = @"";
    if (iPhanDu > 0) {
        strMoney = [[NSString alloc] initWithFormat:@"%d.%dđ", iphanNguyen, iPhanDu];
    }
    else
    {
        strMoney = [[NSString alloc] initWithFormat:@"%d.000đ", iphanNguyen];
    }
    [lblMoney setText:strMoney];
    [lblMoney setTextColor:[UIColor redColor]];
}

-(void)layoutInfoCell:(NSString *)strGhe sessionTime:(NSString *)session_time totalMoney:(int) totalMoney
{
    //Layout thong tin ghe
    UILabel *lblTitleGhe = [[UILabel alloc] init];
    [lblTitleGhe setBackgroundColor:[UIColor clearColor]];
    [lblTitleGhe setFont:[UIFont getFontBoldSize12]];
    [lblTitleGhe setText:@"Số ghế"];
    CGSize sizeText = [lblTitleGhe.text sizeWithFont:lblTitleGhe.font];
    [lblTitleGhe setFrame:CGRectMake(MARGIN_CELL_SESSION, MARGIN_EDGE_TABLE_GROUP, sizeText.width, sizeText.height)];
    
    UILabel *lblGhe = [[UILabel alloc] init];
    [lblGhe setFont:[UIFont getFontNormalSize13]];
    [lblGhe setText:strGhe];
    [lblGhe setBackgroundColor:[UIColor clearColor]];
    sizeText = [lblGhe.text sizeWithFont:lblGhe.font];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(MARGIN_CELL_SESSION, 0, self.frame.size.width / 3 - 2 * MARGIN_CELL_SESSION , self.frame.size.height)];
    [lblGhe setFrame:CGRectMake(0, lblTitleGhe.frame.origin.y + lblTitleGhe.frame.size.height, sizeText.width, sizeText.height)];
    //Layout thong tin suat chieu
    UILabel *lblTitleSession = [[UILabel alloc] init];
    [lblTitleSession setFont:[UIFont getFontBoldSize12]];
    [lblTitleSession setText:@"Suất chiếu"];
    [lblTitleSession setBackgroundColor:[UIColor clearColor]];
    sizeText = [lblTitleSession.text sizeWithFont:lblTitleSession.font];
    [lblTitleSession setFrame:CGRectMake((self.contentView.frame.size.width - sizeText.width)/2, lblTitleGhe.frame.origin.y, sizeText.width, sizeText.height)];
    UILabel *lblSession = [[UILabel alloc] init];
    [lblSession setBackgroundColor:[UIColor clearColor]];
    [lblSession setFont:[UIFont getFontNormalSize13]];
    [lblSession setText:session_time];
    sizeText = [lblSession.text sizeWithFont:lblSession.font];
    [lblSession setFrame:CGRectMake((self.contentView.frame.size.width - sizeText.width)/2, lblTitleSession.frame.origin.y + lblTitleSession.frame.size.height, sizeText.width, sizeText.height)];
    //Layout thong tin tong tien
    UILabel *lblTitleMoney = [[UILabel alloc] init];
    [lblTitleMoney setBackgroundColor:[UIColor clearColor]];
    [lblTitleMoney setFont:[UIFont getFontBoldSize12]];
    [lblTitleMoney setText:@"Tổng tiền"];
    [lblTitleMoney setTag:30];
    [lblTitleMoney setTextAlignment:UITextAlignmentRight];
    sizeText = [lblTitleMoney.text sizeWithFont:lblTitleMoney.font];
    [lblTitleMoney setFrame:CGRectMake((self.contentView.frame.size.width - 2*MARGIN_EDGE_TABLE_GROUP - sizeText.width - MARGIN_CELL_SESSION), lblTitleGhe.frame.origin.y, sizeText.width, sizeText.height)];
    UILabel *lblMoney = [[UILabel alloc] init];
    [lblMoney setFont:[UIFont getFontNormalSize13]];
    [lblMoney setBackgroundColor:[UIColor clearColor]];
    int iphanNguyen = totalMoney/1000;
    int iPhanDu = totalMoney%1000;
    NSString *strMoney = @"";
    if (iPhanDu > 0) {
        strMoney = [[NSString alloc] initWithFormat:@"%d.%dđ", iphanNguyen, iPhanDu];
    }
    else
    {
        strMoney = [[NSString alloc] initWithFormat:@"%d.000đ", iphanNguyen];
    }
    [lblMoney setText:strMoney];
    [lblMoney setTag:31];
    [lblMoney setTextAlignment:UITextAlignmentRight];
    sizeText = [lblMoney.text sizeWithFont:lblMoney.font];
    [lblMoney setFrame:CGRectMake((self.contentView.frame.size.width - sizeText.width - 2*MARGIN_EDGE_TABLE_GROUP - MARGIN_CELL_SESSION), lblTitleMoney.frame.origin.y + lblTitleMoney.frame.size.height, sizeText.width, sizeText.height)];
    
    //Add to content view
    [scrollView addSubview:lblGhe];
    scrollView.contentSize = CGSizeMake(lblGhe.frame.size.width + 10, 0);
    [self.contentView addSubview:lblTitleGhe];
    [self.contentView addSubview:scrollView];
    [self.contentView addSubview:lblTitleSession];
    [self.contentView addSubview:lblSession];
    [self.contentView addSubview:lblTitleMoney];
    [self.contentView addSubview:lblMoney];
}
@end
