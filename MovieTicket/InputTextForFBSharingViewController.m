//
//  InputTextForFBSharingViewController.m
//  123Phim
//
//  Created by Nhan Mai on 4/24/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//


static BOOL isSharing = NO;
static BOOL isFinishShare = NO;
static BOOL isCancelShare = NO;

#import "InputTextForFBSharingViewController.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "FacebookManager.h"


@interface InputTextForFBSharingViewController ()

@end

@implementation InputTextForFBSharingViewController

@synthesize btnSend;
@synthesize tvReview, lblHolderDisplayReview;
@synthesize layoutTable;
@synthesize film;
@synthesize message = _message;
@synthesize alert;
@synthesize link = _link;
@synthesize fbShareType;

-(void)dealloc
{
    alert.delegate = nil;
    _delegate_comment = nil;
    _currentRating = nil;
    layoutTable = nil;
    _film_id = nil;
    btnSend = nil;
    tvReview = nil;
    lblHolderDisplayReview = nil;
    film = nil;
    _message = nil;
    alert = nil;
    _link = nil;
    fbShareType = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _message = @"";
        viewName = INPUT_TEXT_FOR_FB_SHARING_VIEW_NAME;
    }
    return self;
}

- (void)initLayoutTable
{
    //init layouttable
    
    CGFloat tableHeight = [[UIScreen mainScreen] bounds].size.height - NAVIGATION_BAR_HEIGHT - 20;
    layoutTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, tableHeight) style:UITableViewStylePlain];
    layoutTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    layoutTable.dataSource = self;
    layoutTable.delegate = self;
    layoutTable.backgroundView = nil;
    layoutTable.userInteractionEnabled = YES;
}

-(void)layoutBoxComment:(UITableViewCell *)cell
{
    UILabel *lbtext=[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_EDGE_TABLE_GROUP, 0, cell.contentView.frame.size.width - 2*MARGIN_EDGE_TABLE_GROUP, 30)];
    lbtext.text=@"  Nội dung muốn chia sẻ";
    lbtext.font = [UIFont getFontBoldSize13];
    lbtext.textColor=[UIColor blackColor];
//    lbtext.font=[UIFont getFontNormalSize13;
    [lbtext setBackgroundColor:[UIColor clearColor]];
    [cell.contentView addSubview:lbtext];
    
    //add textvew
    UIImage *commentBoxImage = [UIImage imageNamed:@"fb_box.png"];
    CGFloat tvcmtHeight = commentBoxImage.size.height;
    CGFloat tvcmtWidth = commentBoxImage.size.width;
    tvReview =[[UITextView alloc] initWithFrame:CGRectMake(lbtext.frame.origin.x, lbtext.frame.size.height, tvcmtWidth, tvcmtHeight)];
    tvReview.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);   
    tvReview.text = self.message;
    tvReview.clipsToBounds = NO;
    self.tvReview.delegate=self;
    [tvReview becomeFirstResponder];
    tvReview.textColor=[UIColor blackColor];
    tvReview.layer.masksToBounds=YES;
    UIImageView *tvView = [[UIImageView alloc] initWithImage:commentBoxImage];
    tvView.frame = tvReview.frame;
    [cell.contentView addSubview:tvView];
    [self.tvReview setBackgroundColor:[UIColor clearColor]];
    tvReview.keyboardType = UIKeyboardTypeDefault;
    
    [cell.contentView addSubview:tvReview];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:@"Chia sẻ qua Facebook"];
    [self initLayoutTable];
    [self.view addSubview:layoutTable];
    
    UIImage *imageRight = [UIImage imageNamed:@"send_plane.png"];
    UIButton *customButtonR = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0, 0, imageRight.size.width, imageRight.size.height);
    customButtonR.frame = frame;
    [customButtonR setBackgroundImage:imageRight forState:UIControlStateNormal];
    [customButtonR addTarget:self action:@selector(performSendRatingAndComment) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc] initWithCustomView:customButtonR];
    self.navigationItem.rightBarButtonItem = btnRight;
//    NSString* previewView = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).currentView;
//    NSString* currentView = viewName;
//    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:currentView comeFrom:previewView withActionID:LOG_ACTION_ID_VIEW currentFilmID:[NSNumber numberWithInt:NO_FILM_ID] currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID] returnCodeValue:0 context:self];
}

-(void)performSendRatingAndComment
{
    
    [self shareViaFacebook:self.tvReview.text];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Film"
                                                withAction:@"Share"
                                                 withLabel:@"FaceBook"
                                                 withValue:[NSNumber numberWithInt:103]];
    
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:delegate.currentView
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_SESSION_SHARE_FB
                                                     currentFilmID:film.film_id
                                                   currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID]
                                                   returnCodeValue:0 context:nil];

}

- (void)shareViaFacebook:(NSString *)message
{
    //    LOG_123PHIM(@"Sharing via Facebook with message: %@", message);
    
    if (isSharing) return;
    
    [self showAlertSharing:@"Đang chia sẻ..."];
    
    FacebookManager *fbManager = [FacebookManager shareMySingleton];
    
//    [fbManager shareFilm:self.film withMessage:message onSuccess:^(id result) {
//        [self showAlertDone:@"Bạn đã chia sẻ thành công."];
//    } onError:^(NSError *error) {
//        [self showAlertFail:@"Chia sẻ không thành công."];
//    }];
    NSString* key = @"";
    if (self.fbShareType == FBShareTypeShareFilm) {
        key = @"film";
    }else if (self.fbShareType == FBShareTypeShareEvent){
        key = @"event";
    }else{}    
    
    [fbManager shareUrl:self.link key:key withMessage:message onSuccess:^(id result) {
        [self showAlertDone:@"Bạn đã chia sẻ thành công."];
    } onError:^(NSError *error) {
        [self showAlertFail:@"Chia sẻ không thành công."];
    }];

    
    
    //[self performSelector:@selector(shareTimer) withObject:nil afterDelay:15];
}

- (void)showAlertDone:(NSString *)message
{
    isFinishShare = YES;
    isSharing = NO;
    
    if (alert) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    }
    
    if (!isCancelShare) {
        alert = [[UIAlertView alloc] initWithTitle:@"123Phim" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        alert.tag = 102;
        [alert show];
        
        // auto close after 2.5s
        //        [self performSelector:@selector(closeAlertDone) withObject:nil afterDelay:2.5];
    } else {
        isCancelShare = NO;
    }
    
}

- (void)showAlertFail:(NSString *)message
{
    isFinishShare = YES;
    isSharing = NO;
    
    alert.tag = 103;
    alert.message = message;
    ((UIButton *)[alert viewWithTag:1]).hidden = NO;
    [((UIButton *)[alert viewWithTag:1]) setTitle:@"Đóng" forState:UIControlStateNormal];
    [((UIButton *)[alert viewWithTag:1]) setTitle:@"Đóng" forState:UIControlStateSelected];
}


- (void)showAlertSharing:(NSString *)message
{
    isFinishShare = NO;
    isSharing = YES;
    
    alert = [[UIAlertView alloc] initWithTitle:@"123Phim" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    
    ((UIView *)[alert viewWithTag:1]).hidden = YES;
    alert.tag = 101;
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark TableView Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell_%d",indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [self layoutBoxComment:cell];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark TableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = 2*MARGIN_EDGE_TABLE_GROUP;

    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"comment_box" ofType:@"png"];
    UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
    height += [@"From: " sizeWithFont:[UIFont getFontNormalSize13]].height + prodImg.size.height + MARGIN_EDGE_TABLE_GROUP;

    return height;

}

#pragma mark textField delegate
- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView hasText]) {
        if (textView == tvReview) {
            [lblHolderDisplayReview setHidden:YES];
        }
    } else {
        btnSend.enabled = NO;
        if (textView == tvReview) {
            [lblHolderDisplayReview setHidden:NO];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
}


@end
