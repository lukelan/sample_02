//
//  CellOrderTicketCell.h
//  MovieTicket
//
//  Created by nhanht on 12/11/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellOrderTicketCell : UITableViewCell{
    UILabel *lbFilmName;
    UILabel *lbCinemaRoom;
    UILabel *lbTimeShow;
    UIImageView *imgfimposter;
}
@property(nonatomic,retain)  UILabel *lbFilmName;
@property(nonatomic,retain)  UILabel *lbCinemaRoom;
@property(nonatomic,retain)  UILabel *lbTimeShow;
@property(nonatomic,retain)  UIImageView *imgfimposter;
@end
