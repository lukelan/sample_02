/*
 * This file is part of the MVSelectorScrollView package.
 * (c) Andrea Bizzotto <bizz84@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE.md
 * file that was distributed with this source code.
 */


#import "MVSelectorScrollView.h"
#import "MVSelectorContentView.h"

@implementation MVSelectorScrollView {
    NSMutableArray *subviews;
}
@synthesize values = _values;
@synthesize selectedIndex = _selectedIndex;

- (void)dealloc {
//    [_values release];
    self.scrollView = nil;
    self.scroller = nil;
    [self clearSubviews];
}

// Explanation of why initWithCoder is used here:
// http://stackoverflow.com/questions/9251202/how-do-i-create-a-custom-ios-view-class-and-instantiate-multiple-copies-of-it-i/9251254#9251254
// Potential problem with recursive calls if view is used instead of owner
// http://stackoverflow.com/questions/10455521/endless-recursive-calls-to-initwithcoder-when-instantiating-xib-in-storyboard
-(id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])){
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"MVSelectorScrollView" owner:self options:nil];
        UIView *view = [views objectAtIndex:0];
        [self addSubview:view];
        //The setup code (in viewDidLoad in your view controller)
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];
//        [singleFingerTap release];
    }
    return self;
}

- (void)setValues:(NSArray *)values {
    _selectedIndex = 0;
    NSAssert(values != nil, @"Values can't be nil");

    _values = values;
    
    // Set contentSize to width of scroll view times the number of values
    CGRect frame = self.scrollView.frame;
    self.scrollView.contentSize = CGSizeMake(values.count * frame.size.width, frame.size.height);
    self.scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
    
    [self populateScrollView:values];
}

- (void)clearSubviews {
    
    for (UIView *view in subviews) {
        [view removeFromSuperview];
    }
    subviews = nil;
}

- (void)populateScrollView:(NSArray *)values {
    
    [self clearSubviews];
    
    CGSize size = self.scrollView.frame.size;
    
    subviews = [NSMutableArray new];
    for (int i = 0; i < values.count; i++) {
        
        NSString *text = [values objectAtIndex:i];

        // Position based on index
        CGRect frame = CGRectMake(i * size.width, 0.0f, size.width, size.height);
        MVSelectorContentView *subview = [[MVSelectorContentView alloc] initWithFrame:frame text:text];
        [subviews addObject:subview];
        [self.scrollView addSubview:subview];
        if (_selectedIndex == i) {
            subview.selected = YES;
        } else {
            subview.selected = NO;
        }
    }
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self];
    CGPoint pointInScrollView = [self convertPoint:location toView:self.scrollView];
    //Do stuff here...
    if (pointInScrollView.x < 0.0f || pointInScrollView.x > self.scrollView.contentSize.width) {
        return;
    }
    NSInteger page = [self calculatePage:pointInScrollView.x];
    if (_selectedIndex != page) {
        
        // Page has changed: update index, change hightlight, call delegate
        if (page >= 0 && page < subviews.count) {
            
            [self changeHighlightFrom:_selectedIndex to:page];
            //NSLog(@"%s old: %d, new: %d", __func__, previousPage, page);

            [self updatePage:page];
        }
        [self.scrollView setContentOffset:CGPointMake(page * self.scrollView.frame.size.width, 0.0f) animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate methods

// Detecting page change:
// http://stackoverflow.com/questions/5272228/detecting-uiscrollview-page-change
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Skip negative values as they may end up generating a positive index != 0
    if (scrollView.contentOffset.x < 0.0f)
        return;
    
    NSInteger page = [self calculatePage:scrollView.contentOffset.x];
    if (_selectedIndex != page) {

        // Page has changed: update index, change hightlight, call delegate
        if (page >= 0 && page < subviews.count) {
            //NSLog(@"%s old: %d, new: %d", __func__, previousPage, page);
            
            if (self.updateIndexWhileScrolling)
            {
                [self changeHighlightFrom:_selectedIndex to:page];
                [self updatePage:page];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.updateIndexWhileScrolling) {
        NSInteger page = [self calculatePage:scrollView.contentOffset.x];
        [self changeHighlightFrom:_selectedIndex to:page];
            [self updatePage:page];
    }
}


#pragma mark - setters

- (void)setSelectedIndex:(int)selectedIndex {
    
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(int)selectedIndex animated:(BOOL)animated {
    
    if (_selectedIndex != selectedIndex) {

        [self changeHighlightFrom:_selectedIndex to:selectedIndex];
        CGPoint offset = CGPointMake(selectedIndex * self.scrollView.frame.size.width, 0.0f);
        [self.scrollView setContentOffset:offset animated:animated];
    }
}

#pragma mark - utility methods

- (void)updatePage:(NSInteger)page 
{  
    [self.delegate scrollView:self pageSelected:page];
}

- (NSInteger)calculatePage:(CGFloat)currentOffset {
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = currentOffset / pageWidth;
//    NSInteger page = lroundf(fractionalPage);
    //NSAssert(page < subviews.count, @"Page: %d, Count: %d", page, subviews.count);
    if (page >= subviews.count)
        page = subviews.count - 1;
    if (page < 0)
        page = 0;
    return page;
}

// Update highlighting
- (void)changeHighlightFrom:(int)oldIndex to:(int)newIndex
{
//    NSLog(@"oldIndex = %d, newIndex = %d", oldIndex, newIndex);
    if (oldIndex != newIndex) {
        MVSelectorContentView *subview = [subviews objectAtIndex:newIndex];
        subview.selected = YES;
        
        MVSelectorContentView *oldSubview = [subviews objectAtIndex:oldIndex];
        oldSubview.selected = NO;
        _selectedIndex = newIndex;
    }
}

@end
