//
//  CommentFilmView.m
//  MovieTicket
//
//  Created by Nhan Ho Thien on 2/19/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#define COMMENT_VIEW_SECTION_PROFILE 0
#define COMMENT_VIEW_SECTION_CAPTURE 1
#define COMMENT_VIEW_SECTION_FILM 2
#define COMMENT_VIEW_SECTION_RATING 3
#define COMMENT_VIEW_SECTION_COMMENT 4
#define COMMENT_VIEW_SECTION_SEND 5
#define COMMENT_VIEW_SECTION_TOTAL 6
#define UPLOAD_IMAGE_WIDTH 320
#define UPLOAD_IMAGE_LIMIT 5
#define SHOW_IMAGE_WIDTH 60
//#define SENT_IMAGE_HEIGHT 60

#import "CommentFilmView.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "FacebookManager.h"
#import "ProfileTableViewCell.h"
#import "UIImage+Ultility.h"
#import "CustomUIImagePickerController.h"
#import <QuartzCore/QuartzCore.h>

@interface CommentFilmView ()
@end

@implementation CommentFilmView

@synthesize delegate_comment,currentRating, content, comment_id;
@synthesize lblHolderDisplayReview, btnSend;
@synthesize ratingControl;
@synthesize film = _film;

-(void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
    }
    if (_postRequest)
    {
        [_postRequest clearDelegatesAndCancel];
    }
    [_lstImage removeAllObjects];
    delegate_comment = nil;
    isNeedCheck = nil;
    previousRating = nil;
    httpRequest = nil;
    _postRequest =nil;
    _tvComment = nil;
    _svImageList =nil;
    _lstImage = nil;
    _loadingShowing = nil;
    layoutTable = nil;
    _lbUploadImage = nil;
    _lstImageUrl = nil;
    comment_id = nil;
    currentRating = nil;
    content = nil;
    ratingControl =nil;
    _film = nil;
    btnSend = nil;
    lblHolderDisplayReview = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        currentRating = 0;
        comment_id = -1;
        previousRating = 0;
        self.content = @"";
        isNeedCheck = NO;//check xem co can kiem tra data khac data truoc moi duoc commit hay ko
        viewName = COMMENT_VIEW_NAME;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLoadMyCommentIfNeed) name:NOTIFICATION_NAME_LOGIN_SUCCESS object:nil];
    }
    return self;
}

-(void)checkLoadMyCommentIfNeed
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([[delegate getCurrentViewController] isEqual:self]) {
        if (currentRating == 0 && [delegate isUserLoggedIn])
        {
            if ([AppDelegate isNetWorkValiable])
            {
                [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR];
                [[APIManager sharedAPIManager] getMyCommentByFilmID:_film.film_id.integerValue withUserId:delegate.userProfile.user_id context:self];
            }
        } else {
            [self hideLoadingView];
        }
    }
}
- (void)initLayoutTable
{
    //init layouttable
    
    CGFloat tableHeight = [[UIScreen mainScreen] bounds].size.height - NAVIGATION_BAR_HEIGHT - 20;
    layoutTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, tableHeight) style:UITableViewStyleGrouped];
    layoutTable.dataSource = self;
    layoutTable.delegate = self;
    layoutTable.backgroundView = nil;
    layoutTable.userInteractionEnabled = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:@"Bình Luận / Đánh Giá"];
    
    [self initLayoutTable];
    [self.view addSubview:layoutTable];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    [[[GAI sharedInstance] defaultTracker] sendView:viewName];
    self.trackedViewName = viewName;
//    self = viewName;
//    NSString* previewView = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).currentView;
//    NSString* currentView = viewName;
//    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:currentView comeFrom:previewView withActionID:LOG_ACTION_ID_VIEW currentFilmID:[NSNumber numberWithInt:NO_FILM_ID] currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID] returnCodeValue:0 context:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"-----------");
}

-(void)viewWillAppear:(BOOL)animated
{
    [self checkLoadMyCommentIfNeed];
    if (_lstImage && _lstImage.count > 0) {
        NSArray *arr = _svImageList.subviews;
//        CGPoint offset = CGPointZero;
        if (arr)
        {
            [arr makeObjectsPerformSelector:@selector(removeFromSuperview)];
//            offset = _svImageList.contentOffset;
            _svImageList.contentSize = CGSizeZero;
        }
        for (UIImage *image in _lstImage)
        {
//            CGSize size = image.size;
            NSInteger imageWidth = SHOW_IMAGE_WIDTH;
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            CGSize contentSize = _svImageList.contentSize;
            if (contentSize.width != 0)
            {
                contentSize.width += MARGIN_EDGE_TABLE_GROUP;
            }
            imageView.frame = CGRectMake(contentSize.width, 0, imageWidth, imageWidth);
            contentSize.width += imageWidth;
            _svImageList.contentSize = contentSize;
            UIImage *closeImage = [UIImage imageNamed:@"delete_image.png"];
            UIImageView *closeView = [[UIImageView alloc] initWithImage:closeImage];
            closeView.frame = CGRectMake(imageView.frame.size.width - closeImage.size.width, 0, closeImage.size.width, closeImage.size.height);
            [imageView addSubview:closeView];
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeImageViewWithGesture:)];
            [imageView addGestureRecognizer:tapGesture];
            [_svImageList addSubview:imageView];
            if (_lbUploadImage && _lbUploadImage.superview)
            {
                [_lbUploadImage removeFromSuperview];
            }
        }
        if (_svImageList.contentSize.width > _svImageList.frame.size.width)
        {
            [_svImageList setContentOffset:CGPointMake(_svImageList.contentSize.width - _svImageList.frame.size.width, 0) animated:YES];
        }
    }
    [super viewWillAppear:animated];
}

-(BOOL)uploadImageList
{
    if (!_lstImage || _lstImage.count == 0)
    {
        return NO;
    }
    if (!_lstImageUrl)
    {
        _lstImageUrl = [[NSMutableArray alloc] init];
    }
    for (UIImage *image in _lstImage)
    {
         [[APIManager sharedAPIManager] uploadImage: image name:@"comments" compressionQuality:0.7 responseID:self];
    }
    return YES;
}

-(void)performSendRatingAndComment
{
    // send log to 123phim server
    
//    for (UIImageView *view in _svImageList.subviews) {
//        UIImage *image = view.image;
//        CGSize size= image.size;
//        LOG_123PHIM(@"AA___ %f, %f", size.width, size.height);
//    }
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:delegate.currentView
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_FILM_COMMENT
                                                     currentFilmID:self.film.film_id
                                                   currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID]
                                                   returnCodeValue:0 context:nil];


    if (![delegate isUserLoggedIn])
    {
    #ifdef ENABLECOMMENTBYMAIL
        [self alertComment:@""];
    #else
        {
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate showAlert:@"Thông báo" content:@"Bạn phải đăng nhập để sử dụng tính năng này"];
        }
    #endif
        return;
    }

    NSString *textComment = [[_tvComment getText] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![textComment isKindOfClass:[NSString class]] || textComment.length == 0) {
        [_tvComment becomeFirstResponder];
        return;
    }
    [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR];
    if (![self uploadImageList])
    {
        [self summitComment];
    }
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Film"
                                                    withAction:@"Rating&Comment"
                                                     withLabel:@"Touched"
                                                     withValue:[NSNumber numberWithInt:112]];
}
-(void)summitComment
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (currentRating > 0)
    {
        if ([delegate isUserLoggedIn])
        {
            [[APIManager sharedAPIManager] saveCommentByFilm:_film.film_id.integerValue andRating:currentRating ofUser:delegate.userProfile.user_id withContent:[_tvComment getText] optionalContentID:comment_id optionalImageURlList:_lstImageUrl responseID: self];
            [_tvComment setText:@""];
            [ratingControl setRating:0];
            btnSend.enabled = NO;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)isCommentValidToSendOverride
{
    if (!isNeedCheck) {
        btnSend.enabled = YES;
        return;
    }
    if (currentRating > 0) {
        if(previousRating > 0 && previousRating == currentRating)
        {
            if ([self.content isEqualToString:[_tvComment getText]]) {
                btnSend.enabled = NO;
                return;
            }
        }
    }
    btnSend.enabled = YES;
}
#pragma mark Event AlertView

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
   
    if  (buttonIndex == 1)
        {
//            NSLog(@"1 %@", [alertView textFieldAtIndex:0].text);
//            NSLog(@"2 %@", [alertView textFieldAtIndex:1].text);
            if (buttonIndex == [alertView cancelButtonIndex])
            {
                NSLog(@"The cancel button was clicked for alertView");
            }
            else
            {
                if ( [[alertView textFieldAtIndex:0].text isEqualToString:@""] || [[alertView textFieldAtIndex:1].text isEqualToString:@""])
                {
                    [self alertComment:@"Vui lòng điền đầy đủ thông tin"];
                }
                else if (![[alertView textFieldAtIndex:0].text isEqualToString:@""] && ![[alertView textFieldAtIndex:1].text isEqualToString:@""])
                {
                    if ([self validateEmailWithString:[alertView textFieldAtIndex:0].text] == NO)
                    {
                    [self alertComment:@"Email chưa đúng"];
                    }
                    else
                    {
                     //comment success
                    }
                }
            }
        }
 
}
- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
-(void)alertComment: (NSString *)checkEmail
{
    if ([checkEmail isEqualToString:@""])
    {
    checkEmail = @"Vui lòng nhập thông tin để đánh giá";
    }
    UIAlertView *alertComment = [[UIAlertView alloc] initWithTitle:@"Bạn chưa đăng nhập" message:checkEmail delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertComment setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];

//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
//    {
//        UIView *viewAlert=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
//        viewAlert.backgroundColor=[UIColor yellowColor];
//        UIButton *btFacebook=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
//        btFacebook.backgroundColor =[UIColor blueColor];
//        //[aleartComment addSubview:newButton];
//        // Alert style customization
//        UILabel *labelerror=[[UILabel alloc]initWithFrame:CGRectMake(0,0 , 200, 30)];
//        labelerror.text = checkEmail;
//        labelerror.font = [UIFont systemFontOfSize:12];
//        [viewAlert addSubview:btFacebook];
//        [btFacebook setFrame:CGRectMake((viewAlert.frame.size.width - btFacebook.frame.size.width)/2, 0,   btFacebook.frame.size.width, btFacebook.frame.size.height)];
//        [labelerror setFrame:CGRectMake((viewAlert.frame.size.width - labelerror.frame.size.width)/2, viewAlert.frame.size.height - labelerror.frame.size.height,   labelerror.frame.size.width, labelerror.frame.size.height)];
//        [viewAlert addSubview:labelerror];
//        [alertComment addSubview:viewAlert];
//          [alertComment setValue:viewAlert forKey:@"accessoryView"];
//    }
    [[alertComment textFieldAtIndex:1] setSecureTextEntry:NO];
    [[alertComment textFieldAtIndex:0] setPlaceholder:@"Email"];
    [[alertComment textFieldAtIndex:1] setPlaceholder:@"Name"];
    [alertComment show];
}
#pragma mark TableView Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return COMMENT_VIEW_SECTION_TOTAL;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"CELL_%d_%d",indexPath.section, indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        if (indexPath.section == COMMENT_VIEW_SECTION_PROFILE)
        {
            cell = [[ProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            ((ProfileTableViewCell *)cell).text = COMMENT_LOGIN_DESC;
            [cell layoutIfNeeded];
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center addObserver:self selector:@selector(didLoadUserProfile:) name:NOTIFICATION_NAME_PROFILE_CELL_USER_PROFILE_DID_LOAD object:nil];
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.section == COMMENT_VIEW_SECTION_CAPTURE)
            {
                [self layoutCaptureCell: cell];
            }
            else if (indexPath.section == COMMENT_VIEW_SECTION_FILM)
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font = [UIFont getFontBoldSize15];
                cell.textLabel.text = _film.film_name;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
            else if (indexPath.section == COMMENT_VIEW_SECTION_RATING)
            {
                [self layoutCellRating:cell];
            }
            else if (indexPath.section == COMMENT_VIEW_SECTION_COMMENT)
            {
                [self layoutBoxComment:cell];
            }
            else
            {
                //    save button
                UIImage *saveImage = [UIImage imageNamed:@"send_comment.png"];
                CGRect saveFrame = CGRectZero;
                saveFrame.size.width = saveImage.size.width;
                saveFrame.size.height = saveImage.size.height;
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
                {
                    saveFrame = CGRectMake(10, 0, 300, 40);
                    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                }
                btnSend = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                btnSend.frame = saveFrame;
                [btnSend addTarget:self action:@selector(performSendRatingAndComment) forControlEvents:UIControlEventTouchUpInside];
                btnSend.enabled = NO;
                [btnSend setBackgroundImage: saveImage forState:UIControlStateNormal];
                btnSend.layer.cornerRadius = 2.0f;
                cell.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:btnSend];
                
            }
        }
        
    }
    return cell;
}

-(void)pushImagePickerViewController
{
    CustomUIImagePickerController * imagePicker = [[CustomUIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    [self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * image;// = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGSize size = image.size;
    NSInteger imageWidth = UPLOAD_IMAGE_WIDTH;
    NSInteger imageHeight = imageWidth *(size.width / size.height);
    image = [UIImage reduceImage:[info objectForKey:UIImagePickerControllerOriginalImage] toRect:CGSizeMake(imageWidth, imageHeight)];
    if (!_lstImage)
    {
        _lstImage = [[NSMutableArray alloc] init];
    }
    [_lstImage addObject:image];
    [self dismissModalViewControllerAnimated:YES];
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.view == self.view)
    {
        [_tvComment resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void) removeImageViewWithGesture: (UITapGestureRecognizer *) gesture
{
    UIImageView *imageView = (UIImageView *) gesture.view;
    if (![imageView isKindOfClass:[UIImageView class]])
    {
        return;
    }
    UIImage *image = imageView.image;
    [_lstImage removeObject:image];
    [imageView removeFromSuperview];
    CGSize size = _svImageList.contentSize;
    size.width -= (imageView.frame.size.width + MARGIN_EDGE_TABLE_GROUP);
    _svImageList.contentSize = size;
    for (UIImageView *imgView in _svImageList.subviews)
    {
        CGRect frame = imgView.frame;
        if (frame.origin.x > imageView.frame.origin.x)
        {
            frame.origin.x -= (frame.size.width + MARGIN_EDGE_TABLE_GROUP);
            imgView.frame = frame;
        }
    }
    if (_lstImage.count == 0)
    {
        [_svImageList addSubview:_lbUploadImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark TableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return MARGIN_EDGE_TABLE_GROUP / 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return MARGIN_EDGE_TABLE_GROUP / 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = 40;
    if (indexPath.section == COMMENT_VIEW_SECTION_PROFILE)
    {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if([delegate isUserLoggedIn])
        {
            return PROFILE_CELL_DID_LOAD_HEIGHT;
        }
        else
        {
            return PROFILE_CELL_NOT_LOAD_HEIGHT;
        }
    }
    if (indexPath.section == COMMENT_VIEW_SECTION_COMMENT || indexPath.section == COMMENT_VIEW_SECTION_CAPTURE)
    {
        return (height * 2);
    }
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == COMMENT_VIEW_SECTION_FILM)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark layout cell

-(void)layoutCaptureCell: (UITableViewCell *) cell
{
    UIImage *cameraImage = [UIImage imageNamed:@"camera.png"];
    CGSize imageSize = cameraImage.size;
    CGRect frame = CGRectMake(cell.contentView.frame.size.width - imageSize.width - 3 * MARGIN_EDGE_TABLE_GROUP, MARGIN_EDGE_TABLE_GROUP, imageSize.width, imageSize.height);
    
    UIButton *btnBrowse = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBrowse.frame = frame;
    [btnBrowse setImage:cameraImage forState:UIControlStateNormal];
    [btnBrowse addTarget:self action:@selector(openActionSheet:) forControlEvents:UIControlEventTouchUpInside];
//    [btnBrowse setBackgroundImage:[UIImage imageNamed:@"button_session"] forState:UIControlStateNormal];
  //  [btnBrowse setImage:cameraImage forState:UIControlStateNormal];
    [cell.contentView addSubview:btnBrowse];
    
    frame.origin.x = MARGIN_EDGE_TABLE_GROUP;
    frame.size.width = cell.contentView.frame.size.width - imageSize.width - 5 * MARGIN_EDGE_TABLE_GROUP;
    _svImageList = [[UIScrollView alloc] initWithFrame:frame];
    frame.origin.y = 0;
    frame.origin.x = 0;
    _lbUploadImage = [[UILabel alloc] initWithFrame:frame];
    _lbUploadImage.font = [UIFont getFontNormalSize13];
    _lbUploadImage.text = @"Hình tải lên";
    _lbUploadImage.textColor=[UIColor lightGrayColor];
    [_lbUploadImage setBackgroundColor:[UIColor clearColor]];
    [_svImageList addSubview:_lbUploadImage];
    [cell.contentView addSubview:_svImageList];
}

-(void)layoutBoxComment:(UITableViewCell *)cell
{
    _tvComment =[[CustomTextView alloc] initWithFrame:CGRectMake(0, MARGIN_EDGE_TABLE_GROUP / 2, cell.contentView.frame.size.width - MARGIN_EDGE_TABLE_GROUP * 2, cell.contentView.frame.size.height + 5 * MARGIN_EDGE_TABLE_GROUP / 2)];
    [_tvComment setDelegate:[MainViewController sharedMainViewController]];
    [_tvComment layoutWithRadius:MARGIN_CELL_SESSION andImageIcon:nil hoderText:@"Nội dung bình luận"];
    _tvComment.layer.masksToBounds=YES;
    [_tvComment setText: self.content];
    [_tvComment setKeyBoardType: UIKeyboardTypeDefault];
//    stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding
    [cell.contentView addSubview:_tvComment];
}

-(void)layoutCellRating:(UITableViewCell *)cell
{
    //NSString *thePath = [[NSBundle mainBundle] pathForResource:@"star-grey" ofType:@"png"];
    //UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
    CGRect frame = cell.contentView.frame;
    frame.origin.x = MARGIN_EDGE_TABLE_GROUP;
    frame.size.width -= (4 * MARGIN_EDGE_TABLE_GROUP);
    ratingControl = [[StarRatingControl alloc] initWithFrame:frame andStars:10];
    ratingControl.delegate = self;
    [ratingControl setRating:currentRating];
    [cell.contentView addSubview:ratingControl];
}

#pragma mark start rating delegate
- (void)starRatingControl:(StarRatingControl *)control didUpdateRating:(NSUInteger)rating
{
    currentRating = rating;
    if (rating > 0 && rating <= MAX_STAR_TO_RATING) {
        [self isCommentValidToSendOverride];
    } else {
        btnSend.enabled = NO;
    }
}
#pragma mark process alert
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView.message compare:COMMENT_MESSAGE_SEND_DONE] == NSOrderedSame)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -RKManageDelegate
-(void)processResultResponseDictionaryMapping:(DictionaryMapping *)dictionary requestId:(int)request_id
{
    if (![dictionary isKindOfClass:[DictionaryMapping class]])
    {
        return;
    }
    if (request_id == ID_REQUEST_GET_MY_COMMENT_BY_FILM)
    {
        [self parseToGetRatingAndContentComment:dictionary.curDictionary];
        [self hideLoadingView];
    }
    else if (request_id == ID_REQUEST_POST_COMMENT)
    {
        id result = [dictionary.curDictionary objectForKey:@"result"];
        if ([[APIManager sharedAPIManager] isValidData:result] && [result isKindOfClass:[NSString class]]) {
            [self showStatusMessageSend:result];
        }
        [self hideLoadingView];
    }
}

-(void)processResultResponseArrayMapping:(ArrayMapping *)array requestId:(int)request_id
{
    if (request_id == ID_REQUEST_UPLOAD_IMAGE)
    {
        [self getResultUploadImageResponse:array.curArray];
    }
}

- (void)getResultUploadImageResponse:(NSArray *)arr
{
    NSString *url = [[APIManager sharedAPIManager] parseToGetUrlOfImageUploadedWithRespone:arr];
    [_lstImageUrl addObject:url];
    if (_lstImageUrl.count == _lstImage.count) {
        [self summitComment];
    }
}
#pragma mark - ASIHttpRequestDelegate
- (void)showStatusMessageSend:(NSString *)response
{
    //        LOG_123PHIM(@"%@", response);
    NSString *msg = COMMENT_MESSAGE_SEND_FAILED;
    if (response && response.length > 0)
    {
        msg = COMMENT_MESSAGE_SEND_DONE;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message: msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    NSString *response = [request responseString];
    if(request.tag == ID_REQUEST_UPLOAD_IMAGE)
    {
        NSArray *arr = [[APIManager sharedAPIManager].parser objectWithString:response];
        [self getResultUploadImageResponse:arr];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
     [super requestFailed:request];
}

-(void) parseToGetRatingAndContentComment:(NSDictionary *)dicObject
{
    if (!dicObject || ![dicObject isKindOfClass:[NSDictionary class]])
    {
        return;
    }
//    NSDictionary * dicObject = [[APIManager sharedAPIManager].parser objectWithString:response error:nil];
    NSDictionary *token = [dicObject  objectForKey:@"result"];
    if ([token isKindOfClass:[NSDictionary class]]) {
        id getData = [token objectForKey:@"content"];
        if([[APIManager sharedAPIManager] isValidData:getData])
        {
            self.content = [getData stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (_tvComment) {
                [_tvComment setText:content];
                [lblHolderDisplayReview setHidden:YES];
            }
        }        
        getData = [token objectForKey:@"rate"];
        if([[APIManager sharedAPIManager] isValidData:getData])
        {
            currentRating = [getData intValue];
            if (ratingControl) {
                previousRating = currentRating;
                [ratingControl setRating:currentRating];
            }
            if (!isNeedCheck) {
                btnSend.enabled = YES;
            }
        }
        getData = [token objectForKey:@"comment_id"];
        if([[APIManager sharedAPIManager] isValidData:getData])
        {
            comment_id = [getData intValue];
        }
    }
//    dicObject = nil;
}

#pragma mark APIManagerDelegate
-(void)setHTTPRequest: (ASIHTTPRequest *) theRequest
{
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
    }
    httpRequest = theRequest;
}

-(void)didLoadUserProfile: (NSNotification*) notification
{
    [layoutTable reloadSections:[NSIndexSet indexSetWithIndex:COMMENT_VIEW_SECTION_PROFILE] withRowAnimation:UITableViewRowAnimationNone];
    if (_loadingShowing)
    {
        [self hideLoadingView];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *v = touches.anyObject;
    if (v != _tvComment)
    {
        [_tvComment resignFirstResponder];
    }
    [super touchesEnded:touches withEvent:event];
}

-(void)showUploadLimitAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:ALERT_MESSAGE_UPLOAD_LIMIT delegate:nil cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil];
    [alert show];
}

-(void)openActionSheet:(id)sender
{
    if ([_lstImage count] >= UPLOAD_IMAGE_LIMIT)
    {
        [self showUploadLimitAlert];
        return;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:STR_INSERT_PIC_FROM delegate:self cancelButtonTitle:BUTTON_CANCEL destructiveButtonTitle:nil otherButtonTitles:BUTTON_TAKE_PIC, BUTTON_PHOTO_LIB, nil];

    [actionSheet showInView:self.view];
}

-(void)openPhotoLibrary
{
    AlbumListViewController *alListVC = [[AlbumListViewController alloc] init];
    alListVC.delegate = self;
    [self.navigationController pushViewController:alListVC animated:YES];
}

-(void)albumContentsViewController:(AlbumContentsViewController *)viewController didSelectImageList:(NSArray *)imageList
{
    if (!_lstImage)
    {
        _lstImage = [[NSMutableArray alloc] init];
    }
    if (!imageList)
    {
        return;
    }
    if ([_lstImage count] + [imageList count] > UPLOAD_IMAGE_LIMIT) {
        [self showUploadLimitAlert];
        return;
    }
    
//    resize image
    for (__strong UIImage *image in imageList)
    {
        CGSize size = image.size;
        NSInteger imageWidth = UPLOAD_IMAGE_WIDTH;
        NSInteger imageHeight = imageWidth *(size.width / size.height);
        image = [UIImage reduceImage:image toRect:CGSizeMake(imageWidth, imageHeight)];
        if (!_lstImage)
        {
            _lstImage = [[NSMutableArray alloc] init];
        }
        [_lstImage addObject:image];

    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:BUTTON_TAKE_PIC])
    {
        [self pushImagePickerViewController];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:BUTTON_PHOTO_LIB])
    {
        [self openPhotoLibrary];
    }
}


@end
