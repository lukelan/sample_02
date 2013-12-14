//
//  StarRatingControl.h
//  RouteMonitor
//
//  Created by Tom Fewster on 16/03/2012.
//

#import <UIKit/UIKit.h>

@protocol StarRatingDelegate;

@interface StarRatingControl : UIControl
{
    UILabel *_lbTipMax;
}
- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame andStars:(NSUInteger)_numberOfStars;

@property (strong) UIImage *star;
@property (strong) UIImage *highlightedStar;
@property (nonatomic, retain) UILabel *lblTip;
@property (assign) NSUInteger rating;
@property (nonatomic, retain) NSObject<StarRatingDelegate> *delegate;
+(CGFloat)getHeightDefault;
+(CGFloat)getWidthDefault:(int)numOfStar;
@end

@protocol StarRatingDelegate

@optional
- (void)starRatingControl:(StarRatingControl *)control didUpdateRating:(NSUInteger)rating;
- (void)starRatingControl:(StarRatingControl *)control willUpdateRating:(NSUInteger)rating;

@end
