//
//  InputTextForFBSharingViewController.h
//  123Phim
//
//  Created by Nhan Mai on 4/24/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "AppDelegate.h"
#import "APIManager.h"
#import "Film.h"
#import "CommentFilmView.h"
#import "DefineDataType.h"

@interface InputTextForFBSharingViewController : CustomViewController<UITextViewDelegate, StarRatingDelegate,UITableViewDataSource, UITableViewDelegate>{
    NSNumber *_film_id;
}
@property int currentRating;
@property(nonatomic,weak) id<CommentFilmViewDelegate> delegate_comment;
@property(nonatomic,strong) UITableView *layoutTable;

@property(nonatomic,strong) NSNumber *film_id;
@property(nonatomic,strong) UIButton *btnSend;
@property(nonatomic,strong) UITextView *tvReview;
@property(nonatomic,strong) UILabel *lblHolderDisplayReview;

@property (nonatomic, strong) Film* film;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) NSString* link;

@property (nonatomic, assign) FBShareType fbShareType;

@end
