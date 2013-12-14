//
//  APIManager.h
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/7/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIDefines.h"
#import "ASIHTTPRequest.h"
#import "SBJsonParser.h"
#import "ASIFormDataRequest.h"
#import "Location.h"
#import "Film.h"
#import "Event.h"
#import "News.h"
#import "BankInfo.h"
#import "BuyingInfo.h"
#import "DictionaryMapping.h"
#import "ArrayMapping.h"
#import "StringMapping.h"

@protocol APIManagerDelegate <ASIHTTPRequestDelegate>

//implement this to handle crash bug: delegate release when request dont finish
//need retain the request in override function and remember to release it
@optional
-(void)setHTTPRequest: (ASIHTTPRequest *) theRequest;
-(void)setPostRequest: (ASIFormDataRequest *) postRequest;

@end

@protocol RKManagerDelegate <NSObject>

@optional
-(void)processResultResponseDictionaryMapping:(DictionaryMapping *)dictionary requestId:(int)request_id;
-(void)processResultResponseArrayMapping:(ArrayMapping *)array requestId:(int)request_id;
-(void)processResultResponseStringMapping:(StringMapping *)stringMap requestId:(int)request_id;
//Return array of object declare in source
-(void)processResultResponseArray:(NSArray *)array requestId:(int)request_id;

@end

@interface APIManager : NSObject<RKManagerDelegate>
{
    APIManager *instance;
    ASIFormDataRequest *postRequest;
//    SBJsonParser *parser;
//    NSHTTPCookie *myCookies;
}
#pragma mark using for communicate with server
@property (nonatomic, assign) BOOL wasSendLogin;
@property (nonatomic, strong) NSHTTPCookie *myCookies;
@property (nonatomic, strong) SBJsonParser *parser;
@property (nonatomic, strong) NSString *accessTokenKey;

+(APIManager*)sharedAPIManager;
-(BOOL) isValidData:(id)getData;
-(void)grabURLInBackground:(NSString *)urlStr context:(id)context_id requestIndex:(NSInteger)idx;

-(void)postUIID:(NSString *)udid andDeviceToken:(NSString *)device_token context:context_id;

-(void)getRequestLoginFaceBookAccountWithContext:(id)context_id;
-(void)parseToGetResultLoginSucessRK:(NSDictionary *)getData;
//-(void)parseToGetResultLoginSucess:(NSString *)response;
-(void)notifyRequestUpdateStatusPhim:(BOOL)isPhim promotionStatus:(BOOL)isPromotion dateGoldStatus:(BOOL)isDateGold context:(id)context_id;
//get file define text from server
-(void) getFileDefineTextWithContext:(id)context_id;
-(void) parseToGetFileTextDefine:(NSDictionary *)myDic;

//get list film user like
-(void) getListFilmLikeOfUser:(NSString*)user_id context:(id)context_id;

//get list all film
-(void) getListAllFilmContext:(id)context_id;
//get list Promotion
-(void) getListPromotionWithContext:(id)context_id;
// get Event
-(void)getEvent:(id)context;

//get list location
-(void) getListLocationWithContext:(id)context_id;
//get list ticket
-(void) getListTicketWithUser:(NSString*)user context:(id)context_id;

//get list distace to cinema from Google Map
-(void)requestGoogleMapGetDistanceMatrixOfCinema:(NSMutableArray *)cinemas fromLocation:(Location *)location inMode:(NSString *)mode context:context_id;
//get list cinema at location
-(void)getListAllCinemaByLocation:(int)location_id context:(id)context_id;

//Process comment and rating
-(void)getMyCommentByFilmID:(int)film_id withUserId:(NSString *)user_id context:context_id;
//get list Comment
-(void)getListCommentByID:(int)film_id fromDate:(NSString *)date_update withLimit:(int)num context:context_id;
//Save comment and rating
-(void) saveCommentByFilm:(int)film_id andRating:(NSInteger)rating ofUser:(NSString *)user_id withContent:(NSString *)content optionalContentID:(NSInteger)commentID optionalImageURlList: (NSArray *) lstUrl responseID: (id) responseID;

//get list film session of a cinema
-(NSArray *)sendFavouriteFilmListIfNeedWithResponseID:(id)context_id;
-(BOOL)parseToGetStatusOfUpdatingFavouriteFilmListWithResponse:(NSDictionary *)dicObject;
-(void) getListFilmSessionByCinema:(int)cinema_id context:context_id;
-(void) parseListFilmSessionByCinema:(int)cinema_id toArray:(NSMutableArray *)filmSessionArray with:(NSString *)response;

//get Trailer Link of a film
-(void) getTrailerLinkOfFilm:(int)film_id context:context_id;

//get list cinema session of a film
-(void)getListCinemaSessionByFilm:(int)film_id byDate:(NSString *)viewDate atLocation:(int)location_id withRequestID:(int)requestID context:context_id;
-(void) parseListCinemaSession:(NSMutableArray *)cinemaSessionArray cinemaGroup:(NSMutableArray*)cinema_g byFilm:(int)film_id with:(NSString *)response;

//Lay 3 xuat chieu gan nhat cua 1 phim tren tat ca cac rap
-(void)getThreeSessionTimeNearestOfFilm:(int)film_id context:(id)context_id;

#pragma mark using for load user default
//Function for save data to phone through NSUserDefaults class
+(NSArray *) getArrayDataInAppForKey:(NSString *)key;
+(void) setArrayDataInApp:(NSArray *)array ForKey:(NSString *)key;

+(BOOL) getBooleanInAppForKey:(NSString *)key;
+(void) setBooleanInApp:(BOOL)bvalue ForKey:(NSString *)key;
+(void)setBoolValue:(BOOL)bvalue ForKey:(NSString *)key;
+(BOOL)getValueAsBoolForKey:(NSString *)key;

+(NSString *)getStringInAppForKey:(NSString *)key;
+(void) setStringInApp:(NSString *)value ForKey:(NSString *)key;
+(void) deleteObjectForKey:(NSString *)key;
+ (BOOL)isStoredLocalData;
+ (void)resetDefaults;

+(void) setValueForKey:(id)value ForKey:(NSString *)key;
+(id) getValueForKey:(NSString *)key;

//Save My Location
+ (void)saveLocationObject:(Location *)obj;
+ (Location *)loadLocationObject;

//Save for local Object
+ (void) saveObject:(id)obj forKey:(NSString *)key;
+ (id)loadObjectForKey:(NSString *)key;

+(NSDictionary*)encryptDictionaryWithDictionary:(NSDictionary*)dict;
+(NSDictionary*)decryptDictionaryWithDictionary:(NSDictionary*)dict;


#pragma mark Friend List (Facebook)
- (void)getFacebookFriendList:(NSString *)fbId accessToken:(NSString *)token context:(id)context;

-(void)checkAppVersion:(NSString *) currentVersion responseContext: (id)context_id request: (ASIFormDataRequest *)request;
-(NSDictionary*)parseToGetVersionInfo: (NSDictionary *) dicObject;

- (void)CheckCompactableOfRoomLayout:(NSInteger)room_id layoutVersion:(NSInteger)layoutVersion context:(id)context request: (ASIFormDataRequest *)request;
-(NSMutableArray*)parseToGetRoomLayoutInfo: (NSMutableDictionary*) dicObject;

- (void)getListStatusOfseatWithSessionID:(NSInteger)sessionID context:(id)context request: (ASIFormDataRequest *)request;
-(NSArray*)parseToGetListStatusOfSeat: (NSDictionary*) dicObject;
-(void)getTotalMoney:(NSArray *) seatInfoList sessionID: (NSInteger) sessionID context:(id)context_id;
#pragma mark process request thanhToan system from 123pay
//send log to server
-(void)sendLogToSever123PhimRequestURL:(NSString *)currentView comeFrom:(NSString *)previousView withActionID:(int)action_id currentFilmID:(NSNumber *)film_id currentCinemaID:(NSNumber *)cinema_id returnCodeValue:(int)returnCode context:(id)context_id;
-(void)sendLogToSever123PhimRequestURL:(NSString *)currentView comeFrom:(NSString *)previousView withActionID:(int)action_id currentFilmID:(NSNumber *)film_id currentCinemaID:(NSNumber *)cinema_id sessionId:(NSNumber*) session_id returnCodeValue:(int)returnCode context:(id)context_id; //with session id
-(void)thanhToanRequestGetInforTransactionDetail:(id)context_id;

#pragma mark Check in at cinema
- (void)userCheckinAtCinema: (NSString*) cinema_id userId: (NSString*)userId context: (id)context_id;
- (void)getListOfCheckedInCinema:(NSString*) userId context: (id)context_id;
-(void)uploadImage: (UIImage*) image name: (NSString *) name compressionQuality: (CGFloat) quality responseID: (id)context_id
;
- (NSString *)parseToGetUrlOfImageUploadedWithRespone: (NSArray*)response;

#pragma mark User location history
- (void)user:(NSString*)userId beInAddress:(NSString*)addr lat:(NSString*)lat log:(NSString*)log atTime:(NSString*)time context:(id)context;
-(void)getDetailForFilm: (NSInteger) filmID responseID: (id) context;
-(void)parseToUpdateFilm: (Film*) film withResponse: (NSString *) response;
-(void)setDefaultCookies;

+(void)retryRequest: (ASIHTTPRequest *)request showAlert: (BOOL) alertShow;

-(void)getNewsContentWithID:(NSInteger)newsID responseTo:(id) context;
-(void)parseToUpdateNews: (News*) news withResponse: (NSDictionary *) dicObject;

-(void)getListBankingWithVerion:(NSString *)version context:(id)context_id;
-(NSArray *)getBankListWithDictionary:(NSDictionary *)dic;
+(void)saveBankInfoWithDictionary:(NSDictionary*)dict isATM:(BOOL)isATM;
+(NSDictionary*)getBankInfoForATM:(BOOL)isATM;
+(void)removeBankInfoForATM:(BOOL)isATM;
-(void)getBankInfoWithCode:(NSString*)bankCode version:(NSInteger)version responseTo:(id)context;
-(NSDictionary*)parseToGetBankInfoDictionaryWithResponse:(NSString*)response;
-(void)thanhToanRequestVerifyCardForBankInfo: (BankInfo *)bankInfo bankData:(NSDictionary *)bankData buyInfo:(BuyingInfo *)buyInfo context:(id)context_id;
-(void)thanhToanRequestVerifyOTPForBankInfo:(BankInfo *)bankInfo bankData:(NSDictionary *)bankData buyInfo:(BuyingInfo *)buyInfo context:(id)context_id;

-(void)getBannerListWithResponseTo:(id)context;
@end
