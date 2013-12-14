//
//  ProfileTableViewCell.m
//  123Phim
//
//  Created by phuonnm on 5/24/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "ProfileTableViewCell.h"
#import "AppDelegate.h"
#import "FacebookManager.h"

#import "APIManager.h"

extern BOOL _isBeingLogin;

@implementation ProfileTableViewCell

@synthesize text = _text;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(beginLoadFacebookAccount:) name:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_BEGIN_LOGIN object:nil];
        [center addObserver:self selector:@selector(didLoginFacebookFail:) name:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_DID_LOGIN_FAIL object:nil];
        [center addObserver:self selector:@selector(didLoadFacebookAvatar:) name:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_DID_LOAD_AVATAR object:nil];
        [center addObserver:self selector:@selector(didLogoutFacebook:) name:NOTIFICATION_NAME_FACEBOOK_ACCOUNT_INFO_DID_DID_LOGOUT object:nil];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(BOOL) isNeedLayout
{
    if (_currentStatus == 0)
    {
        _currentStatus = 1;
        return YES;
    }
    NSInteger newStatus = 0;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([delegate isUserLoggedIn])
    {
        newStatus = 3;
    }
    else if (_isBeingLogin)
    {
        newStatus = 2;
    }
    if (newStatus != _currentStatus)
    {
        _currentStatus = newStatus;
        return YES;
    }
    return NO;
}

-(void) layoutIfNeeded
{
    [super layoutIfNeeded];
    if (![self isNeedLayout])
    {
        return;
    }
    if (self.contentView.subviews.count > 0)
    {
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([delegate isUserLoggedIn])
    {
        SDImageView* avatarView = [[SDImageView alloc] initWithFrame:CGRectMake(MARGIN_EDGE_TABLE_GROUP, MARGIN_EDGE_TABLE_GROUP, 55, 55)];
        avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
        avatarView.layer.borderWidth = 2.0;
        avatarView.layer.shadowColor = [UIColor grayColor].CGColor;
        avatarView.layer.shadowOffset = CGSizeMake(1, 1);
        avatarView.layer.masksToBounds = NO;
        avatarView.layer.shadowOpacity = 15.0;
        [avatarView setImage: delegate.userProfile.avatarImage];
        
        UILabel* userName = [[UILabel alloc] initWithFrame:CGRectMake(2 * MARGIN_EDGE_TABLE_GROUP + avatarView.frame.size.width, 15, 200, 20)];
        userName.backgroundColor = [UIColor clearColor];
        userName.font = [UIFont getFontBoldSize15];
        userName.text = delegate.userProfile.name;
        
        UILabel* userEmail = [[UILabel alloc] initWithFrame:CGRectMake(userName.frame.origin.x, userName.frame.origin.y+18, 200, 20)];
        userEmail.backgroundColor = [UIColor clearColor];
        userEmail.font = [UIFont getFontNormalSize15];
        userEmail.textColor = [UIColor blueColor];
        userEmail.text = delegate.userProfile.email;
        
        [self.contentView addSubview:avatarView];
        [self.contentView addSubview:userName];
        [self.contentView addSubview:userEmail];
    }
    else
    {
        if (_isBeingLogin)
        {    
            UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicatorView.frame = CGRectMake(140, (PROFILE_CELL_NOT_LOAD_HEIGHT - 24) / 2, 24, 24);
            [indicatorView startAnimating];
            [self.contentView addSubview:indicatorView];
        }
        else
        {
            UIImage* loginImage = [UIImage imageNamed:@"facebook-login-button.png"];
            UILabel *mainText = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_EDGE_TABLE_GROUP, 0 , self.contentView.frame.size.width - 5*MARGIN_EDGE_TABLE_GROUP - loginImage.size.width, PROFILE_CELL_NOT_LOAD_HEIGHT)];
            mainText.backgroundColor = [UIColor clearColor];
            mainText.font = [UIFont getFontNormalSize13];
            mainText.text = _text;
            mainText.numberOfLines = 0;
            mainText.textAlignment = UITextAlignmentLeft;
            [self.contentView addSubview:mainText];
            
            UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 3 *MARGIN_EDGE_TABLE_GROUP - loginImage.size.width, (PROFILE_CELL_NOT_LOAD_HEIGHT - loginImage.size.height)/2, loginImage.size.width, loginImage.size.height)];
            loginButton.backgroundColor = [UIColor clearColor];
            [loginButton setBackgroundImage:loginImage forState:UIControlStateNormal];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSignInFacebook)];
            [loginButton addGestureRecognizer:tapGesture];
//            [loginButton addTarget:self action:@selector(handleSignInFacebook) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:loginButton];
        }
    }
}

- (void)handleSignInFacebook
{
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:delegate.currentView
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_LOG_IN
                                                     currentFilmID:[NSNumber numberWithInt:NO_FILM_ID]
                                                   currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID]
                                                   returnCodeValue:0 context:nil];
    
    FacebookManager *fbManager = [FacebookManager shareMySingleton];
    [fbManager loginAndGetFacebookInfo];
    [self layoutIfNeeded];
}

-(void)beginLoadFacebookAccount:(NSNotification*) notificationInfo
{
    _isBeingLogin = YES;
    [self layoutIfNeeded];
}

-(void)didLoadFacebookAvatar:(NSNotification*) notificationInfo
{
    [self layoutIfNeeded];
}

-(void)didLoginFacebookFail:(NSNotification*) notificationInfo
{
    _isBeingLogin = NO;
    [self layoutIfNeeded];
}

-(void)didLogoutFacebook:(NSNotification*) notificationInfo
{
    _isBeingLogin = NO;
    [self layoutIfNeeded];
}

-(void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

@end
