//
//  ActorCell.h
//  123Phim
//
//  Created by Le Ngoc Duy on 3/10/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDImageView.h"

@interface ActorCell : UITableViewCell
@property (weak, nonatomic) IBOutlet SDImageView *ivActorAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lbActorName;
@property (weak, nonatomic) IBOutlet UILabel *lbCharacterName;
@property (strong, nonatomic) IBOutlet UIView *viewLayout;
- (void)setContentForCell:(NSString *)strContent;
@end
