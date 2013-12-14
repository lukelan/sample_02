//
//  ShareTemplateViewController.h
//  123Phim
//
//  Created by Phuc Phan on 3/13/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#define CELL_SMS 0
#define CELL_EMAIL 1
#define CELL_FACEBOOK 2

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "GAI.h"

@interface ShareTemplateViewController : CustomGAITrackedViewController<UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) Film *film;
@property (nonatomic, strong) NSString *navTitle;
@property (nonatomic) NSInteger source;

@end
