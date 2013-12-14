/*
 * This file is part of the MVSelectorScrollView package.
 * (c) Andrea Bizzotto <bizz84@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE.md
 * file that was distributed with this source code.
 */


#import <UIKit/UIKit.h>

@class MVSelectorScrollView;

@protocol MVSelectorScrollViewDelegate
/**
 * Method called when a new page is selected
 * @param page index of selected page
 */
- (void)scrollView:(MVSelectorScrollView *)scrollView pageSelected:(int)pageSelected;
@end

/**
 * Class holding a scroll view with multiple values
 */
@interface MVSelectorScrollView : UIView<UIScrollViewDelegate>
{
    __weak id<MVSelectorScrollViewDelegate> _delegate;
}
/**
 * Scroll view with page size smaller than full control width
 */
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *scroller;

/**
 * Array of NSString instances representing values to be displayed
 */
@property (nonatomic, retain) NSArray *values;

/**
 * Currently selected index
 */
@property (nonatomic, assign) int selectedIndex;

/**
 * Method to select index with optional scroll view animation
 */
- (void)setSelectedIndex:(int)selectedIndex animated:(BOOL)animated;

/**
 * Whether the delegate method is called while the view is still scrolling. Fires multiple delegate calls each time a page boundary is crossed.
 * Leave disabled to receive a single delegate call only when the scrolling is completed
 */
@property (nonatomic, assign) BOOL updateIndexWhileScrolling;

/**
 * Delegate
 */
@property (nonatomic, weak) id<MVSelectorScrollViewDelegate> delegate;

@end
