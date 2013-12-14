//
//  APIDefines.h
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/7/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#ifndef MovieTicket_APIDefines_h
#define MovieTicket_APIDefines_h

#define API_LINK
#define GOOGLE_API_LINK
#define FACEBOOK_API_LINK



#pragma mark
#pragma mark server config
#define ROOT_SERVER ([NSString stringWithFormat:@"%@%@",BASE_URL_SERVER,MSERVICE_API])
#define IS_TEST 0//Khi build len app store nho xoa key nay
#define MSERVICE_API @"mservice12?"
#ifndef DEBUG
    #define BASE_URL_SERVER @"http://mapp-dev.123phim.vn/"
    #define MAPP_KEY @"MAPP_1@3Phim1@3"
    #define ROOT_FBSERVICE @"http://mapp-dev.123phim.vn/fbservice/"
    #define SERVER_SET_DEVICETOKEN @"http://mapp-dev.123phim.vn/auth?method=Device.save"
#else
    #define BASE_URL_SERVER @"https://mapp.123phim.vn/"
    #define MAPP_KEY @"MAPP_1@3Phim_IOS_920"
    #define ROOT_FBSERVICE @"https://mapp.123phim.vn/fbservice/"
    #define SERVER_SET_DEVICETOKEN @"https://mapp.123phim.vn/auth?method=Device.save"
#endif

#pragma mark
#pragma mark api links
#pragma mark
#pragma mark function film
#define API_REQUEST_FILM_GET_FAVOURITE_LIST_WITH_USER @"%@method=Film.getListLike&user_id=%@"
#define API_REQUEST_FILM_GET_LIST_WITH_USER @"%@method=Film.getList"
#define API_REQUEST_FILM_GET_ALL_SESSION_WITH_CINEMA @"%@method=Film.getListFilmSession&cinema_id=%d"
#define API_REQUEST_FILM_GET_DETAIL_WITH_ID @"%@method=Film.detail&film_id=%d"
#define API_REQUEST_FILM_GET_TRAILER_WITH_ID @"%@method=Film.getTrailler&film_id=%d"
#define API_REQUEST_FILM_GET_COMING_SESSION_WITH_ID @"%@method=Film.getTopSession&film_id=%d&location_id=%d"
#define API_REQUEST_FILM_POST_UPDATE_FAVOURITE @"%@method=Film.likeByList"

#pragma mark
#pragma mark function_cinema
#define API_REQUEST_CINEMA_GET_ALL_SESSION_WITH_FILM @"%@method=Cinema.getListCinemaSession&film_id=%d&view_date=%@&location_id=%d"
#define API_REQUEST_CINEMA_GET_LIST_WITH_CITY @"%@method=Cinema.getList&location_id=%d"
#define API_REQUEST_CINEMA_GET_TO_CHECKIN_WITH_USER @"%@method=Cinema.checkin&user_id=%@&cinema_id=%@"
#define API_REQUEST_CINEMA_GET_CHECKIN_USER_LIST @"%@method=Cinema.getListCheckin&user_id=%@"

#pragma mark
#pragma mark funtion news
#define API_REQUEST_NEWS_GET_LIST @"%@method=News.getList&type_id=4"
#define API_REQUEST_NEWS_GET_DETAIL_WITH_ID @"%@method=News.detail&news_id=%d"
#define API_REQUEST_NEWS_GET_EVENT @"%@method=News.getEvent"

#pragma mark
#pragma mark function city
#define API_REQUEST_CITY_GET_LIST @"%@method=Location.getList"

#pragma mark
#pragma mark function banner
#define API_REQUEST_BANNER_GET_LIST @"%@method=Banner.getList"

#pragma mark
#pragma mark function comment
#define API_REQUEST_COMMENT_GET_DETAIL_WITH_FILM_AND_USER @"%@method=Comment.detail&film_id=%d&user_id=%@"
#define API_REQUEST_COMMENT_GET_LIST_WITH_FILM @"%@method=Comment.getListComment&film_id=%d&date=%@"
#define API_REQUEST_COMMENT_POST_UPDATE @"%@method=Comment.save"
#define API_REQUEST_APP_GET_NEW_VERSION @"%@auth?method=App.getNewsVersion&version=%@"

#pragma mark
#pragma mark function user
#define API_REQUEST_USER_POST_LOGIN @"%@method=User.checkLogin"
#define API_REQUEST_USER_POST_UPDATE_RECEIVED_NOTIFICATION @"%@method=User.setNotification"
#define API_REQUEST_USER_GET_FB_FRIEND_LIST @"%@friends/?facebook_id=%@&access_token=%@"
#define API_REQUEST_USER_POST_LOCATION_TRACKING @"%@method=User.addLocationHistory"

#pragma mark
#pragma mark function room layout & booking

#pragma mark function room layout
#define API_REQUEST_ROOM_GET_LAYOUT_WITH_VERSION @"%@method=Room.checkRoom&version=%d&room_id=%d"
#define API_REQUEST_ROOM_GET_BOOKED_SEAT_LIST_WITH_SESSION @"%@method=Room.listSeatBooked&session_id=%d"

#pragma mark function room booking
#define API_REQUEST_ROOM_POST_BOOKING_GET_PAYMENT_AMOUNT @"%@method=Room.getTotalRevenue"
#define API_REQUEST_ROOM_POST_BOOKING_CANCEL @"%@method=Room.cancelBooking"
#define API_REQUEST_ROOM_POST_BOOKING_VERIFY_CARD @"%@method=Room.verifyCard"
#define API_REQUEST_ROOM_POST_BOOKING_VERIFY_CONFIRM_KEY @"%@method=Room.verifyOTP"

#pragma mark
#pragma mark funtion bank
#define API_REQUEST_BANK_GET_LIST_WITH_VERSION @"%@method=Banking.getListStruct&version=%@"
#define API_REQUEST_BANK_GET_STRUCT_WITH_VERSION @"%@method=Banking.getStruct&bank_code=%@&version=%d"

#pragma mark
#pragma mark function transaction
#define API_REQUEST_TRANSACTION_GET_TICKET_LIST @"%@method=Transaction.getTransactionUserId&user_id=%@&udid=%@"
#define API_REQUEST_TRANSACTION_GET_DETAIL @"%@method=Transaction.getDetail&invoice_no=%@&is_test=%d"

#pragma mark
#pragma mark text
#define API_REQUEST_TEXT_GET_WITH_VERSION @"%@method=Errorcode.getList&version=%@"

#pragma mark
#pragma mark log
#define API_REQUEST_LOG_POST_WRITING @"%@method=Logs.write&%@"

#pragma mark
#pragma mark
#pragma mark api tags
#define ID_REQUEST_FILM_LIST_ALL    0
#define ID_REQUEST_FILM_LIST_COMMING    1
#define ID_REQUEST_FILM_LIST_SHOWING    2
#define ID_REQUEST_ACCESS_TOKEN 3
#define ID_REQUEST_CINEMA_LIST  4
#define ID_REQUEST_ROOM_LIST    5
#define ID_REQUEST_SESSION_LIST 6
#define ID_REQUEST_CINEMA_GROUP_LIST    7
#define ID_REQUEST_GET_ALL_OBJECT   8
#define ID_REQUEST_ACCOUNT_LOGIN    9
#define ID_REQUEST_GET_NEAREST_SESSION_TIME 10
#define ID_REQUEST_GET_LIST_FILM_LIKE   11
#define ID_REQUEST_GET_LIST_CINEMA_LIKE   12
#define ID_REQUEST_CHECK_VERSION 13
#define ID_POST_UDID_DEVICE_TOKEN   14
#define ID_REQUEST_GET_DISTANCE_FROM_GOOGLE_MAP 15
#define ID_REQUEST_CHECK_ROOM_LAYOUT 16
#define ID_REQUEST_GET_LIST_STATUS_OF_SEAT 17
#define ID_REQUEST_GET_TRAILER_URL_OF_FILM 18
#define ID_REQUEST_GET_MY_COMMENT_BY_FILM  19
#define ID_REQUEST_GET_LIST_COMMENT_BY_FILM 20
#define ID_REQUEST_THANHTOAN_CREATE_ORDER 21
#define ID_REQUEST_THANHTOAN_VERIFY_ATM 22
#define ID_REQUEST_THANHTOAN_VERIFY_OTP 23
#define ID_REQUEST_THANHTOAN_QUERY_ORDER 24
#define ID_REQUEST_BLOCK_SEATS_LIST 25
#define ID_REQUEST_THANHTOAN_GET_LIST_BANK 26
#define ID_REQUEST_THANHTOAN_CREATE_ORDER_123PHIM 27
#define ID_REQUEST_THANHTOAN_TOTAL_MONEY 28
#define ID_REQUEST_UPDATE_THANHTOAN_123PHIM 29
#define ID_REQUEST_RECHECK_SEAT_BEFORE_PAY 30
#define ID_REQUEST_CANCEL_BOOKING_TIMEOUT  31
#define ID_REQUEST_UPDATE_STATUS_STEP   32
#define ID_REQUEST_THANHTOAN_CONFIRM_DONE   33
#define ID_REQUEST_NOTIFICATION_UPDATE 34
#define ID_REQUEST_USER_CHECK_IN_AT_CINEMA 35
#define ID_REQUEST_GET_LIST_CHECK_INS_OF_USER 36
#define ID_REQUEST_UPLOAD_IMAGE 37
#define ID_REQUEST_THANHTOAN_INFOR_TRANSACTION_DETAIL 38
#define ID_REQUEST_POST_COMMENT 39
#define ID_REQUEST_STORE_USER_LOCATION 40
#define ID_REQUEST_GET_ALL_LOCATION_USER 41
#define ID_REQUEST_GET_FILM_DETAIL 42
#define ID_REQUEST_SAVE_LOG_TO_SERVER_123PHIM 43
#define ID_REQUEST_SEND_LOG_TO_SERVER 44
#define ID_REQUEST_LOAD_FILM_POSTER 45
#define ID_REQUEST_GET_FILE_DEFINE_TEXT 46
#define ID_REQUEST_GET_EVENT 47
#define ID_REQUEST_GET_123PHIM_FRIEND 48
#define ID_REQUEST_GET_TICKET_LIST 49
#define ID_REQUEST_GET_PROMOTION_CONTENT 50
#define ID_REQUEST_THANHTOAN_GET_BANK_INFO 51
#define ID_REQUEST_BANNER_LIST 52
#define ID_REQUEST_FILM_POST_UPDATE_FAVOURITE 53
#define MAX_ID_REQUEST 54

#endif
