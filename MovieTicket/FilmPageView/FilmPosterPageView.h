//
//  FilmPosterPageView.h
//  MovieTicket
//
//  Created by phuonnm on 1/10/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGPageView.h"

#import "AutoScrollLabel.h"

@interface FilmPosterPageView : HGPageView

@property (nonatomic, strong) IBOutlet SDImageView *viewCustom;
@property (nonatomic, weak) IBOutlet UILabel *lbTilteRate_Show;
@property (nonatomic, weak) IBOutlet UILabel *lbValueRate_Show;
@property (nonatomic, strong) IBOutlet AutoScrollLabel *lbScrollFilmTitle;
@property (nonatomic, weak) IBOutlet UIImageView *ivNew;
@property (nonatomic, weak) IBOutlet UIImageView *ivBomTan;
@property (weak, nonatomic) IBOutlet UIImageView *ivPosterTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSaleOff;
@property (weak, nonatomic) IBOutlet UIView *viewSaleOff;

@property (nonatomic, assign) BOOL isInitialized;

@end

