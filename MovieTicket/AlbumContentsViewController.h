

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

#import "AlbumContentsTableViewCell.h"
#import "CustomGAITrackedViewController.h"

@class AlbumContentsViewController;

@protocol AlbumContentsViewControllerDelegate <NSObject>

-(void)albumContentsViewController:(AlbumContentsViewController*) viewController didSelectImageList: (NSArray *) imageList;

@end

@interface AlbumContentsViewController : CustomGAITrackedViewController <UITableViewDataSource, UITableViewDelegate, AlbumContentsTableViewCellSelectionDelegate> {
    UITableView *_tableView;
    ALAssetsGroup *assetsGroup;
    NSMutableArray *assets;
    NSInteger lastSelectedRow;
    NSMutableArray *_lstSelectedImages;
}

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property(nonatomic, weak) id<AlbumContentsViewControllerDelegate> delegate;

@end
