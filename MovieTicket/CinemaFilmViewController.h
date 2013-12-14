//
//  CinameFilmView.h
//  MovieTicket
//
//  Created by Nhan Ho Thien on 1/11/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "ASIHTTPRequestDelegate.h"
#import "CinemaWithDistance.h"
#import "GAI.h"
#import "ShowMapViewController.h"
#import "CinemaInfoCell.h"
#import "APIManager.h"
@interface CinemaFilmViewController : CustomGAITrackedViewController<UITableViewDataSource,UITableViewDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate, APIManagerDelegate, CinemaSessionDelegate>{
    BOOL wifiOn;
    ASIHTTPRequest *httpRequest;
}
@property (nonatomic, strong) NSMutableArray *arrFilmSessionTime;
@property (nonatomic,strong) CinemaWithDistance *curCinemaDistance;
@property (nonatomic,weak) IBOutlet UITableView *filmTableView;
@property (nonatomic,strong) News *news;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@end
