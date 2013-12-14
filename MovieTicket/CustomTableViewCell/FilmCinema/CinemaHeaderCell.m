//
//  CinemaHeaderCell.m
//  123Phim
//
//  Created by Nhan Mai on 4/12/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#define MARGIN_FILM 3

#import "CinemaHeaderCell.h"
#import "MainViewController.h"
#import "CinemaWithDistance.h"

@implementation CinemaHeaderCell

@synthesize imageButton = _imageButton;
@synthesize cinemaName = _cinemaName;
@synthesize cinemaAddress = _cinemaAddress;
@synthesize distanceTo = _distanceTo;
@synthesize like = _like;
@synthesize lblType = _lblType;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code        
    }
    return self;
}

//load for cinemaViewController
-(void)loadDataWithImage: (NSString*)imageName cinemaName: (NSString*)_cinmeName cinemaAddress:(NSString*)_cinameAddress withMargin:(int)margin_film_left
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        [self loadDataWithImage:imageName cinemaName:_cinmeName film2D3D:-1 cinemaAddress:_cinameAddress distance:-1 withMargin:margin_film_left button_interact_enable:NO isVNeseVoice:NO];
    } else {
        [self loadDataWithImage:[NSString stringWithFormat:@"%@7", imageName] cinemaName:_cinmeName film2D3D:-1 cinemaAddress:_cinameAddress distance:-1 withMargin:margin_film_left button_interact_enable:NO isVNeseVoice:NO];
    }
}

//load cell for FilmCinemaViewController
-(void)loadDataWithImage: (NSString*)imageName cinemaName: (NSString*)_cinmeName film2D3D:(int)film2D3D cinemaAddress:(NSString*)_cinameAddress distance:(CGFloat)_distance withMargin:(int)margin_film_left button_interact_enable:(BOOL)button_interact_enable isVNeseVoice:(BOOL)is_VNese_voice
{
    self.distanceTo.layer.cornerRadius = 5;
    [self.lblType.layer setCornerRadius:5];
    NSString *thePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
    UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
    [self.imageButton setImage:prodImg forState:UIControlStateNormal];
    self.imageButton.userInteractionEnabled =  button_interact_enable;
    
    UIFont *nameFont = [UIFont getFontBoldSize12];
    NSString* cinema_name = _cinmeName;   
    NSString* version = nil;
    if (film2D3D != -1)
    {
        if (film2D3D != 3) {
            if (is_VNese_voice == YES) {
                version = @"2D-Lồng tiếng";
            }else{
                version = @"2D";
            }
         }else{
            if (is_VNese_voice == YES) {
                version = [NSString stringWithFormat:@"3D-Lồng tiếng"];
            }else{
                version = [NSString stringWithFormat:@"3D"];
             }
        }
        CGRect frame = self.cinemaName.frame;
        frame.size.width = 165;
        [self.cinemaName setFrame:frame];
        [self.lblType setHidden:NO];
        [self.lblType setText:version];
    }
    else
    {
        CGRect frame = self.cinemaName.frame;
        frame.size.width = 225;
        [self.cinemaName setFrame:frame];
        [self.lblType setHidden:YES];
    }
    
    self.cinemaName.text = cinema_name;
    [self.cinemaName setFont:nameFont];
    [self.cinemaName setTextColor:[UIColor colorWithWhite:0.3 alpha:1]];
    [self.cinemaAddress setFont:[UIFont getFontNormalSize10]];
    [self.cinemaAddress setTextColor:[UIColor colorWithWhite:0 alpha:0.4]];
    self.cinemaAddress.text = _cinameAddress;
    [self.cinemaAddress setBackgroundColor:[UIColor clearColor]];
    if (_distance >= 0) {
        self.distanceTo.hidden = NO;
        self.distanceTo.text = [NSString stringWithFormat:@"%.01fkm",_distance/1000];
    }else{
        self.distanceTo.hidden = YES;
    }
    
 
}
-(void) section0 :(BOOL)checksection0
{
    if (checksection0)
    {
        _viewDiscount.hidden = YES;
    }
    else
    {
        _viewDiscount.hidden = NO;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void) configLayout
{
  //  _lbDiscount.transform= CGAffineTransformMakeRotation(-DEGREES_TO_RADIANS(45));
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        _viewLayout.frame = CGRectMake( _viewLayout.frame.origin.x + MARGIN_EDGE_TABLE_GROUP,  _viewLayout.frame.origin.y,  _viewLayout.frame.size.width,  _viewLayout.frame.size.height);
    }
}
@end
