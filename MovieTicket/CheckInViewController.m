//
//  CheckInViewController.m
//  123Phim
//
//  Created by Nhan Mai on 5/27/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "CheckInViewController.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "ProfileTableViewCell.h"
#import "FacebookManager.h"
#import "CustomUIResponder.h"
#import "UIImage+Ultility.h"
#import "CustomUIImagePickerController.h"
#import "UIImage+Ultility.h"

static BOOL isSharing = NO;
static BOOL isFinishShare = NO;
static BOOL isCancelShare = NO;

#define COMMENT_VIEW_SECTION_PROFILE 0
#define COMMENT_VIEW_SECTION_COMMENT 1
#define COMMENT_VIEW_SECTION_CAPTURE 2
#define COMMENT_VIEW_SECTION_SEND 3


@interface CheckInViewController ()

@end

@implementation CheckInViewController
@synthesize messageTextInput, imageString;
@synthesize layoutTable;
@synthesize cinema;
@synthesize alertMessage, sharingAlert;
@synthesize link, eventTitle, cinemaTitle;
@synthesize fbShareType;

-(void) dealloc
{
    [_lstImage removeAllObjects];
    
    _svImageList = nil;
    _lbUploadImage = nil;
    _tvComment = nil;
    _lstImage = nil;
    _loadingShowing = nil;
    messageTextInput = nil;
    imageString = nil;
    layoutTable =nil;
    cinema = nil;
    _content = nil;
    alertMessage = nil;
    sharingAlert = nil;
    link = nil;
    eventTitle = nil;
    cinemaTitle = nil;
    fbShareType = nil;
    isSharing = nil;
    isFinishShare = nil;
    isCancelShare = nil;
    
}
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        //for layout table
        layoutTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - TITLE_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
        UIView* transparent = [[UIView alloc] init];
        transparent.backgroundColor = [UIColor clearColor];
        layoutTable.backgroundView = transparent;
        layoutTable.dataSource = self;
        layoutTable.delegate = self;
        
        self.content = @"";
        viewName = CHECK_IN_VIEW_NAME;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
	// Do any additional setup after loading the view.
    //for navigation bar
    self.navigationController.navigationBar.clipsToBounds = YES;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    
    NSString* viewTitle = @"";
    if (self.fbShareType == FBShareTypeCheckInCinema) {
        viewTitle = [NSString stringWithFormat: @"%@", self.cinemaTitle];
    }else if (self.fbShareType == FBShareTypeJoinEvent){
        viewTitle = [NSString stringWithFormat: @"%@", self.eventTitle];
    }else{}
    [delegate setTitleLabelForNavigationController:self withTitle:viewTitle];
    
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    
    [self.view addSubview:layoutTable];
    
//    NSString* previewView = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).currentView;
//    NSString* currentView = viewName;
//    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:currentView comeFrom:previewView withActionID:LOG_ACTION_ID_VIEW currentFilmID:[NSNumber numberWithInt: NO_FILM_ID] currentCinemaID:self.cinema.cinema_id returnCodeValue:0 context:self];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString* cellId = [NSString stringWithFormat:@"cell_%d_%d", indexPath.section, indexPath.row];
//    UITableViewCell *retCell = [tableView dequeueReusableCellWithIdentifier:cellId];
//    if (retCell == nil)
//    {
//        if (indexPath.section == 0) {
//            if (indexPath.row == 0) {
//                retCell = [[[TextViewWithImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
//                retCell.bounds = CGRectMake(0, 0, 300, 80);
//                [((TextViewWithImageCell*)retCell) makeStructure];
//                [((TextViewWithImageCell*)retCell).textview setTextHolderTips:@"Cảm nghĩ của bạn..."];
//                retCell.accessoryType = UITableViewCellAccessoryNone;
//                retCell.selectionStyle = UITableViewCellSelectionStyleNone;
//                return retCell;
//            }else if (indexPath.row == 1){
//                retCell = [[[TextViewWithImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
//                [((TextViewWithImageCell*)retCell) makeStructure];
//                retCell.accessoryType = UITableViewCellAccessoryNone;
//                retCell.selectionStyle = UITableViewCellSelectionStyleNone;
//                return retCell;
//            }else{}
//        }else if (indexPath.section == 1){
//            retCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//            UIButton* share = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            share.frame = CGRectMake(10, 10, 200, 30);
//            [share setTitle:@"share on facebook" forState:UIControlStateNormal];
//            [share addTarget:self action:@selector(handleShare) forControlEvents:UIControlEventTouchUpInside];
//            [retCell.contentView addSubview:share];
//            UIButton* share1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            share1.frame = CGRectMake(10, 50, 200, 30);
//            [share1 setTitle:@"get check in list" forState:UIControlStateNormal];
//            [share1 addTarget:self action:@selector(handleGetCheckInList) forControlEvents:UIControlEventTouchUpInside];
//            [retCell.contentView addSubview:share1];
//            
//            return  retCell;
//        }else{}
//        
//    }
//    return nil;
    NSString *cellIdentifier = [NSString stringWithFormat:@"CELL_%d_%d",indexPath.section, indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        if (indexPath.section == COMMENT_VIEW_SECTION_PROFILE)
        {
            cell = [[ProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            NSString* loginText = @"";
            if (self.fbShareType == FBShareTypeCheckInCinema) {
                loginText = COMMENT_LOGIN_DESC_CHECK_IN;
            }else if (self.fbShareType == FBShareTypeJoinEvent){
                loginText = COMMENT_LOGIN_DESC_EVENT_JOIN;
            }else{}
            ((ProfileTableViewCell *)cell).text = loginText;
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
            else if (indexPath.section == COMMENT_VIEW_SECTION_COMMENT)
            {
                [self layoutBoxComment:cell];
            }
            else
            {
                //    save button
                UIView* trans = [[UIView alloc] init];
                trans.backgroundColor = [UIColor clearColor];
                cell.backgroundView = trans;
                
                UIImage* imageLeft = [UIImage imageNamed:@"orange_wide_button.png"];
                UIButton* suportButton = [UIButton buttonWithType:UIButtonTypeCustom];
                suportButton.frame = CGRectMake(0, 0, 300, 40);
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
                {
                     suportButton.frame = CGRectMake(0, 0, 320, 40);
                    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                    cell.backgroundColor = [UIColor clearColor];
                }
                [suportButton setImage:imageLeft forState:UIControlStateNormal];
                [suportButton addTarget:self action:@selector(handleShareButton) forControlEvents:UIControlEventTouchUpInside];
                [suportButton setBackgroundColor:[UIColor clearColor]];
                
                UILabel *lblTitle = [[UILabel alloc] init];
                [lblTitle setFont:[UIFont getFontBoldSize14]];
                [lblTitle setText:CHECK_IN_SHARE_BUTTON_TITTLE];
                [lblTitle setTextColor:[UIColor whiteColor]];
                [lblTitle setBackgroundColor:[UIColor clearColor]];
                CGSize size = [lblTitle.text sizeWithFont:lblTitle.font];
                [lblTitle setFrame:CGRectMake((imageLeft.size.width - size.width)/2, (imageLeft.size.height - size.height)/2, size.width, size.height)];
                [suportButton addSubview:lblTitle];
                [cell.contentView addSubview:suportButton];
            }
        }
        
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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
#pragma mark -
#pragma mark -RKManageDelegate
#pragma mark -
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
    [self shareOnFacebookAndSaveOnServerWithImage:url];
}
#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
//    LOG_123PHIM(@"requestFinished abc");
    NSString* response = [request responseString];
    if(request.tag == ID_REQUEST_UPLOAD_IMAGE)
    {
        NSArray *arr = [[APIManager sharedAPIManager].parser objectWithString:response];
        [self getResultUploadImageResponse:arr];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
}

- (void)shareOnFacebookAndSaveOnServerWithImage: (NSString*)image
{
    [self shareViaFacebook:[_tvComment getText] imageUrl:image];
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [[APIManager sharedAPIManager] userCheckinAtCinema: [NSString stringWithFormat:@"%d", [self.cinema.cinema_id integerValue]] userId:appDelegate.userProfile.user_id context:nil];
}

#pragma mark - Button action
- (void)handleShareButton
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isUserLoggedIn]) {
        UIImage* img = [_lstImage objectAtIndex:0];        
        [[APIManager sharedAPIManager] uploadImage: img name:@"test_image" compressionQuality:1.0 responseID:self];
        
        
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"123Phim" message:@"Bạn cần đăng nhập để thực hiện chức năng này" delegate:nil cancelButtonTitle:@"Đóng" otherButtonTitles:nil];
        [alert show];
    }
    
}

#pragma mark - Layout cell

-(void)layoutCaptureCell: (UITableViewCell *) cell
{
    UIImage *cameraImage = [UIImage imageNamed:@"camera.png"];
    CGSize imageSize = cameraImage.size;
    UIImageView *cameraView = [[UIImageView alloc] initWithImage:cameraImage];
    CGRect frame = CGRectMake(cell.contentView.frame.size.width - imageSize.width - 3 * MARGIN_EDGE_TABLE_GROUP, MARGIN_EDGE_TABLE_GROUP, imageSize.width, imageSize.height);
    cameraView.frame = frame;
    cameraView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushImagePickerViewController)];
    [cameraView addGestureRecognizer:tapGesture];
    [cell.contentView addSubview:cameraView];
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
    _tvComment =[[CustomTextView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width - MARGIN_EDGE_TABLE_GROUP*2, cell.contentView.frame.size.height+30)];
    [_tvComment setDelegate:[MainViewController sharedMainViewController]];
    [_tvComment layoutWithRadius:MARGIN_CELL_SESSION andImageIcon:nil hoderText:@"Nội dung chia sẻ"];
    _tvComment.layer.masksToBounds=YES;
    [_tvComment setText: self.content];
    [_tvComment setKeyBoardType: UIKeyboardTypeDefault];
//    _tvComment.backgroundColor = [UIColor redColor];
    
    [cell.contentView addSubview:_tvComment];
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

-(void)pushImagePickerViewController
{
    NSInteger sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        CustomUIImagePickerController * imagePicker = [[CustomUIImagePickerController alloc] init];
        imagePicker.sourceType = sourceType;
        imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }else{
        LOG_123PHIM(@"device do not support");
    }
}

#pragma mark ImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGFloat width = originalImage.size.width;
    CGFloat height = originalImage.size.height;
    
    CGFloat desWidth = 480;
    CGFloat desHeight = desWidth*(height/width); //stand up
    
    if (width > height) {// lie on
        desHeight = 480;
        desWidth = desHeight*(width/height);
    }   
    
    UIImage* image = [UIImage reduceImage:originalImage toRect:CGSizeMake(desWidth, desHeight)];        
    NSData* imageData = UIImageJPEGRepresentation(image, 0.7);
    UIImage* reducedCapacitiImage = [UIImage imageWithData:imageData];
    
    LOG_123PHIM(@"image orientaion BEFOR adjust: %d", originalImage.imageOrientation);
//    if (image.imageOrientation != 0) {
//        image = [image fixOrientation];
//    }
    LOG_123PHIM(@"image orientaion AFTER adjust: %d", image.imageOrientation);
    
 
//    NSArray* array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString* documentPath = [array objectAtIndex:0];
//    NSString* filePath = [documentPath stringByAppendingPathComponent:@"test.jpg"];
//    [imageData writeToFile:filePath atomically:YES];
    
    if (!_lstImage)
    {
        _lstImage = [[NSMutableArray alloc] init];
    }
    [_lstImage removeAllObjects];
    [_lstImage addObject:reducedCapacitiImage];
    
    UIImageView *imageView = (UIImageView *)[_svImageList viewWithTag:123];
    LOG_123PHIM(@"type: %@", [imageView class]);
    
    if (imageView == nil) {
        imageView = [[UIImageView alloc] init];
        imageView.tag = 123;
        imageView.frame = CGRectMake(0, 0, 60, 60);
        
        UIImage *closeImage = [UIImage imageNamed:@"delete_image.png"];
        UIImageView *closeView = [[UIImageView alloc] initWithImage:closeImage];
        closeView.frame = CGRectMake(imageView.frame.size.width - closeImage.size.width, 0, closeImage.size.width, closeImage.size.height);
        [imageView addSubview:closeView];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeImageViewWithGesture:)];
        [imageView addGestureRecognizer:tapGesture];
        
        _svImageList.contentSize = CGSizeMake(imageView.frame.size.width, imageView.frame.size.height);
        [_svImageList addSubview: imageView];
    }
    imageView.image = reducedCapacitiImage;
    
    if (_lbUploadImage && _lbUploadImage.superview)
    {
        [_lbUploadImage removeFromSuperview];
    }
    [self dismissModalViewControllerAnimated:YES];
}
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    UIImage * image;// = [info objectForKey:UIImagePickerControllerOriginalImage];
//    NSInteger imageWidth = 60;
////    image = [UIImage reduceImage:[info objectForKey:UIImagePickerControllerOriginalImage] toRect:CGSizeMake(imageWidth, imageWidth)];
//    image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    if (!_lstImage)
//    {
//        _lstImage = [[NSMutableArray alloc] init];
//    }
//    [_lstImage addObject:image];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//    CGSize contentSize = _svImageList.contentSize;
//    if (contentSize.width != 0)
//    {
//        contentSize.width += MARGIN_EDGE_TABLE_GROUP;
//    }
//    imageView.frame = CGRectMake(contentSize.width, 0, imageWidth, imageWidth);
//    contentSize.width += imageWidth;
//    _svImageList.contentSize = contentSize;
//    
//    UIImage *closeImage = [UIImage imageNamed:@"delete_image.png"];
//    UIImageView *closeView = [[UIImageView alloc] initWithImage:closeImage];
//    closeView.frame = CGRectMake(imageView.frame.size.width - closeImage.size.width, 0, closeImage.size.width, closeImage.size.height);
//    [imageView addSubview:closeView];
//    [closeView release];
//    imageView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeImageViewWithGesture:)];
//    [imageView addGestureRecognizer:tapGesture];
//    [tapGesture release];
//    
//    [_svImageList addSubview:imageView];
//    if (contentSize.width > _svImageList.frame.size.width)
//    {
//        [_svImageList setContentOffset:CGPointMake(contentSize.width - _svImageList.frame.size.width, 0) animated:YES];
//    }
//    [imageView release];
//    if (_lbUploadImage && _lbUploadImage.superview)
//    {
//        [_lbUploadImage removeFromSuperview];
//    }
//    [self dismissModalViewControllerAnimated:YES];
//}


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

#pragma mark - Face book sharing
- (void)shareViaFacebook:(NSString *)message imageUrl:(NSString*)imageUrl
{
    //    LOG_123PHIM(@"Sharing via Facebook with message: %@", message);
    
    if (isSharing) return;
    
    [self showAlertSharing:@"Đang chia sẻ..."];
    
    FacebookManager *fbManager = [FacebookManager shareMySingleton];
    
    NSString* key = @"";
    NSString* graphPath = @"";
    if (self.fbShareType == FBShareTypeCheckInCinema) {
        key = @"cinema";
        graphPath = @"me/vng_phim:check_in";
    }else if (self.fbShareType == FBShareTypeJoinEvent){
        key = @"event";
        graphPath = @"me/vng_phim:join";
    }else{}    
    
    [fbManager shareUrl:self.link key:key graphPath:graphPath withMessage:message withImageUrl:imageUrl onSuccess:^(id result) {
        [self showAlertDone:@"Bạn đã chia sẻ thành công."];
    } onError:^(NSError *error) {
        LOG_123PHIM(@"error: %@", error.localizedDescription);
        [self showAlertFail:@"Chia sẻ không thành công."];
    }];
    
//    [fbManager shareUrl:cinema.cinema_url withMessage:message withImageUrl:imageUrl onSuccess:^(id result) {
//        [self showAlertDone:@"Bạn đã chia sẻ thành công."];
//    } onError:^(NSError *error) {
//        LOG_123PHIM(@"error: %@", error.localizedDescription);
//        [self showAlertFail:@"Chia sẻ không thành công."];
//    }];
    
    
    //[self performSelector:@selector(shareTimer) withObject:nil afterDelay:15];
}

- (void)showAlertDone:(NSString *)message
{
    isFinishShare = YES;
    isSharing = NO;
    
    if (sharingAlert) {
        [sharingAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
    
    if (!isCancelShare) {
        sharingAlert = [[UIAlertView alloc] initWithTitle:@"123Phim" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        sharingAlert.tag = 102;
        [sharingAlert show];
        
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
    
    sharingAlert.tag = 103;
    sharingAlert.message = message;
    ((UIButton *)[sharingAlert viewWithTag:1]).hidden = NO;
    [((UIButton *)[sharingAlert viewWithTag:1]) setTitle:@"Đóng" forState:UIControlStateNormal];
    [((UIButton *)[sharingAlert viewWithTag:1]) setTitle:@"Đóng" forState:UIControlStateSelected];
}


- (void)showAlertSharing:(NSString *)message
{
    isFinishShare = NO;
    isSharing = YES;
    
    sharingAlert = [[UIAlertView alloc] initWithTitle:@"123Phim" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    
    ((UIView *)[sharingAlert viewWithTag:1]).hidden = YES;
    sharingAlert.tag = 101;
    [sharingAlert show];
}


@end
