//
//  CellOrderTicketCell.m
//  MovieTicket
//
//  Created by nhanht on 12/11/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#import "CellOrderTicketCell.h"

@implementation CellOrderTicketCell
@synthesize lbFilmName,lbCinemaRoom,lbTimeShow,imgfimposter;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
       
        self.imgfimposter =[[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 100, 115)] autorelease];
        [self.imgfimposter setBackgroundColor:[UIColor redColor]];
        [self.contentView addSubview:self.imgfimposter];
        //add label film name
        self.lbFilmName=[[[UILabel alloc]initWithFrame:CGRectMake(self.imgfimposter.frame.size.width +15, 5, 100, 30)] autorelease];
        [self.contentView addSubview:lbFilmName];
        //add cinema room
        self.lbCinemaRoom =[[[UILabel alloc]initWithFrame:CGRectMake(self.imgfimposter.frame.size.width +15,5+self.lbFilmName.frame.size.height,  100, 30)] autorelease];
        [self.contentView addSubview:lbCinemaRoom]; 
        //add time show
        self.lbTimeShow =[[[UILabel alloc]initWithFrame:CGRectMake(self.imgfimposter.frame.size.width +15 ,35+self.lbCinemaRoom.frame.size.height, 200, 30)] autorelease];
        
        [self.contentView addSubview:lbTimeShow];
    }     
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
