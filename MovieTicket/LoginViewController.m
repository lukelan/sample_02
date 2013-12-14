//
//  LoginViewController.m
//  MovieTicket
//
//  Created by Nhan Mai on 2/22/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "FacebookManager.h"
#import "DefineConstant.h"
#import "APIManager.h"
#import "MainViewController.h"

@interface LoginViewController ()


@end

@implementation LoginViewController
@synthesize table, email, password;
@synthesize checkbox, checkboxSelected;
@synthesize emailTextField, passTextField;


- (void)dealloc
{
    [emailTextField release];
    [passTextField release];
    [table release];
    [email release];
    [password release];
    [checkbox release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height - TITLE_BAR_HEIGHT) style:UITableViewStyleGrouped];// - NAVIGATION_BAR_HEIGHT - TAB_BAR_HEIGHT
        table.delegate = self;
        table.dataSource = self;
        email = @"";
        password = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // set navigation left and tittle
    self.navigationController.navigationBar.clipsToBounds = YES;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:@"Đăng nhập"];
//
//    // set navigation right
//    
//    UIImage *imageRight = [UIImage imageNamed:@"join_button.png"];
//    UIButton *customButtonR = [UIButton buttonWithType:UIButtonTypeCustom];
//    customButtonR.frame = CGRectMake(0, 0, imageRight.size.width, imageRight.size.height);;
//    [customButtonR setBackgroundImage:imageRight forState:UIControlStateNormal];
////    [customButtonR setTitle:@"Đăng ký" forState:UIControlStateNormal];
//    [customButtonR addTarget:self action:@selector(handleJoinButton) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc] initWithCustomView:customButtonR];
//    self.navigationItem.rightBarButtonItem = btnRight;
//    [btnRight release];
    self.navigationItem.hidesBackButton = YES;
    [self.view  addSubview:self.table];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* emailId = @"cell0";
    static NSString* passId = @"cell1";
    
    if (0 == indexPath.row) {
        UITableViewCell* emailCell = [tableView dequeueReusableCellWithIdentifier:emailId];
        if (nil == emailCell) {
            emailCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:emailId] autorelease];
            emailCell.selectionStyle = UITableViewCellSelectionStyleNone;
            emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 280, 20)];
            emailTextField.delegate = self;
            emailTextField.placeholder = @"Email hoặc ZingID";
            emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            emailTextField.tag = 0;
            emailTextField.returnKeyType = UIReturnKeyNext;
            emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
            [emailCell.contentView addSubview:emailTextField];
        }
        return emailCell;
    }
    UITableViewCell* passCell = [tableView dequeueReusableCellWithIdentifier:passId];
    if (nil == passCell) {
        passCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:passId] autorelease];
        passCell.selectionStyle = UITableViewCellSelectionStyleNone;
        passTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 280, 20)];
        passTextField.delegate = self;
        passTextField.placeholder = @"Mật khẩu";
        passTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        passTextField.tag = 1;
        passTextField.returnKeyType = UIReturnKeyDone;
        passTextField.secureTextEntry = YES;
        [passCell.contentView addSubview:passTextField];        
    }
    return passCell;
    
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView* retView = [[[UIView alloc] init] autorelease];
    retView.backgroundColor = [UIColor clearColor];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 300, 40)];
    label.numberOfLines = 0;
    label.font = [UIFont fontWithName:@"Helvetica" size:13];
    label.text = @"Đăng nhập để đánh giá và chia sẻ cảm nhận với bạn bè";
    label.backgroundColor = [UIColor clearColor];
    [retView addSubview: label];
    [label release];
    return  retView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 200;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* retView = [[[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 136)] autorelease];
    
    // create remmember checkbox
    checkbox = [[UIButton alloc] initWithFrame:CGRectMake(20,7,20,20)];
    checkbox.backgroundColor = [UIColor clearColor];
    [checkbox setBackgroundImage:[UIImage imageNamed:@"notselectedcheckbox.png"]
                                    forState:UIControlStateNormal];
    [checkbox setBackgroundImage:[UIImage imageNamed:@"selectedcheckbox.png"]
                                    forState:UIControlStateSelected];
    [checkbox setBackgroundImage:[UIImage imageNamed:@"selectedcheckbox.png"]
                                    forState:UIControlStateHighlighted];
    checkbox.adjustsImageWhenHighlighted=YES;
    [checkbox addTarget:self action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    // add text for checkbox
    UILabel* remLabel = [[UILabel alloc] initWithFrame:CGRectMake(checkbox.frame.origin.x+ checkbox.frame.size.width+10, 7, 320, 20)];
    remLabel.backgroundColor = [UIColor clearColor];
    remLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    remLabel.text = @"Ghi nhớ";
    
    
    UIButton* signinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signinButton.frame = CGRectMake(10, checkbox.frame.origin.y + checkbox.frame.size.height+15 , 300, 40);
    [signinButton setBackgroundImage:[UIImage imageNamed:@"sign_in_button.png"] forState:UIControlStateNormal];
    [signinButton addTarget:self action:@selector(handleSignIn) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* or = [[UILabel alloc] initWithFrame:CGRectMake(10, signinButton.frame.origin.y + signinButton.frame.size.height, 300, 44)];
    or.font = [UIFont fontWithName:@"Helvetica" size:13];
    or.backgroundColor = [UIColor clearColor];
    or.textColor = [UIColor grayColor];
    or.text = @"-------------------------------hoặc-------------------------------";
    
    UIButton* facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    facebookButton.frame = CGRectMake(10, or.frame.origin.y + or.frame.size.height, 300, 40);
    [facebookButton setBackgroundImage:[UIImage imageNamed:@"sign_in_facebook_button.png"] forState:UIControlStateNormal];
    [facebookButton addTarget:self action:@selector(handleSignInFacebook) forControlEvents:UIControlEventTouchUpInside];
    [retView addSubview:self.checkbox];
    [retView addSubview:remLabel];
    [retView addSubview:signinButton];
    [retView addSubview:or];
    [retView addSubview:facebookButton];
    [remLabel release];
    [or release];
    return retView;
}

- (void)facebookButtonTouch
{
    
}

-(void)checkboxSelected:(id)sender
{
//    NSLog(@"checkbox touch");
    checkboxSelected = !checkboxSelected;
    [checkbox setSelected:checkboxSelected];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    NSLog(@"textFieldShouldReturn");
    
    if (0 == textField.tag) {
        //focus to pass
        UITableViewCell* cell =  [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        return [[cell.contentView viewWithTag:1] becomeFirstResponder];
    }
    return [textField resignFirstResponder];
}

- (void)handleJoinButton
{
//    NSLog(@"Dang ky");
    
}

- (void)handleSignIn
{
    if(self.emailTextField.text.length < MIN_LENG_ACCOUNT || self.passTextField.text.length < MIN_LENG_ACCOUNT)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Invalid" message:[NSString stringWithFormat:@"username và password phải lớn hơn %d ký tự",MIN_LENG_ACCOUNT] delegate:nil cancelButtonTitle:@"Nhập lại" otherButtonTitles:@"Đồng ý", nil];
        [alert show];
        [alert release];
        return;
    }
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (app.userProfile == nil) {
        app.userProfile = [[UserProfile alloc] init];
    }
    app.userProfile.username = self.emailTextField.text;
    app.userProfile.password = self.passTextField.text;
    [[APIManager sharedMySingleton] getRequestLoginZingAccountWithContext:[MainViewController sharedMySingleton]];
//    [self skipAction];
}

- (void)handleSignInFacebook
{
    FacebookManager *fbHandler = [FacebookManager shareMySingleton];
    [fbHandler loginFacebookWithResponseContext: self selector: @selector(finishGetFacebookAccountInfo:) switchUser: NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)finishGetFacebookAccountInfo: (id<FBGraphUser>) fbUser
{
    if (fbUser)
    {
        NSLog(@"fbUser: %@", fbUser);

        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (app.userProfile == nil) {
            app.userProfile = [[UserProfile alloc] init];
        }
        app.userProfile.facebook_id = [fbUser id];
        app.userProfile.username = [fbUser username];
        app.userProfile.email = [fbUser objectForKey:@"email"];
        app.userProfile.avatar = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?", [fbUser id]];
//        NSLog(@"RetainCount of UserDefautl : %d", [app.userProfile retainCount]);
        [[APIManager sharedMySingleton] getRequestLoginFaceBookAccountWithContext:[MainViewController sharedMySingleton]];
//        [self skipAction];
    }
    else
    {
        NSLog(@"Can not get fb User");
    }
}

@end
