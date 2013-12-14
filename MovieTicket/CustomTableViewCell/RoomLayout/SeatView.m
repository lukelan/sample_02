//
//  SeatView.m
//  123Phim
//
//  Created by phuonnm on 4/11/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "SeatView.h"

@implementation SeatView

-(id)initWithImage:(UIImage *)image
{
    if(self = [super initWithImage:image])
    {
        _normalImage = image;
    }
    return self;
}

-(void)showImageWithState:(NSInteger)status
{
    if (status == SEAT_STATUS_SELECTED)
    {
        self.image = _selectedImage;
    }
    else if (status == SEAT_STATUS_AVAILABLE)
    {
        self.image = _normalImage;
    }
    else if (status == SEAT_STATUS_DISABLE)
    {
        self.image = _disableImage;
    }
    else if (status == SEAT_STATUS_BLOCK)
    {
        self.image = _blockImage;
    }
}
@end
