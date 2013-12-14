//
//  SelectSeatViewController.m
//  123Phim
//
//  Created by Phuc Phan on 4/5/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#import "SelectSeatViewController.h"
#import "AppDelegate.h"
#import "Session.h"
#import "APIManager.h"
#import "MainViewController.h"
#import "SeatView.h"
#import "NSData+FileHandler.h"
#import "CheckoutWebViewController.h"
#import "SelectTypeThanhToanViewController.h"
#import "ConfirmInputViewController.h"

#define TAG_ALERT_PENDING_TRANSACTION 999
#define TAG_CONFIRM_USING_PREVIOUS_INPUT_OTP 1000

#define TAG_SEEK 100

@interface SelectSeatViewController ()

@end

@implementation SelectSeatViewController
@synthesize cleanSelectedSeats = _cleanSelectedSeats;
@synthesize currentFilm = _currentFilm, currentCinemaWithDistance = _currentCinemaWithDistance, currentSession = _currentSession;

-(void) dealloc
{
    [_roomLayout removeAllObjects];
    [_selectedSeats removeAllObjects];
    
    _scrollView = nil;
    _scrollViewLeftTitle = nil;
    _roomView = nil;
    _roomLayout = nil;
    _leftTitleView = nil;
    _normalSeatImage = nil;
    _unavailableNormalSeatImage = nil;
    _selectedNormalSeatImage = nil;
    _blockSeatImage = nil;
    _doorImage = nil;
    _vipSeatImage = nil;
    _selectedVipSeatImage = nil;
    _unavailableVipSeatImage = nil;
    _normalLeftCoupleSeatImage = nil;
    _selectedLeftCoupleSeatImage = nil;
    _unavailableLeftCoupleSeatImage = nil;
    _normalRightCoupleSeatImage = nil;
    _selectedRightCoupleSeatImage = nil;
    _unavailableRightCoupleSeatImage = nil;
    _selectedSeats = nil;
    _lbSelectedSeats = nil;
    _lbSelectedSeatsDefault = nil;
    _dataLoadingStep = nil;
    _renderStatus = nil;
    _chosenSeatLimit = nil;
    _seatGroupList = nil;
    _listStatusOfSeat = nil;
    _roomTitle = nil;
    _currentSession = nil;
    _currentFilm = nil;
    _currentCinemaWithDistance = nil;
    _lastScale = 0;
}
-(id)init
{
    if (self = [super init])
    {
        _selectedSeats = [[NSMutableArray alloc] init];
        _normalSeatImage = [UIImage imageNamed:@"seat.png"];
        _selectedNormalSeatImage = [UIImage imageNamed:@"seat_chosen.png"];
        _unavailableNormalSeatImage = [UIImage imageNamed:@"seat_unavailable.png"];
        _blockSeatImage = _unavailableNormalSeatImage;
        // door
        _doorImage = [UIImage imageNamed:@"room_door.png"];
//        vip seat image
        _vipSeatImage = [UIImage imageNamed:@"seat_vip"];;
        _selectedVipSeatImage = [UIImage imageNamed:@"seat_vip_chosen"];;
        _unavailableVipSeatImage = [UIImage imageNamed:@"seat_vip_unavailable"];;
        
//        couple seat image
        _normalLeftCoupleSeatImage = [UIImage imageNamed:@"seat-couple-left"];
        _selectedLeftCoupleSeatImage = [UIImage imageNamed:@"seat-couple-left-chosen"];
        _unavailableLeftCoupleSeatImage = [UIImage imageNamed:@"seat-couple-left-unavailable"];
        
        _normalRightCoupleSeatImage = [UIImage imageNamed:@"seat-couple-right"];
        _selectedRightCoupleSeatImage = [UIImage imageNamed:@"seat-couple-right-chosen"];
        _unavailableRightCoupleSeatImage = [UIImage imageNamed:@"seat-couple-right-unavailable.png"];
        
        _chosenSeatLimit = NSIntegerMax;
        _lastScale = 1;
        _renderStatus = 3;
//        reset transactionID
        AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        app._TransactionID = @"";
        viewName = SELECT_SEAT_VIEW_NAME;
        self.isSkipWarning = YES;
    }
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:viewName
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_SESSION_VIEW
                                                     currentFilmID:self.currentSession.film_id
                                                   currentCinemaID:self.currentSession.cinema_id
                                                         sessionId:self.currentSession.session_id
                                                   returnCodeValue:0
                                                           context:nil];
    
    
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:_currentFilm.film_name];
    CGRect frame = self.view.frame;
    
    frame.size.height -= (NAVIGATION_BAR_HEIGHT + TITLE_BAR_HEIGHT);
    self.view.frame = frame;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"launch_image.png"]];
    self.view.clipsToBounds = YES;
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    if (_renderStatus == 3 && _roomLayout)
    {
        [self renderRoom];
        _renderStatus--;
    }
    else
    {
        _renderStatus--;
    }
    if ([_currentCinemaWithDistance.cinema.maxSeatToBook intValue] > 0)
    {
        _chosenSeatLimit = [_currentCinemaWithDistance.cinema.maxSeatToBook intValue];
    }
    self.trackedViewName = viewName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark process response from server
- (void)processResultResponseArrayMapping:(ArrayMapping *)array requestId:(int)request_id
{
    
}

-(void)processResultResponseDictionaryMapping:(DictionaryMapping *)dictionary requestId:(int)request_id
{
    if (request_id == ID_REQUEST_THANHTOAN_TOTAL_MONEY) {
        [self processResponseTotalMoney:dictionary.curDictionary];
    }
    else if (request_id == ID_REQUEST_GET_LIST_STATUS_OF_SEAT)
    {
        NSArray *array = [[APIManager sharedAPIManager] parseToGetListStatusOfSeat:dictionary.curDictionary];
        [self performSelectorOnMainThread:@selector(setListStatusOfSeat:) withObject:array waitUntilDone:YES];
        if (_renderStatus > 0)
        {
            [self checkCompactRoomLayoutVersion];
        }
    }
    else if (request_id == ID_REQUEST_CHECK_ROOM_LAYOUT)
    {
        [self getResultCheckRoomLayoutResponse:[NSMutableDictionary dictionaryWithDictionary:dictionary.curDictionary]];
    }
}

- (void)processResponseTotalMoney:(NSDictionary *)dic
{
    [self hideLoadingView];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!dic)
    {
        [self showMessageDialogInfo:THANHTOAN_TEXT_ERROR_RECEIVE withTag:-1];
        return;
    }
    //        ok
    if (![dic isKindOfClass:[NSNumber class]])
    {
        NSNumber *price = [dic objectForKey:@"total_revenue"];
        NSNumber *price_after = [dic objectForKey:@"total_revenue_after"];
        if (price.intValue > price_after.intValue) {
            app._Amount = [price_after intValue];
            [self performSelectorOnMainThread:@selector(pushThanhToanViewController:) withObject:price_after waitUntilDone:NO];
        } else {
            app._Amount = [price intValue];
            [self performSelectorOnMainThread:@selector(pushThanhToanViewController:) withObject:price waitUntilDone:NO];
        }
    }
    else
    {
        [self getListStatusOfSeat];
        [self showMessageDialogInfo:THANHTOAN_TEXT_SELECT_SEAT_DUPLICATE_BY_ORTHER withTag:-1];
    }
}

- (void)getResultCheckRoomLayoutResponse:(NSMutableDictionary *)dicObject
{
    NSMutableArray *roomFileInfo = [[APIManager sharedAPIManager] parseToGetRoomLayoutInfo:dicObject];
    //        new version
    if (roomFileInfo)
    {
        //    parse list seat of room and save file
        NSDictionary *dicRoomLayout = [roomFileInfo objectAtIndex:1];
        
        if ([dicRoomLayout isKindOfClass:[NSDictionary class]])
        {
            //                convert to one array
            NSMutableArray *roomLayout = [[NSMutableArray alloc] init];
            NSArray *arrSeatID = [dicRoomLayout objectForKey:@"seat_id"];
            NSArray *arrType = [dicRoomLayout objectForKey:@"type"];
            NSArray *arrGroup = [dicRoomLayout objectForKey:@"group"];
            NSArray *arrTitle = [dicRoomLayout objectForKey:@"title"];
            
            for (int row = 0; row < arrTitle.count; row++) {
                NSMutableArray *rowLayout = [[NSMutableArray alloc] init];
                NSString *rowTitle = [arrTitle objectAtIndex:row];
                if (!rowTitle || rowTitle.length == 0)
                {
                    [rowLayout addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"seat_id", nil]];
                    [roomLayout addObject:rowLayout];
                    continue;
                }
                // title
                [rowLayout addObject:[NSDictionary dictionaryWithObjectsAndKeys:rowTitle, @"seat_id", nil]];
                NSArray *arrColSeatID = [arrSeatID objectAtIndex:row];
                NSArray *arrColGroup = [arrGroup objectAtIndex:row];
                NSArray *arrColType = [arrType objectAtIndex:row];
                for (int col = 0; col < arrColSeatID.count; col++) {
                    NSString *strSeatID;
                    NSNumber *seatID = [arrColSeatID objectAtIndex:col];
                    if ([seatID isKindOfClass: [NSNumber class]])
                    {
                        if (seatID.integerValue <= 0)
                        {
                            strSeatID = @"";
                        }
                        else
                        {
                            NSString *patten = @"%@%d";
                            if (seatID.integerValue < 10)
                            {
                                patten = @"%@0%d";
                            }
                            strSeatID = [NSString stringWithFormat:patten, rowTitle, seatID.integerValue];
                        }
                    }
                    else
                    {
                        strSeatID = (NSString *)seatID;
                    }
                    NSMutableDictionary *seat = [NSMutableDictionary dictionaryWithObjectsAndKeys:strSeatID, @"seat_id", nil];
                    if (strSeatID.length > 0)
                    {
                        // type
                        NSNumber *type = [arrColType objectAtIndex:col];
                        [seat setValue:type forKey:@"type"];
                        // group
                        NSString *groupID;
                        NSNumber *group = [arrColGroup objectAtIndex:col];
                        if ([group isKindOfClass: [NSNumber class]])
                        {
                            if (group.integerValue > 0)
                            {
                                NSString *patten = @"%@%d";
                                if (group.integerValue < 10)
                                {
                                    patten = @"%@0%d";
                                }
                                groupID = [NSString stringWithFormat:patten, rowTitle, group.integerValue];
                                [seat setValue:groupID forKey:@"group"];
                            }
                        }
                    }
                    [rowLayout addObject:seat];
                }
                [roomLayout addObject:rowLayout];
            }
            //            save info file
            NSString *roomLayoutInfoFile = [NSString stringWithFormat:@"%@/"ROOM_LAYOUT_ROOM_FOLDER"/"ROOM_LAYOUT_INFO_FILE_NAME, ROOM_LAYOUT_PATH, _currentSession.room_id.intValue];
            NSDictionary *versionInfo = [roomFileInfo objectAtIndex:0];
            _roomTitle = [versionInfo objectForKey:@"RoomTitle"];
            [versionInfo writeToFile:roomLayoutInfoFile atomically:YES];
            
            NSString *roomLayoutFile = [NSString stringWithFormat:@"%@/"ROOM_LAYOUT_ROOM_FOLDER"/"ROOM_LAYOUT_FILE, ROOM_LAYOUT_PATH, _currentSession.room_id.intValue];
            [roomLayout writeToFile:roomLayoutFile atomically:NO];
            
            _roomLayout = [[NSMutableArray alloc] initWithArray:roomLayout];
        }
        else
        {
            [self showMessageDialogInfo:THANHTOAN_TEXT_ERROR_RECEIVE withTag:-1];
            return;
        }
    }
    //        not change layout, will load from file
    if (_renderStatus < 3)
    {
        [self performSelectorOnMainThread:@selector(renderRoom) withObject:nil waitUntilDone:YES];
        _renderStatus--;
    }
}

- (void)renderDefaultRoom
{
    if (_roomView.subviews.count > 0)
    {
        [_roomView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    if (!_roomLayout)
    {
        NSString *roomFile = [NSString stringWithFormat:@"%@/"ROOM_LAYOUT_ROOM_FOLDER"/"ROOM_LAYOUT_FILE, ROOM_LAYOUT_PATH, _currentSession.room_id.intValue];
        _roomLayout = [[NSMutableArray alloc] initWithContentsOfFile:roomFile];
        if (!_roomLayout)
        {
//            load default
            roomFile = [NSString stringWithFormat:@"%@/room_layout_default.txt", BUNDLE_PATH];
            _roomLayout = [[NSMutableArray alloc] initWithContentsOfFile:roomFile];
        }
    }
    
    CGSize roomSize = CGSizeMake(0, _roomLayout.count);
    CGSize margin = CGSizeMake(0, 0);
    UIImage *screenImage = [UIImage imageNamed:@"screen"];
//    _ROOMVIEW
    CGSize seatSize = _normalSeatImage.size;
    NSInteger screenMargin = 55;
    NSInteger roomMargin = 12;
    CGFloat scrollH = roomMargin + screenImage.size.height + screenMargin + (roomSize.height * (seatSize.height + margin.height) - margin.height);
    CGRect roomFrame = CGRectMake(0, 0, 0, scrollH);
    _roomView = [[UIView alloc] initWithFrame:roomFrame];
     [_scrollView addSubview:_roomView];
    _leftTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _scrollViewLeftTitle.frame.size.width, scrollH)];
    _leftTitleView.backgroundColor = [UIColor clearColor];
    _leftTitleView.tag = NSIntegerMax;
    [_scrollViewLeftTitle addSubview:_leftTitleView];
    
    NSInteger index = TAG_SEEK;
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSInteger collumnGroup = 1;
    for (NSInteger row = 0; row < _roomLayout.count; row++)
    {
        NSArray * rowLayout = [_roomLayout objectAtIndex:row];
        if (roomSize.width < rowLayout.count - 1)
        {
            roomSize.width = rowLayout.count - 1; // sub title
        }
        NSDictionary *titleInfo = [rowLayout objectAtIndex:0];
        if (titleInfo)
        {
            NSString *lable = [titleInfo valueForKey:@"seat_id"];
            
            if (lable.length == 0)
            {
//                row is emty
                continue;
            }
            UILabel *v1 = [[UILabel alloc] initWithFrame:CGRectMake(0, row * (seatSize.height + margin.height)  + screenMargin, _leftTitleView.frame.size.width, seatSize.height)];
            v1.textAlignment = UITextAlignmentCenter;
            v1.textColor = [UIColor whiteColor];
            v1.text = lable;
            v1.font = [UIFont getFontNormalSize10];
            v1.backgroundColor = [UIColor clearColor];
            [_leftTitleView addSubview:v1];
        }
        for (int col = 1; col < rowLayout.count; col++)
        {
            NSInteger addingX = 0;
            NSMutableDictionary *info = [rowLayout objectAtIndex:col];
            NSString *identify = [info valueForKey:@"seat_id"];
            if ([identify stringByTrimmingCharactersInSet:charSet].length == 0)
            {
//                empty
                collumnGroup++; // next
                continue;
            }
            [info setValue:[NSNumber numberWithInteger:collumnGroup] forKey:@"collumn_group"];
            NSInteger type =[[info valueForKey:@"type"] integerValue];
            id group = [info valueForKey:@"group"];
            NSString *groupID;
            if ([group isKindOfClass:[NSString class]])
            {
                groupID = group;
                if (groupID.length == 2) // fixing group id wrong for old data
                {
                    groupID = [groupID stringByReplacingCharactersInRange:NSMakeRange(1, 0) withString:@"0"];
                }
            }
            else
            {
                groupID =[group stringValue];
            }
            UIImage *tmpNormal = _normalSeatImage;
            UIImage *tmpSelected = _selectedNormalSeatImage;
            UIImage *disableImage = _unavailableNormalSeatImage;
            UIImage *blockImage = _blockSeatImage;
            if (type == SEAT_TYPE_VIP)
            {
                tmpNormal = _vipSeatImage;
                tmpSelected = _selectedVipSeatImage;
                disableImage = _unavailableVipSeatImage;
            }
            else if (type == SEAT_TYPE_COUPLE_1 || type == SEAT_TYPE_COUPLE_2)
            {
                if ([identify isEqualToString:groupID])
                {
                    tmpNormal = _normalRightCoupleSeatImage;
                    tmpSelected = _selectedRightCoupleSeatImage;
                    disableImage = _unavailableRightCoupleSeatImage;
                }
                else
                {
                    tmpNormal = _normalLeftCoupleSeatImage;
                    tmpSelected = _selectedLeftCoupleSeatImage;
                    disableImage = _unavailableLeftCoupleSeatImage;
                }
            }
            SeatView *seatView = [[SeatView alloc] initWithImage:tmpNormal];
            seatView.selectedImage = tmpSelected;
            seatView.disableImage = disableImage;
            seatView.blockImage = blockImage;
            seatView.seatInfo.identify = identify;
            seatView.tag = index++;
            seatView.userInteractionEnabled = YES;
            seatView.seatInfo.groupID = groupID;
            SeatInfo *seatInfo = [[SeatInfo alloc] init];
            seatInfo.identify = identify;
            seatInfo.groupID = groupID;
            seatInfo.collumnGroup = collumnGroup;
            if (identify.length <= 1)
            {
                if (type == SEAT_TYPE_DOOR)
                {
                    seatView.disableImage = _doorImage;
                }
                [seatView showImageWithState:SEAT_STATUS_DISABLE];
                seatView.userInteractionEnabled = NO;
            }
            if (type == SEAT_TYPE_COUPLE_1 || type == SEAT_TYPE_COUPLE_2)
            {
                if (!_seatGroupList)
                {
                    _seatGroupList = [[NSMutableDictionary alloc] init];
                }
        
                NSMutableArray *seatList = [_seatGroupList valueForKey:groupID];
                if (!seatList)
                {
                    seatList = [[NSMutableArray alloc] init];
                    [_seatGroupList setValue:seatList forKey:groupID];
                }
                [seatList addObject:seatView];
                NSInteger groupType = type == SEAT_TYPE_COUPLE_2 ? SEAT_GROUP_TYPE_SELECT_ALL : SEAT_GROUP_TYPE_NORMAL;
                seatView.seatInfo.groupType = groupType;
                seatInfo.groupType = groupType;
            }
            [info setValue:[NSNumber numberWithInteger:seatView.tag] forKey:@"tag"];

            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, seatSize.width, seatSize.height - 2)];
            title.font = [UIFont getFontNormalSize10];
            title.text = identify;
            if (identify.length > 1)
            {
                title.text = [identify substringFromIndex:1];
            }
            else if (type == SEAT_TYPE_DOOR)
            {
                title.text = @"";
            }

            title.backgroundColor = [UIColor clearColor];
            title.textAlignment = UITextAlignmentCenter;
            title.textColor = [UIColor whiteColor];
            [seatView addSubview:title];
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            [seatView addGestureRecognizer:gesture];
            CGRect seatFrame = seatView.frame;
            seatFrame.origin.x = (col - 1) * (seatSize.width + margin.width) + addingX+ roomMargin; // skip tilte
            seatFrame.origin.y = row * (seatSize.height + margin.height) + screenMargin;
            seatView.frame = seatFrame;
            seatView.seatInfo = seatInfo;
            [_roomView addSubview:seatView];
        }
    }

//    correct width
    CGFloat scrollW = roomSize.width * (seatSize.width + margin.width) + 2 * roomMargin;

    // screen
    UIImageView *theScreen = [[UIImageView alloc] initWithImage:screenImage];
    CGRect screenFrame = theScreen.frame;
    screenFrame.origin.x = (scrollW - screenFrame.size.width) / 2;
    screenFrame.origin.y = roomMargin;
    theScreen.frame = screenFrame;
    [_roomView addSubview:theScreen];
    
    UIImage *breaklineImage = [UIImage imageNamed:@"divider"];
    UIImage *seatDesImage = [UIImage imageNamed:@"seat_desc"];
    
    CGFloat desMargin = 20;
    scrollH += desMargin;
    UIImageView *breaklineView = [[UIImageView alloc] initWithImage:breaklineImage];
    breaklineView.frame = CGRectMake((scrollW - breaklineImage.size.width ) / 2, scrollH, breaklineImage.size.width, breaklineImage.size.height);
    
    scrollH += roomMargin + breaklineImage.size.height;
    UIImageView *seatDesImageView = [[UIImageView alloc] initWithImage:seatDesImage];
    seatDesImageView.frame = CGRectMake((scrollW - seatDesImage.size.width ) / 2, scrollH, seatDesImage.size.width, seatDesImage.size.height);
    seatDesImageView.userInteractionEnabled = YES;
    scrollH += seatDesImage.size.height + roomMargin;
    
    roomFrame = CGRectMake(0, 0, scrollW, scrollH);
    _roomView.frame = roomFrame;
    
    [_roomView addSubview:breaklineView];
    [_roomView addSubview:seatDesImageView];
    
    _scrollView.contentSize = CGSizeMake(scrollW, scrollH);
   _scrollViewLeftTitle.contentSize = CGSizeMake(0, scrollH);
    
    _scrollView.maximumZoomScale = 1.6;
    _scrollView.minimumZoomScale = _scrollView.frame.size.width / scrollW;
    _scrollView.zoomScale = _scrollView.frame.size.width / ((seatSize.width + margin.width) * 10);
    CGPoint offset = _scrollView.contentOffset;
    offset.x += (scrollW - _scrollView.frame.size.width) / 2;
    offset.y = 0;
    _scrollView.contentOffset = offset;
    [self updateStateForSeatList:_listStatusOfSeat];
    if (!_roomTitle || _roomTitle.length == 0)
    {
        _roomTitle = @"public";
    }
    NSString *title = [NSString stringWithFormat:@"Phòng: %@", _roomTitle];
    UIFont *font = [UIFont getFontNormalSize10];
    CGSize textSize = [title sizeWithFont:font];
    CGRect frame = CGRectMake(self.view.frame.size.width - textSize.width, 0, textSize.width, textSize.height);
    UILabel *roomTitle = [[UILabel alloc] initWithFrame:frame];
    roomTitle.font = font;
    roomTitle.text = title;
    roomTitle.textColor = [UIColor whiteColor];
    roomTitle.backgroundColor = [UIColor clearColor];
    [self.view addSubview:roomTitle];
    //    check can book online
    
    [self setTextForLableSeateDefault];
}

- (void)setTextForLableSeateDefault
{
    NSString *pendingTranID = [APIManager getStringInAppForKey:KEY_STORE_TRANSACTION_ID_PENDING];
//    if (_isMaintained)
//    {
//        _lbSelectedSeatsDefault.font = [UIFont getFontNormalSize10];
//        [_lbSelectedSeatsDefault setText:[NSString stringWithFormat:THANHTOAN_TEXT_WARNING_CINEMA_IS_MAINTAINING, _currentCinemaWithDistance.cinema.cinema_name]];
//    }
//    else
    if(pendingTranID && pendingTranID.length > 0)
    {
        _lbSelectedSeatsDefault.font = [UIFont getFontNormalSize10];
        [_lbSelectedSeatsDefault setText:ALERT_NOTICE_EXISTS_TRANSACTION_PENDING];
    }
}

- (void)renderRoom
{
    if (_dataLoadingStep > 0)
    {
        _dataLoadingStep = 0;
        [self hideLoadingView];
    }
    CGRect mainFrame = self.view.frame;
    CGRect frame = self.view.frame;

    // checkout
    UIView *infoCheckOutView = [[UIView alloc] init];
    infoCheckOutView.backgroundColor = [UIColor whiteColor];
    // break line
    UIImageView *breakline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
    CGRect brframe = breakline.frame;
    brframe.origin.x = 0;
    brframe.origin.y = 0;
    breakline.frame = brframe;
    [infoCheckOutView addSubview:breakline];
    UIImage *checkoutImage = [UIImage imageNamed:@"process_checkout.png"];
    UIImageView *checkoutImageView = [[UIImageView alloc] initWithImage:checkoutImage];
    checkoutImageView.frame = CGRectMake((mainFrame.size.width - checkoutImage.size.width) / 2,
                                          breakline.frame.size.height + breakline.frame.origin.y, checkoutImage.size.width, checkoutImage.size.height);
    checkoutImageView.userInteractionEnabled = YES;
    CGRect lbFrame = infoCheckOutView.frame;
    lbFrame.origin.x = 12;
    lbFrame.origin.y = 7;
    lbFrame.size = CGSizeMake(196, 40);
    _lbSelectedSeats = [[UIScrollView alloc] initWithFrame:lbFrame];
    _lbSelectedSeats.backgroundColor = [UIColor clearColor];
    lbFrame.origin.x = 4;
    lbFrame.origin.y = 0;
    lbFrame.size.width -= 8;
    _lbSelectedSeatsDefault = [[UILabel alloc] initWithFrame:lbFrame];
    _lbSelectedSeatsDefault.backgroundColor = [UIColor clearColor];
    _lbSelectedSeatsDefault.font = [UIFont getFontBoldSize11];
    _lbSelectedSeatsDefault.textAlignment = UITextAlignmentCenter;
    _lbSelectedSeatsDefault.numberOfLines = 0;
    _lbSelectedSeatsDefault.text = @"Ghế đang chọn";
    [_lbSelectedSeats addSubview:_lbSelectedSeatsDefault];
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureForThanhToan:)];
    [checkoutImageView addGestureRecognizer:tap];
    frame.size.height = checkoutImageView.frame.size.height + checkoutImageView.frame.origin.y;
    frame.origin.y = mainFrame.size.height - frame.size.height;
    infoCheckOutView.frame = frame;
    [checkoutImageView addSubview:_lbSelectedSeats];
    [infoCheckOutView addSubview:checkoutImageView];
    _lbSelectedSeats.userInteractionEnabled = YES;
    NSInteger leftTitleWidth = 12;
    frame = mainFrame;
    frame.origin.x = leftTitleWidth;
    frame.origin.y = 0;
    frame.size.height -= infoCheckOutView.frame.size.height;
    frame.size.width -= leftTitleWidth;
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    _scrollViewLeftTitle = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, leftTitleWidth, frame.size.height)];
    _scrollViewLeftTitle.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    _scrollViewLeftTitle.userInteractionEnabled = NO;
    _scrollView.clipsToBounds = NO;
    [self.view addSubview:_scrollView];
    [self.view addSubview:_scrollViewLeftTitle];
    [self.view addSubview:infoCheckOutView];

    // release
    _scrollView.delegate = self;
    _scrollViewLeftTitle.delegate = self;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureToZoomView:)];
    [_scrollView addGestureRecognizer:gesture];
    [self renderDefaultRoom];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([scrollView isEqual:_scrollView]) {
        CGPoint offset = _scrollView.contentOffset;
        CGPoint offsetLeft = _scrollViewLeftTitle.contentOffset;
        offsetLeft.y = offset.y;
        [_scrollViewLeftTitle setContentOffset:offsetLeft];
    }
}


-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if([scrollView isEqual:_scrollView])
    {
        CGFloat rate = scrollView.zoomScale / _lastScale;
        if (scrollView.zoomScale > _lastScale)
        {
//        scrollView.contentOffset = CGPointMake(scrollView.frame.size.width/2 * (scrollView.zoomScale - _lastScale), scrollView.frame.size.height/2 * (scrollView.zoomScale - _lastScale));
            
//            CGPoint offset = _scrollView.contentOffset;
//            [_scrollView setContentOffset:CGPointMake(400, 400)];

        }
//        re origin of left title
        for (UILabel *lb in _leftTitleView.subviews) {
            CGRect frame = lb.frame;
            frame.origin.y *= rate;
            lb.frame = frame;
        }
        _lastScale = scrollView.zoomScale;
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_scrollView])
    {
        return _roomView;
    }
    return _leftTitleView;
}

-(void)handleSelectSeatView:(SeatView *) seatView
{
    //    UNSELECT SEAT
    NSInteger status = SEAT_STATUS_SELECTED;
    if ([_selectedSeats containsObject:seatView])
    {
        [_selectedSeats removeObject:seatView];
        status = SEAT_STATUS_AVAILABLE;
    }
    else
    {
        [_selectedSeats addObject:seatView];
    }
    CGSize margin = CGSizeMake(4, 0);
    CGRect frame = CGRectMake(margin.width, 0, 48, 34);
    if (_lbSelectedSeats.subviews.count > 0)
    {
        [_lbSelectedSeats.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    UIImage *image = [UIImage imageNamed:@"title_selected_seat_bg"];
    frame.origin.y = (_lbSelectedSeats.frame.size.height - frame.size.height) / 2;
    for (SeatView *seat in _selectedSeats)
    {
        UIButton *btnChosenSeat = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnChosenSeat.frame = frame;
        [btnChosenSeat setBackgroundImage: image forState:UIControlStateNormal];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClickDeselectSeat:)];
//        [btnChosenSeat addTarget:self action:@selector(handleClickDeselectSeat:) forControlEvents:UIControlEventTouchUpInside];
        [btnChosenSeat addGestureRecognizer:gesture];
        [btnChosenSeat setTitle: seat.seatInfo.identify forState:UIControlStateNormal];
        btnChosenSeat.titleLabel.textColor = [UIColor blackColor];
        btnChosenSeat.titleLabel.textAlignment = UITextAlignmentCenter;
        [_lbSelectedSeats addSubview:btnChosenSeat];
        btnChosenSeat.tag = seat.tag;
        frame.origin.x += frame.size.width + margin.width;
    }
    _lbSelectedSeats.contentSize = CGSizeMake(frame.origin.x, 0);
    if (status != SEAT_STATUS_AVAILABLE && frame.origin.x > _lbSelectedSeats.frame.size.width)
    {
        [_lbSelectedSeats setContentOffset: CGPointMake(frame.origin.x - _lbSelectedSeats.frame.size.width, 0) animated:YES];
    }
    if (_selectedSeats.count == 0)
    {
        [_lbSelectedSeats addSubview:_lbSelectedSeatsDefault];
    }
    [seatView showImageWithState:status];
}

-(void) handleTapGesture:(UIGestureRecognizer*)gesture
{
    [self handleTapGestureToZoomView:gesture];
    NSString *pendingTranID = [APIManager getStringInAppForKey:KEY_STORE_TRANSACTION_ID_PENDING];
    if (pendingTranID && pendingTranID.length > 0)
    {
        return;
    }
    SeatView *seatView = (SeatView*)gesture.view;
    if (!seatView)
    {
        return;
    }
    if ([self checkAndShowConfirmInputOTP]) {
        return;
    }
    BOOL showLimitAlert = YES;
    if (![_selectedSeats containsObject:seatView])
    {
        showLimitAlert = NO;
    }
    if (seatView.seatInfo.groupID && seatView.seatInfo.groupID.length > 0 && seatView.seatInfo.groupType == SEAT_GROUP_TYPE_SELECT_ALL)
    {
        NSArray *seatList = [_seatGroupList valueForKey:seatView.seatInfo.groupID];
        if (!showLimitAlert && _selectedSeats.count + seatList.count > _chosenSeatLimit)
        {
            showLimitAlert = YES;
        }
        else
        {
            for (SeatView *seat in seatList)
            {
                [self handleSelectSeatView:seat];
            }
            showLimitAlert = NO;
        }
    }
    else
    {
        if (!showLimitAlert && _selectedSeats.count + 1 > _chosenSeatLimit)
        {
            showLimitAlert = YES;
        }
        else
        {
            [self handleSelectSeatView:seatView];
            showLimitAlert = NO;
        }
    }
    if (showLimitAlert)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"123Phim" message:[NSString stringWithFormat:@"Số ghế lựa chọn tối đa là %d ghế", _chosenSeatLimit] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

-(void) handleClickDeselectSeat: (UIGestureRecognizer*)gesture
{
    if (!gesture)
    {
        return;
    }
    UIButton *button = (UIButton *)gesture.view;
    SeatView *seatView = (SeatView *)[_roomView viewWithTag:button.tag];
    if (seatView.seatInfo.groupID && seatView.seatInfo.groupID.length > 0 && seatView.seatInfo.groupType == SEAT_GROUP_TYPE_SELECT_ALL)
    {
        NSArray *seatList = [_seatGroupList valueForKey:seatView.seatInfo.groupID];
        for (SeatView *seat in seatList)
        {
            [self handleSelectSeatView:seat];
        }
    }
    else
    {
        [self handleSelectSeatView:seatView];
    }

}


-(void)pushThanhToanViewController:(NSNumber *) totalOfMoney
{
    SelectTypeThanhToanViewController *selectTypeThanhToanView = [[SelectTypeThanhToanViewController alloc] init];
    BuyingInfo *buyingInfo = [[BuyingInfo alloc] init];
    NSMutableArray *seatInfoList = [[NSMutableArray alloc] init];
    for (SeatView *seat in _selectedSeats) {
        [seatInfoList addObject:seat.seatInfo];
    }
    buyingInfo.chosenSeatInfoList = seatInfoList;
    buyingInfo.chosenSession = _currentSession;
    buyingInfo.chosenFilm = _currentFilm;
    buyingInfo.totalMoney = totalOfMoney.integerValue;
    buyingInfo.room_name = _roomTitle;
    buyingInfo.chosenCinema = _currentCinemaWithDistance.cinema;
    [selectTypeThanhToanView setBuyInfo:buyingInfo];
    selectTypeThanhToanView.delegate = self;
    [self.navigationController pushViewController:selectTypeThanhToanView animated:YES];
}

-(BOOL) validateSelectedSeats
{
    NSMutableArray *selectedRows = [[NSMutableArray alloc] init];
    for (SeatView *seat in _selectedSeats)
    {
        NSString *t = seat.seatInfo.identify;
        NSString *lb = [t substringToIndex:1];
        NSInteger collumnGroup = seat.seatInfo.collumnGroup;
        BOOL add = NO;
        NSMutableArray *rangeInRow = nil;
        for (NSMutableArray *dic in selectedRows)
        {
            if ([lb compare:[dic valueForKey:@"ROW_LABEL"]] == NSOrderedSame && collumnGroup == [[dic valueForKey:@"COLLUMN_GROUP"] integerValue])
            {
                rangeInRow = [dic valueForKey:@"SELECTED_SEATS_IN_ROW"];
                [rangeInRow addObject:t];
                add = YES;
                break;
            }
        }
        [rangeInRow sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             return [((NSString *)obj1) compare:obj2];
        }];
        if (!add)
        {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:lb forKey:@"ROW_LABEL"];
            NSMutableArray *rangeInRow = [[NSMutableArray alloc] init];
            [rangeInRow addObject:t];
            [dic setValue:rangeInRow forKey:@"SELECTED_SEATS_IN_ROW"];
            [dic setValue:[NSNumber numberWithInteger:collumnGroup] forKey:@"COLLUMN_GROUP"];
            [selectedRows addObject:dic];
        }
    }
    
    for (NSDictionary *row in selectedRows)
    {
        if (![self validateFirstWithArray:row])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:ALERT_SELECT_SEAT_RULE_1 delegate:nil cancelButtonTitle:nil otherButtonTitles:ALERT_BUTTON_OK, nil];
            [alert show];
            return NO;
        }
        if (![self validateSecondWithArray:row])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:ALERT_SELECT_SEAT_RULE_2 delegate:nil cancelButtonTitle:nil otherButtonTitles:ALERT_BUTTON_OK, nil];
            [alert show];
            return NO;
        }
    }
    return YES;
}

-(BOOL) validateFirstWithArray: (NSDictionary *) rowSelected
{
    NSMutableArray * range = [rowSelected valueForKey:@"SELECTED_SEATS_IN_ROW"];
    NSMutableArray *rangeInRow = [[NSMutableArray alloc] init];
    for (NSString *seatInfo in _listStatusOfSeat)
    {
        NSString *lb = [seatInfo substringToIndex:1];
        if ([lb compare:[rowSelected valueForKey:@"ROW_LABEL"]] == NSOrderedSame)
        {
            [rangeInRow addObject:seatInfo];
        }
    }
    
    [range sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((NSString *) obj1) compare:obj2];
    }];
    // check selected seats wrong
    for (int i = 0; i < range.count; i++)
    {
        NSString *strCur = [range objectAtIndex:i];
        NSInteger cur = [strCur substringFromIndex:1].integerValue;
        NSInteger j = i + 1;
        if (j < range.count)
        {
            NSString *strNext = [range objectAtIndex:j];
            NSInteger next = [strNext substringFromIndex:1].integerValue;
            if (next - cur == 2)
            {
                __block BOOL wrong = YES;
                NSString *center;
                if (cur < 9)
                {
                     center = [NSString stringWithFormat:@"%@0%d", [strCur substringToIndex:1], cur + 1];
                }
                else
                {
                    center = [NSString stringWithFormat:@"%@%d", [strCur substringToIndex:1], cur + 1];
                }
                [rangeInRow enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([center isEqualToString:obj])
                    {
                        *stop = YES;
                        wrong = NO;
                        return;
                    }
                }];
                if (wrong)
                {
                    return NO;
                }
            }
        }
    }
    
    //            found row
    //            find list in collumn group
    
    NSMutableArray *lstSeatInGroup = [[NSMutableArray alloc] init];
    for (NSInteger row = 0; row < _roomLayout.count; row++)
    {
        //        check each row if exist seat chosen
        NSArray * rowLayout = [_roomLayout objectAtIndex:row];
        for (NSInteger i = 0; i < rowLayout.count; i++)
        {
            NSDictionary *info = [rowLayout objectAtIndex:i];
            NSInteger collumnG = [[info valueForKey:@"collumn_group"] integerValue];
            if (collumnG == [[rowSelected valueForKey:@"COLLUMN_GROUP"] integerValue])
            {
                NSString *str = [info valueForKey:@"seat_id"];
                [lstSeatInGroup addObject:str];
            }
        }
    }
    [lstSeatInGroup sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
         return [((NSString *)obj1) compare:obj2];
     }];

    __block NSInteger maxFree = 0;
    __block NSInteger maxLoop = 0;
    [lstSeatInGroup enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        // check in block seats
        [rangeInRow enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx1, BOOL *stop1)
         {
             if ([obj isEqualToString:obj1])
             {
                 if (maxLoop > maxFree)
                 {
                     maxFree = maxLoop;
                 }
                 maxLoop = -1;
                 *stop1 = YES;
             }
         }];
        maxLoop++;
    }];
    
    if (maxFree <= [range count] + 1)
    {
        return YES;
    }
    
    [rangeInRow addObjectsFromArray:range];
    [rangeInRow sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
         return [((NSString *) obj1) compare:obj2];
     }];
    
    for (int i = 0; i < rangeInRow.count; i++)
    {
        NSString *strCur = [rangeInRow objectAtIndex:i];
        NSInteger cur = [strCur substringFromIndex:1].integerValue;
        NSInteger j = i + 1;
        if (j < rangeInRow.count)
        {
            NSString *strNext = [rangeInRow objectAtIndex:j];
            NSInteger next = [strNext substringFromIndex:1].integerValue;
            if (next - cur == 2 && ([range containsObject:strCur] || [range containsObject:strNext]))
            {
                return NO;
            }
        }
    }
    return YES;
}

-(BOOL) validateSecondWithArray: (NSDictionary *) rowSelected
{
    for (NSInteger row = 0; row < _roomLayout.count; row++)
    {
//        check each row if exist seat chosen
        NSArray * rowLayout = [_roomLayout objectAtIndex:row];
        NSDictionary *titleInfo = [rowLayout objectAtIndex:0];
        if (titleInfo)
        {
            NSString *lable = [titleInfo valueForKey:@"seat_id"];
            if (lable.length <= 1 && [lable compare:[rowSelected valueForKey:@"ROW_LABEL"]] != NSOrderedSame)
            {
                continue;
            }
//            found row
//            find list in collumn group
            NSMutableArray *lstSeatInGroup = [[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < rowLayout.count; i++)
            {
                NSDictionary *info = [rowLayout objectAtIndex:i];
                NSInteger collumnG = [[info valueForKey:@"collumn_group"] integerValue];
                if (collumnG == [[rowSelected valueForKey:@"COLLUMN_GROUP"] integerValue])
                {
                    NSString *str = [info valueForKey:@"seat_id"];
                    [lstSeatInGroup addObject:str];
                }
            }
            [lstSeatInGroup sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
             {
                return [((NSString *)obj1) compare:obj2];
            }];
            NSArray * range = [rowSelected valueForKey:@"SELECTED_SEATS_IN_ROW"];
            NSString *first = [range objectAtIndex:0];
            NSString *last = [range lastObject];
            NSInteger countF = 0, countL = 0, totalFreeF = 0, totalFreeL = 0;
            BOOL add = YES, addTotal = YES, br = NO;
            for (NSInteger i = 0; i < lstSeatInGroup.count; i++)
            {
                NSString *key = [lstSeatInGroup objectAtIndex:i];
                if (key.length > 1)
                {
                    for (NSString *seat in _listStatusOfSeat)
                    {
                        if ([key isEqualToString:seat])
                        {
                            br = YES;
                            break;
                        }
                    }
                    if (br)
                    {
                        break;
                    }
                    if ([key isEqualToString:first])
                    {
                        add = NO;
                    }
                    if (add)
                    {
                        countF ++;
                    }
                    addTotal = YES;
                    for (SeatView *seat in _selectedSeats)
                    {
                        if ([key isEqualToString:seat.seatInfo.identify])
                        {
                            addTotal = NO;
                            break;
                        }
                    }
                    if (addTotal)
                    {
                        totalFreeF ++;
                    }
                }
            }
            
            add = YES;
            br = NO;
            
            for (NSInteger i = lstSeatInGroup.count - 1; i >= 0; i--)
            {
                NSString *key = [lstSeatInGroup objectAtIndex:i];
                if (key.length > 1)
                {
                    for (NSString *seat in _listStatusOfSeat)
                    {
                        if ([key isEqualToString:seat])
                        {
                            br = YES;
                            break;
                        }
                    }
                    if (br)
                    {
                        break;
                    }
                    if ([key isEqualToString:last])
                    {
                        add = NO;
                    }
                    if (add)
                    {
                        countL ++;
                    }
                    addTotal = YES;
                    for (SeatView *seat in _selectedSeats)
                    {
                        if ([key isEqualToString:seat.seatInfo.identify])
                        {
                            addTotal = NO;
                            break;
                        }
                    }
                    if (addTotal)
                    {
                        totalFreeL ++;
                    }
                }
            }
            if (countF == 1 || countL == 1)
            {
//                    may be invalid
                if (countF == 1 && totalFreeF > 1)
                {
                    return  NO;
                }
                if (countL == 1 && totalFreeL > 1)
                {
                    return NO;
                }
            }
        }
    }
    return YES;
}

-(void) handleTapGestureForThanhToan:(UIGestureRecognizer*)gesture
{
    NSString *pendingTranID = [APIManager getStringInAppForKey:KEY_STORE_TRANSACTION_ID_PENDING];
    if ((pendingTranID && pendingTranID.length > 0)) {
        return;
    }
   
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:(NSStringFromClass([SelectTypeThanhToanViewController class]))
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_TICKET_CLICK_MUAVE_BUTTON
                                                     currentFilmID:self.currentSession.film_id
                                                   currentCinemaID:self.currentSession.cinema_id
                                                         sessionId:self.currentSession.session_id
                                                   returnCodeValue:0 context:nil];
    if (_selectedSeats.count > 0)
    {
        if (![self validateSelectedSeats])
        {
            return;
        }
        [self showLoadingScreenWithType:LOADING_TYPE_FULLSCREEN];
        NSMutableArray *seatInfoList = [[NSMutableArray alloc]init];
        for (SeatView *seat in _selectedSeats) {
            [seatInfoList addObject:seat.seatInfo];
        }
        [[APIManager sharedAPIManager] getTotalMoney:seatInfoList sessionID:_currentSession.session_id.integerValue context:self];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:THANHTOAN_TEXT_WARNING_SELECT_SEAT_BEFORE delegate:nil cancelButtonTitle:nil otherButtonTitles:ALERT_BUTTON_OK, nil];
    [alert show];
}

-(void) handleTapGestureToZoomView:(UIGestureRecognizer*)gesture
{
    if (_scrollView.zoomScale < _scrollView.maximumZoomScale)
    {
        CGPoint offset = _scrollView.contentOffset;
        CGFloat rate = _scrollView.maximumZoomScale / _scrollView.zoomScale;
        UIView *v = gesture.view;
        CGPoint point =[gesture locationInView:v];
        if (v == _scrollView)
        {
            point = [_roomView convertPoint:point fromView:nil];
            point.x *= rate;
            point.y *= rate;
        }
        else
        {
            while (v != _roomView) {
                point = [v.superview convertPoint:point fromView:v];
                v = v.superview;
            }
            point = [_roomView convertPoint:point fromView:gesture.view];
        }
        [_scrollView setZoomScale:_scrollView.maximumZoomScale animated:YES];
        CGSize size = _scrollView.frame.size;
        offset.x = point.x - size.width;
        offset.y = point.y - size.height;
        if (offset.x < 0)
        {
            offset.x = 0;
        }
        if (offset.y < 0)
        {
            offset.y = 0;
        }
        if (offset.x + size.width > _scrollView.contentSize.width)
        {
            offset.x = _scrollView.contentSize.width - size.width;
        }
        if (offset.y + size.width > _scrollView.contentSize.height)
        {
            offset.y = _scrollView.contentSize.height - size.height;
        }
        _scrollView.contentOffset = offset;
    }
}

-(void)updateStateForSeatList: (NSArray*)seatList
{
    if (_selectedSeats && _selectedSeats.count > 0)
    {
        BOOL cont = NO, reset = _cleanSelectedSeats;
        if (!reset)
        {
            // check to reset selected seats list
            for (SeatView *seat in _selectedSeats)
            {
                for (NSString *seatId in seatList)
                {
                    if ([seatId isEqualToString:seat.seatInfo.identify])
                    {
                        // exist
                        cont = YES;
                        break;
                    }
                }
                if (cont)
                {
                    reset = YES;
                    break;
                }
            }
        }
        if (reset)
        {
            // reset selected seats list
            for (int i = _selectedSeats.count - 1; i >= 0; i--)
            {
                SeatView *seat = [_selectedSeats objectAtIndex:i];
                [self handleSelectSeatView:seat];
            }
            [_selectedSeats removeAllObjects];
            _cleanSelectedSeats = NO;
        }
    }
    
    for (NSString *seatId in seatList)
    {
        NSInteger startRow = [seatId characterAtIndex:0] - 'A';
        SeatView *view = nil;
        for (NSInteger row = startRow; row < _roomLayout.count; row++)
        {
            NSArray *rowLayout = [_roomLayout objectAtIndex:row];
            for (NSDictionary *seat in rowLayout)
            {
                if ([seatId compare:[seat valueForKey:@"seat_id"]] == 0)
                {
                    view = (SeatView *)[_roomView viewWithTag: [[seat objectForKey:@"tag"] integerValue]];
                    break;
                }
            }
        }
        if (!view)
        {
            if (startRow > _roomLayout.count)
            {
                startRow = _roomLayout.count;
            }
            for (NSInteger row = 0; row < startRow; row++)
            {
                NSArray *rowLayout = [_roomLayout objectAtIndex:row];
                for (NSDictionary *seat in rowLayout)
                {
                    if ([seatId compare:[seat valueForKey:@"seat_id"]] == 0)
                    {
                        view = (SeatView *)[_roomView viewWithTag: [[seat objectForKey:@"tag"] integerValue]];
                        break;
                    }
                }
            }
        }
        if (view)
        {
            NSInteger status = SEAT_STATUS_BLOCK;
            if ([_selectedSeats containsObject:view])
            {
                status = SEAT_STATUS_SELECTED;
            }
            else
            {
                 view.userInteractionEnabled = NO;
            }
            [view showImageWithState:status];
        }
    }
    _renderStatus = 0;
}

-(void) downloadRoomLayout:(NSURL*) fileUrl
{
    NSData *data = [NSData dataWithContentsOfURL:fileUrl];
    NSString *fileName = [NSString stringWithFormat:ROOM_LAYOUT_FILE];
    [data saveDataTofile:fileName path:[NSString stringWithFormat:@"%@/"ROOM_LAYOUT_ROOM_FOLDER, ROOM_LAYOUT_PATH, _currentSession.room_id.integerValue]];
    _dataLoadingStep--;;
    [self performSelectorOnMainThread:@selector(renderRoom) withObject:nil waitUntilDone:YES];
}

-(void)setCurrentSession:(Session *)currentSession
{
    _currentSession = currentSession;
     _dataLoadingStep++;
    [self getListStatusOfSeat];
}

-(void)checkCompactRoomLayoutVersion
{
    NSString *roomInfoDir = [NSString stringWithFormat:@"%@/"ROOM_LAYOUT_ROOM_FOLDER, ROOM_LAYOUT_PATH, _currentSession.room_id.intValue];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:roomInfoDir])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:roomInfoDir withIntermediateDirectories:NO attributes:nil error:&error];
        if (error)
        {
            //            can not create dir
        }
    }
    NSString *roomLayoutInfoFile = [NSString stringWithFormat:@"%@/"ROOM_LAYOUT_INFO_FILE_NAME, roomInfoDir];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:roomLayoutInfoFile];
//    must download layout
    if (dic == nil)
    {
        dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0", @"Version", nil];
    }
    _roomTitle = [dic objectForKey:@"RoomTitle"];
    [[APIManager sharedAPIManager] CheckCompactableOfRoomLayout:_currentSession.room_id.integerValue layoutVersion:[[dic valueForKey:@"Version"] integerValue] context:self request:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_renderStatus <= 0)
    {
        [self getListStatusOfSeat];
    }
    [self scrollViewDidScroll:_scrollView]; // unknow must relayout
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_dataLoadingStep > 0)
    {
        [self showLoadingScreenWithType:LOADING_TYPE_WITHOUT_NAVIGATOR];
    }
    NSString *pendingTranID = [APIManager getStringInAppForKey:KEY_STORE_TRANSACTION_ID_PENDING];
    if (pendingTranID && pendingTranID.length > 0)
    {
        AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [app setIcountTryRequestTransaction:0];//reset counting
        [[APIManager sharedAPIManager] thanhToanRequestGetInforTransactionDetail:app];
//        [self showMessageDialogInfo:ALERT_NOTICE_EXISTS_TRANSACTION_PENDING withTag:TAG_ALERT_PENDING_TRANSACTION];
    }
    [self setTextForLableSeateDefault];
}

-(BOOL)checkAndShowConfirmInputOTP
{
    NSNumber *number = [APIManager getValueForKey:KEY_STORE_STATUS_THANH_TOAN];
    if (number || [number isKindOfClass:[NSNumber class]])
    {
        if ([number intValue] == STATUS_WAITING_INPUT_OTP) {
            NSDictionary *dicThanhToan = [APIManager getValueForKey:KEY_STORE_INFO_THANH_TOAN];
            if (!dicThanhToan || ![dicThanhToan isKindOfClass:[NSDictionary class]])
            {
                return NO;
            }
            NSDictionary *dictBuyInfo = [dicThanhToan objectForKey:DICT_KEY_BUY_INFO];
            BuyingInfo *buyingInfo = [[BuyingInfo alloc] initWithDictionary:dictBuyInfo];
            NSString *session_time = [NSDate getForMatStringAsDateFromTimeTamp:[buyingInfo.chosenSession.session_time doubleValue] formatClock:@"H:mm" formatDate:@"d/M/y" desExtend:@"Hôm nay"];
            NSString *filmName = @"";
            if (buyingInfo.chosenFilm)
            {
                filmName = buyingInfo.chosenFilm.film_name;
            }
            NSString *strDes = [NSString stringWithFormat:@"%@ %@", filmName, session_time];
            [self showConfirmMessageUsingPreviousOTP:[NSString stringWithFormat:MESSAGE_CONFIRM_USING_PREVIOUS_INPUT_OTP,strDes] withTag:TAG_CONFIRM_USING_PREVIOUS_INPUT_OTP];
            return YES;
        }
    }
    return NO;
}

-(void)getListStatusOfSeat
{
    [[APIManager sharedAPIManager] getListStatusOfseatWithSessionID:_currentSession.session_id.integerValue context:self request:nil];
}

-(void)setListStatusOfSeat: (NSArray*) array
{
    _listStatusOfSeat = [[NSArray alloc] initWithArray:array];
    if (_renderStatus <= 0)
    {
        [self updateStateForSeatList:_listStatusOfSeat];
    }
}

-(void)setCurrentCinemaWithDistance:(CinemaWithDistance *)currentCinemaWithDistance
{
    _currentCinemaWithDistance = currentCinemaWithDistance;
//    _isMaintained = _currentCinemaWithDistance.cinema.is_booking.integerValue == 1; // booking online
}

#pragma mark alertView delegate
-(void)showMessageDialogInfo:(NSString *)des withTag:(int)tag
{
    [self hideLoadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:des delegate:nil cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil];
    alert.tag = tag;
    [alert setDelegate:self];
    [alert show];
}

-(void)showConfirmMessageUsingPreviousOTP:(NSString *)des withTag:(int)tag
{
    [self hideLoadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:des delegate:nil cancelButtonTitle:ALERT_BUTTON_CONTINUE otherButtonTitles:ALERT_BUTTON_ABORT,nil];
    alert.tag = tag;
    [alert setDelegate:self];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Xu ly cho su kien click cua alertView tuong ung
    if (alertView.tag == TAG_ALERT_PENDING_TRANSACTION) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag == TAG_CONFIRM_USING_PREVIOUS_INPUT_OTP)
    {
        if (buttonIndex == 0) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate pushVerifyOTPFromPendingOnApp];
        } else {
            [APIManager setValueForKey:[NSNumber numberWithInteger:STATUS_OUT_RANGE] ForKey:KEY_STORE_STATUS_THANH_TOAN];
            return;
        }
    }
}

@end
