//
//  PositionOffCell.h
//  123Phim
//
//  Created by Nhan Mai on 7/31/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PositionOffCell : UITableViewCell
{
    
}
@property (nonatomic, strong) IBOutlet UIImageView* image;
@property (nonatomic, strong) IBOutlet UILabel* text;
@property (strong, nonatomic) IBOutlet UIView *viewLayout;
-(void)configLayout;
-(void)setData:(NSString *)content;

@end
