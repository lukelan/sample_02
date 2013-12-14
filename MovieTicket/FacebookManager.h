//
//  FacebookManger.h
//  123Phim
//
//  Created by phuonnm on 3/11/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "FacebookHandler.h"
#import "Film.h"
#import "Cinema.h"
#import "Ticket.h"
#import "Event.h"

@interface FacebookManager : FacebookHandler

- (void) shareFilm:(Film *)film withMessage:(NSString *)message;
- (void) shareFilm:(Film *)film
       withMessage:(NSString *)message
         onSuccess:(void (^) (id))successCallback
           onError:(void (^) (NSError *))errorCallback;
- (void)shareFilmWithUrl:(NSString *)filmUrl
             withMessage:(NSString *)message
               onSuccess:(void (^)(id))successCallback
                 onError:(void (^)(NSError *))errorCallback;

- (void) checkInCinema:(Cinema *)cinema withMessage:(NSString *)message withImageUrl:(NSString*)image;
- (void) checkInCinema:(Cinema *)cinema
           withMessage:(NSString *)message
          withImageUrl:(NSString*)image
             onSuccess:(void (^) (id))successCallback
               onError:(void (^) (NSError *))errorCallback;
- (void)checkInCinemaWithUrl:(NSString *)cinemaUrl
                 withMessage:(NSString *)message
                withImageUrl:(NSString*)image
                   onSuccess:(void (^)(id))successCallback
                     onError:(void (^)(NSError *))errorCallback;

- (void) buyTicket:(Ticket *)ticket withMessage:(NSString *)message;
- (void) buyTicket:(Ticket *)ticket
           withMessage:(NSString *)message
             onSuccess:(void (^) (id))successCallback
               onError:(void (^) (NSError *))errorCallback;
- (void)buyTicketWithUrl:(NSString *)ticketUrl
                 withMessage:(NSString *)message
                   onSuccess:(void (^)(id))successCallback
                     onError:(void (^)(NSError *))errorCallback;
- (void)shareEvent:(Event *)event withMessage:(NSString *)message;
- (void)shareEvent:(Event *)event
       withMessage:(NSString *)message
         onSuccess:(void (^)(id))successCallback
           onError:(void (^)(NSError *))errorCallback;
- (void)shareEventWithUrl:(NSString *)eventUrl
              withMessage:(NSString *)message
                onSuccess:(void (^)(id))successCallback
                  onError:(void (^)(NSError *))errorCallback;

- (void)shareUrl:(NSString *)url
              key:(NSString*)key
      withMessage:(NSString *)message
        onSuccess:(void (^)(id))successCallback
          onError:(void (^)(NSError *))errorCallback;

- (void)shareUrl:(NSString *)url
             key:(NSString*)key
       graphPath:(NSString*)graphPath
     withMessage:(NSString *)message
    withImageUrl:(NSString*)image
       onSuccess:(void (^)(id))successCallback
         onError:(void (^)(NSError *))errorCallback;

- (void)loginAndGetFacebookInfo;

@end
