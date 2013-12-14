//
//  CinemaHeaderCell.h
//  123Phim
//
//  Created by Nhan Mai on 4/12/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FilmCinemaViewController;

@interface CinemaHeaderCell : UITableViewCell
{
}
@property (nonatomic, weak) IBOutlet UIButton* imageButton;
@property (nonatomic, weak) IBOutlet UILabel* cinemaName;
@property (nonatomic, weak) IBOutlet UILabel* cinemaAddress;
@property (nonatomic, weak) IBOutlet UILabel* distanceTo;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (strong, nonatomic) IBOutlet UIView *viewLayout;
@property (strong, nonatomic) IBOutlet UILabel *lbDiscount;
@property (strong, nonatomic) IBOutlet UIView *viewDiscount;
@property (nonatomic) BOOL *isSection0;
@property (strong, nonatomic) IBOutlet UIImageView *imageDiscount;
@property (nonatomic, assign) BOOL like;
- (void) configLayout;
-  (void) section0 :(BOOL)checksection0;
-(void)loadDataWithImage: (NSString*)imageName cinemaName: (NSString*)_cinmeName cinemaAddress:(NSString*)_cinameAddress withMargin:(int)margin_film_left;
-(void)loadDataWithImage: (NSString*)imageName cinemaName: (NSString*)_cinmeName film2D3D:(int)film2D3D cinemaAddress:(NSString*)_cinameAddress distance:(CGFloat)_distance withMargin:(int)margin_film_left button_interact_enable:(BOOL)button_interact_enable isVNeseVoice:(BOOL)is_VNese_voice;

@end
