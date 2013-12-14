//
//  FavoriteFilmViewController.h
//  MovieTicket
//
//  Created by Nhan Mai on 2/26/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GAI.h"

@interface FavoriteFilmViewController : CustomGAITrackedViewController<UITableViewDataSource, UITableViewDelegate>
{
    __weak id<PushVCFilmDelegate> _delegate;
}
@property (nonatomic, weak) id<PushVCFilmDelegate> delegate;

@property (nonatomic, strong) UITableView* table;

@end
