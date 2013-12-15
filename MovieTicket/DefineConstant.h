//
//  DefineConstant.h
//  MovieTicket
//
//  Created by Le Ngoc Duy on 12/10/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#ifndef MovieTicket_DefineConstant_h
#define MovieTicket_DefineConstant_h
//#define SAFE_RELEASE(p) {if (p){[p release]; p = nil;}}
// Trongvm - 29/11/2013: ARC support
#define SAFE_RELEASE(p) {}

//#define IS_SUPPORT_PLUS
//#define ENABLECOMMENTBYMAIL

//show / hide remember info
#define IS_ENABLE_REMEMBER_FUNCTION 0
// Debug
#define IS_DEBUG_LOG_MEM 0
#define USING_LOCAL_TESTING 0

#define IS_NEED_OVERRIDE_DATABASE 1//define value to override database(1:need Override, 0: nothing)
#define IS_GA_ENABLE 1

#ifdef DEBUG
#define GA_TRACKING_ID @"UA-39785275-1"// @"UA-39765806-1"
#define LOG_123PHIM(s...) {NSLog(@"%@",[NSString stringWithFormat:@"123Phim_LOG: %@",[NSString stringWithFormat:s]]);}
#else
#define GA_TRACKING_ID @"UA-38927740-1"
#define LOG_123PHIM(s...) ;
#endif
#define PINGREMARKETING {[GoogleConversionPing pingRemarketingWithConversionId:@"983463027" label:@"jLppCIXKgAgQ8-j51AM" screenName:viewName customParameters:nil];}

#define FONT_NAME @"Helvetica"
#define FONT_BOLD_NAME @"Helvetica-Bold"

//Define key store in app setting
#define KEY_STORE_IS_SHOW_MY_LOCATION @"IS_SHOW_MY_LOCATION_MY_LOCATION"
#define KEY_STORE_MY_USER_ID @"USER_ID"
#define KEY_STORE_MY_DEVICE_TOKEN @"DEVICE_TOKEN"
#define KEY_STORE_IS_RECEIVE_NOTIFY_NEW_PHIM @"PHIM_MOI"
#define KEY_STORE_IS_RECEIVE_NOTIFY_PROMOTION @"KHUYEN_MAI_HOT"
#define KEY_STORE_IS_RECEIVE_NOTIFY_DATE_GOLD @"NGAY_VANG"
#define KEY_STORE_TRANSACTION_ID_PENDING @"TRANSACTION_ID"
#define KEY_STORE_USER_EMAIL @"EMAIL"
#define KEY_STORE_USER_PHONE @"PHONE"
#define KEY_STORE_NUMBER_LOGIN_SKIP @"NUMBER_LOGIN_SKIP"
#define KEY_STORE_NUMBER_APP_LAUNCHING @"NUMBER_APP_LAUNCHING"
#define KEY_STORE_STATUS_THANH_TOAN @"STATUS_THANH_TOAN"
#define KEY_STORE_INFO_THANH_TOAN @"INFO_THANH_TOAN"
#define KEY_STORE_GROUP_ID_CINEMA @"GROUP_ID_CINEMA"

//define default contant for height of component of ihpne
#define TITLE_BAR_HEIGHT 20 //[UIApplication sharedApplication].statusBarFrame.size.height)
#define NAVIGATION_BAR_HEIGHT 44
#define TAB_BAR_HEIGHT 44
#define TOOL_BAR_HEIGHT 40

//define status of session
#define STATUS_SESSION_DISABLE  3
#define STATUS_SESSION_ACTIVE   1
#define STATUS_SESSION_INACTIVE 2

#define AWAY_STRUCT 0
#define PRESENT_STRUCT 1
//CommentView
#define HEIGHT_VIEW_EMOTION 80
#define WIDTH_VIEW_EMOTION 300
//SliderViewImage
#define HEIGHT_IMAGE 218

#define MAX_ITEM_CELL_SESSION_LAYOUT 4

//film detail
#define smallPicW 60
#define smallPicH 60
#define ACTOR_AVATAR_W 58
#define ACTOR_AVATAR_H 58
#define picNum 8
#define filmDesHeightDefault 125
#define LEFT_MARGIN_RATE_CONTENT 80

//picture gallary
#define THUMBNAIL_W 75
#define THUMBNAIL_H 75

//Size Image PROMOTION
#define IMAGE_PROMOTION_W   75
#define IMAGE_PROMOTION_H   100

//Size Image for comment Image
#define IMAGE_COMMENT_W 50
#define IMAGE_COMMENT_H 50

//Define Default margin for table grouped type
#define MARGIN_EDGE_TABLE_GROUP 10
//Define margin for header film cinema
#define MARGIN_CELL_SESSION 11

#define MINIMUM_LENGTH_COMMENT  3
//define corner radius of text box in payment
#define CORNER_RADIUS_TEXT_BOX_ACCOUNT    7

//define height of segment Group
#define HEIGH_GROUP_TITLE_CINEMA 35

#define MAX_DISTANCE_TO_CINEMA 30
#define MIN_DISTANCE_TO_CINEMA 0.1
//50M
#define DATA_MAX_SIZE (50 * (long long)1000000)

//define tag for autoscrollLabel
#define TAG_AUTO_SCROLL_LABEL 999

//so luong sao de danh gia
#define MAX_STAR_TO_RATING 10

//Define type ThanhToan
#define THANHTOAN_TYPE_VISA_MASTER 0
#define THANHTOAN_TYPE_ATM 1

//Define for keyboard rect
#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")


//Define variable for thanhToan
//Define content title for text remember
#define TIME_INTERVAL_RETRY_GET_TRANSACTION_DETAIL 30
#define MAX_REQUEST_GET_TRANSACTION_DETAIL 20
#endif

#pragma mark - File name
#define USER_LOATION_HISTORY @"user_location_history.txt"

#pragma mark - View name
#define ABOUT_VIEW_NAME @"UIAbout"
#define ACCOUNT_VIEW_NAME @"UIAccount"
#define CINEMA_VIEW_NAME @"UIRap"
#define BUYING_VIEW_NAME @"UIBuying"
#define CHECK_IN_VIEW_NAME @"UICheckin"
#define CHOOSE_CITY_VIEW_NAME @"UIChangeCity"
#define CINEMA_FILM_VIEW_NAME @"UIRap-Film"
#define COMMENT_VIEW_NAME @"UIComment"
#define FAVORITE_FILM_VIEW_NAME @"UIPhimYeuThich"
#define FILM_CINEMA_VIEW_NAME @"UILichChieu"
#define FILM_DETAIL_VIEW_NAME @"UIDetail"
#define FILM_PAGING_VIEW_NAME @"UIFilmPaging"
#define FRIEND_VIEW_NAME @"UIFriend"
#define GALAXY_VIEW_NAME @"UIGallery"
#define GALAXY_THUMNAIL_VIEW_NAME @"UIGalleryThumnail"
#define INPUT_TEXT_FOR_FB_SHARING_VIEW_NAME @"UIInputTextForFBSharing"
#define MAIN_VIEW_NAME @"UIHome"
#define NOT_FRIEND_VIEW_NAME @"UINotFriend"
#define PLAY_TRAILER_VIEW_NAME @"UIPlayTrailer"
#define PROMOTION_DETAIL_VIEW_NAME @"UIChiTietKhuyenMai"
#define PROMOTION_VIEW_NAME @"UIKhuyenMai"
#define SELECT_BANK_VIEW_NAME @"UISelectBank"
#define SELECT_DATE_VIEW_NAME @"UIChangeDate"
#define SELECT_SEAT_VIEW_NAME @"UISelectSeat"
#define SELECT_SESSION_VIEW_NAME @"UISuatChieu"
#define SELECT_ATM_TYPE_VIEW_NAME @"UISelectTypeATM"
#define SELECT_THANHTOAN_TYPE_VIEW_NAME @"UISelectTypeThanhToan"
#define FILM_SHARING_VIEW_NAME @"UIShare"
#define SHARE_TEMPLATE_VIEW_NAME @"UIShareDetail"
#define MAP_VIEW_NAME @"UIMap"
#define THANHTOAN_VISA_VIEW_NAME @"UIThanhToanVisaCredit"
#define TICKET_LIST_VIEW_NAME @"UITicketList"
#define TUTORIAL_VIEW_NAME @"UITutorial"
#define VERIFY_ATM_BY_OTP_VIEW_NAME @"UIInputOTP"
#define VERSION_NOTIFICATION_VIEW_NAME @"UIVersionNotification"
#define WELCOME_VIEW_NAME @"UIWelcome"
#define FILM_LIST_VIEW_NAME @"UIFilmList"
#define DETAIL_TICKET_VIEW_NAME @"UITicketDetail"
#define SUCCESS_CHECK_OUT_VIEW_NAME @"UISuccessThanhToan"
#define AD_VIEW_CONTROLLER @"UIAdViewController"
#define ALBUM_CONTENT_VIEW_CONTROLLER @"UIAlbumContentViewController"
#define ALBUM_LIST_VIEW_CONTROLLER @"UIAlbumListViewController"
#define BAR_CODE_VIEW_CONTROLLER @"UIBarCodeViewController"
#define PLUS_VIEW_CONTROLLER @"UIPlusViewController"

#define TAB_CINEMA 0
#define TAB_FILM 1
#define TAB_PROMOTION 2
#define TAB_ACCOUNT 3

#define NO_FILM_ID 0
#define NO_CINEMA_ID 0
#define NO_USER_ID 0
#define NO_DATA_FOR_LOG 0

#define INTERVAL_BETWEEN_TWO_SEND_USER_LOCATION_TO_SERVER 180 //seconds
#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0) //rotate
#define NOTIFICATION_NAME_NEW_CITY @"NOTIFICATION_NAME_NOTIFICATION_NAME_NEW_CITY"

// define Action sheet
#define ACTION_SHEET_SHARE 0
#define ACTION_SHEET_SHARE_SMS 0
#define ACTION_SHEET_SHARE_EMAIL 1
#define ACTION_SHEET_SHARE_FB 2

//track user action
#define	ACTION_CINEMA_VIEW				2010
#define	ACTION_CINEMA_SHARE				2020
#define	ACTION_CINEMA_CHECK_IN				2050
#define	ACTION_CINEMA_LIKE				2060
#define	ACTION_CINEMA_UNLIKE				2070
#define	ACTION_CINEMA_CALL				2100
#define	ACTION_CINEMA_COPY_WIFI_PASS				2230
#define	ACTION_CINEMA_VIEW_MAP				2250
#define	ACTION_FILM_VIEW				3010
#define	ACTION_FILM_SHARE_SMS				3021
#define	ACTION_FILM_SHARE_EMAIL				3022
#define	ACTION_FILM_SHARE_FB				3023
#define	ACTION_FILM_COMMENT				3030
#define	ACTION_FILM_RATE				3040
#define	ACTION_FILM_LIKE				3060
#define	ACTION_FILM_UNLIKE				3070
#define ACTION_FILM_CLICK_MUAVE_BUTTON	3160
#define	ACTION_FILM_PLAY_TRAILER				3120
#define	ACTION_SESSION_VIEW				4010
#define	ACTION_SESSION_CHANGE_DATE				4090
#define	ACTION_SESSION_SHARE_SMS				4021
#define	ACTION_SESSION_SHARE_EMAIL				4022
#define	ACTION_SESSION_SHARE_FB				4023
#define	ACTION_TICKET_CLICK_MUAVE_BUTTON				5160
#define	ACTION_TICKET_VIEW                  5010
#define	ACTION_TICKET_SHARE                 5040
#define	ACTION_TICKET_PUT_CHECKOUT_INFO		5170
#define	ACTION_TICKET_SELECT_CHECKOUT_TYPE	5180
#define ACTION_TICKET_PUT_USER_INFO         5260
#define	ACTION_TICKET_CLICK_CHECKOUT        5140
#define ACTION_TICKET_GET_OTP               5270
#define	ACTION_UPDATE_VERSION				5190
#define	ACTION_PROMOTION_VIEW				6010
#define	ACTION_MAP_VIEW				7010
#define	ACTION_MAP_VIEW_DIRECTION				7240
#define	ACTION_LOCATION_CHANGE_CITY				8080
#define	ACTION_LOG_IN				1130
#define	ACTION_LOG_OUT				1140
#define ACTION_TICKET_SHOW_BAR_CODE	5250
#define TIMER_REQUEST_TIMEOUT											60
#define TIMER_REQUEST_UPLOAD_TIMEOUT                                    5*60

#define IS_RETINA ([[UIScreen mainScreen] scale] > 1.0 )


