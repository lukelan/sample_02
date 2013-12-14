//
//  FavoriteButton.m
//  123Phim
//
//  Created by Nhan Mai on 7/22/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "FavoriteButton.h"

@implementation FavoriteButton
@synthesize strPathImage = _strPathImage;
@synthesize delegate = _delegate;
@synthesize isLiked = _isLiked;
@synthesize filmId = _filmId;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addTarget:self action:@selector(changeLikeStatus) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self addTarget:self action:@selector(changeLikeStatus) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setIsLiked:(BOOL)isLiked{
    _isLiked = isLiked;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:[NSString stringWithFormat:NOTIFICATION_FAVORITE_CLICK_WITH_FILM_ID,_filmId] object:[NSNumber numberWithBool:_isLiked]];
}

- (void)changeLikeStatus
{
    self.isLiked = !self.isLiked;
}

-(void)didReceiveFavoriteUpdate:(NSNotification *)notification
{
    NSString *strFile = @"btnadd_to_watch_list";//default
    if (_strPathImage && _strPathImage.length > 1) {
        strFile = _strPathImage;
    }
    BOOL isLiked = [((NSNumber *) notification.object) boolValue];
    if (isLiked == YES) {
        NSString *thePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_sl", strFile] ofType:@"png"];
        UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
        [self setImage:prodImg forState:UIControlStateNormal];
    }else{
        NSString *thePath = [[NSBundle mainBundle] pathForResource:strFile ofType:@"png"];
        UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
        [self setImage:prodImg forState:UIControlStateNormal];
    }
    _isLiked = isLiked;
}

-(void)setFilmId:(NSInteger)filmId
{
    if (_filmId > 0)
    {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:[NSString stringWithFormat:NOTIFICATION_FAVORITE_CLICK_WITH_FILM_ID,filmId] object:nil];
    }
    _filmId = filmId;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didReceiveFavoriteUpdate:) name:[NSString stringWithFormat:NOTIFICATION_FAVORITE_CLICK_WITH_FILM_ID,filmId] object:nil];
}

-(void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    self.strPathImage = nil;
}

@end
