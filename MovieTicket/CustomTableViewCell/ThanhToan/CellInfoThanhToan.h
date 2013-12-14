//
//  CellInfoThanhToan.h
//  123Phim
//
//  Created by Le Ngoc Duy on 4/26/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuyingInfo.h"

@interface CellInfoThanhToan : UITableViewCell
{
    
}
-(void)layoutInfoCell:(BuyingInfo *)buyInfo;
-(void)layoutInfoCell:(NSString *)strGhe sessionTime:(NSString *)session_time totalMoney:(int) totalMoney;
@end
