//
//  CinemaTableViewLocationCell.m
//  123Phim
//
//  Created by Tai Truong on 12/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CinemaTableViewLocationCell.h"

@implementation CinemaTableViewLocationCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // image
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 49, 49)];
        [_imageView setImage:[UIImage imageNamed:@"location.png"]];
        [self.contentView addSubview:_imageView];
        // title
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(64, 5 , 185, 21)];
        _titleLbl.backgroundColor  = [UIColor clearColor];
        _titleLbl.textColor = [UIColor blackColor];
        _titleLbl.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
        [self.contentView addSubview:_titleLbl];
        
        // address
        _addressLbl = [[UILabel alloc] initWithFrame:CGRectMake(64, 23 , 220, 21)];
        _addressLbl.textColor = [UIColor grayColor];
        _addressLbl.font = [UIFont getFontNormalSize10];
        [self.contentView addSubview:_addressLbl];
    }
    return self;
}

#pragma mark - Public Methods

+(CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object
{
    return 50.0f + kCinemaTableViewPlaceCell_PaddingBottom;
}

-(void)setObject:(id)object
{
    [super setObject:object];
    
    CinemaTableViewLocationItem *item = object;
    _titleLbl.text = item.title;
    _addressLbl.text = item.address;
    if (item.isActive) {
        [_imageView setImage:[UIImage imageNamed:@"location_active"]];
        _titleLbl.hidden = NO;
    }
    else {
        [_imageView setImage:[UIImage imageNamed:@"location.png"]];
        _titleLbl.hidden = YES;
    }
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect r = self.contentView.frame;
    r.origin.y = kCinemaTableViewPlaceCell_PaddingTop;
    r.size.height = CGRectGetHeight(self.frame) - kCinemaTableViewPlaceCell_PaddingBottom;
    self.contentView.frame = r;
    
    r = _addressLbl.frame;
    if ([_titleLbl.text isEqualToString:@""]) {
        r.origin.y = 0;
        r.size.height = 50.0f;
    }
    else {
        r.origin.y = 23;
        r.size.height = 21.0f;
    }
    _addressLbl.frame = r;
}

@end
