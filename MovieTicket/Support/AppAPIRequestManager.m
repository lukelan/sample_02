//
//  AppAPIRequestManager.m
//  VISIKARD
//
//  Created by Trong Vu on 5/6/13.
//
//

#import "AppAPIRequestManager.h"
#import "AFJSONRequestOperation.h"
#import "SupportFunction.h"
#import "DefineString.h"
#import "DefinePath.h"
#import "DefineConstant.h"

@implementation AppAPIRequestManager

+ (AppAPIRequestManager *)sharedClient {
    static AppAPIRequestManager *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        sharedClient = [[AppAPIRequestManager alloc] initWithBaseURL:[NSURL URLWithString:STRING_REQUEST_ROOT]];
        sharedClient = [[AppAPIRequestManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
        [sharedClient setDefaultSSLPinningMode:AFSSLPinningModeCertificate];
    });
    
    return sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"Accept-Encoding" value:@"gzip"];
    [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(status == AFNetworkReachabilityStatusNotReachable) {
            ALERT(STRING_ALERT_CONNECTION_ERROR_TITLE, STRING_ALERT_CONNECTION_ERROR);
        }
    }];

    
    // By default, the example ships with SSL pinning enabled for the app.net API pinned against the public key of adn.cer file included with the example. In order to make it easier for developers who are new to AFNetworking, SSL pinning is automatically disabled if the base URL has been changed. This will allow developers to hack around with the example, without getting tripped up by SSL pinning.
    if ([[url scheme] isEqualToString:@"https"]) {
        [self setDefaultSSLPinningMode:AFSSLPinningModeCertificate];
    }
    
    return self;
}

#pragma mark - AppAPIRequestManager operations

#pragma mark operationWithType
// Wrapper old API to call New API with failure Block
- (AFHTTPRequestOperation *)operationWithType:(ENUM_API_REQUEST_TYPE)type andPostMethodKind:(BOOL)methodKind andParams:(NSMutableDictionary *)params update:(BOOL)update inView:(UIView *)view isQueued:(BOOL)queue andSimultaneous:(BOOL)simultaneous completeBlock:(void (^)(id responseObject))block
{
    AFHTTPRequestOperation *operation = nil;
    operation = [self operationWithType:type andPostMethodKind:methodKind andParams:params update:update inView:view isQueued:queue andSimultaneous:simultaneous completeBlock:block failureBlock:nil];
    return operation;
}

- (AFHTTPRequestOperation *)operationWithType:(ENUM_API_REQUEST_TYPE)type andPostMethodKind:(BOOL)methodKind andParams:(NSMutableDictionary *)params update:(BOOL)update inView:(UIView *)view isQueued:(BOOL)queue andSimultaneous:(BOOL)simultaneous completeBlock:(void (^)(id responseObject))block failureBlock:(void (^)(NSError *error))failureBlock
{
    if (!simultaneous) {
        NSLog(@"Cancel operation");
        [self cancelAllOperations];
    }
    NSString *path = nil;
    AFHTTPRequestOperation *operation;
    switch (type) {
        case ENUM_API_REQUEST_TYPE_GET_LIST_CINEMA_BY_LOCATION:
        {
            path = [NSString  stringWithFormat:@"%@%@", STRING_REQUEST_URL_GET_LIST_CINEMA_BY_LOCATION, [params objectForKey:@"location_id"]] ;
            [self executedOperation:params path:path methodKind:methodKind block:block failureBlock:failureBlock view:view type:type operation_p:&operation queue:queue];
            break;
        }
        case ENUM_API_REQUEST_TYPE_SEND_LOG_CINEMA:
        {
            path = [NSString  stringWithFormat:@"%@%@", STRING_REQUEST_URL_POST_LOG, [params objectForKey:@"paramStr"]] ;
            [self executedOperation:params path:path methodKind:methodKind block:block failureBlock:failureBlock view:view type:type operation_p:&operation queue:queue];
            break;
        }
            
        default:
            break;
    }

    return operation;
}

// Wrapper old API to call new API with nil failureBlock
# pragma mark operationWithType and PATH
- (AFHTTPRequestOperation *)operationWithType:(ENUM_API_REQUEST_TYPE)type andPath:(NSString *)path andPostMethodKind:(BOOL)methodKind andParams:(NSMutableDictionary *)params update:(BOOL)update inView:(UIView *)view isQueued:(BOOL)queue andSimultaneous:(BOOL)simultaneous completeBlock:(void (^)(id responseObject))block
{
    AFHTTPRequestOperation *operation = nil;
    operation = [self operationWithType:type andPath:path andPostMethodKind:methodKind andParams:params  update:update inView:view isQueued:queue andSimultaneous:simultaneous completeBlock:block failureBlock:nil];
    return operation;
}

- (AFHTTPRequestOperation *)operationWithType:(ENUM_API_REQUEST_TYPE)type andPath:(NSString *)path andPostMethodKind:(BOOL)methodKind andParams:(NSMutableDictionary *)params update:(BOOL)update inView:(UIView *)view isQueued:(BOOL)queue andSimultaneous:(BOOL)simultaneous completeBlock:(void (^)(id responseObject))block failureBlock:(void (^)(NSError *error))failureBlock
{
    if (!simultaneous) {
        NSLog(@"Cancel operation");
        [self cancelAllOperations];
    }
    
    AFHTTPRequestOperation *operation = nil;
    NSURLRequest *request;
    
    if (!methodKind) {
        request = [self requestWithMethod:@"GET" path:path parameters:params];
    } else {
        request = [self requestWithMethod:@"POST" path:path parameters:params];
    }
    
    operation = [self constructOperationwithType:type andRequest:request inView:view completeBlock:block failureBlock:failureBlock];
    if (operation != nil) {
        if (queue) return operation;
        [self enqueueHTTPRequestOperation:operation];
    }
 
    return operation;
}


#pragma mark operationMultipartWithType
- (AFHTTPRequestOperation *)operationMultipartWithType:(ENUM_API_REQUEST_TYPE)type andPostMethodKind:(BOOL)methodKind andValues:(NSArray *)values andKeys:(NSArray *)keys update:(BOOL)update inView:(UIView *)view isQueued:(BOOL)queue andSimultaneous:(BOOL)simultaneous completeBlock:(void (^)(id))block
{
    AFHTTPRequestOperation *operation = nil;
    operation = [self operationMultipartWithType:type andPostMethodKind:methodKind andValues:values andKeys:keys update:update inView:view isQueued:queue andSimultaneous:simultaneous completeBlock:block failureBlock:nil];
    return operation;
}

- (AFHTTPRequestOperation *)operationMultipartWithType:(ENUM_API_REQUEST_TYPE)type andPostMethodKind:(BOOL)methodKind andValues:(NSArray *)values andKeys:(NSArray *)keys update:(BOOL)update inView:(UIView *)view isQueued:(BOOL)queue andSimultaneous:(BOOL)simultaneous completeBlock:(void (^)(id responseObject))block failureBlock:(void (^)(NSError *error))failureBlock
{
    if (!simultaneous) {
        [self cancelAllOperations];
    }
//    NSString *path = nil;
    AFHTTPRequestOperation *operation = nil;
    switch (type) {
            // sample multipart request
//        case ENUM_API_REQUEST_TYPE_UPLOAD:
//        {
//            path = STRING_REQUEST_URL_UPLOAD;
//            [self executeMultipartOperation:keys values:values path:path methodKind:methodKind block:block failureBlock:failureBlock view:view type:type operation_p:&operation queue:queue];
//            break;
//        }
         
        default:
            break;
    }

    return operation;
}

# pragma mark - helper
- (void)executedOperation:(NSMutableDictionary *)params path:(NSString *)path methodKind:(BOOL)methodKind block:(void (^)(id))block failureBlock:(void (^)(id))blockFailure
                     view:(UIView *)view type:(ENUM_API_REQUEST_TYPE)type operation_p:(AFHTTPRequestOperation **)operation_p queue:(BOOL)queue
{
    path = [self getFullLinkAPI:path];
    NSURLRequest *request;
    if (!methodKind) {
        request = [self requestWithMethod:@"GET" path:path parameters:params];
    } else request = [self requestWithMethod:@"POST" path:path parameters:params];
    *operation_p = [self constructOperationwithType:type andRequest:request inView:view completeBlock:block failureBlock:blockFailure];
    if (!queue) [self enqueueHTTPRequestOperation:*operation_p];
}

- (void)executeMultipartOperation:(NSArray *)keys values:(NSArray *)values path:(NSString *)path methodKind:(BOOL)methodKind block:(void (^)(id))block failureBlock:(void (^)(id))blockFailure view:(UIView *)view type:(ENUM_API_REQUEST_TYPE)type operation_p:(AFHTTPRequestOperation **)operation_p queue:(BOOL)queue
{
    NSMutableURLRequest *request;
    if (!methodKind) {
        request = [self multipartFormRequestWithMethod:@"GET" path:path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [self appendMultipartFormData:formData withValues:values andKeys:keys];
        }];
        request.timeoutInterval = TIMER_REQUEST_UPLOAD_TIMEOUT;
    } else {
        request = [self multipartFormRequestWithMethod:@"POST" path:path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [self appendMultipartFormData:formData withValues:values andKeys:keys];
        }];
        request.timeoutInterval = TIMER_REQUEST_UPLOAD_TIMEOUT;
    }
    *operation_p = [self constructOperationwithType:type andRequest:request inView:view completeBlock:block failureBlock:blockFailure];
    if (!queue) [self enqueueHTTPRequestOperation:*operation_p];
}


- (AFHTTPRequestOperation *)constructOperationwithType:(ENUM_API_REQUEST_TYPE)type andRequest:(NSURLRequest *)request inView:(UIView *)view completeBlock:(void (^)(id))block failureBlock:(void (^)(id))blockFailure
{
    
    AFHTTPRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    operation.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:type]] forKeys:@[@"type"]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (block) {
            block(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {        
        NSLog(@"%@ %@",operation.responseString,error);
        
        if (blockFailure) {
            blockFailure(operation.responseString);
        }
        
    }];
    return operation;
}

- (AFHTTPRequestOperation *)constructOperationForGetMethodNoParamsWithType:(ENUM_API_REQUEST_TYPE)type andPath:(NSString *)path inView:(UIView *)view isQueued:(BOOL)queue completeBlock:(void (^)(id))block failureBlock:(void (^)(id))blockFailure

{
    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
    AFHTTPRequestOperation *operation = [self constructOperationwithType:type andRequest:request inView:view completeBlock:block failureBlock:blockFailure];
    if (operation != nil) {
        if (queue) return operation;
        [self enqueueHTTPRequestOperation:operation];
    }
    return operation;
}

- (void)cancelAllOperations
{
    if (self.operationQueue.operations.count > 0) {
        [self.operationQueue cancelAllOperations];  
    }
}

- (void)startQueue:(NSArray *)operations inView:(UIView *)view completionBlock:(void(^)(id))block
{
    
    [self enqueueBatchOfHTTPRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"NumberOfFinished: %d",numberOfFinishedOperations);
    } completionBlock:^(NSArray *operations) {
        if (block) {
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    block(operations);
            });
        }
    }];
}

- (void)appendMultipartFormData:(id<AFMultipartFormData>) formData withValues:(NSArray *)values andKeys:(NSArray*)keys
{
    // Formdata append
    if (values) {
        for (int i = 0; i < values.count; i++) {
            id object = [values objectAtIndex:i];
            if ([object isKindOfClass:[NSData class]]) {
                [formData appendPartWithFileData:object name:@"media" fileName:@"uploadPhoto" mimeType:@"image/jpeg"];
            }
            else {
                if ([object respondsToSelector:@selector(dataUsingEncoding:)]) {
                    [formData appendPartWithFormData:[object dataUsingEncoding:NSUTF8StringEncoding] name:[keys objectAtIndex:i]];
                } else if ([object isKindOfClass:[NSNumber class]]) {
                    [formData appendPartWithFormData:[[object stringValue] dataUsingEncoding:NSUTF8StringEncoding] name:[keys objectAtIndex:i]];
                }
            }
        }
    }
}

-(NSString *)getFormatAuthentication
{
    return [NSString stringWithFormat:@"sig=%@&ts=%0.0f",[[NSString stringWithFormat:@"%@%0.0f",MAPP_KEY,[NSDate timeIntervalSinceReferenceDate]] stringFromMD5],[NSDate timeIntervalSinceReferenceDate]];
}


- (NSString *)getFullLinkAPI:(NSString *)url
{
    NSString *pathURL = [NSString stringWithFormat:@"%@&%@",url, [self getFormatAuthentication]];
    return pathURL;
}
@end
