

#import "ThumbnailImageView.h"

@interface ThumbnailImageView()
-(void)createHighlightImageViewIfNecessary;
@end

@implementation ThumbnailImageView

@synthesize delegate;

-(void) dealloc
{
    highlightView = nil;
    delegate = nil;
}

#pragma mark -
#pragma mark Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self createHighlightImageViewIfNecessary];
    if (highlightView && highlightView.superview)
    {
        [highlightView removeFromSuperview];
    }
    else
    {
        [self addSubview:highlightView];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [delegate thumbnailImageViewWasSelected:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [highlightView removeFromSuperview];
}

- (void)clearSelection {
    [highlightView removeFromSuperview];
}


#pragma mark -
#pragma mark Helper methods

- (void)createHighlightImageViewIfNecessary {
    if (!highlightView) {
        UIImage *thumbnailHighlight = [UIImage imageNamed:@"ThumbnailHighlight"];
        highlightView = [[UIImageView alloc] initWithImage:thumbnailHighlight];
        [highlightView setAlpha: 0.5];
    }
}


@end
