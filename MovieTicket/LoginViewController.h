//
//  LoginViewController.h
//  MovieTicket
//
//  Created by Nhan Mai on 2/22/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    
}
@property (nonatomic, retain) UITextField* emailTextField;
@property (nonatomic, retain) UITextField* passTextField;
@property (nonatomic, retain) UITableView* table;
@property (nonatomic, retain) NSString* email;
@property (nonatomic, retain) NSString* password;

@property (nonatomic, retain) UIButton* checkbox;
@property (nonatomic) BOOL checkboxSelected;



@end
