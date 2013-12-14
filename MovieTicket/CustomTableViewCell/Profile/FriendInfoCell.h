//
//  FriendInfoCell.h
//  123Phim
//
//  Created by Nhan Mai on 7/2/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendInfoCell : UITableViewCell

{
    CGFloat cellHeight;
}
@property (nonatomic, readonly) UIImageView* avatar;
@property (nonatomic, readonly) UILabel* name;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andHeight:(CGFloat)cellH;

@end
