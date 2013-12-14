//
//  CheckInViewController.h
//  123Phim
//
//  Created by Nhan Mai on 5/27/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GAI.h"
#import "APIManager.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequestDelegate.h"
#import "Cinema.h"
#import "CustomTextView.h"
#import "DefineDataType.h"

@interface CheckInViewController : CustomGAITrackedViewController<UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RKManagerDelegate>


{
    UIScrollView *_svImageList;
    UILabel *_lbUploadImage;
    CustomTextView *_tvComment;
    NSMutableArray *_lstImage;
    BOOL _loadingShowing;
}

@property (nonatomic, strong) UITextView* messageTextInput;
@property (nonatomic, strong) NSString* imageString;
@property (nonatomic, strong) UITableView* layoutTable;
@property (nonatomic, weak) Cinema* cinema;
@property (nonatomic, strong) NSString *content;

@property (nonatomic, strong) NSString* alertMessage;
@property (nonatomic, strong) UIAlertView *sharingAlert;

@property (nonatomic, strong) NSString* link;
@property (nonatomic, strong) NSString* eventTitle;
@property (nonatomic, strong) NSString* cinemaTitle;
@property (nonatomic, assign) FBShareType fbShareType;



@end
