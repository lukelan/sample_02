//
//  StarRatingControl.m
//  RouteMonitor
//
//  Created by Tom Fewster on 16/03/2012.
//
#import "StarRatingControl.h"

#define kDefaultNumberOfStars 5
#define kStarPadding 5.0f
#define kTipWidth 40


@interface StarRatingControl ()
@property (assign) int numberOfStars;
@property (assign) int currentIdx;
@property (strong) NSArray *stars;
@end

@implementation StarRatingControl

@synthesize star = _star;
@synthesize highlightedStar = _highlightedStar;
@synthesize lblTip = _lblTip;

@synthesize delegate;
@synthesize numberOfStars = _numberOfStars;
@synthesize currentIdx = _currentIdx;

@synthesize stars = _stars;

#pragma mark -
#pragma mark Initialization
+(CGFloat)getHeightDefault
{
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"star-grey" ofType:@"png"];
    UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
    CGSize sizeText = [@"ABC" sizeWithFont:[UIFont getFontNormalSize10]];
    CGFloat height = sizeText.height + 3 + prodImg.size.height;
    [prodImg release];
    return height;
}

+(CGFloat)getWidthDefault:(int)numOfStar
{
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"star-grey" ofType:@"png"];
    UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
    int widthUnit = prodImg.size.width ;
    [prodImg release];
    return numOfStar*widthUnit + (numOfStar - 1)*kStarPadding;
}

- (UIFont*) getFontLabelTipsNumber
{
    return [UIFont getFontBoldSize13];
}

- (UIFont*) getFontLabelTipValue
{
    return [UIFont getFontBoldSize18];
}

-(UIColor *)getColorLabelTips
{
    return [UIColor colorWithWhite:0 alpha:0.5];
}

- (void)setupView
{
	self.clipsToBounds = YES;
	_currentIdx = 0;
	_star = [UIImage imageNamed:@"star-grey"];
	_highlightedStar = [UIImage imageNamed:@"star"];
	NSMutableArray *s = [NSMutableArray arrayWithCapacity:_numberOfStars];
	for (int i=0; i<_numberOfStars; i++) {
		UIImageView *v = [[UIImageView alloc] initWithImage:_star highlightedImage:_highlightedStar];
		[self addSubview:v];
		[s addObject:v];
        [v release];
	}
    CGSize sizeTips = [@"/99" sizeWithFont:[self getFontLabelTipsNumber]];
    _lbTipMax = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - sizeTips.width, self.frame.size.height - sizeTips.height, sizeTips.width, sizeTips.height)];
    [_lbTipMax setTextColor:[self getColorLabelTips]];
    [_lbTipMax setFont:[self getFontLabelTipsNumber]];
    [_lbTipMax setBackgroundColor:[UIColor clearColor]];
    [_lbTipMax setTextAlignment:UITextAlignmentLeft];
    [_lbTipMax setText:[NSString stringWithFormat:@"/%d", _numberOfStars]];
    [self addSubview:_lbTipMax];
    
    sizeTips = [@"99" sizeWithFont:[self getFontLabelTipValue]];
    _lblTip = [[UILabel alloc] initWithFrame:CGRectMake(_lbTipMax.frame.origin.x - sizeTips.width, self.frame.size.height - sizeTips.height, sizeTips.width, sizeTips.height)];
    [_lblTip setTextColor:[UIColor blackColor]];
    [_lblTip setFont:[self getFontLabelTipValue]];
    [_lblTip setBackgroundColor:[UIColor clearColor]];
    [_lblTip setTextAlignment:UITextAlignmentRight];
    [_lblTip setText:[NSString stringWithFormat:@"%d", self.currentIdx]];
    [self addSubview:_lblTip];
    
	_stars = [s copy];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		_numberOfStars = kDefaultNumberOfStars;
		[self setupView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		_numberOfStars = kDefaultNumberOfStars;
		[self setupView];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame andStars:(NSUInteger)numberOfStars {
	self = [super initWithFrame:frame];
	if (self) {
		_numberOfStars = numberOfStars;
		[self setupView];
	}
	return self;
}

- (void)layoutSubviews
{
	CGFloat width = (self.frame.size.width - kTipWidth - (kStarPadding * (_numberOfStars + 1))) / _numberOfStars;
	CGFloat cellWidth = MIN(self.frame.size.height, width);

	// We need to align the starts in the center of the view
	CGFloat padding = (self.frame.size.width - kTipWidth - (cellWidth * _numberOfStars + (kStarPadding * (_numberOfStars + 1)))) / 2.0f;
	CGFloat startTop = (self.frame.size.height - cellWidth) / 2;
    CGRect frame = _lbTipMax.frame;
    frame.origin.y = startTop + cellWidth - frame.size.height;
    _lbTipMax.frame = frame;
    frame = _lblTip.frame;
    frame.origin.y = startTop + cellWidth - frame.size.height + 2;
    _lblTip.frame = frame;
	[_stars enumerateObjectsUsingBlock:^(UIImageView *star, NSUInteger idx, BOOL *stop) {
		star.frame = CGRectMake(padding + kStarPadding + idx * cellWidth + idx * kStarPadding, startTop, cellWidth, cellWidth);
	}];
}

-(void)dealloc
{
    [_lbTipMax release];
    [_lblTip release];
    [super dealloc];
}
#pragma mark -
#pragma mark Touch Handling

- (UIImageView*)starForPoint:(CGPoint)point {
	for (UIImageView *star in _stars) {
		if (CGRectContainsPoint(star.frame, point)) {
			return star;
		}
	}

	return nil;
}

- (NSUInteger)indexForStarAtPoint:(CGPoint)point {
	return [_stars indexOfObject:[self starForPoint:point]];
}


- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint point = [touch locationInView:self];	
	NSUInteger index = [self indexForStarAtPoint:point];
	if (index != NSNotFound) {
		[self setRating:index+1];
		if ([self.delegate respondsToSelector:@selector(starRatingControl:willUpdateRating:)]) {
			[self.delegate starRatingControl:self willUpdateRating:self.rating];
		}
	} else if (point.x < ((UIImageView *)[_stars objectAtIndex:0]).frame.origin.x) {
		[self setRating:0];
		if ([self.delegate respondsToSelector:@selector(starRatingControl:willUpdateRating:)]) {
			[self.delegate starRatingControl:self willUpdateRating:self.rating];
		}
	}

	return YES;		
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
	[super cancelTrackingWithEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint point = [touch locationInView:self];

	NSUInteger index = [self indexForStarAtPoint:point];
	if (index != NSNotFound) {
		[self setRating:index + 1];
		if ([self.delegate respondsToSelector:@selector(starRatingControl:willUpdateRating:)]) {
			[self.delegate starRatingControl:self willUpdateRating:self.rating];
		}
	} else if (point.x < ((UIImageView*)[_stars objectAtIndex:0]).frame.origin.x) {
		[self setRating:0];
		if ([self.delegate respondsToSelector:@selector(starRatingControl:willUpdateRating:)]) {
			[self.delegate starRatingControl:self willUpdateRating:self.rating];
		}
	}
	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	if ([self.delegate respondsToSelector:@selector(starRatingControl:didUpdateRating:)]) {
		[self.delegate starRatingControl:self didUpdateRating:self.rating];
	}
	[super endTrackingWithTouch:touch withEvent:event];
}

#pragma mark -
#pragma mark Rating Property

- (void)setRating:(NSUInteger)rating {
	_currentIdx = rating;
    [_lblTip setText:[NSString stringWithFormat:@"%d", self.currentIdx]];
	[_stars enumerateObjectsUsingBlock:^(UIImageView *star, NSUInteger idx, BOOL *stop) {
		star.highlighted = (idx < _currentIdx);
	}];
}

- (NSUInteger)rating {
	return (NSUInteger)_currentIdx;
}

@end
