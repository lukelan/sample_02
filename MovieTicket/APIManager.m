//
//  APIManager.m
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/7/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "APIManager.h"
#import "JSON.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "UIDevice+IdentifierAddition.h"
#import "Location.h"
#import "Film.h"
#import "Comment.h"
#import "Cinema.h"
#import "Ticket.h"
#import "FilmSession.h"
#import "CinemaWithDistance.h"
#import "Session.h"
#import "News.h"
#import "BankInfo.h"
#import "SeatInfo.h"
#import "MainViewController.h"
#import "BuyingInfo.h"

@implementation APIManager

@synthesize parser;
@synthesize myCookies;
@synthesize wasSendLogin;

static APIManager* _sharedMySingleton = nil;
+(APIManager*)sharedAPIManager
{
    //This way guaranttee only a thread execute and other thread will be returned when thread was running finished process
    if(_sharedMySingleton != nil)
    {
        return _sharedMySingleton;
    }
    static dispatch_once_t _single_thread;//block thread
    dispatch_once(&_single_thread, ^ {
        _sharedMySingleton = [[super allocWithZone:nil] init];
    });//This code is called most once.
    return _sharedMySingleton;
}

#pragma implements these methods below to do the appropriate things to ensure singleton status.
//if you want a singleton instance but also have the ability to create other instances as needed through allocation and initialization, do not override allocWithZone: and the orther methods below
//We don't want to allocate a new instance, so return the current one
+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedAPIManager];
}


//We don't want to generate mutiple conpies of the singleton
-(id)copyWithZone:(NSZone *)zone
{
    return self;
}


-(id)init{
    self=[super init];
    if (self) {
        self.parser=[[SBJsonParser alloc]init];
    }
    return self;
}

#pragma mark General method for app
-(NSString *)getFormatAuthentication
{
    return [NSString stringWithFormat:@"sig=%@&ts=%0.0f",[[NSString stringWithFormat:@"%@%0.0f",MAPP_KEY,[NSDate timeIntervalSinceReferenceDate]] stringFromMD5],[NSDate timeIntervalSinceReferenceDate]];
}


- (NSString *)getFullLinkAPI:(NSString *)url
{
    NSString *pathURL = [NSString stringWithFormat:@"%@&%@",url, [self getFormatAuthentication]];
    return pathURL;
}

#pragma mark process for Object is subclass of NSManageObject
//using request post with default key @"data"
- (void)RK_RequestApi_EntityMapping:(RKEntityMapping *)objMapping pathURL:(NSString *)pathURL postData:(NSDictionary *)temp keyPath:(NSString *)keyPath
{
    [self RK_RequestApi_EntityMapping:objMapping pathURL:pathURL postData:temp keyPost:@"data" keyPath:keyPath];
}

//using request when post with key
- (void)RK_RequestApi_EntityMapping:(RKEntityMapping *)objMapping pathURL:(NSString *)pathURL postData:(NSDictionary *)temp keyPost:(NSString *)keyPost keyPath:(NSString *)keyPath
{
    RKResponseDescriptor *filmDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:objMapping method:RKRequestMethodAny pathPattern:nil keyPath:keyPath statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [filmDescriptor setBaseURL:[NSURL URLWithString:BASE_URL_SERVER]];
    [[RKObjectManager sharedManager] addResponseDescriptor:filmDescriptor];
    
    [self RK_SendRequestFetchCD_URL:[NSURL URLWithString:pathURL] postData:temp keyPost:keyPost responseDescriptor:filmDescriptor];
}

- (void)RK_SendRequestFetchCD_URL:(NSURL *)pathURL postData:(NSDictionary *)temp keyPost:(NSString *)keyPost responseDescriptor:(RKResponseDescriptor *)responseDescriptor
{
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:[pathURL absoluteString]];
    //send request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pathURL];
    if (temp) {
        request = [self RK_SetupConfigPostRequestWithURL:pathURL temp:temp keyPost:keyPost];
    }
    
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectManager sharedManager] managedObjectRequestOperationWithRequest:request managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [[RKObjectManager sharedManager] removeResponseDescriptor:responseDescriptor];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Failed %@", error);
    }];
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:objectRequestOperation];
}

#pragma mark process for Object not subclass NSManageObject
//post using keyDefault @"data"
- (void)RK_RequestStringMappingResponseWithURL:(NSString *)url postData:(NSDictionary *)temp keyPath:(NSString *)keyPath withContext:(id)context_id requestId:(int)request_id
{
    [self RK_RequestStringMappingResponseWithURL:url postData:temp keyPost:@"data" keyPath:keyPath withContext:context_id requestId:request_id];
}

- (void)RK_RequestDictionaryMappingResponseWithURL:(NSString *)url postData:(NSDictionary *)temp keyPath:(NSString *)keyPath withContext:(id)context_id requestId:(int)request_id
{
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:temp keyPost:@"data" keyPath:keyPath withContext:context_id requestId:request_id];
}

- (void)RK_RequestArrayMappingResponseWithURL:(NSString *)url postData:(NSDictionary *)temp keyPath:(NSString *)keyPath withContext:(id)context_id requestId:(int)request_id
{
    [self RK_RequestArrayMappingResponseWithURL:url postData:temp keyPost:nil keyPath:keyPath withContext:context_id requestId:request_id];
}

//post using key
- (void)RK_RequestStringMappingResponseWithURL:(NSString *)url postData:(NSDictionary *)temp keyPost:(NSString *)keyPost keyPath:(NSString *)keyPath withContext:(id)context_id requestId:(int)request_id
{
    RKObjectMapping *dicMapping = [RKObjectMapping mappingForClass:[StringMapping class]];
    [dicMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"curString"]];
    
    [self RK_RequestWithObjectMapping:dicMapping pathURL:[self getFullLinkAPI:url] postData:temp keyPost:keyPost keyPath:keyPath withContext:context_id requestId:request_id];
}

- (void)RK_RequestDictionaryMappingResponseWithURL:(NSString *)url postData:(NSDictionary *)temp keyPost:(NSString *)keyPost keyPath:(NSString *)keyPath withContext:(id)context_id requestId:(int)request_id
{
    RKObjectMapping *dicMapping = [RKObjectMapping mappingForClass:[DictionaryMapping class]];
    [dicMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"curDictionary"]];
    
    [self RK_RequestWithObjectMapping:dicMapping pathURL:[self getFullLinkAPI:url] postData:temp keyPost:keyPost keyPath:keyPath withContext:context_id requestId:request_id];
}

- (void)RK_RequestArrayMappingResponseWithURL:(NSString *)url postData:(NSDictionary *)temp keyPost:(NSString *)keyPost keyPath:(NSString *)keyPath withContext:(id)context_id requestId:(int)request_id
{
    RKObjectMapping *arrMapping = [RKObjectMapping mappingForClass:[ArrayMapping class]];
    [arrMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"curArray"]];
    NSString *linkUrl = [self getFullLinkAPI:url];
    if (request_id == ID_REQUEST_UPLOAD_IMAGE) {
        linkUrl = url;
    }
    [self RK_RequestWithObjectMapping:arrMapping pathURL:linkUrl postData:temp keyPost:keyPost keyPath:keyPath withContext:context_id requestId:request_id];
}

//request general mapping object and send, receive response
- (void)RK_RequestWithObjectMapping:(RKObjectMapping *)objMapping pathURL:(NSString *)pathURL postData:(NSDictionary *)temp keyPost:(NSString *)keyPost keyPath:(NSString *)keyPath withContext:(id)context_id requestId:(int)request_id
{
    RKResponseDescriptor *objDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:objMapping method:RKRequestMethodAny pathPattern:nil keyPath:keyPath statusCodes:nil];
    if (request_id == ID_REQUEST_GET_123PHIM_FRIEND) {
        [objDescriptor setBaseURL:[NSURL URLWithString:ROOT_FBSERVICE]];
    }
    else if (request_id == ID_REQUEST_UPLOAD_IMAGE)
    {
        [objDescriptor setBaseURL:[NSURL URLWithString:@"http://upload.123mua.vn/"]];
    }
    else
    {
        [objDescriptor setBaseURL:[NSURL URLWithString:BASE_URL_SERVER]];
    }
    
    [self RK_SendRequestAPI_Descriptor:objDescriptor withURL:[NSURL URLWithString:pathURL] postData:temp keyPost:(NSString *)keyPost withContext:context_id requestId:request_id];
}

- (NSMutableURLRequest *)RK_SetupConfigPostRequestWithURL:(NSURL *)pathURL temp:(NSDictionary *)temp keyPost:(NSString *)keyPost
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:temp options:0 error:&error];
//    [RKMIMETypeSerialization dataFromObject:temp MIMEType:RKMIMETypeJSON error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *stringSend = jsonString;
    if (keyPost) {
        stringSend = [NSString stringWithFormat:@"%@=%@", keyPost, jsonString];
    }
    NSData *requestBody = [stringSend dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *myRequest = [NSMutableURLRequest requestWithURL:pathURL];    
    [myRequest setHTTPMethod:@"POST"];
    [myRequest setHTTPBody:requestBody];
    [myRequest setHTTPShouldHandleCookies:YES];
    [myRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];

    [myRequest setTimeoutInterval:60];
    [[RKObjectManager sharedManager] setRequestSerializationMIMEType:RKMIMETypeJSON];
    [[RKObjectManager sharedManager] setRequestSerializationMIMEType:RKMIMETypeFormURLEncoded];
    [[RKObjectManager sharedManager] setRequestSerializationMIMEType:RKMIMETypeXML];
    
    [[RKObjectManager sharedManager] setAcceptHeaderWithMIMEType:RKMIMETypeXML];
    [[RKObjectManager sharedManager] setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [[RKObjectManager sharedManager] setAcceptHeaderWithMIMEType:RKMIMETypeFormURLEncoded];
    return myRequest;
}

- (void)RK_SendRequestAPI_Descriptor:(RKResponseDescriptor *)objectDescriptor withURL:(NSURL *)pathURL postData:(NSDictionary *)temp keyPost:(NSString *)keyPost withContext:(id)context_id requestId:(int)request_id
{
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:[pathURL absoluteString]];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:pathURL];
    if (temp) {
        request = [self RK_SetupConfigPostRequestWithURL:pathURL temp:temp keyPost:keyPost];
    }
    else
    {
        //send request
        if (!request) {
            return;
        }
        [request setHTTPShouldHandleCookies:YES];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:60];
    }
    if (!request) {
        return;
    }
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[objectDescriptor]];
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        //            RKLogInfo(@"Array Load content  = %@", mappingResult.dictionary);
        [self RK_CallBackMethod:request_id mappingResult:mappingResult context_id:context_id objectDescriptor:objectDescriptor];
        [[RKObjectManager sharedManager] removeResponseDescriptor:objectDescriptor];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Failed %@", error);
    }];
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:objectRequestOperation];
}

#pragma mark process call back method for result response from server
- (void)RK_CallBackMethod:(int)request_id mappingResult:(RKMappingResult *)mappingResult context_id:(id)context_id objectDescriptor:(RKResponseDescriptor *)objectDescriptor
{
    if (context_id)
    {
        id resultObject = [mappingResult.dictionary objectForKey:objectDescriptor.keyPath];
        if (!objectDescriptor.keyPath)
        {
            NSEnumerator *enumerator = [mappingResult.dictionary objectEnumerator];
            resultObject = [enumerator nextObject];
        }
        if (resultObject ) {
            if ([context_id respondsToSelector:@selector(processResultResponseDictionaryMapping:requestId:)] && [resultObject isKindOfClass:[DictionaryMapping class]])
            {
                [context_id processResultResponseDictionaryMapping:(DictionaryMapping *)resultObject requestId:request_id];
            }
            else if([resultObject isKindOfClass:[NSArray class]])
            {
                if (([resultObject count] == 0)) {
                    if([context_id respondsToSelector:@selector(processResultResponseArrayMapping:requestId:)])
                    {
                        [context_id processResultResponseArrayMapping:(ArrayMapping *)resultObject requestId:request_id];
                    }
                    else
                    {
                        if([context_id respondsToSelector:@selector(processResultResponseArray:requestId:)])
                        {
                            [context_id processResultResponseArray:mappingResult.array requestId:request_id];
                        }
                    }
                    return;
                }
                id curObject = [resultObject objectAtIndex:0];
                if ([curObject isKindOfClass:[ArrayMapping class]]) {
                    if([context_id respondsToSelector:@selector(processResultResponseArrayMapping:requestId:)])
                    {
                        [context_id processResultResponseArrayMapping:(ArrayMapping *)curObject requestId:request_id];
                    }
                } else {
                    if([context_id respondsToSelector:@selector(processResultResponseArray:requestId:)])
                    {
                        [context_id processResultResponseArray:mappingResult.array requestId:request_id];
                    }
                }
            }
        }
    }
}

#pragma mark API request with restkit
- (void)RK_RequestAPIGetListTicket:(NSString *)url
{
    //-------------------------------//
    RKEntityMapping *ticketMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Ticket class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    ticketMapping.identificationAttributes = @[@"invoice_no"];
    [ticketMapping addAttributeMappingsFromDictionary:@{
     @"ticket_url" : @"ticket_url",
     @"date_add" : @"date_buy",
     @"publish_date" : @"film_publish_date",
     @"session_time" : @"date_show",
     @"film_name" : @"film_name",
     @"film_version" : @"film_version",
     @"poster_url" : @"film_poster_url",
     @"list_seat" : @"listSeat",
     @"room_code" : @"room_name",
     @"invoice_no" : @"invoice_no",
     @"customer_phone" : @"phone",
     @"ticket_code" : @"ticket_code",
     @"price_after" : @"ticket_total_price",
     @"film_duration" : @"film_duration",
     @"cinema_id" : @"cinema_id",
     @"cinema_name" : @"cinema_name",
     @"film_url" : @"film_url",
     @"film_id" : @"film_id",
     @"session_id": @"session_id"
     }];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [ticketMapping setDateFormatters:@[dateFormatter]];
    
    [ticketMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"@metadata.mapping.collectionIndex" toKeyPath:@"order_id"]];    
    [self RK_RequestApi_EntityMapping:ticketMapping pathURL:[self getFullLinkAPI:url] postData:nil keyPath:@"result"];
}

- (void)RK_RequestAPIGetListFilm:(NSString *)url
{    
    //-------------------------------//
    RKEntityMapping *filmMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Film class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    filmMapping.identificationAttributes = @[ @"film_id" ];
    [filmMapping addAttributeMappingsFromArray:@[@"film_id", @"film_name",@"film_version",@"publish_date",@"poster_url"
     ,@"is_like",@"status_id",@"film_duration",@"film_total_rating",@"film_point_rating",@"is_new",@"type_id",@"date_start",@"date_end", @"total",@"buy",@"discount_value", @"discount_type", @"image"]];
    [filmMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"@metadata.mapping.collectionIndex" toKeyPath:@"order_id"]];
    
    [self RK_RequestApi_EntityMapping:filmMapping pathURL:[self getFullLinkAPI:url] postData:nil keyPath:@"result"];
}

- (void)RK_RequestAPIGetListComment:(NSString *)url
{
    //-------------------------------//
    RKEntityMapping *commentMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Comment class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    commentMapping.identificationAttributes = @[ @"comment_id" ];
    [commentMapping addAttributeMappingsFromArray:@[@"comment_id",@"film_id",@"content",@"avatar",@"date_add",@"date_update",@"list_image"]];
    [commentMapping addAttributeMappingsFromDictionary:@{@"username": @"user_name", @"rate":@"ratingFilm"}];
    [commentMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"@metadata.mapping.collectionIndex" toKeyPath:@"order_id"]];
    
    //-------------------------------//
    RKEntityMapping *filmMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Film class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    filmMapping.identificationAttributes = @[ @"film_id" ];
    [filmMapping addAttributeMappingsFromArray:@[@"film_id"]];
    [commentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:nil toKeyPath:@"film" withMapping:filmMapping]];
    
    [self RK_RequestApi_EntityMapping:commentMapping pathURL:[self getFullLinkAPI:url] postData:nil keyPath:@"result"];
}


-(void)RK_RequestApiGetListLocationURL:(NSString *)url withContext:(id)context_id
{
    //---------------------------------//
    RKObjectMapping *location = [RKObjectMapping mappingForClass:[Location class]];
    [location addAttributeMappingsFromDictionary:@{
     @"location_id" : @"location_id",
     @"name" : @"location_name",
     @"location_name" : @"center_name",
     @"latitude" : @"latitude",
     @"longitude" : @"longtitude"
     }];
    RKResponseDescriptor *locationDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:location method:RKRequestMethodAny pathPattern:nil keyPath:@"result" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self RK_SendRequestAPI_Descriptor:locationDescriptor withURL:[NSURL URLWithString:[self getFullLinkAPI:url]] postData:nil keyPost:nil withContext:context_id requestId:-1];
}

-(void)RK_RequestApiGetListEventWithURL:(NSString *)url withContext:(id)context_id
{    
    //---------------------------------//
    RKObjectMapping *eventMapping = [RKObjectMapping mappingForClass:[Event class]];
    [eventMapping addAttributeMappingsFromDictionary:@{
     @"title" : @"title",
     @"link" : @"link",
     @"web_link" : @"webLink",
     @"actions" : @"lstButtons",
     }];
    
    RKResponseDescriptor *eventDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:eventMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"result" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self RK_SendRequestAPI_Descriptor:eventDescriptor withURL:[NSURL URLWithString:[self getFullLinkAPI:url]] postData:nil keyPost:nil withContext:context_id requestId:ID_REQUEST_GET_EVENT];
}

- (void)RK_RequestAPIGetListCinemaAtLocation:(NSString *)url
{   
    //-------------------------------//
    RKEntityMapping *cinemaMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Cinema class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    cinemaMapping.identificationAttributes = @[ @"cinema_id" ];
    [cinemaMapping addAttributeMappingsFromDictionary:@{@"cinema_id":@"cinema_id",
                                                       @"cinema_name":@"cinema_name",
                                                       @"cinema_phone":@"cinema_phone",
                                                       @"cinema_url":@"cinema_url",
                                                       @"cinema_address":@"cinema_address",
                                                       @"cinema_latitude":@"cinema_latitude",
                                                       @"is_booking":@"is_booking",
                                                       @"time_car":@"time_car",
                                                       @"time_moto":@"time_moto",
                                                       @"distance":@"distance",
                                                       @"p_cinema_id":@"p_cinema_id",
                                                       @"location_id":@"location_id",
                                                       @"cinema_longitude":@"cinema_longtitude",
                                                       @"is_like":@"is_cinema_favourite",
                                                       @"pass_wifi":@"cinema_wifi_pwd",
                                                        @"max_seat":@"maxSeatToBook",
                                                        @"news_id" : @"news_id",
                                                        @"date_start" : @"date_start",
                                                        @"date_end" : @"date_end",
                                                        @"total" : @"total",
                                                        @"buy" : @"buy",
                                                        @"discount_type" : @"discount_type",
                                                        @"discount_value" : @"discount_value",
     }];

    [self RK_RequestApi_EntityMapping:cinemaMapping pathURL:[self getFullLinkAPI:url] postData:nil keyPath:@"result"];
}

-(void)RK_RequestApiGetListPromotionURL:(NSString *)url withContext:(id)context_id
{
    //---------------------------------//
    RKObjectMapping *newsMapping = [RKObjectMapping mappingForClass:[News class]];
    [newsMapping addAttributeMappingsFromDictionary:@{
     @"news_id" : @"news_id",
     @"news_title" : @"news_title",
     @"news_description" : @"news_description",
     @"image2x" : @"image",
     @"banner": @"bannerURL",
     @"content" : @"content",
     @"p_cinema_id" : @"cinemaGroupID",
     @"cinema_id" : @"cinemaID",
     @"list_film" : @"filmIDList"
     }];
    
    RKResponseDescriptor *newsDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:newsMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"result" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self RK_SendRequestAPI_Descriptor:newsDescriptor withURL:[NSURL URLWithString:[self getFullLinkAPI:url]] postData:nil keyPost:nil withContext:context_id requestId:-1];
}

#pragma mark RKManageDelegate
-(void)processResultResponseDictionaryMapping:(DictionaryMapping *)dictionary requestId:(int)request_id
{
    if (request_id == ID_REQUEST_ACCOUNT_LOGIN)
    {
        [self parseToGetResultLoginSucessRK:dictionary.curDictionary];
    }
}

#pragma mark check valid data
-(NSArray *)checkResponseDataValidAsArray:(NSString *)response
{
    NSDictionary * dicObject = [parser objectWithString:response error:nil];
    int status = [[dicObject objectForKey:@"status"] intValue];
    if(status == 0)
    {
        return  nil;
    }
    NSArray *arr= [dicObject  objectForKey:@"result"];
    if (arr == nil || ![[dicObject  objectForKey:@"result"] isKindOfClass:[NSArray class]]) {
        return  nil;
    }
    return  arr;
}

-(NSDictionary *)checkResponseDataValidAsDictionary:(NSString *)response
{
    NSDictionary * dicObject = [parser objectWithString:response error:nil];
    int status = [[dicObject objectForKey:@"status"] intValue];
    if(status == 0)
    {
        return  nil;
    }
    NSDictionary *obj= [dicObject  objectForKey:@"result"];
    if (obj == nil || ![obj isKindOfClass:[NSDictionary class]]) {
        return  nil;
    }
    return obj;
}

-(id)checkResponseDataValidAsObject:(NSString *)response
{
    NSDictionary * dicObject = [parser objectWithString:response error:nil];
    int status = [[dicObject objectForKey:@"status"] intValue];
    if(status == 0)
    {
        return  nil;
    }
    id obj= [dicObject  objectForKey:@"result"];
    return obj;
}

-(BOOL) isValidData:(id)getData
{
    if (getData != [NSNull null] && getData != nil) {
        return YES;
    }
    return NO;
}

//#pragma mark post data
//-(void)grabPostURLInBackGround:(NSString *)url withData:(NSDictionary *)temp requestTag:(int)indexTag withContext:(id)context_id
//{
//    NSError *error;
////    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&error];
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:temp options:kNilOptions error:&error];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSURL *urlLink = [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@", url,[self getFormatAuthentication]]];
//    postRequest = [ASIFormDataRequest requestWithURL:urlLink];
//    [postRequest setPostValue:jsonString forKey:@"data"];
//    [postRequest setDelegate:context_id];
//    [postRequest addRequestHeader:@"Content-Type" value:@"text/json; charset=utf-8"];
//    if ([APIManager sharedAPIManager].myCookies)
//    {
//        [postRequest setRequestCookies:[NSMutableArray arrayWithObject:[APIManager sharedAPIManager].myCookies]];
//    }
//    if (indexTag != -1) {
//        postRequest.tag = indexTag;
//    }
//    if (context_id && [context_id respondsToSelector:@selector(setPostRequest:)])
//    {
//        [context_id setPostRequest:postRequest];
//    }
//    postRequest.timeOutSeconds = 60;
//    [postRequest startAsynchronous];
////    LOG_123PHIM(@"---------post request %@", url);
//    urlLink=nil;
//    [urlLink release];
//    [jsonString release];
//}

#pragma Call request Get APIs and get accessToken
-(void)grabURLInBackground:(NSString *)urlStr context:(id)context_id
{
    [self grabURLInBackground:urlStr context:context_id requestIndex:-1];
}

-(void)grabURLInBackground:(NSString *)urlStr context:(id)context_id requestIndex:(NSInteger)idx
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@", urlStr,[self getFormatAuthentication]]];
    ASIHTTPRequest* request=[ASIHTTPRequest requestWithURL:url];
    if ([APIManager sharedAPIManager].myCookies)
    {
        [request setRequestCookies:[NSMutableArray arrayWithObject:[APIManager sharedAPIManager].myCookies]];
    }
    if (context_id && [context_id respondsToSelector:@selector(setHTTPRequest:)])
    {
        [context_id setHTTPRequest:request];
    }
    request.timeOutSeconds = 30;
    [request setNumberOfTimesToRetryOnTimeout:2];
    [request setAllowCompressedResponse:YES];
    [request setDelegate:context_id];
    if (idx >= 0)
    {
        request.tag = idx;
    }
    [request startAsynchronous];
//    LOG_123PHIM(@"---------send request %@", url);
    url=nil;
}

#pragma mark process get define text and check version to get info
-(void) getFileDefineTextWithContext:(id)context_id
{
    NSMutableString *strVer = [[NSMutableString alloc] initWithString:@"0"];
    [self checkCompactDefineVersion:strVer];
    NSString *url=[NSString stringWithFormat:API_REQUEST_TEXT_GET_WITH_VERSION,ROOT_SERVER,strVer];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:nil keyPath:nil withContext:context_id requestId:ID_REQUEST_GET_FILE_DEFINE_TEXT];
    strVer = nil;
}

-(void) parseToGetFileTextDefine:(NSDictionary *)dicObject
{
    NSDictionary *myDic = [dicObject  objectForKey:@"result"];
    if (![myDic isKindOfClass:[NSDictionary class]])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *fileNameTextDefine = [NSString stringWithFormat:@"%@/%@",DOCUMENTS_PATH, FILE_NAME_TEXT_DEFINE];
        NSDictionary *offDic = [NSDictionary dictionaryWithContentsOfFile:fileNameTextDefine];
        [appDelegate setDicObjectText:offDic];
        return;
    }
    
    //save version and file define text to document folder
    NSString *fileDefineVersion = [NSString stringWithFormat:@"%@/%@",DOCUMENTS_PATH, FILE_NAME_TEXT_DEFINE_VERSION];
    id versionNum = [myDic objectForKey:@"version"];
    NSNumber *version = [NSNumber numberWithInteger:[versionNum integerValue]];
    NSDictionary *versionInfo = [NSDictionary dictionaryWithObject:version forKey:@"version"];
    if (versionInfo) {
        [versionInfo writeToFile:fileDefineVersion atomically:YES];
    }
    
    NSString *fileNameTextDefine = [NSString stringWithFormat:@"%@/%@",DOCUMENTS_PATH, FILE_NAME_TEXT_DEFINE];
    [myDic writeToFile:fileNameTextDefine atomically:NO];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setDicObjectText:myDic];
}

-(void)checkCompactDefineVersion:(NSMutableString *)stringVer
{
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:DOCUMENTS_PATH])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:DOCUMENTS_PATH withIntermediateDirectories:NO attributes:nil error:&error];
        if (error)
        {
            //            can not create dir
            return;
        }
    }
    NSString *versionInfoDefine = [NSString stringWithFormat:@"%@/%@", DOCUMENTS_PATH, FILE_NAME_TEXT_DEFINE_VERSION];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:versionInfoDefine];
    //    must download define text
    if (dic == nil)
    {
        dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0", @"version", nil];
    }
    [stringVer setString:[NSString stringWithFormat:@"%@",[dic objectForKey:@"version"]]];
}

#pragma mark post udid and device token
-(void)postUIID:(NSString *)udid andDeviceToken:(NSString *)device_token context:context_id
{
    NSDictionary *temp  = [NSDictionary dictionaryWithObjectsAndKeys:
                           udid, @"udid",
                           device_token, @"device_token",
                           nil];
    [self RK_RequestDictionaryMappingResponseWithURL:SERVER_SET_DEVICETOKEN postData:temp keyPath:@"result" withContext:nil requestId:ID_POST_UDID_DEVICE_TOKEN];
}

#pragma mark process request thanhToan system from 123pay
-(void)thanhToanRequestVerifyCardForBankInfo: (BankInfo *)bankInfo bankData:(NSDictionary *)bankData buyInfo:(BuyingInfo *)buyInfo context:(id)context_id
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (SeatInfo *seatInfo in buyInfo.chosenSeatInfoList)
    {
        [arr addObject:seatInfo.identify];
    
    }
    NSString *method = @"ATM";
    if ([bankInfo.bank_code isEqualToString:BANK_CODE_VISA_MASTER])
    {
        method = @"Credit/Visa Card";
    }
    NSMutableDictionary *dicSend = [[NSMutableDictionary alloc] init];
    [dicSend setObject:buyInfo.chosenSession.session_id.stringValue forKey:@"session_id"];
    [dicSend setObject:arr forKey:@"list_seat"];
    
    NSMutableDictionary *payment_info = [NSMutableDictionary dictionaryWithDictionary:bankData];
    [payment_info setValue:delegate.email forKey:@"customer_email"];
    [payment_info setValue:delegate.phone forKey:@"customer_phone"];
    [payment_info setValue:[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] forKey:@"udid"];
    [payment_info setValue:bankInfo.bank_code forKey:@"bankCode"];
    [payment_info setValue:[NSNumber numberWithInt:buyInfo.totalMoney] forKey:@"totalAmount"];
    [payment_info setValue:method forKey:@"method"];
    if ([delegate isUserLoggedIn])
    {
        [payment_info setValue:delegate.userProfile.user_id forKey:@"user_id"];
    }
    [dicSend setValue:payment_info forKey:@"payment_info"];
//    LOG_123PHIM(@"----send verify = %@", dicSend);
     NSString *url = [NSString stringWithFormat:API_REQUEST_ROOM_POST_BOOKING_VERIFY_CARD, ROOT_SERVER];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:dicSend keyPath:nil withContext:context_id requestId:ID_REQUEST_THANHTOAN_VERIFY_ATM];
}

-(void)thanhToanRequestVerifyOTPForBankInfo:(BankInfo *)bankInfo bankData:(NSDictionary *)bankData buyInfo:(BuyingInfo *)buyInfo context:(id)context_id
{
    NSMutableDictionary *dicSend = [NSMutableDictionary dictionaryWithDictionary:bankData];
    [dicSend setValue:bankInfo.bank_code forKey:@"bankCode"];
    [dicSend setValue:buyInfo.orderNo forKey:@"orderNo"];
    NSString *url = [NSString stringWithFormat:API_REQUEST_ROOM_POST_BOOKING_VERIFY_CONFIRM_KEY, ROOT_SERVER];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:dicSend keyPath:nil withContext:context_id requestId:ID_REQUEST_THANHTOAN_VERIFY_OTP];
}

-(void)thanhToanRequestGetInforTransactionDetail:(id)context_id
{
    NSString *pendingTranID = [APIManager getStringInAppForKey:KEY_STORE_TRANSACTION_ID_PENDING];
    if (!pendingTranID || pendingTranID.length < 1) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (!delegate.Invoice_No || ![delegate.Invoice_No isKindOfClass:[NSString class]]|| delegate.Invoice_No.length < 1) {
            return;
        }
        pendingTranID = delegate.Invoice_No;
    }
    NSString *url=[NSString stringWithFormat:API_REQUEST_TRANSACTION_GET_DETAIL,ROOT_SERVER, pendingTranID,IS_TEST];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:nil keyPath:nil withContext:context_id requestId:ID_REQUEST_THANHTOAN_INFOR_TRANSACTION_DETAIL];
}

#pragma mark get list banking
-(void)getListBankingWithVerion:(NSString *)version context:(id)context_id
{
    NSString *url = [NSString stringWithFormat:API_REQUEST_BANK_GET_LIST_WITH_VERSION,ROOT_SERVER, version];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:nil keyPath:@"result" withContext:context_id requestId:ID_REQUEST_THANHTOAN_GET_LIST_BANK];
}

-(NSArray *)getBankListWithDictionary:(NSDictionary *)dic
{
    NSArray *arr = [dic objectForKey:@"bank_list"];
    // Do du lieu cho danh sach ngan hang.
    NSMutableArray *bankArray = [[NSMutableArray alloc] init];
    for (int i=0; i< [arr count]; i++)
    {
        NSArray *arrInfo = [arr objectAtIndex:i];
        if ([arrInfo isKindOfClass:[NSArray class]] && arrInfo.count >= 4)
        {
            int j = 0;
            NSString *code = [arrInfo objectAtIndex:j++];
            NSNumber *version = [arrInfo objectAtIndex:j++];
            NSString *name = [arrInfo objectAtIndex:j++];
            NSNumber *status = [arrInfo objectAtIndex:j++];
            NSString *statusDesc = [arrInfo objectAtIndex:j++];
            NSString *logoURL = [arrInfo objectAtIndex:j];
            BankInfo *bank = [[BankInfo alloc] init];
            [bank setBank_code:code];
            [bank setBank_name:name];
            [bank setBank_version: [version integerValue]];
            [bank setBank_status:[status integerValue]];
            [bankArray addObject:bank];
            [bank setBankStatusDesc:statusDesc];
            [bank setBank_logo_URL:logoURL];
        }
    }
    return bankArray;
}

#pragma mark update notification
-(void)notifyRequestUpdateStatusPhim:(BOOL)isPhim promotionStatus:(BOOL)isPromotion dateGoldStatus:(BOOL)isDateGold context:(id)context_id
{
    NSDictionary *temp  = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:isPhim], @"notify_phim",
                           [NSNumber numberWithBool:isPromotion], @"notify_promotion",
                           [NSNumber numberWithBool:isDateGold],@"notify_date",
                           nil];
    
    NSString *url=[NSString stringWithFormat:API_REQUEST_USER_POST_UPDATE_RECEIVED_NOTIFICATION,ROOT_SERVER];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:temp keyPath:@"result" withContext:context_id requestId:ID_REQUEST_NOTIFICATION_UPDATE];
}

#pragma mark process login account
-(void)getRequestLoginFaceBookAccountWithContext:(id)context_id
{
    if (self.wasSendLogin) {
        return;
    }
    self.wasSendLogin = YES;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary *temp  = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier],@"udid",
                           delegate.userProfile.facebook_id, @"facebook_id",
                           nil];
    [temp setValue:delegate.userProfile.email forKey:@"email"];
    [temp setValue:delegate.userProfile.username forKey:@"username"];
    [temp setValue:delegate.userProfile.name forKey:@"full_name"];
    [temp setValue:delegate.userProfile.avatar forKey:@"avatar"];

    NSString *url=[NSString stringWithFormat:API_REQUEST_USER_POST_LOGIN,ROOT_SERVER];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:temp keyPath:@"result" withContext:self requestId:ID_REQUEST_ACCOUNT_LOGIN];
}

-(void)parseToGetResultLoginSucessRK:(NSDictionary *)getData
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([self isValidData:getData])
    {
        id tempAccount = [getData objectForKey:@"user_id"];
        if([self isValidData:tempAccount])
        {
            delegate.userProfile.user_id = tempAccount;
            [APIManager setStringInApp:tempAccount ForKey:KEY_STORE_MY_USER_ID];
        }
    }
    if (delegate.userProfile.user_id && delegate.userProfile.user_id.length > 0) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:NOTIFICATION_NAME_LOGIN_SUCCESS object:nil];
        [[APIManager sharedAPIManager] getListFilmLikeOfUser:delegate.userProfile.user_id context:[MainViewController sharedMainViewController]];
    }
}

#pragma mark get Comment and rating Info
-(void)getMyCommentByFilmID:(int)film_id withUserId:(NSString *)user_id context:context_id
{
    NSString *url=[NSString stringWithFormat:API_REQUEST_COMMENT_GET_DETAIL_WITH_FILM_AND_USER,ROOT_SERVER,film_id,user_id];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:nil keyPath:nil withContext:context_id requestId:ID_REQUEST_GET_MY_COMMENT_BY_FILM];
}

-(void)getListCommentByID:(int)film_id fromDate:(NSString *)date_update withLimit:(int)num context:(id)context_id
{
    NSString *url=[NSString stringWithFormat:API_REQUEST_COMMENT_GET_LIST_WITH_FILM,ROOT_SERVER,film_id, date_update];
//    [self grabURLInBackground:url context:context_id requestIndex:ID_REQUEST_GET_LIST_COMMENT_BY_FILM];
    [self RK_RequestAPIGetListComment:url];
}
#pragma makr Save comment and rating
-(void) saveCommentByFilm:(int)film_id andRating:(NSInteger)rating ofUser:(NSString *)user_id withContent:(NSString *)content optionalContentID:(NSInteger)commentID optionalImageURlList: (NSArray *) lstUrl responseID:(id)responseID
{   
    NSMutableDictionary *temp  = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt: film_id], @"film_id",
                           user_id, @"user_id",
                           content, @"comment",
                           [NSNumber numberWithInt: rating], @"rating",
                           nil];
//    LOG_123PHIM(@"-----temp---- = %@", temp);
    if (commentID > 0)
    {
        [temp setObject:[NSNumber numberWithInt:commentID] forKey: @"comment_id"];
    }
    if (lstUrl)
    {
        NSError *error = nil;
        if (!error)
        {
            [temp setObject:lstUrl forKey: @"list_image"];
        }
    }
    NSString *url = [NSString stringWithFormat:API_REQUEST_COMMENT_POST_UPDATE,ROOT_SERVER];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:temp keyPath:nil withContext:responseID requestId:ID_REQUEST_POST_COMMENT];
}

#pragma mark get Promotion
-(void) getListPromotionWithContext:(id)context_id
{
    NSString *url=[NSString stringWithFormat:API_REQUEST_NEWS_GET_LIST,ROOT_SERVER];
    [self RK_RequestApiGetListPromotionURL:url withContext:context_id];
}

-(void)getNewsContentWithID:(NSInteger)newsID responseTo:(id) context
{
    NSString* urlString = [NSString stringWithFormat:API_REQUEST_NEWS_GET_DETAIL_WITH_ID, ROOT_SERVER, newsID];
    [self RK_RequestDictionaryMappingResponseWithURL:urlString postData:nil keyPath:nil withContext:context requestId:ID_REQUEST_GET_PROMOTION_CONTENT];
}

-(void)parseToUpdateNews: (News*) news withResponse: (NSDictionary *) dicObject
{
    NSNumber *status = [dicObject objectForKey:@"status"];
    if (!status.intValue)
    {
        return;
    }
    NSMutableDictionary *result = [dicObject objectForKey:@"result"];
    if (!result)
    {
        return;
    }
    NSString *content = [result objectForKey:@"content"];
    [news setContent:content];
}

#pragma mark Location
-(void) getListLocationWithContext:(id)context_id
{
    NSString *url=[NSString stringWithFormat:API_REQUEST_CITY_GET_LIST,ROOT_SERVER];
    [self RK_RequestApiGetListLocationURL:url withContext:context_id];
}
#pragma mark Ticket
-(void) getListTicketWithUser:(NSString*)user_id context:(id)context_id
{    
	NSString *url=[NSString stringWithFormat:API_REQUEST_TRANSACTION_GET_TICKET_LIST,ROOT_SERVER, user_id, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    [self RK_RequestAPIGetListTicket:url];
//    [self grabURLInBackground:url context:context_id requestIndex:ID_REQUEST_GET_TICKET_LIST];
}


-(void)RK_GetListFilmLikeOfUserwithURL:(NSString *)url withContext:(id)context_id
{
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:url];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:nil keyPath:nil withContext:context_id requestId:ID_REQUEST_GET_LIST_FILM_LIKE];
}
//get list film user like
-(void) getListFilmLikeOfUser:(NSString*)user_id context:(id)context_id
{
//    LOG_123PHIM(@"getListFilmLikeOfUser");
    NSString *url=[NSString stringWithFormat:API_REQUEST_FILM_GET_FAVOURITE_LIST_WITH_USER,ROOT_SERVER, user_id];
    [self RK_GetListFilmLikeOfUserwithURL:url withContext:context_id];
}

#pragma mark get Film
-(NSArray *)sendFavouriteFilmListIfNeedWithResponseID:(id)context_id;
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!app.userProfile.user_id || app.userProfile.user_id.length == 0)
    {
        // dont send list
        return nil;
    }
    NSDictionary *changedDict = app.updatedFavouriteFilmList;
    if (![changedDict objectForKey:@"GOT_SERVER_FAVOURITE_FILM_LIST"])
    {
        // not got favourite list from server;
        return nil;
    }
    //__weak
    NSMutableArray *fFilmIDList = [[NSMutableArray alloc] init];
    [changedDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *strKey = (NSString*)key;
        if (![strKey isEqualToString:@"GOT_SERVER_FAVOURITE_FILM_LIST"])
        {
            NSNumber *changed = (NSNumber *)obj;
            if ([changed isKindOfClass:[NSNumber class]])
            {
                if (changed.boolValue)
                {
                    [fFilmIDList addObject:strKey];
                }
            }
        }
    }];
    if ([fFilmIDList count] == 0)
    {
        return nil;
    }
    NSDictionary *temp  = [NSDictionary dictionaryWithObjectsAndKeys:
                           fFilmIDList, @"film_ids",
                           app.userProfile.user_id, @"user_id",
                           nil];
    NSString *url=[NSString stringWithFormat:API_REQUEST_FILM_POST_UPDATE_FAVOURITE,ROOT_SERVER];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:temp keyPath:@"result" withContext:context_id requestId:ID_REQUEST_FILM_POST_UPDATE_FAVOURITE];
    return fFilmIDList;
}

-(BOOL)parseToGetStatusOfUpdatingFavouriteFilmListWithResponse:(NSDictionary *)dicObject
{
    int status = [[dicObject objectForKey:@"status"] intValue];
    if(status == 0)
    {
        return  nil;
    }
    NSNumber *result = (NSNumber*)[dicObject  objectForKey:@"result"];
    if (result == nil || ![result isKindOfClass:[NSNumber class]])
    {
        return NO;
    }
    return (result.integerValue > 0);
}

-(void) getListAllFilmContext:(id)context_id
{
    NSString *url=[NSString stringWithFormat:API_REQUEST_FILM_GET_LIST_WITH_USER,ROOT_SERVER];
    [self RK_RequestAPIGetListFilm:url];
}

#pragma mark get detail a film
-(void)getDetailForFilm: (NSInteger) filmID responseID: (id) context
{
    NSString* urlString = [NSString stringWithFormat:API_REQUEST_FILM_GET_DETAIL_WITH_ID, ROOT_SERVER, filmID];
    [self grabURLInBackground:urlString context:context requestIndex: ID_REQUEST_GET_FILM_DETAIL];
}

-(void)parseToUpdateFilm: (Film*) film withResponse: (NSString *) response
{
    NSDictionary *obj = [self checkResponseDataValidAsDictionary:response];
    if (!obj)
    {
        return;
    }
    [self parseToUpdateFilmDetailObject:film withObjectInfo:obj withContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext isNeedSave:YES];
}

#pragma mark get trailer link of a film
-(void) getTrailerLinkOfFilm:(int)film_id context:context_id
{
    NSString *url=[NSString stringWithFormat:API_REQUEST_FILM_GET_TRAILER_WITH_ID,ROOT_SERVER,film_id];
    [self grabURLInBackground:url context:context_id requestIndex:ID_REQUEST_GET_TRAILER_URL_OF_FILM];
}

#pragma mark get List Distance to Cinema From Google Map
-(void)requestGoogleMapGetDistanceMatrixOfCinema:(NSMutableArray *)cinemas fromLocation:(Location *)location inMode:(NSString *)mode context:context_id
{
    NSString *api = @"http://maps.googleapis.com/maps/api/distancematrix/json?origins=%@&destinations=%@&mode=%@&sensor=false";
    NSString *origin;
    NSString *destinations;
    NSMutableArray *destinationsArray = [[NSMutableArray alloc] init];
    
    for (Cinema *cinema in cinemas) {
        
        NSString *item = [NSString stringWithFormat:@"%@,%@", cinema.cinema_latitude, cinema.cinema_longtitude];
        
        [destinationsArray addObject:item];
        
    }
    
    origin = [NSString stringWithFormat:@"%f,%f", location.latitude, location.longtitude];
    destinations = [destinationsArray componentsJoinedByString:@"|"];
    api = [NSString stringWithFormat:api, origin, destinations, mode];
    api = [api stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self grabURLInBackground:api context:context_id requestIndex:ID_REQUEST_GET_DISTANCE_FROM_GOOGLE_MAP];
}

#pragma mark get List Cinema
-(void)getListAllCinemaByLocation:(int)location_id context:(id)context_id
{
//    LOG_123PHIM(@"send request get list cinema at a location = %d", location_id);
    NSString *url=[NSString stringWithFormat:API_REQUEST_CINEMA_GET_LIST_WITH_CITY,ROOT_SERVER,location_id];
    [self RK_RequestAPIGetListCinemaAtLocation:url];
}

#pragma mark get list film session by cinema
-(void) getListFilmSessionByCinema:(int)cinema_id context:context_id
{
    NSString *url=[NSString stringWithFormat:API_REQUEST_FILM_GET_ALL_SESSION_WITH_CINEMA,ROOT_SERVER,cinema_id];
    [self grabURLInBackground:url context:context_id];
}

-(void) parseListFilmSessionByCinema:(int)cinema_id toArray:(NSMutableArray *)filmSessionArray with:(NSString *)response
{
    NSArray *arr = [self checkResponseDataValidAsArray:response];
    if (arr == nil) {
        return;
    }
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    int number = [arr count];
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    for (int i=0; i<number; i++) {
        NSDictionary * dicObject=[arr objectAtIndex:i];
        FilmSession *filmSession = [[FilmSession alloc] init];
        int film_id = [[dicObject objectForKey:@"film_id"] intValue];
        NSArray *arraySession = [dicObject objectForKey:@"session"];
        filmSession.sessionArrays  = [[NSMutableArray alloc] initWithCapacity:arraySession.count];
        for(int j = 0; j < [arraySession count]; j++)
        {
            NSDictionary *currentDic = [arraySession objectAtIndex:j];
            Session *session = [self parseToGetSessionObject:currentDic ofFilmID:film_id andCinemaID:cinema_id withContext:context];
            filmSession.film = [app getFilmWithID:session.film_id];
            
            if(session != nil)
            {
                [filmSession.sessionArrays addObject:session];
            }
        }
        [filmSessionArray addObject:filmSession];
        arraySession = nil;
    }
    arr=nil;
}
#pragma mark get list cinema session by film
-(void)getListCinemaSessionByFilm:(int)film_id byDate:(NSString *)viewDate atLocation:(int)location_id withRequestID:(int)requestID context:context_id
{
    NSString *url=[NSString stringWithFormat:API_REQUEST_CINEMA_GET_ALL_SESSION_WITH_FILM,ROOT_SERVER,film_id,viewDate,location_id];
    [self grabURLInBackground:url context:context_id requestIndex:requestID];
}

-(void) parseListCinemaSession:(NSMutableArray *)cinemaSessionArray cinemaGroup:(NSMutableArray*)cinema_g byFilm:(int)film_id with:(NSString *)response
{
    NSArray *arr = [self checkResponseDataValidAsArray:response];
    if (arr == nil) {
        return;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSMutableArray *listCinemaSession = [[NSMutableArray alloc] init];
    int number = [arr count];
    for (int i=0; i<number; i++)
    {       
        
        NSDictionary * dicObject=[arr objectAtIndex:i];
        int cinema_id = [[dicObject objectForKey:@"cinema_id"] intValue] ;
        
        //get list of cinema group        
        NSNumber* p_cinema_id = [dicObject objectForKey:@"p_cinema_id"];
        NSString* p_cinema_name = [dicObject objectForKey:@"p_cinema_name"];
        NSDictionary* cinemaGroup = [[NSDictionary alloc] initWithObjectsAndKeys:p_cinema_id, @"cinemaGrpId", p_cinema_name, @"cinemaGrpName", nil];        
        if (cinema_g != nil) {
            if ([cinema_g indexOfObject:cinemaGroup] == NSNotFound) {
                [cinema_g addObject:cinemaGroup];
            }
        }
        ////////////////////
        
        int indexCinema = [delegate getIndexOfCinemaInArrayCinemaDistance:cinema_id];
        if (indexCinema == -1) {
            continue;
        }

        NSArray *listSession = [dicObject objectForKey:@"session"];
        NSMutableArray *arraySession2D = [[NSMutableArray alloc] init];
        NSMutableArray *arraySession3D = [[NSMutableArray alloc] init];
        NSMutableArray* arraySession2D_VNeseVoice = [[NSMutableArray alloc] init];
        NSMutableArray* arraySession3D_VNeseVoice = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < listSession.count; j++) {
            NSDictionary * curSessionDic =[listSession objectAtIndex:j];
            Session *temSession = [self parseToGetSessionObject:curSessionDic ofFilmID:film_id andCinemaID:cinema_id withContext:context];
            if (temSession != nil)
            {
                if ([temSession.version_id intValue] == 3) {
                    if (temSession.is_voice == YES) {
                        [arraySession3D_VNeseVoice addObject:temSession];
                    }else {
                        [arraySession3D addObject:temSession];
                    }                    
                }
                else
                    if (temSession.is_voice == YES) {
                        [arraySession2D_VNeseVoice addObject:temSession];
                    }else {
                        [arraySession2D addObject:temSession];
                    }
            }
        }
        CinemaWithDistance *curCinemaDistance = [delegate.arrayCinemaDistance objectAtIndex:indexCinema];
        if ([arraySession2D_VNeseVoice count] > 0)
        {
            CinemaWithDistance *cinemaSessionDistance = [[CinemaWithDistance alloc] init];
            Cinema *cinema = curCinemaDistance.cinema;
            cinemaSessionDistance.arraySessions = arraySession2D_VNeseVoice;
            cinemaSessionDistance.cinema = cinema;
            cinemaSessionDistance.distance = curCinemaDistance.distance;
            [listCinemaSession addObject:cinemaSessionDistance];
//            [cinema release];
        }
        
        if ([arraySession2D count] > 0)
        {
            CinemaWithDistance *cinemaSessionDistance = [[CinemaWithDistance alloc] init];
            Cinema *cinema = curCinemaDistance.cinema;
            cinemaSessionDistance.arraySessions = arraySession2D;
            cinemaSessionDistance.cinema = cinema;
            cinemaSessionDistance.distance = curCinemaDistance.distance;
            [listCinemaSession addObject:cinemaSessionDistance];
            //            [cinema release];
        }
        
        if ([arraySession3D_VNeseVoice count] > 0)
        {
            CinemaWithDistance *cinemaSessionDistance = [[CinemaWithDistance alloc] init];
            Cinema *cinema = curCinemaDistance.cinema;
            cinemaSessionDistance.arraySessions = arraySession3D_VNeseVoice;
            cinemaSessionDistance.cinema = cinema;
            cinemaSessionDistance.distance = curCinemaDistance.distance;
            [listCinemaSession addObject:cinemaSessionDistance];
//            [cinema release];
        }
        
        if ([arraySession3D count] > 0)
        {
            CinemaWithDistance *cinemaSessionDistance = [[CinemaWithDistance alloc] init];
            Cinema *cinema = curCinemaDistance.cinema;
            cinemaSessionDistance.arraySessions = arraySession3D;
            cinemaSessionDistance.cinema = cinema;
            cinemaSessionDistance.distance = curCinemaDistance.distance;
            [listCinemaSession addObject:cinemaSessionDistance];
            //            [cinema release];
        }
        
        
        arraySession2D_VNeseVoice = nil;
        arraySession2D = nil;
        arraySession3D_VNeseVoice = nil;
        arraySession3D = nil;
    }
    
    for(int j = 0; j < listCinemaSession.count; j++)
    {
        CinemaWithDistance *objectIndex = (CinemaWithDistance *)[listCinemaSession objectAtIndex:j];
        [cinemaSessionArray addObject:objectIndex];
    }
    arr=nil;
}

#pragma mark Lay 3 xuat chieu gan nhat cua 1 phim tren tat ca cac rap
-(void)getThreeSessionTimeNearestOfFilm:(int)film_id context:(id)context_id
{
    NSString *url=[NSString stringWithFormat:API_REQUEST_FILM_GET_COMING_SESSION_WITH_ID,ROOT_SERVER,film_id,[AppDelegate getMyLocationId]];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:nil keyPath:nil withContext:context_id requestId:ID_REQUEST_GET_NEAREST_SESSION_TIME];
}

#pragma mark parse for each object of NSManageObject
-(void) checkingSaveNSManageObject:(NSManagedObject *)objectSave withNSManageObjectContext:(NSManagedObjectContext *)context
{
    if (objectSave == nil) {
        return;
    }
    NSError *error;
    if (context && ![context saveToPersistentStore:&error]) {
        LOG_123PHIM(@"Error when save %@", error.description);
    }
}

-(void)parseToUpdateFilmDetailObject:(Film *)film withObjectInfo: (NSDictionary *)dicObject withContext:(NSManagedObjectContext *)context isNeedSave:(BOOL)needSave
{
    id getData = [dicObject objectForKey:@"list_actor"];
    if([self isValidData:getData])
    {
        NSMutableString *temp = [[NSMutableString alloc] init];
        NSArray *arr = getData;
        for (int j = 0; j < arr.count; j++) {
            NSDictionary *dic = [arr objectAtIndex:j];
            id objTemp = [dic objectForKey:@"artist_name"];
            if (objTemp != [NSNull null]) {
                [temp appendString:objTemp];
            }
            [temp appendString:@";"];
            objTemp = [dic objectForKey:@"char_name"];
            if (objTemp != [NSNull null]) {
                [temp appendString:objTemp];
            }
            [temp appendString:@";"];
            objTemp = [dic objectForKey:@"avatar"];
            if (objTemp != [NSNull null]) {
                [temp appendString:objTemp];
            }
            if(j < (arr.count - 1))
            {
                [temp appendString:@"∂"];
            }
        }
        if (temp.length > 3) {
            [film setFilm_actors:temp];
        }
    }
    getData = [dicObject objectForKey:@"film_description_mobile"];
    if([self isValidData:getData])
    {
        [film setFilm_description:getData];
    }
    getData = [dicObject objectForKey:@"film_description_mobile_short"];
    if([self isValidData:getData])
    {
        [film setFilm_description_short:getData];
    }
    getData = [dicObject objectForKey:@"list_image_view"];
    if([self isValidData:getData])
    {
        [film setArrayImageReviews:getData];
        NSMutableString *list = [[NSMutableString alloc] initWithString:@""];
        for(int j= 0; j < [getData count]; j++)
        {
            id temp = [getData objectAtIndex:j];
            if (temp != [NSNull null]) {
                [list appendString:[getData objectAtIndex:j]];
                if(j < ([getData count] - 1))
                {
                    [list appendString:@"∂"];
                }
            }
        }
        [film setList_image_review:list];
    }
    getData = [dicObject objectForKey:@"list_image_thumbnail"];
    if([self isValidData:getData])
    {
        [film setArrayImageThumbnailReviews:getData];
        NSMutableString *list = [[NSMutableString alloc] initWithString:@""];
        for(int j= 0; j < [getData count]; j++)
        {
            id temp = [getData objectAtIndex:j];
            if (temp != [NSNull null]) {
                [list appendString:[getData objectAtIndex:j]];
                if(j < ([getData count] - 1))
                {
                    [list appendString:@"∂"];
                }
            }
        }
        [film setList_image_thumbnail_review:list];
    }
    getData = [dicObject objectForKey:@"film_url"];
    if([self isValidData:getData])
    {
        NSRange range = [((NSString *)getData) rangeOfString:@"?"];
        NSString *formatString = @"%@?filmId=%d";
        if (range.location != NSNotFound)
        {
            formatString = @"%@&filmId=%d";
        }
        NSString *url = [NSString stringWithFormat:formatString, getData, [film.film_id integerValue]];
        [film setFilm_url:url];
    }
    if (needSave) {
        [self checkingSaveNSManageObject:film withNSManageObjectContext:context];
    }
}

-(Session *)parseToGetSessionObject:(NSDictionary *)dicObject ofFilmID:(int)film_id andCinemaID:(int)cinema_id  withContext:(NSManagedObjectContext *)context
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    Session *session = [[Session alloc]init];
    [session setSession_id:[NSNumber numberWithInt:[[dicObject objectForKey:@"session_id"]intValue]]];
    
    [session setFilm_id:[NSNumber numberWithInt:film_id]];
    [session setCinema_id:[NSNumber numberWithInt:cinema_id]];
    id getData = [dicObject objectForKey:@"session_time"];
    if([self isValidData:getData])
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *tmpDate = [dateFormatter dateFromString:getData];
        NSNumber *timetamp = [NSNumber numberWithDouble:[tmpDate timeIntervalSinceReferenceDate]];
        [session setSession_time:timetamp];
    }
    getData = [dicObject objectForKey:@"status_id"];
    if([self isValidData:getData])
    {
        [session setStatus:[NSNumber numberWithInt:[getData intValue]]];
    }
    getData = [dicObject objectForKey:@"room_id"];
    if([self isValidData:getData])
    {
        [session setRoom_id:[NSNumber numberWithInt:[getData intValue]]];
    }
    getData = [dicObject objectForKey:@"version_id"];
    if([self isValidData:getData])
    {
        [session setVersion_id:[NSNumber numberWithInt:[getData intValue]]];
    }
    getData = [dicObject objectForKey:@"is_voice"];
    if ([self isValidData:getData]) {
        [session setIs_voice:[getData boolValue]];
    } 
    getData = [dicObject objectForKey:@"session_link"];
    if([self isValidData:getData] && [getData isKindOfClass:[NSString class]] && ((NSString *)getData).length > 0)
    {
        [session setSession_link:getData];
    }
    return session;
}

-(void) checkingSaveNSManageObjectDict:(NSDictionary*)dict
{
    NSMutableArray * arr = [[NSMutableArray alloc] initWithArray: nil];
    NSManagedObjectContext *context = [dict objectForKey:@"context"];
    for (NSManagedObject *object in arr) {
        [self checkingSaveNSManageObject:object withNSManageObjectContext:context];
    }
}

#pragma mark save for UserDefaults
//Function for save data to phone through NSUserDefaults class
+(NSArray *) getArrayDataInAppForKey:(NSString *)key
{
    
    NSData *data = [APIManager getValueForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+(void) setArrayDataInApp:(NSArray *)array ForKey:(NSString *)key
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    [APIManager setValueForKey:data ForKey:key];
}

+(BOOL) getBooleanInAppForKey:(NSString *)key
{
    return [AppDelegate getCurrentPostionON];
}

+(void) setBooleanInApp:(BOOL)bvalue ForKey:(NSString *)key
{
    return [AppDelegate setCurrentPostionON:bvalue];
}

+(BOOL)getValueAsBoolForKey:(NSString *)key
{
    NSNumber *obj = [APIManager getValueForKey:key];
    if (obj)
    {
        return [obj boolValue];
    }
    return NO;
}

+(void)setBoolValue:(BOOL)bvalue ForKey:(NSString *)key
{
    [APIManager setValueForKey:[NSNumber numberWithBool:bvalue] ForKey:key];
}

+(NSString *)getStringInAppForKey:(NSString *)key
{
    NSData *cipher = [APIManager getValueForKey:[NSString sha1:key]];
    NSData *plain = [self decryptDataWithData:cipher];
    return [[NSString alloc] initWithData:plain encoding:NSUTF8StringEncoding];
}

+(void)setStringInApp:(NSString *)value ForKey:(NSString *)key
{
    NSData *plain = [value dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipher = [self encryptDataWithData:plain];
    [self setValueForKey:cipher ForKey:[NSString sha1:key]];
}

+(NSData *)encryptDataWithData:(NSData *)data
{
	return [data AES256EncryptWithKey:[APIManager sharedAPIManager].accessTokenKey];
}

+(NSData*)decryptDataWithData:(NSData*)data
{
    return [data AES256DecryptWithKey:[APIManager sharedAPIManager].accessTokenKey];
}

-(NSString *)createKeyChangeToSaveLocal:(NSString *)key
{
    if (!key || key.length < 3) {
        return key;
    }
    int length = key.length;
    int midle = length/2;
    NSString *subStringFirst = [key substringFromIndex:midle];
    NSString *subStringEnd = [key substringToIndex:midle];
    NSString *result = [NSString stringWithFormat:@"%@%@", [subStringEnd reverseString], [subStringFirst reverseString]];
    return result;
}

+(NSDictionary*)encryptDictionaryWithDictionary:(NSDictionary*)dict
{
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] init];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSData *data = [((NSString*)obj) dataUsingEncoding:NSUTF8StringEncoding];
            NSString *keySave = [[APIManager sharedAPIManager] createKeyChangeToSaveLocal:key];
            [returnDict setObject:[APIManager encryptDataWithData:data] forKey:keySave];
        }
    }];
    return returnDict;
}

+(NSDictionary*)decryptDictionaryWithDictionary:(NSDictionary*)dict
{
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] init];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSData class]])
        {
            NSData *data = [APIManager decryptDataWithData:obj];
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *keySave = [[APIManager sharedAPIManager] createKeyChangeToSaveLocal:key];
            [returnDict setObject:str forKey:keySave];
        }
    }];
    return returnDict;
}

+(void)saveBankInfoWithDictionary:(NSDictionary*)dict isATM:(BOOL)isATM
{
    if (dict)
    {
        NSString *key = @"LAST_BANK_VISA";
        if (isATM)
        {
            key = @"LAST_BANK_ATM";
        }
        NSDictionary *d = [APIManager encryptDictionaryWithDictionary:dict];
        [APIManager setValueForKey:d ForKey:key];
    }
}

+(NSDictionary*)getBankInfoForATM:(BOOL)isATM
{
    NSString *key = @"LAST_BANK_VISA";
    if (isATM)
    {
        key = @"LAST_BANK_ATM";
    }
    NSDictionary *dict = [APIManager getValueForKey:key];
    if (dict)
    {
        return [APIManager decryptDictionaryWithDictionary:dict];
    }
    return nil;
}

+(void)removeBankInfoForATM:(BOOL)isATM
{
    NSString *key = @"LAST_BANK_VISA";
    if (isATM)
    {
        key = @"LAST_BANK_ATM";
    }
    [APIManager deleteObjectForKey:key];
}

+(void)deleteObjectForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    NSArray *arr = [APIManager getValueForKey:@"SAVED_KEY_LIST"];
    NSMutableArray *mArr = [NSMutableArray arrayWithArray:arr];
    NSString *obj = nil;
    for (NSString *str in mArr)
    {
        if ([str isEqualToString:key]) {
            obj = str;
            break;
        }
    }
    if (obj)
    {
        [mArr removeObject:obj];
    }
    [defaults setValue:mArr forKey:@"SAVED_KEY_LIST"];
    [defaults synchronize];
}

+ (BOOL)isStoredLocalData
{
    BOOL isResult = NO;
    NSArray *arr = [APIManager getValueForKey:@"SAVED_KEY_LIST"];
    if ([arr isKindOfClass:[NSArray class]])
    {
        isResult = YES;
    }
    return isResult;
}

+ (void)resetDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [APIManager getValueForKey:@"SAVED_KEY_LIST"];
    if ([arr isKindOfClass:[NSArray class]])
    {
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             NSString *key = obj;
             if ([key isKindOfClass:[NSString class]])
             {
                 [defaults removeObjectForKey:key];
             }
        }];
    }    
    [defaults removeObjectForKey:@"SAVED_KEY_LIST"];
    //some key to remove for version 1.0
    NSArray *previousArray = [NSArray arrayWithObjects:KEY_STORE_IS_RECEIVE_NOTIFY_NEW_PHIM,KEY_STORE_IS_RECEIVE_NOTIFY_PROMOTION,KEY_STORE_IS_RECEIVE_NOTIFY_DATE_GOLD,KEY_STORE_TRANSACTION_ID_PENDING,KEY_STORE_USER_EMAIL,KEY_STORE_USER_PHONE,KEY_STORE_NUMBER_LOGIN_SKIP,KEY_STORE_NUMBER_APP_LAUNCHING,KEY_STORE_STATUS_THANH_TOAN,KEY_STORE_INFO_THANH_TOAN,KEY_STORE_GROUP_ID_CINEMA, nil];
    for (NSString *key in previousArray)
    {
        if ([key isEqual:KEY_STORE_USER_EMAIL] || [key isEqual:KEY_STORE_USER_PHONE]) {
            [defaults removeObjectForKey:[NSString sha1:key]];
        } else {
            [defaults removeObjectForKey:key];
        }
    }
    
    [defaults synchronize];
}

+(void)setValueForKey:(id)value ForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    NSArray *arr = [APIManager getValueForKey:@"SAVED_KEY_LIST"];
    NSMutableArray *mArr = [NSMutableArray arrayWithArray:arr];
    NSString *obj = nil;
    for (NSString *str in mArr)
    {
        if ([str isEqualToString:key]) {
            obj = str;
            break;
        }
    }
    if (!obj)
    {
        [mArr addObject:key];
    }
    [defaults setValue:mArr forKey:@"SAVED_KEY_LIST"];
    [defaults synchronize];
}

+(id)getValueForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:key];
}

//get location object
+ (void)saveLocationObject:(Location *)obj
{
    [AppDelegate setMyLocationId:obj.location_id];
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:obj];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"MY_LOCATION"];
    [defaults setObject:myEncodedObject forKey:@"MY_LOCATION"];
    [defaults synchronize];
}

+ (Location *)loadLocationObject
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id temp = [defaults objectForKey:@"MY_LOCATION"];
    if ([temp isKindOfClass:[NSData class]]) {
        return (Location *)[NSKeyedUnarchiver unarchiveObjectWithData: (NSData *)temp];
    }
    return nil;
}

//+ (void)saveLocationObject:(Location *)obj
//{
//    [AppDelegate setMyLocationId:obj.location_id];
//    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:obj];
//    [APIManager deleteObjectForKey:@"MY_LOCATION"];
//    [APIManager setValueForKey:myEncodedObject ForKey:@"MY_LOCATION"];
//}
//
//+ (Location *)loadLocationObject
//{
//    id temp = [APIManager getValueForKey:@"MY_LOCATION"];
//    if ([temp isKindOfClass:[NSData class]]) {
//        return (Location *)[NSKeyedUnarchiver unarchiveObjectWithData: (NSData *)temp];
//    }
//    return nil;
//}

//save and get object class must implement NSCoding
+ (void) saveObject:(id)obj forKey:(NSString *)key
{
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [APIManager deleteObjectForKey:[NSString sha1:key]];
    [APIManager setValueForKey:myEncodedObject ForKey:[NSString sha1:key]];
}

+ (id)loadObjectForKey:(NSString *)key
{
    id temp = [APIManager getValueForKey:[NSString sha1:key]];
    if ([temp isKindOfClass:[NSData class]]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData: (NSData *)temp];
    }
    return nil;
}

#pragma mark Friend List (Facebook)
- (void)getFacebookFriendList:(NSString *)fbId accessToken:(NSString *)token context:(id)context
{
    NSString *url = [NSString stringWithFormat:API_REQUEST_USER_GET_FB_FRIEND_LIST, ROOT_FBSERVICE, fbId, token];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:nil keyPath:nil withContext:context requestId:ID_REQUEST_GET_123PHIM_FRIEND];
}

- (void)CheckCompactableOfRoomLayout:(NSInteger)room_id layoutVersion:(NSInteger)layoutVersion context:(id)context request: (ASIFormDataRequest *)request
{
    NSString *url = [NSString stringWithFormat:API_REQUEST_ROOM_GET_LAYOUT_WITH_VERSION, ROOT_SERVER, layoutVersion, room_id];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:nil keyPath:nil withContext:context requestId:ID_REQUEST_CHECK_ROOM_LAYOUT];
}

-(NSArray*)parseToGetRoomLayoutInfo: (NSMutableDictionary*) dicObject
{
    if (![dicObject isKindOfClass:[NSMutableDictionary class]]) {
        return  nil;
    }
//    NSMutableDictionary * dicObject = [parser objectWithString:response error:nil];
    NSNumber *status = [dicObject objectForKey:@"status"];
    if (!status.intValue)
    {
        return nil;
    }
    NSArray *array = [dicObject objectForKey:@"result"];
    NSNumber *newVersionExist = [array objectAtIndex:0];
    if (newVersionExist.integerValue == 0)
    {
        return nil;
    }
    NSNumber *version = [array objectAtIndex:2];
    NSString *roomTitle = [array objectAtIndex:1];
    if ([roomTitle isKindOfClass:[NSNull class]])
    {
        roomTitle = nil;
    }
    array = [array objectAtIndex:3];
    [dicObject removeAllObjects];
    [dicObject setObject:version forKey:@"Version"];
    [dicObject setObject:roomTitle forKey:@"RoomTitle"];
    return [NSArray arrayWithObjects:dicObject, array, nil];
}

- (void)getListStatusOfseatWithSessionID:(NSInteger)sessionID context:(id)context request: (ASIFormDataRequest *)request
{
    NSString *url = [NSString stringWithFormat:API_REQUEST_ROOM_GET_BOOKED_SEAT_LIST_WITH_SESSION, ROOT_SERVER, sessionID];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:nil keyPath:@"result" withContext:context requestId:ID_REQUEST_GET_LIST_STATUS_OF_SEAT];
}


-(NSArray*)parseToGetListStatusOfSeat: (NSDictionary*) blockInfo
{
    if (!blockInfo || ![blockInfo isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }
    NSMutableArray *arrBolckedSeat = [[NSMutableArray alloc] init];
    //                convert to one array
    NSArray *arrSeatID = [blockInfo objectForKey:@"seat_id"];
    NSArray *arrTitle = [blockInfo objectForKey:@"title"];
    
    for (int row = 0; row < arrTitle.count; row++)
    {
        NSString *rowTitle = [arrTitle objectAtIndex:row];
        if (!rowTitle || rowTitle.length == 0)
        {
            continue;
        }
        NSArray *arrColSeatID = [arrSeatID objectAtIndex:row];
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
            [arrBolckedSeat addObject:strSeatID];
        }
    }        
    return arrBolckedSeat;
}

#pragma mark check version to update
-(void)checkAppVersion:(NSString *) currentVersion responseContext: (id)context_id request: (ASIFormDataRequest *)request
{
    NSString *url=[NSString stringWithFormat:API_REQUEST_APP_GET_NEW_VERSION,BASE_URL_SERVER,currentVersion];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:nil keyPath:nil withContext:context_id requestId:ID_REQUEST_CHECK_VERSION];
}

-(NSDictionary*)parseToGetVersionInfo: (NSDictionary *) dicObject
{
    NSNumber *status = [dicObject objectForKey:@"status"];
    if (!status.intValue)
    {
        return nil;
    }
    dicObject = [dicObject objectForKey:@"result"];
    if ([dicObject isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return dicObject;
}

#pragma mark get total money
-(void)getTotalMoney:(NSArray *) seatInfoList sessionID: (NSInteger) sessionID context:(id)context_id
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (SeatInfo *seatInfo in seatInfoList)
    {
        [arr addObject:seatInfo.identify];
    }
    NSDictionary *temp  = [NSDictionary dictionaryWithObjectsAndKeys:
                           arr, @"list_seat",
                           [NSString stringWithFormat:@"%d",sessionID],@"session_id",
                           nil];
    NSString *url=[NSString stringWithFormat:API_REQUEST_ROOM_POST_BOOKING_GET_PAYMENT_AMOUNT,ROOT_SERVER];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:temp keyPath:@"result" withContext:context_id requestId:ID_REQUEST_THANHTOAN_TOTAL_MONEY];
}

#pragma mark send log to 123phim
-(void)sendLogToSever123PhimRequestURL:(NSString *)currentView comeFrom:(NSString *)previousView withActionID:(int)action_id currentFilmID:(NSNumber *)film_id currentCinemaID:(NSNumber *)cinema_id returnCodeValue:(int)returnCode context:(id)context_id
{
    [self sendLogToSever123PhimRequestURL:currentView comeFrom:previousView withActionID:action_id currentFilmID:film_id currentCinemaID:cinema_id sessionId:[NSNumber numberWithInt: NO_DATA_FOR_LOG] returnCodeValue:returnCode context:context_id];
}

-(void)sendLogToSever123PhimRequestURL:(NSString *)currentView comeFrom:(NSString *)previousView withActionID:(int)action_id currentFilmID:(NSNumber *)film_id currentCinemaID:(NSNumber *)cinema_id sessionId:(NSNumber*) session_id returnCodeValue:(int)returnCode context:(id)context_id
{
    //    $data->requestURL     :currentView
    //    $data->ref            :previousView
    //    $data->domain         :Default Mobile
    //    $data->s1             :[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]
    //    $data->s2             :[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]
    //    $data->action_id      :0(LOG_ACTION_ID_VIEW), 1(LOG_ACTION_ID_SELECT_SEAT), 2(LOG_ACTION_ID_INFO_PAYMENT), 3(LOG_ACTION_ID_PAYMENT_DONE ) define in file DefineString.h
    //    $data->returnCode     :default 0 neu khong co returnCode
    //    $data->invoice_no
    //    $data->film_id
    //    $data->session_id     :suat chieu
    //    $data->userAgent
    //    $data->user_id
    //    $data->cinema_id
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *user_id = @"";
    if ([appDelegate isUserLoggedIn]) {
        user_id = appDelegate.userProfile.user_id;
    }
    NSMutableString *param = [NSMutableString stringWithFormat:@"invoice_no=%@&session_id=%d&userAgent=%@&user_id=%d&film_id=%d&cinema_id=%d&requestURL=%@&ref=%@&domain=Mobile&s1=%@&s2=%@&action_id=%d&requestDate=%@&returnCode=%d",appDelegate.Invoice_No == nil ? @"":appDelegate.Invoice_No,session_id.intValue,@"",user_id.intValue,film_id.intValue,cinema_id.intValue,currentView,previousView,[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier],[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier],action_id,[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]],returnCode];
    
    NSString *url=[NSString stringWithFormat:API_REQUEST_LOG_POST_WRITING,ROOT_SERVER,param];
    [self RK_RequestDictionaryMappingResponseWithURL:url postData:nil keyPath:@"result" withContext:nil requestId:ID_REQUEST_SAVE_LOG_TO_SERVER_123PHIM];
}

#pragma mark - user check in at cinema
- (void)userCheckinAtCinema: (NSString*) cinema_id userId: (NSString*)userId context: (id)context_id
{    
    NSString* urlString = [NSString stringWithFormat:API_REQUEST_CINEMA_GET_TO_CHECKIN_WITH_USER, ROOT_SERVER, userId, cinema_id];
    [self RK_RequestDictionaryMappingResponseWithURL:urlString postData:nil keyPath:nil withContext:context_id requestId:ID_REQUEST_USER_CHECK_IN_AT_CINEMA];
}

- (void)getListOfCheckedInCinema:(NSString*) userId context: (id)context_id
{
    NSString* urlString = [NSString stringWithFormat:API_REQUEST_CINEMA_GET_CHECKIN_USER_LIST, ROOT_SERVER, userId];
    [self RK_RequestDictionaryMappingResponseWithURL:urlString postData:nil keyPath:nil withContext:context_id requestId:ID_REQUEST_GET_LIST_CHECK_INS_OF_USER];
}

-(void)uploadImage: (UIImage*) image name: (NSString *) name compressionQuality: (CGFloat) quality responseID: (id)context_id
{
    NSString *url=[NSString stringWithFormat:UPLOAD_SERVER_LINK];
    NSURL *urlLink=[NSURL URLWithString:url];

    NSData *data = UIImageJPEGRepresentation(image, quality);
    if (![UIImage isJPEGValid:data])
    {
        LOG_123PHIM(@"NOt jpeg image");
        return;
    }
    postRequest = [ASIFormDataRequest requestWithURL:urlLink];
//    NSString *secKey = [NSString stringWithFormat:@"%@%@", name, UPLOAD_SERVER_KEY];
    [postRequest setNumberOfTimesToRetryOnTimeout:3];
    [postRequest addData:data withFileName:name andContentType:@"image/jpg" forKey:@"files"];
    [postRequest addPostValue:name forKey:@"image_name"];
    [postRequest setDelegate:context_id];
    postRequest.tag = ID_REQUEST_UPLOAD_IMAGE;
    postRequest.timeOutSeconds = 60;
    if (context_id && [context_id respondsToSelector:@selector(setPostRequest:)])
    {
        [context_id setPostRequest:postRequest];
    }
    [postRequest startAsynchronous];
    urlLink=nil;
    
//    NSMutableDictionary *dicSend = [NSMutableDictionary dictionaryWithObjectsAndKeys:name,@"image_name", nil];
//    NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    [dicSend setValue:strData forKey:@"files"];
//    [self grabPostURLInBackGround:url withData:dicSend requestTag:ID_REQUEST_UPLOAD_IMAGE withContext:context_id];
//    [self RK_RequestArrayMappingResponseWithURL:url postData:dicSend keyPost:nil keyPath:nil withContext:context_id requestId:ID_REQUEST_UPLOAD_IMAGE];
}

- (NSString *)parseToGetUrlOfImageUploadedWithRespone: (NSArray*)arr
{
//    NSArray *arr = [parser objectWithString:response];
    if (arr == nil) {
        return @"";
    }
    NSDictionary* item = [arr objectAtIndex:0];
    id getData = [item objectForKey:@"url"];
    if ([getData isKindOfClass:[NSString class]])
    {
        return getData;
    }
    return @"";
}

#pragma mark - User location history
- (void)user:(NSString*)userId beInAddress:(NSString*)addr lat:(NSString*)lat log:(NSString*)log atTime:(NSString*)time context:(id)context
{
//    LOG_123PHIM(@"beInAddress");
    NSString* urlString = [NSString stringWithFormat:API_REQUEST_USER_POST_LOCATION_TRACKING, ROOT_SERVER];
    NSDictionary* temp = [NSDictionary dictionaryWithObjectsAndKeys:
                           [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier], @"udid",
                           userId, @"user_id",
                           lat, @"latitude",
                           log, @"longitude",
                           addr, @"address",
                           time, @"date",
                           nil];
    [self RK_RequestDictionaryMappingResponseWithURL:urlString postData:temp keyPath:@"result" withContext:nil requestId:ID_REQUEST_STORE_USER_LOCATION];

}

#pragma mark - Get event
-(void)getEvent:(id)context
{
    NSString* urlString = [NSString stringWithFormat:API_REQUEST_NEWS_GET_EVENT, ROOT_SERVER];
    [self RK_RequestApiGetListEventWithURL:urlString withContext:context];
}
#pragma mark set cookies and retry request
-(void)setDefaultCookies
{
    if(!self.myCookies)
    {
        NSURL *url = [[NSURL alloc] initWithString:ROOT_SERVER];
        if ([[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url].count > 0) {
            [self setMyCookies:[[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url] objectAtIndex:0]];
        }
    }
}

+(void)retryRequest: (ASIHTTPRequest *)request showAlert: (BOOL) alertShow
{
    if (alertShow)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"123Phim" message:@"Không thể kết nối với server.\nBạn vui lòng thử lại." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
//    if ([AppDelegate isNetWorkValiable])
//    {
//        //        retry
//        [request cancel];
//        [request startAsynchronous];
//    }
}
#pragma mark get Info banking
-(void)getBankInfoWithCode:(NSString*)bankCode version:(NSInteger)version responseTo:(id)context
{
    NSString* urlString = [NSString stringWithFormat:API_REQUEST_BANK_GET_STRUCT_WITH_VERSION, ROOT_SERVER, bankCode, version];
    [self RK_RequestDictionaryMappingResponseWithURL:urlString postData:nil keyPath:@"result" withContext:context requestId:ID_REQUEST_THANHTOAN_GET_BANK_INFO];
}

-(NSDictionary*)parseToGetBankInfoDictionaryWithResponse:(NSString*)response
{
    NSDictionary *dict = [self checkResponseDataValidAsDictionary:response];
    return dict;
}

-(void)getBannerListWithResponseTo:(id)context
{
    NSString* urlString = [NSString stringWithFormat:API_REQUEST_BANNER_GET_LIST, ROOT_SERVER];
    [self RK_RequestArrayMappingResponseWithURL:urlString postData:nil keyPath:@"result.showing" withContext:context requestId:ID_REQUEST_BANNER_LIST];
}
@end

