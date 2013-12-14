//
//  FBMessageView.h
//  123Phim
//
//  Created by phuonnm on 6/17/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Film.h"

@interface FBMessageView : UIView <UITextViewDelegate>

@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, strong) NSString *filmUrl;
@property (nonatomic, strong) NSString *defaultString;

@end
