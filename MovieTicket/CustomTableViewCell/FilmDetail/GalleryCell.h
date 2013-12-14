//
//  GalleryCell.h
//  123Phim
//
//  Created by Le Ngoc Duy on 3/10/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Film.h"
@interface GalleryCell : UITableViewCell
{
    NSInteger isLoadingGalaryOfFilmID;
}
@property (nonatomic, weak) Film * myfilm;
- (void)layoutGallery:(Film *)film;
-(void)setContentForCell:(Film *)film;
@end
