//
//  CinemaTableViewCell.h
//  123Phim
//
//  Created by Tai Truong on 12/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCinemaTableViewPlaceCell_PaddingTop 3.0f
#define kCinemaTableViewPlaceCell_PaddingBottom 12.0f

@class CinemaTableViewCell;
@protocol CinemaTableViewCellDelegate <NSObject>

@optional
-(void)cinemaTableViewCell:(CinemaTableViewCell*)cell didSelect:(id)object atIndex:(NSInteger)index;

@end

@interface CinemaTableViewCell : UITableViewCell
@property (nonatomic, weak) id object;
@property (nonatomic, weak) id<CinemaTableViewCellDelegate> delegate;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object;
@end
