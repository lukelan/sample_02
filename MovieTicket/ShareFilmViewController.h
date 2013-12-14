//
//  ShareFilmViewController.h
//  123Phim
//
//  Created by Phuc Phan on 3/13/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Film.h"
#import "GAI.h"

@interface ShareFilmViewController : CustomGAITrackedViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Film *film;
@property (nonatomic, strong) UITableView *table;
@end
