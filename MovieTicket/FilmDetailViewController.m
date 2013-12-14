//
//  AViewController.m
//  MovieTicket
//
//  Created by nhanmt on 1/8/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

//#define SECTION_SALE_OFF 0
//#define SECTION_FILM_INFO SECTION_SALE_OFF + 1
//#define SECTION_ACTOR   SECTION_FILM_INFO + 1
//#define SECTION_COMMENT SECTION_ACTOR + 1
//#define MAX_SECTION_TABLE SECTION_COMMENT + 1

typedef enum
{
    SECTION_SALE_OFF = 0,
    SECTION_FILM_INFO,
    SECTION_ACTOR,
    SECTION_COMMENT,
    MAX_SECTION_TABLE
} ENUM_FILM_DETAIL_SECTION;


#import "FilmDetailViewController.h"
#import "PlayTrailerViewController.h"
#import "ImageIconViewController.h"
#import "FilmCinemaViewController.h"
#import "ShareFilmViewController.h"
#import "APIManager.h"
#import "AppDelegate.h"
#import "FilmInfoCell.h"
#import "GalleryCell.h"
#import "CommentCell.h"
#import "ActorCell.h"
#import "FacebookManager.h"
#import "MainViewController.h"
#import "DefineString.h"
#import "CellFilmSaleOff.h"
#import "AboutViewController.h"

@interface FilmDetailViewController()<NSFetchedResultsControllerDelegate, RKManagerDelegate>
{
}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation FilmDetailViewController

@synthesize film, arrComments;
@synthesize layoutTable, tempTable;
@synthesize delegate = _delegate;
@synthesize timeSession, nearestSessionDate;
@synthesize isFromFavoriteList;

static NSInteger sessionUIState = -1; //0: downloading; 1: there's session; 2: no session; -1: no determine
static NSMutableArray* filmStack;
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark init and dealloc
- (void) dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    [NSFetchedResultsController deleteCacheWithName:@"comment"];
    [arrComments removeAllObjects];
    filmNext = nil;
    timeSession = nil;
    nearestSessionDate = nil;
    layoutTable = nil;
    tempTable = nil;
    _delegate = nil;
    total = nil;
    filmNext = nil;
    film = nil;
    layoutTable = nil;
    tempTable = nil;
    _btnSessionFilm  = nil;
    _lblSessionFilm = nil;
    _viewSessionTime = nil;
    _lbAlert = nil;
}

- (NSFetchedResultsController *)fetchedResultsController{
    
    if (!_fetchedResultsController)
    {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Comment class])];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"order_id" ascending:YES]];
        NSPredicate* commentPredicate = [NSPredicate predicateWithFormat:@"film_id=%d", film.film_id.intValue];
        [fetchRequest setPredicate:commentPredicate];
        
        NSFetchedResultsController *myFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:@"comment"];
        [myFetchedResultsController setDelegate:self];
        self.fetchedResultsController = myFetchedResultsController;
        
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
        //        LOG_123PHIM(@"aaaa %@",[self.fetchedResultsController fetchedObjects]);
        NSAssert(!error, @"Error performing fetch request: %@", error);
    }
    return _fetchedResultsController;
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self reloadComment:NO];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.timeSession = @" ";
        nearestSessionDate = [[NSDate alloc] init];
        sessionUIState = -1;
        self.viewName = FILM_DETAIL_VIEW_NAME;
    }
    return self;
}

#pragma mark set Font for text
-(UIColor *) getColorNearestSessionTime
{
    return [UIColor orangeColor];
}

#pragma mark table datasource
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier=[NSString stringWithFormat:@"retCell_%d_%d",indexPath.section,indexPath.row];
    switch (indexPath.section) {
        case SECTION_FILM_INFO:
            if(indexPath.row == 0)
            {
                CellIdentifier = @"Cell_FilmInfo";
            }
            break;
        case SECTION_ACTOR:
            CellIdentifier = @"Cell_Actor";
            break;
        case SECTION_SALE_OFF:
            CellIdentifier = @"CellFilmSaleOff";
            break;
        default:
            if (indexPath.row == 0) {
                CellIdentifier = @"Cell_Title_Comment";
            } else {
                CellIdentifier = @"Cell_Comment";
            }
            break;
    }
    UITableViewCell* retCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(retCell == nil)
    {
        if(indexPath.section == SECTION_FILM_INFO)
        {
            if(indexPath.row == 0)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Cell_FilmInfo" owner:self options:nil];
                retCell = [nib objectAtIndex:0];
                [(FilmInfoCell *)retCell setDelegate:self];
                retCell.accessoryType = UITableViewCellAccessoryNone;
                retCell.selectionStyle = UITableViewCellSelectionStyleNone;
                FilmInfoCell *infoCell = (FilmInfoCell *) retCell;
                [infoCell.lblSrollTitle setFont:[UIFont getFontBoldSize12]];
                [infoCell.lblSrollTitle setTextColor:[UIColor darkTextColor]];
                [infoCell.lblSrollTitle setTextAlignment:UITextAlignmentCenter];
                [infoCell.lblVer.layer setCornerRadius:5];
                [infoCell.lblDura.layer setCornerRadius:5];
                [infoCell.lblCate.layer setCornerRadius:5];
            }
            else if(indexPath.row == 1)
            {
                retCell=[[GalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                [(GalleryCell *)retCell layoutGallery:self.film];
            }
        }
        else if (indexPath.section == SECTION_ACTOR)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Cell_Actor" owner:self options:nil];
            retCell = [nib objectAtIndex:0];
        }
        else if(indexPath.section == SECTION_COMMENT)
        {
            //            comment section
            if (indexPath.row == 0)
            {
                retCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                retCell.selectionStyle = UITableViewCellSelectionStyleNone;
                retCell.textLabel.font = [UIFont getFontBoldSize14];
                retCell.textLabel.text = @"Bình Luận & Đánh Giá";
                retCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                retCell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            else
            {
                retCell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier withHeight:[self tableView:tableView heightForRowAtIndexPath:indexPath]];
                //        comment section
                if (self.arrComments.count >= indexPath.row) {
                    Comment *comment = ((Comment*)[self.arrComments objectAtIndex:indexPath.row - 1]);
                    [(CommentCell *)retCell layoutComment:comment];
                }
                retCell.accessoryType = UITableViewCellAccessoryNone;
                retCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        else
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
            retCell = [nib objectAtIndex:0];
            retCell.accessoryType = UITableViewCellAccessoryNone;
            retCell.selectionStyle = UITableViewCellSelectionStyleNone;
            retCell.clipsToBounds = YES;
        }
    }
    
    if (retCell)
    {
        if (indexPath.section == SECTION_FILM_INFO)
        {
            if (indexPath.row == 0)
            {    
                [(FilmInfoCell *)retCell setContentForCell:self.film];
            }
            else if (indexPath.row == 1)
            {
                [(GalleryCell *)retCell setContentForCell:self.film];
            }
        }
        else if (indexPath.section == SECTION_ACTOR)
        {
            NSArray *arrayActor = [self.film.film_actors componentsSeparatedByString:@"∂"];
            if (arrayActor.count > indexPath.row)
            {
                [(ActorCell *)retCell setContentForCell:[arrayActor objectAtIndex:indexPath.row]];
            }
        }
        else if (indexPath.section == SECTION_COMMENT)
        {
            if (indexPath.row != 0) {
                if (self.arrComments.count >= indexPath.row) {
                    [(CommentCell *)retCell setContentWithComment:((Comment*)[self.arrComments objectAtIndex:indexPath.row - 1]) withHeight:[self tableView:tableView heightForRowAtIndexPath:indexPath]];
                }
            }
        }
        else
        {
            [(CellFilmSaleOff *)retCell loadDataOnView:film];
        }
    }
    return retCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat ret = 0;
    switch (indexPath.section)
    {
        case SECTION_FILM_INFO:
            if(indexPath.row == 0)
            {
                if (_filmInfoCellHeight < kCell_Film_Info_Height)
                {
                    ret = kCell_Film_Info_Height;
                }
                else
                {
                    ret = _filmInfoCellHeight;
                }
            }
            else
            {
                ret = smallPicH + 2*MARGIN_EDGE_TABLE_GROUP;
            }
            break;
        case SECTION_ACTOR:
            ret = ACTOR_AVATAR_W + 2*MARGIN_EDGE_TABLE_GROUP;
            break;
        case SECTION_COMMENT:
            if (indexPath.row == 0) {
                ret = MARGIN_EDGE_TABLE_GROUP*4;
            }
            else
            {
                NSString *thePath = [[NSBundle mainBundle] pathForResource:@"rate_star_1" ofType:@"png"];
                UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
                CGFloat heightStar = 0;
                if (prodImg) {
                    heightStar = prodImg.size.height;
                }
                
                if (!self.arrComments || self.arrComments.count < indexPath.row)
                {
                    return (3*MARGIN_EDGE_TABLE_GROUP + ACTOR_AVATAR_H + heightStar);
                }
                CGFloat cellHeight = (3*MARGIN_EDGE_TABLE_GROUP + ACTOR_AVATAR_H + heightStar);               
                Comment *comment = ((Comment*)[self.arrComments objectAtIndex:indexPath.row - 1]);
                CGSize maximumSize = CGSizeMake(self.view.frame.size.width - 5*MARGIN_EDGE_TABLE_GROUP - ACTOR_AVATAR_W, self.view.frame.size.height);
                
                UIFont *font = [UIFont getFontNormalSize13];
                CGSize sizeTextDynamic = [comment.content sizeWithFont:font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
                
                font = [UIFont getFontBoldSize15];
                CGSize sizeTextUserName = [@"ABC" sizeWithFont:font];
                CGFloat heightNew = 2*MARGIN_EDGE_TABLE_GROUP + sizeTextUserName.height + sizeTextDynamic.height;
                if ([comment.list_image isKindOfClass:[NSArray class]])
                {
                    heightNew += IMAGE_COMMENT_H;
                }
                if (cellHeight >= heightNew)
                {
                    ret = cellHeight;
                } else {
                    ret = heightNew;
                }
            }
            break;
        default:
            if(film.discount_value.intValue == 0)
            {
                ret = 0;
            }
            else
            {
                ret = 70;
            }
            break;
    }
    return ret;
}

-(BOOL)filmInfoCell:(FilmInfoCell *)filmInfoCell didUpdateLayoutWithHeight:(CGFloat)newHeight
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _filmInfoCellHeight = newHeight;
        int targetSection = SECTION_FILM_INFO;
        int numberRowOfSection = [layoutTable numberOfRowsInSection:targetSection];
        if (isDislayingTempTable)
        {
            if (numberRowOfSection == 0) {
                return;
            }
            [self.tempTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:targetSection]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            numberRowOfSection = [layoutTable numberOfRowsInSection:targetSection];
            if (numberRowOfSection == 0) {
                return;
            }
            [self.layoutTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:targetSection]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    });
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MAX_SECTION_TABLE;//3 to view section comment
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == SECTION_FILM_INFO)
    {
        return 2;
    }
    else if(section == SECTION_ACTOR)
    {
        return [[film.film_actors componentsSeparatedByString:@"∂"] count];
    }
    else if(section == SECTION_COMMENT)
    {
        return [self.arrComments count] + 1;
    }
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == (MAX_SECTION_TABLE - 1))
    {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    if(section == SECTION_SALE_OFF)
    {
        return 1;
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == SECTION_SALE_OFF || section == SECTION_FILM_INFO)
    {
            return 1;
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
    if (indexPath.section == SECTION_FILM_INFO && indexPath.row == 1)
    {
        if (self.film.arrayImageThumbnailReviews == nil && self.film.arrayImageThumbnailReviews.count == 0)
        {
            return;
        }
        [self showGallaryViewOfFilm:self.film.film_name withListOfImages:film.arrayImageThumbnailReviews];
    }
    if (indexPath.section == SECTION_COMMENT && indexPath.row == 0) {
        [self showCommentAndRatingViewController];
    }
}

#pragma mark Process Action
-(void)showGallaryViewOfFilm:(NSString*) filmTittle withListOfImages:(NSArray*)imageList{
    ImageIconViewController* gallary = [[ImageIconViewController alloc] init];
    gallary.film = self.film;
    gallary.filmTitle = filmTittle;
    gallary.listOfImageURL = imageList;
    gallary.idFilm = [self.film.film_id integerValue];
    [self.navigationController pushViewController:gallary animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showCommentAndRatingViewController
{
    if (_delegate && [_delegate respondsToSelector:@selector(pushVCFilmCommentWithFilm:)]) {
        [_delegate pushVCFilmCommentWithFilm:film];
    }
}

#pragma mark init data
- (void) layoutForButtonSessionOfFilm
{
    NSString *fileName = @"showtimes_button.png";
    NSString *fileNameHL = @"showtimes_button_selected.png";
    if ([self.film.status_id intValue] != ID_REQUEST_FILM_LIST_SHOWING) {
        fileName = @"showtimes_button_book_ticket.png";
        fileNameHL = @"showtimes_button_book_ticket_selected.png";
    }
    [self.btnSessionFilm setImage:[UIImage imageNamed:fileName] forState:UIControlStateNormal];
    [self.btnSessionFilm setImage:[UIImage imageNamed:fileNameHL] forState:UIControlStateHighlighted];
    [self.lbAlert.layer setCornerRadius:5.0];
    [self reloadDataForButtonSession];
}

- (void) reloadDataForButtonSession
{
    BOOL flag = (sessionUIState == 2 || sessionUIState == 0);
    [self.lbAlert setHidden:!flag];
    flag = (sessionUIState == 1);
    [self.btnSessionFilm setHidden:!flag];
    [self.lblSessionFilm setHidden:!flag];
    if (sessionUIState == 1 || sessionUIState == -1) { //downloading, there's session or no determine
        if (sessionUIState == 1)//there's seesion
        {
            self.lblSessionFilm.text = self.timeSession;
            self.lblSessionFilm.font = [UIFont getFontCustomSize:15];
            [self.lblSessionFilm setTextColor:[self getColorNearestSessionTime]];
        }
        else
        {}
    }
    else if (sessionUIState == 2 || sessionUIState == 0 )
    { //there's no session
        Location *loc = [APIManager loadLocationObject];
        NSString *city = loc.location_name;
        if (sessionUIState == 0)//downloading
        {
            self.lbAlert.text = [NSString stringWithFormat:@"Đang kiểm tra ..."];
        }
        else if (self.film.status_id.intValue == ID_REQUEST_FILM_LIST_COMMING) {
            self.lbAlert.text = [NSString stringWithFormat:@"Chưa có suất chiếu tại %@", city];
        }
        else
        {
            self.lbAlert.text = [NSString stringWithFormat:@"Đã hết suất chiếu tại %@", city];
        }
    }
    else
    {}
}

- (void)initLayoutTable
{
    //init layouttable
    if (layoutTable)
    {
        return;
    }
    layoutTable.backgroundView = nil;
    [layoutTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [layoutTable setContentSize:layoutTable.frame.size];
    // add layout table
}

- (void)initTempTable
{
    if (tempTable)
    {
        return;
    }
    //init layouttable
    CGFloat tableHeight = [[UIScreen mainScreen] bounds].size.height - NAVIGATION_BAR_HEIGHT - TITLE_BAR_HEIGHT;
    if (self.viewSessionTime) {
        tableHeight -= self.viewSessionTime.frame.size.height;
    }

    tempTable = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, tableHeight) style:UITableViewStyleGrouped];
    tempTable.dataSource = self;
    tempTable.delegate = self;
    tempTable.backgroundColor = [UIColor clearColor];
    tempTable.backgroundView = nil;
    tempTable.userInteractionEnabled = YES;
    [tempTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [tempTable setContentSize:layoutTable.frame.size];
    [self.view addSubview:tempTable];
}

-(void) requestGetThreeSessionTimeNearestOfFilm
{
    //download film session
    if ([AppDelegate isNetWorkValiable])
    {
        sessionUIState = 0; //downloading session
        [[APIManager sharedAPIManager] getThreeSessionTimeNearestOfFilm:[self.film.film_id intValue] context:self];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Không thể kết nối Internet." delegate:nil cancelButtonTitle:@"Tiếp tục" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)viewDidLoad
{
//    LOG_123PHIM(@"viewDidLoad");
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    if (!filmStack) {
        filmStack = [[NSMutableArray alloc] init];    
    }
    [filmStack addObject:self.film];
    
    if (arrComments == nil) {
        arrComments = [[NSMutableArray alloc] init];
    }
    UIImage *imageRight = [UIImage imageNamed:@"header-button-share.png"];
    UIButton *customButtonR = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0, 0, imageRight.size.width, imageRight.size.height);
    customButtonR.frame = frame;
    [customButtonR setBackgroundImage:imageRight forState:UIControlStateNormal];
    [customButtonR addTarget:self action:@selector(btnShareFilm_Click) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc] initWithCustomView:customButtonR];
    self.navigationItem.rightBarButtonItem = btnRight;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    // set background
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    self.trackedViewName = viewName;
    [self layoutForButtonSessionOfFilm];
    [self initLayoutTable];
    [self initTempTable];
    [self initHandleSwipeGestureRecognizer];    
    NSString* previousView = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).currentView;
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:NSStringFromClass([FilmDetailViewController class]) comeFrom:previousView withActionID:ACTION_FILM_VIEW currentFilmID:self.film.film_id currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID] returnCodeValue:0 context:self];
}

-(void)initHandleSwipeGestureRecognizer
{
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(handleSwipeFrom:)];
    [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [gesture setCancelsTouchesInView:YES];
    [self.view  addGestureRecognizer:gesture];
    
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(handleSwipeFrom:)];
    [gestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [gestureLeft setCancelsTouchesInView:YES];
    [self.view  addGestureRecognizer:gestureLeft];
}

- (void)scrollTableViewToTop
{
    int targetSection = SECTION_SALE_OFF;
    if (isDislayingTempTable) {
        [layoutTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:targetSection]
                           atScrollPosition:UITableViewScrollPositionTop
                                   animated:YES];
    } else {
        [tempTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:targetSection]
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:YES];
    }
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        sessionUIState = 0; //downloading session
        [self reloadDataForButtonSession];
        self.timeSession = @" ";
        [filmStack removeLastObject];
        
        if (filmStack.count > 0) {
            self.film = [filmStack lastObject];
        }else{
            if (isDislayingTempTable)
            {
                [layoutTable removeFromSuperview];
            }
            else
            {
                [tempTable removeFromSuperview];
            }
            [delegate popViewController];
            return;
        }        
        //        prepare next view
        if (isDislayingTempTable)
        {
            [layoutTable setFrame:CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, layoutTable.frame.size.height)];
            [layoutTable reloadData];
        }
        else
        {
            [tempTable setFrame:CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, tempTable.frame.size.height)];
            [tempTable reloadData];
        }
        isDislayingTempTable = !isDislayingTempTable;
        [self performHorizontalChangeRootViewDuration:0.5 fromViewDefault:layoutTable toViewPrepair:tempTable isCurrentPrepairView:!isDislayingTempTable isFromRightToLeft:NO compelete:^{
            [delegate updateTitle:film.film_name forViewController:self];
            [self scrollTableViewToTop];
        }];
        if (self.viewSessionTime) {
            [self.view bringSubviewToFront:self.viewSessionTime];
        }
    }
    else if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        sessionUIState = 0; //downloading session
        [self reloadDataForButtonSession];
        self.timeSession = @" ";
        if (filmNext == nil)
        {
            return;
        }
        
        if (filmStack.count == total)
        {
            [filmStack removeAllObjects];
        }
        [filmStack addObject:filmNext];
        self.film = filmNext;

        [self initTempTable];
//        prepare next view
        if (isDislayingTempTable)
        {
            [layoutTable setFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, layoutTable.frame.size.height)];
            [layoutTable reloadData];
        }
        else
        {
            [tempTable setFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, tempTable.frame.size.height)];
            [tempTable reloadData];
        }
        isDislayingTempTable = !isDislayingTempTable;
        [self performHorizontalChangeRootViewDuration:0.5 fromViewDefault:layoutTable toViewPrepair:tempTable isCurrentPrepairView:!isDislayingTempTable isFromRightToLeft:YES compelete:^{
            [delegate updateTitle:film.film_name forViewController:self];
            [self scrollTableViewToTop];
        }];
        if (self.viewSessionTime) {
            [self.view bringSubviewToFront:self.viewSessionTime];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    // show tabbar
    AppDelegate* appDelagate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelagate.tabBarController.tabBar.hidden = NO;
}

-(void)viewWillUnload
{
    [super viewWillUnload];
    [self.layoutTable reloadData];
}

-(void) willPopViewController
{
    [filmStack removeAllObjects];
}

#pragma mark process action share
-(void)didSelectShareAction
{
    [self btnShareFilm_Click];
}

-(void) btnShareFilm_Click
{
    ShareFilmViewController *shareFilmViewController = [[ShareFilmViewController alloc] init];
    [shareFilmViewController setFilm:self.film];
    [self.navigationController pushViewController:shareFilmViewController animated:YES];
}

#pragma mark -
#pragma mark RKManagerDelegate
#pragma mark -
-(void)processResultResponseDictionaryMapping:(DictionaryMapping *)dictionary requestId:(int)request_id
{
    if (request_id == ID_REQUEST_GET_NEAREST_SESSION_TIME) {
        [self parseToGetResultNearestSessionTime:dictionary.curDictionary];
        sessionUIState = -1; //finish downloading
        if (self.timeSession && ![self.timeSession isEqualToString:@""])
        {
            sessionUIState = 1; //there's session
        }else{
            sessionUIState = 2; //no session
        }
        if (self.lblSessionFilm) {
            [self reloadDataForButtonSession];
        }
        [NSFetchedResultsController deleteCacheWithName:@"comment"];
        _fetchedResultsController = nil;
        [self reloadComment:YES];
    }
}

-(void)didLoadFilmDetail: (NSNotification *) notification
{
    int film_id = ((Film*) notification.object).film_id.intValue;
    if (film_id == film.film_id.intValue) {
        [self checkReloadData];
    }
}

- (void)checkReloadData
{
    if (isDislayingTempTable) {
        [tempTable reloadData];
    } else {
        [layoutTable reloadData];
    }
}

-(void)reloadComment:(BOOL)isLocal
{    
    if (arrComments == nil) {
        arrComments = [[NSMutableArray alloc] init];
    } else {
        [arrComments removeAllObjects];
    }
    self.arrComments = [NSMutableArray arrayWithArray:[self.fetchedResultsController fetchedObjects]];
    [self checkReloadData];
    if (isLocal) {
        NSString *date_update = @"";
        if ([self.arrComments isKindOfClass:[NSMutableArray class]] && self.arrComments.count > 0)
        {
            NSDate *today = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSTimeInterval timeMax = NSIntegerMax;
            for (int i = 0; i < self.arrComments.count; i++) {
                Comment *_comment = [self.arrComments objectAtIndex:i];
                [dateFormatter setDateFormat:@"yyyy-MM-dd H:mm:ss"];
                NSDate *date = [dateFormatter dateFromString:_comment.date_update];
                NSTimeInterval timeDistance = [today timeIntervalSinceDate:date];
                if (timeDistance < timeMax) {
                    timeMax = timeDistance;
                    [dateFormatter setDateFormat:@"yyyyMMddHmmss"];
                    date_update = [dateFormatter stringFromDate:date];
                }
            }
        }
        //send request get comment byID
        [[APIManager sharedAPIManager] getListCommentByID:[self.film.film_id intValue] fromDate:date_update withLimit:-1 context:self];
    }
}



#pragma mark - get result response from server
-(void)parseToGetResultNearestSessionTime:(NSDictionary *)dicObject
{
    int status = [[dicObject objectForKey:@"status"] intValue];
    if(status == 0)
    {
        return;
    }
    id getResult = [dicObject objectForKey:@"result"];
//    id getSession = @"";
    if(![[APIManager sharedAPIManager] isValidData:getResult])
    {
        return;
    }
    if ([getResult isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *tempDic = (NSDictionary *)getResult;
        id getTimeSession =[tempDic objectForKey:@"time"];
        if ([[APIManager sharedAPIManager] isValidData:getTimeSession]) {
            if ([getTimeSession isKindOfClass:[NSNumber class]])
            {
                self.timeSession = @"";
            }
            else
            {
                self.timeSession = getTimeSession;
            }
        }
        else
        {
            self.timeSession = @"";
        }
        
        id getDate = [tempDic objectForKey:@"date"];
        //    id getDate = @"2013-05-10";
        if (![[APIManager sharedAPIManager] isValidData:getDate]) {
            return;
        }
        NSArray* dateComponent = [((NSString*)getDate) componentsSeparatedByString:@"-"];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        NSInteger d = [[dateComponent  objectAtIndex:2] integerValue];
        NSInteger m = [[dateComponent objectAtIndex:1] integerValue];
        NSInteger y = [[dateComponent objectAtIndex:0] integerValue];
        
        [comps setDay:d];
        [comps setMonth:m];
        [comps setYear:y];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        self.nearestSessionDate = [gregorian dateFromComponents:comps];
    }
}

-(void)setFilm:(Film *)theFilm
{
    film = theFilm;
    _filmInfoCellHeight = 0;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (self.isFromFavoriteList)
    {
        filmNext = [delegate getNextFilmInFavoutiteFilmArrayOfFilmId:[film.film_id intValue]];
        total = delegate.arrayFilmFavorite.count;
    }
    else
    {
        filmNext = [delegate getNextFilmInFilmArrayOfFilmId:[film.film_id intValue] withStatus:[film.status_id intValue]];
        total = ([film.status_id intValue] == ID_REQUEST_FILM_LIST_SHOWING)?delegate.arrayFilmShowing.count:delegate.arrayFilmComing.count;
    }
    [self requestGetThreeSessionTimeNearestOfFilm];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    
    NSNotificationCenter *icenter = [NSNotificationCenter defaultCenter];
    [icenter addObserver:self selector:@selector(didLoadFilmDetail:) name:[NSString stringWithFormat:NOTIFICATION_NAME_FILM_DETAIL_DID_LOAD_WITH_FILM_ID, film.film_id.integerValue] object:nil];
}

- (void)viewDidUnload {
    [self setLbAlert:nil];
    [super viewDidUnload];
}

- (IBAction)showSessionTimeClick:(id)sender {
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:NSStringFromClass([FilmCinemaViewController class])
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_FILM_CLICK_MUAVE_BUTTON
                                                     currentFilmID:film.film_id
                                                   currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID]
                                                   returnCodeValue:0 context:nil];
    
    if (![AppDelegate isNetWorkValiable])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Để xem lịch chiếu của phim bạn phải kết nối Internet. Vui lòng kiểm tra trong mục Cài đặt." delegate:self cancelButtonTitle:@"Tiếp tục" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        FilmCinemaViewController *cinemaFilmController = [[FilmCinemaViewController alloc] initWithNibName:@"FimCinemaViewController" bundle:[NSBundle mainBundle]];
        [cinemaFilmController setFilm:film];
        cinemaFilmController.stepNextDayShowSession = [NSDate daysBetween:[NSDate date] and:self.nearestSessionDate];
        [cinemaFilmController requestAPIGetListCinemaSession];
        [self.navigationController pushViewController:cinemaFilmController animated:YES];
    }
}
@end
