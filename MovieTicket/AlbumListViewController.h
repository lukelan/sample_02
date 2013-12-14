//
//  AlbumListViewController.h
//  123Phim
//
//  Created by phuonnm on 7/10/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CustomGAITrackedViewController.h"
#import "AlbumContentsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface AlbumListViewController : CustomGAITrackedViewController <UITableViewDataSource, UITableViewDelegate>
{
    ALAssetsLibrary *assetsLibrary;
    NSMutableArray *groups;
    UITableView *_tableView;
}
@property(nonatomic, weak) id<AlbumContentsViewControllerDelegate> delegate;

@end