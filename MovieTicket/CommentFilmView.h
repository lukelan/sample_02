//
//  CommentFilmView.h
//  MovieTicket
//
//  Created by Nhan Ho Thien on 2/19/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "AppDelegate.h"
#import "APIManager.h"
#import "StarRatingControl.h"
#import "ASIHTTPRequestDelegate.h"
#import "CustomTextView.h"
#import "CustomGAITrackedViewController.h"
#import "AlbumListViewController.h"

@protocol CommentFilmViewDelegate <NSObject>

-(void)commentFilmDelegate:(Comment*)comments;

@end

@interface CommentFilmView : CustomGAITrackedViewController<UITextViewDelegate, StarRatingDelegate,UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, APIManagerDelegate, UINavigationControllerDelegate,  UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, AlbumContentsViewControllerDelegate, UIActionSheetDelegate, RKManagerDelegate>
{
    id<CommentFilmViewDelegate>__weak delegate_comment;
    BOOL isNeedCheck;
    int previousRating;
    ASIHTTPRequest *httpRequest;
    ASIFormDataRequest *_postRequest;
    CustomTextView *_tvComment;
    UIScrollView *_svImageList;
    NSMutableArray *_lstImage;
    BOOL _loadingShowing;
    UITableView *layoutTable;
    UILabel *_lbUploadImage;
    NSMutableArray *_lstImageUrl;
}
@property int comment_id;
@property int currentRating;
@property (nonatomic, strong) NSString *content;
@property(nonatomic,strong) StarRatingControl *ratingControl;
@property(nonatomic,weak) id delegate_comment;
@property(nonatomic,strong) Film *film;
@property(nonatomic,strong) UIButton *btnSend;
@property(nonatomic,strong) UILabel *lblHolderDisplayReview;
@end
