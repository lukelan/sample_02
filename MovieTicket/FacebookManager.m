//
//  FacebookManger.m
//  123Phim
//
//  Created by phuonnm on 3/11/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "FacebookManager.h"

@implementation FacebookManager

static FacebookManager* _sharedMyFacebookManger = nil;

+ (FacebookManager *)shareMySingleton
{
    if(_sharedMyFacebookManger != nil)
    {
        return _sharedMyFacebookManger;
    }
    static dispatch_once_t _single_thread;//block thread
    dispatch_once(&_single_thread, ^ {
        _sharedMyFacebookManger = [[super allocWithZone:nil] init];
    });//This code is called most once.
    return _sharedMyFacebookManger;
}
#pragma mark - Share film
- (void)shareFilm:(Film *)film withMessage:(NSString *)message
{
    [self shareFilm:film withMessage:message onSuccess:^(id result) {
        
    } onError:^(NSError *error) {
        
    }];
}

- (void)shareFilm:(Film *)film
      withMessage:(NSString *)message
        onSuccess:(void (^)(id))successCallback
          onError:(void (^)(NSError *))errorCallback
{
    [self shareFilmWithUrl:film.film_url withMessage:message onSuccess:successCallback onError:errorCallback];
}

- (void)shareFilmWithUrl:(NSString *)filmUrl
      withMessage:(NSString *)message
        onSuccess:(void (^)(id))successCallback
          onError:(void (^)(NSError *))errorCallback
{
    NSMutableDictionary<FBGraphObject> *action = [FBGraphObject graphObject];
    [action setValue:filmUrl forKey:@"film"];
    [action setValue:message forKey:@"message"];
    [action setValue:@"true" forKey:@"fb:explicitly_shared"];
    
    [FBRequestConnection startForPostWithGraphPath:@"me/vng_phim:share"
                                       graphObject:action
                                 completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                     if (error) {
                                         errorCallback(error);
                                     } else {
                                         successCallback(result);
                                     }
                                 }];
}

#pragma mark - Check in
- (void) checkInCinema:(Cinema *)cinema withMessage:(NSString *)message withImageUrl:(NSString*)image
{
    [self checkInCinema:cinema withMessage:message withImageUrl:image
                            onSuccess:^(id result){}
                            onError:^(NSError* error){}
    ];
}
- (void) checkInCinema:(Cinema *)cinema
           withMessage:(NSString *)message
          withImageUrl:(NSString*)image
             onSuccess:(void (^) (id))successCallback
               onError:(void (^) (NSError *))errorCallback{
    [self checkInCinemaWithUrl:cinema.cinema_url withMessage:message withImageUrl:image onSuccess:successCallback onError:errorCallback];
    
}
- (void)checkInCinemaWithUrl:(NSString *)cinemaUrl
                 withMessage:(NSString *)message
                withImageUrl:(NSString*)image
                   onSuccess:(void (^)(id))successCallback
                     onError:(void (^)(NSError *))errorCallback
{
    NSMutableDictionary<FBGraphObject>* action = [FBGraphObject graphObject];
//    [action setValue:cinemaUrl forKey:@"cinema"];
//    [action setValue:@"http://www.123phim.vn/chi-tiet-rap/21-bhd-cineplex-bhd-star-cineplex-3-2.html" forKey:@"cinema"];
    [action setValue:cinemaUrl forKey:@"cinema"];

    NSDictionary* largeImage1 = [[NSDictionary alloc] initWithObjectsAndKeys: image, @"url", @"true", @"user_generated", nil];   
    NSMutableArray* largeImageList = [[NSMutableArray alloc] initWithObjects: largeImage1, nil];
    
    [action setValue:largeImageList forKey:@"image"];
    [action setValue:message forKey:@"message"];
    [action setValue:@"true" forKey:@"fb:explicitly_shared"];
    [FBRequestConnection startForPostWithGraphPath:@"me/vng_phim:check_in" graphObject:action completionHandler:^(FBRequestConnection* connection, id result, NSError* error){
        if (error) {
            errorCallback(error);
        }else {
            successCallback(result);
        }
    }];
}

#pragma mark - Share ticket
- (void) buyTicket:(Ticket *)ticket withMessage:(NSString *)message
{
    [self buyTicket:ticket withMessage:message onSuccess:^(id result){} onError:^(NSError* error){}];
}
- (void) buyTicket:(Ticket *)ticket
       withMessage:(NSString *)message
         onSuccess:(void (^) (id))successCallback
           onError:(void (^) (NSError *))errorCallback
{
    [self buyTicketWithUrl:ticket.ticket_url withMessage:message onSuccess:successCallback onError:errorCallback];
    
}
- (void)buyTicketWithUrl:(NSString *)ticketUrl
             withMessage:(NSString *)message
               onSuccess:(void (^)(id))successCallback
                 onError:(void (^)(NSError *))errorCallback
{
    NSMutableDictionary<FBGraphObject>* action = [FBGraphObject graphObject];
    [action setValue:ticketUrl forKey:@"ticket"];
    [action setValue:message forKey:@"messsage"];
    [action setValue:@"true" forKey:@"fb:explicitly_shared"];
    [FBRequestConnection startForPostWithGraphPath:@"me/vng_phim:buy" graphObject:action completionHandler:^(FBRequestConnection* conn, id res, NSError* err){
        if (err) {
            errorCallback(err);
        }else{
            successCallback(res);
        }
    }];
}

#pragma mark - Share event
- (void)shareEvent:(Event *)event withMessage:(NSString *)message
{
    [self shareEvent:event withMessage:message onSuccess:^(id result) {
        
    } onError:^(NSError *error) {
        
    }];
}

- (void)shareEvent:(Event *)event
      withMessage:(NSString *)message
        onSuccess:(void (^)(id))successCallback
          onError:(void (^)(NSError *))errorCallback
{
    [self shareEventWithUrl:event.link withMessage:message onSuccess:successCallback onError:errorCallback];
}

- (void)shareEventWithUrl:(NSString *)eventUrl
             withMessage:(NSString *)message
               onSuccess:(void (^)(id))successCallback
                 onError:(void (^)(NSError *))errorCallback
{
    NSMutableDictionary<FBGraphObject> *action = [FBGraphObject graphObject];
    [action setValue:eventUrl forKey:@"film"];
    [action setValue:message forKey:@"message"];
    [action setValue:@"true" forKey:@"fb:explicitly_shared"];
    
    [FBRequestConnection startForPostWithGraphPath:@"me/vng_phim:share"
                                       graphObject:action
                                 completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                     if (error) {
                                         errorCallback(error);
                                     } else {
                                         successCallback(result);
                                     }
                                 }];
}

#pragma mark - Share link
- (void)shareUrl:(NSString *)url key:(NSString*)key
              withMessage:(NSString *)message
                onSuccess:(void (^)(id))successCallback
                  onError:(void (^)(NSError *))errorCallback
{
    NSMutableDictionary<FBGraphObject> *action = [FBGraphObject graphObject];
    [action setValue:url forKey:key];
    [action setValue:message forKey:@"message"];
    [action setValue:@"true" forKey:@"fb:explicitly_shared"];
    
    [FBRequestConnection startForPostWithGraphPath:@"me/vng_phim:share"
                                       graphObject:action
                                 completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                     if (error) {
                                         errorCallback(error);
                                     } else {
                                         successCallback(result);
                                     }
                                 }];
}


- (void)shareUrl:(NSString *)url
             key:(NSString*)key
       graphPath:(NSString*)graphPath
                 withMessage:(NSString *)message
                withImageUrl:(NSString*)image
                   onSuccess:(void (^)(id))successCallback
                     onError:(void (^)(NSError *))errorCallback
{
    NSMutableDictionary<FBGraphObject>* action = [FBGraphObject graphObject];
    //    [action setValue:cinemaUrl forKey:@"cinema"];
    //    [action setValue:@"http://www.123phim.vn/chi-tiet-rap/21-bhd-cineplex-bhd-star-cineplex-3-2.html" forKey:@"cinema"];
    [action setValue:url forKey:key];
    
    NSDictionary* largeImage1 = [[NSDictionary alloc] initWithObjectsAndKeys: image, @"url", @"true", @"user_generated", nil];
    NSMutableArray* largeImageList = [[NSMutableArray alloc] initWithObjects: largeImage1, nil];
    
    [action setValue:largeImageList forKey:@"image"];
    [action setValue:message forKey:@"message"];
    [action setValue:@"true" forKey:@"fb:explicitly_shared"];
    [FBRequestConnection startForPostWithGraphPath:graphPath graphObject:action completionHandler:^(FBRequestConnection* connection, id result, NSError* error){
        if (error) {
            errorCallback(error);
        }else {
            successCallback(result);
        }
    }];
}

-(void)loginAndGetFacebookInfo
{
    [self loginFacebookWithResponseContext:self selector:@selector(loginFacebookResponse)];
}

-(void) loginFacebookResponse
{
    [self getFacebookAccountInfoWithResponseContext:nil selector:nil];
}

@end
