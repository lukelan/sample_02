

#import <UIKit/UIKit.h>

@class ThumbnailImageView;

@protocol ThumbnailImageViewSelectionDelegate <NSObject>
- (void)thumbnailImageViewWasSelected:(ThumbnailImageView *)thumbnailImageView;
@end

@interface ThumbnailImageView : UIImageView {

    UIImageView *highlightView;
}

@property(nonatomic, weak) id<ThumbnailImageViewSelectionDelegate> delegate;

- (void)clearSelection;
@end
