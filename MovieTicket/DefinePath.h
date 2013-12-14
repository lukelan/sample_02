//
//  DefinePath.h
//  MovieTicket
//
//  Created by Le Ngoc Duy on 1/11/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#import "APIDefines.h"

#ifndef MovieTicket_DefinePath_h
#define MovieTicket_DefinePath_h


//123mua upload
#define UPLOAD_SERVER_LINK @"http://upload.123mua.vn/go123/upload"
#define UPLOAD_SERVER_KEY @"$@JUYUGOGO"

#define THANH_TOAN_VISA_PATTERN_MIGS @"https://migs.mastercard.com.au/"

#pragma mark app funcion
#define APP_ITUNES_LINK @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=615186197"
//#define APP_ITUNE_LINK @"http://123phim.vn/ios"
#define APP_ID @"615186197"
#define APP_RATING_LINK @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=" APP_ID

#pragma mark paths
#define DOCUMENTS_PATH ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0])
#define GALLERY_PATH NSTemporaryDirectory()
#define BUNDLE_PATH ([[NSBundle mainBundle] bundlePath])
#define CACHE_IMAGE_PATH ([NSString stringWithFormat:@"%@/images/",NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]])

#define ROOM_LAYOUT_PATH DOCUMENTS_PATH
#define ROOM_LAYOUT_ROOM_FOLDER @"room_id_%d"
#define ROOM_LAYOUT_INFO_FILE_NAME @"info.txt"
#define ROOM_LAYOUT_FILE @"room_layout.txt"

#define FILE_NAME_TEXT_DEFINE   @"Define.txt"
#define FILE_NAME_TEXT_DEFINE_VERSION @"define_version.txt"

//define name of file store local
#define FILE_NAME_LIST_FILM_FAVORITE @"list_film_favorite.txt"
#define FILE_NAME_LIST_CINEMA_FAVORITE @"list_cinema_favorite.txt"

//Bank info dir
#define BANK_INFO_DIR ([NSString stringWithFormat:@"%@/bankinfo",DOCUMENTS_PATH])
#define BANK_LIST_INFO_NAME @"listInfo.txt"
#define BANK_INFO_NAME_USING_BANK_CODE @"%@.txt"

#endif
