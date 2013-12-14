//
//  FBMessageView.m
//  123Phim
//
//  Created by phuonnm on 6/17/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "FBMessageView.h"
#import "MainViewController.h"
#import "FacebookManager.h"

@interface FBMessageView ()
{
    UITextView *messageTextView;
    UIAlertView *alert;
    UIButton *sendButton;
    UIBarButtonItem *bkButton;
}
@end

@implementation FBMessageView
@synthesize defaultString = _defaultString;
@synthesize filmUrl = _filmUrl;


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

#pragma mark textField delegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0) {
        sendButton.enabled = YES;
    } else {
        sendButton.enabled = NO;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UIImage *imageRight = [UIImage imageNamed:@"button-60x30"];
    UIButton *customButtonR = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(220, 7, imageRight.size.width, imageRight.size.height);
    customButtonR.frame = frame;
    customButtonR.titleLabel.font = [UIFont getFontBoldSize12];
    customButtonR.layer.opacity = 0;
    customButtonR.tag = 300;
    [customButtonR setTitle:@"Cancel" forState:UIControlStateNormal];
    [customButtonR setBackgroundImage:imageRight forState:UIControlStateNormal];
    [customButtonR addTarget:self action:@selector(cancelShareClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc] initWithCustomView:customButtonR];
    bkButton = self.controller.navigationItem.rightBarButtonItem;
    self.controller.navigationItem.rightBarButtonItem = btnRight;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return  YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return  YES;
}

- (void)cancelShareClick
{
    self.controller.navigationItem.rightBarButtonItem = bkButton;
    [messageTextView resignFirstResponder];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect frame = self.frame;
        frame.origin.x = 320;
        frame.origin.y = - frame.size.height;
        self.frame = frame;
    } completion:^(BOOL finished) {
         [self removeFromSuperview];
    }];
}

-(void)sendButtonClick
{
    NSString *message = messageTextView.text;
    if (message.length > 0)
    {
        [self shareViaFacebook:message];
    }
}

- (void)initMessageInputView
{
    self.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
    UIImage *commentBoxImage = [UIImage imageNamed:@"comment_box_full"];
    CGFloat tvcmtHeight = commentBoxImage.size.height;
    CGFloat tvcmtWidth = commentBoxImage.size.width;
    messageTextView = [[UITextView alloc] initWithFrame:CGRectMake((self.frame.size.width - tvcmtWidth ) / 2, (self.frame.size.width - tvcmtWidth ) / 2, tvcmtWidth, tvcmtHeight)];
    messageTextView.clipsToBounds = NO;
    messageTextView.contentInset = UIEdgeInsetsMake(-4, -4, -4, -4);
    messageTextView.delegate = self;
    messageTextView.textColor = [UIColor blackColor];
    messageTextView.layer.masksToBounds = YES;
    messageTextView.keyboardType = UIKeyboardTypeDefault;
    messageTextView.font = [UIFont getFontNormalSize13];
    [messageTextView setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *tvView = [[UIImageView alloc] initWithImage:commentBoxImage];
    tvView.frame = messageTextView.frame;
    
    // addview
    [self addSubview:tvView];
    [self addSubview:messageTextView];
    
    // send button
    UIImage *sendImage = [UIImage imageNamed:@"send"];
    CGRect sendFrame = messageTextView.frame;
    sendFrame.size = sendImage.size;
    sendFrame.origin.x = messageTextView.frame.size.width  - sendFrame.size.width;
    sendFrame.origin.y = messageTextView.frame.size.height - sendFrame.size.height;
    
    sendButton = [[UIButton alloc] initWithFrame:sendFrame];
    sendButton.enabled = NO;
    [sendButton setBackgroundImage:sendImage forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    // addview
    [messageTextView addSubview:sendButton];
    if (_defaultString && _defaultString.length > 0)
    {
        [messageTextView setText:_defaultString];
        sendButton.enabled = YES;
    }
    [messageTextView becomeFirstResponder];
}

- (void)showAlertSharing:(NSString *)message
{
    alert = [[UIAlertView alloc] initWithTitle:@"123Phim" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    ((UIView *)[alert viewWithTag:1]).hidden = YES;
    alert.tag = 101;
    [alert show];
}

- (void)showAlertDone:(NSString *)message
{
//    isFinishShare = YES;
//    isSharing = NO;
    
    if (alert)
    {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    }
    
//    if (!isCancelShare)
    {
        alert = [[UIAlertView alloc] initWithTitle:@"123Phim" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        alert.tag = 102;
        [alert show];
    }
//    else {
//        isCancelShare = NO;
//    }
    
}

- (void)showAlertFail:(NSString *)message
{    
    alert.tag = 103;
    alert.message = message;
    ((UIButton *)[alert viewWithTag:1]).hidden = NO;
    [((UIButton *)[alert viewWithTag:1]) setTitle:@"Close" forState:UIControlStateNormal];
    [((UIButton *)[alert viewWithTag:1]) setTitle:@"Close" forState:UIControlStateSelected];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [self cancelShareClick];
}

- (void)closeAlertDone
{
    if (alert && alert.tag == 102) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        //        [self backToFilmDetailView];
    }
}

- (void)shareViaFacebook:(NSString *)message
{
    self.userInteractionEnabled = NO;
    
    [self showAlertSharing:@"Đang chia sẻ..."];
    
    FacebookManager *fbManager = [FacebookManager shareMySingleton];
    
    [fbManager shareFilmWithUrl:self.filmUrl withMessage:message onSuccess:^(id result) {
        [self showAlertDone:@"Bạn đã chia sẻ thành công."];
    } onError:^(NSError *error) {
        [self showAlertFail:@"Chia sẻ không thành công."];
    }];
}

-(void) willMoveToWindow:(UIWindow *)newWindow
{
    if (newWindow)
    {
        [self initMessageInputView];
    }
}


@end

