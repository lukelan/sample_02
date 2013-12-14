//
//  FilmInfoCell.h
//  123Phim
//
//  Created by Le Ngoc Duy on 3/10/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#define kCell_Film_Info_Height  242

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "APIManager.h"
#import "FavoriteButton.h"

#import "AutoScrollLabel.h"
#import "Film.h"
#import "SDImageView.h"

@class FilmInfoCell;

@protocol FilmInfoCellDelegate <NSObject>

@required
-(BOOL)filmInfoCell:(FilmInfoCell*)filmInfoCell didUpdateLayoutWithHeight:(CGFloat)newHeight;
@end


@interface FilmInfoCell : UITableViewCell<ASIHTTPRequestDelegate, APIManagerDelegate, UIWebViewDelegate>
{
    ASIHTTPRequest *httpRequest;
    CGRect contentRect;
    __weak id<FilmInfoCellDelegate> _delegate;
}
@property (nonatomic, weak) Film * myfilm;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIView *viewLayout;
@property (weak, nonatomic) IBOutlet SDImageView *imgViewPoster;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayTrailer;
@property (weak, nonatomic) IBOutlet UIImageView *imageStarMask;
@property (weak, nonatomic) IBOutlet UILabel *lblVer;
@property (weak, nonatomic) IBOutlet UILabel *lblDura;
@property (weak, nonatomic) IBOutlet UILabel *lblCate;
@property (weak, nonatomic) IBOutlet FavoriteButton *btnLike;
@property (weak, nonatomic) IBOutlet AutoScrollLabel *lblSrollTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewRatingPoint;
@property (weak, nonatomic) IBOutlet UILabel *lblRatingPoint;
@property (weak, nonatomic) IBOutlet UIButton *btnShowFulFilmlDetail;
@property (weak, nonatomic) id<FilmInfoCellDelegate>delegate;
@property ( nonatomic) BOOL isIOS7;

- (IBAction)requestPlayTralerByFilm:(id)sender;
- (IBAction)viewLayout:(id)sender;
- (IBAction)handleActionLike:(id)sender;
-(void)setContentForCell:(Film *)film;
@end
