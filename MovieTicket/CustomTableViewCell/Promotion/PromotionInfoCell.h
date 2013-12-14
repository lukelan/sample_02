//
//  PromotionInfoCell.h
//  123Phim
//
//  Created by Le Ngoc Duy on 3/20/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AutoScrollLabel.h"
#import "News.h"

@protocol PromotionDetailViewDelegate <NSObject>

-(void)updateTableViewHeight:(CGFloat)height;

@end

@interface PromotionInfoCell : UITableViewCell <UIWebViewDelegate>
{
    __weak id<PromotionDetailViewDelegate> _delegate;
    SDImageView *imgViewPos;
    AutoScrollLabel *lblScroll;
    //UITextView *textViewDescrip;
     UILabel *textViewDescrip;
}
@property (nonatomic, weak) id<PromotionDetailViewDelegate> delegate;
@property (nonatomic) CGFloat cellHeight;
-(void)layoutPromotionCell:(News *)promotion;
-(void)layoutWebView:(News *)promotion;
- (void) reloadContentForProCell:(News *)promotion;
@end
