//
//  AppAPIRequestManager.h
//  VISIKARD
//
//  Created by Trong Vu on 5/6/13.
//
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

typedef enum
{
    ENUM_API_REQUEST_TYPE_GET_LIST_CINEMA_BY_LOCATION,
    ENUM_API_REQUEST_TYPE_SEND_LOG_CINEMA

}ENUM_API_REQUEST_TYPE;


@interface AppAPIRequestManager : AFHTTPClient

+ (AppAPIRequestManager *)sharedClient;


# pragma mark - operationWithType 
// Should use this method with failure Block
- (AFHTTPRequestOperation *)operationWithType:(ENUM_API_REQUEST_TYPE)type andPostMethodKind:(BOOL)methodKind andParams:(NSMutableDictionary *)params update:(BOOL)update inView:(UIView *)view isQueued:(BOOL)queue andSimultaneous:(BOOL)simultaneous completeBlock:(void (^)(id responseObject))block failureBlock:(void (^)(NSError *error))failureBlock;

- (AFHTTPRequestOperation *)operationWithType:(ENUM_API_REQUEST_TYPE)type andPostMethodKind:(BOOL)methodKind andParams:(NSMutableDictionary *)params update:(BOOL)update inView:(UIView *)view isQueued:(BOOL)queue andSimultaneous:(BOOL)simultaneous completeBlock:(void (^)(id responseObject))block;

# pragma mark - operationMultipartWithType
- (AFHTTPRequestOperation *)operationMultipartWithType:(ENUM_API_REQUEST_TYPE)type andPostMethodKind:(BOOL)methodKind andValues:(NSArray *)values andKeys:(NSArray *)keys update:(BOOL)update inView:(UIView *)view isQueued:(BOOL)queue andSimultaneous:(BOOL)simultaneous completeBlock:(void (^)(id responseObject))block;
- (AFHTTPRequestOperation *)operationMultipartWithType:(ENUM_API_REQUEST_TYPE)type andPostMethodKind:(BOOL)methodKind andValues:(NSArray *)values andKeys:(NSArray *)keys update:(BOOL)update inView:(UIView *)view isQueued:(BOOL)queue andSimultaneous:(BOOL)simultaneous completeBlock:(void (^)(id responseObject))block failureBlock:(void (^)(NSError *error))failureBlock;

# pragma mark - operationWithType and PATH
// Should use this method with failure Block
- (AFHTTPRequestOperation *)operationWithType:(ENUM_API_REQUEST_TYPE)type andPath:(NSString *)path andPostMethodKind:(BOOL)methodKind andParams:(NSMutableDictionary *)params update:(BOOL)update inView:(UIView *)view isQueued:(BOOL)queue andSimultaneous:(BOOL)simultaneous completeBlock:(void (^)(id responseObject))block failureBlock:(void (^)(NSError *error))failureBlock;

- (AFHTTPRequestOperation *)operationWithType:(ENUM_API_REQUEST_TYPE)type andPath:(NSString *)path andPostMethodKind:(BOOL)methodKind andParams:(NSMutableDictionary *)params update:(BOOL)update inView:(UIView *)view isQueued:(BOOL)queue andSimultaneous:(BOOL)simultaneous completeBlock:(void (^)(id responseObject))block;

# pragma mark - helper
- (void)startQueue:(NSArray *)queues inView:(UIView *)view completionBlock:(void(^)(id))block;
- (void)cancelAllOperations;


@end
