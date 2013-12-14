//
//  FaceBookHandler.m
//  123Phim
//
//  Created by phuonnm on 3/6/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "FacebookHandler.h"
#import "AppDelegate.h"

@implementation FacebookHandler

static FacebookHandler* _sharedMyFacebookHandler = nil;

+ (FacebookHandler *)shareMySingleton
{
    if(_sharedMyFacebookHandler != nil)
    {
        return _sharedMyFacebookHandler;
    }
    static dispatch_once_t _single_thread;//block thread
    dispatch_once(&_single_thread, ^ {
        _sharedMyFacebookHandler = [[super allocWithZone:nil] init];
    });//This code is called most once.
    return _sharedMyFacebookHandler;
}

- (BOOL)initFacebookSession
{
    if (FBSession.activeSession.isOpen) {
        
        return YES;
    }
    
    NSArray *permission = [[[NSArray alloc] initWithObjects:@"publish_stream", @"email", nil] autorelease];
    FBSession *fbSession = [[FBSession alloc] initWithPermissions:permission];
    
    [FBSession setActiveSession:fbSession];
    [fbSession release];
    [FBSession openActiveSessionWithAllowLoginUI:NO];
    
    if (FBSession.activeSession.isOpen) {
        
        return YES;
    }
    
    return NO;
}


// working
- (void)loginFacebook:(id)context selector:(SEL)selector
{
    if ([self initFacebookSession]) {
        
        if (context && [context respondsToSelector:selector])
        {
            [context performSelector:selector withObject:FBSession.activeSession];
        }
        return;
    }

    [FBSession.activeSession openWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView
                            completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                
                                if (error)
                                {
                                    if (context && [context respondsToSelector:selector])
                                    {
                                        [context performSelector:selector withObject:nil];
                                    }
                                    
                                } else {
                                    
                                    if (status == FBSessionStateOpen)
                                    {
                                        if (context && [context respondsToSelector:selector])
                                        {
                                            [context performSelector:selector withObject:session];
                                        }
                                        
                                    } else
                                    {   
                                        [FBSession setActiveSession:nil];
                                    }
                                }
                            }];
}

- (void)loginFacebookWithResponseContext:(id)context selector:(SEL)selector switchUser:(BOOL)switchUser getUserInfo: (BOOL) getUserInfo
{
    if ([self initFacebookSession]) {
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_DID_LOGIN object:nil];
        if (getUserInfo)
        {
            [self getFacebookAccountInfoWithResponseContext:context selector:selector];
        }
        else
        {
            if (context && [context respondsToSelector:selector])
            {
                [context performSelector:selector withObject:nil];
            }
            [self getFacebookAccountInfoWithResponseContext:nil selector:nil];
        }
        return;
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_BEGIN_LOGIN object:nil];
    FBSessionLoginBehavior behavior = switchUser ?
        FBSessionLoginBehaviorForcingWebView : FBSessionLoginBehaviorWithFallbackToWebView;
//    behavior = FBSessionLoginBehaviorUseSystemAccountIfPresent;
//    behavior = FBSessionLoginBehaviorWithNoFallbackToWebView;
//    behavior = FBSessionLoginBehaviorForcingWebView;

    [FBSession.activeSession openWithBehavior:behavior
                            completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if (error)
        {
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_DID_LOGIN_FAIL object:error];
            if (context && [context respondsToSelector:selector])
            {
                [context performSelector:selector withObject:error];
            }
        } else {
            
            if (status == FBSessionStateOpen) {
                if (context && [context respondsToSelector:selector])
                {
                    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                    [center postNotificationName:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_DID_LOGIN object:nil];
                    if (getUserInfo)
                    {
                        [self getFacebookAccountInfoWithResponseContext:context selector:selector];
                    }
                    else
                    {
                        if (context && [context respondsToSelector:selector])
                        {
                            [context performSelector:selector withObject:nil];
                        }
                        [self getFacebookAccountInfoWithResponseContext:nil selector:nil];
                    }
                }
            
            } else {
                
                [FBSession setActiveSession:nil];
            }
        }
    }];
}

- (void)loginFacebookWithResponseContext:(id)context selector:(SEL)selector
{
    [self loginFacebookWithResponseContext:context selector:selector switchUser:NO getUserInfo:NO];
}

- (void)getFacebookAccountInfoWithResponseContext:(id)context selector:(SEL)selector
{
    if (!FBSession.activeSession.isOpen) {
        
        [self setUserProfile:nil withResponseContext:context selector:selector];
        return;
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_BEGIN_GET_INFO object:nil];
    FBRequestConnection *fbConnection = [[FBRequestConnection alloc] initWithTimeout:20.0];
    [fbConnection addRequest:[FBRequest requestForMe] completionHandler:
     ^(FBRequestConnection *connection, id<FBGraphUser> userInfo, NSError *error)
     {
         LOG_123PHIM(@"End login facebook");
         if (error)
         {
             userInfo = nil;
         }
         
         [self setUserProfile:userInfo withResponseContext:context selector:selector];
     }];
    [fbConnection start];
    [fbConnection release];
}

- (void)setUserProfile:(id<FBGraphUser>)userInfo withResponseContext:(id)context selector:(SEL)selector
{
//    LOG_123PHIM(@"Set user profile");
    if (userInfo == nil) {
        if (context && [context respondsToSelector:selector])
        {
            [context performSelector:selector withObject:nil withObject:nil];
        }
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_DID_LOAD_FAIL object:nil];
        return;
    }

    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (delegate.userProfile == nil) {
        
        delegate.userProfile = [[[UserProfile alloc] init] autorelease];
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    delegate.userProfile.name = [userInfo name];
    delegate.userProfile.avatar = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", [userInfo id]];
    delegate.userProfile.username = [userInfo username];
    //set cho truong hop nhung email bao mat khong lay ve duoc
    NSString *emailData = [userInfo objectForKey:@"email"];
    if (!emailData || ![emailData isKindOfClass:[NSString class]] || emailData.length == 0) {
        delegate.userProfile.email = [NSString stringWithFormat:@"%@@facebook.com", delegate.userProfile.username];
    } else {
        delegate.userProfile.email = emailData;
    }
    delegate.userProfile.facebook_id = [userInfo id];
    if (context && [context respondsToSelector:selector])
    {
        [context performSelector:selector withObject:userInfo withObject:delegate.userProfile];
    }
    
    [center postNotificationName:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_DID_LOAD_SUCCESFUL object:delegate.userProfile];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString:delegate.userProfile.avatar] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:25.0];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData *data, NSError *error) {
        delegate.userProfile.avatarImage = [[[UIImage alloc] initWithData:data] autorelease];
        [center postNotificationName:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_DID_LOAD_AVATAR object:delegate.userProfile];
    }];
    [request release];
}

-(void)logout
{
    if ([[FBSession activeSession] isOpen])
    {
        [[FBSession activeSession] closeAndClearTokenInformation];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_DID_DID_LOGOUT object:nil];
    }
}

@end
