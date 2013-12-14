//
//  ImageIconViewController.h
//  MovieTicket
//
//  Created by Nhan Mai on 3/1/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Film.h"
#import "AppDelegate.h"
#import "APIManager.h"
#import "CustomGAITrackedViewController.h"

@interface ImageIconViewController : CustomGAITrackedViewController<APIManagerDelegate>
{
    ASIHTTPRequest *httpRequest;
}

@property (nonatomic, strong) Film *film;
@property (nonatomic, strong) NSArray* listOfImageURL;
@property (nonatomic, strong) NSMutableArray* listOfOrigionImage;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSString* filmTitle;

@property (nonatomic, assign) NSInteger idFilm;

@property (nonatomic, strong) NSMutableArray* listOfImageName;
@end
