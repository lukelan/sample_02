//
//  DownloadImageManager.h
//  UIImageViewAsynorous
//
//  Created by duong nguyen on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+Action.h"

#define STATUS_INIT 0
#define STATUS_LOADING 1
#define STATUS_SUCCESS 2
#define STATUS_FAIL 3
#define STATUS_CANCEL 4

typedef NS_ENUM(NSInteger, CROP_IMAGE_MODE)
{
    CROP_IMAGE_MODE_NONE = 0,
    CROP_IMAGE_MODE_VIEW_ONLY,
    CROP_IMAGE_MODE_VIEW_AND_SAVE
};

@protocol CustomImageViewDelegate <NSObject>

@optional 

-(void)CustomImageFinishLoading:(int)status;

@end

@interface CustomImageView : UIView<ASIHTTPRequestDelegate>{
    int statusLoading;
    int width;
    int height;
    // Use for gallery
    CGRect fullFrame;
    CGRect smallFrame;
    id<CustomImageViewDelegate>delegate;
    
    int imgId;
    NSString *imgname;
    NSOperationQueue *queue;
}

@property (nonatomic, assign) BOOL imageDownload;
@property (nonatomic, retain) UIImage* origionImage;
@property (nonatomic,assign) id delegate;
@property (nonatomic,retain) UIActivityIndicatorView *indicatorView;
@property (nonatomic,retain) UIImageView *imgView;
@property (nonatomic,retain) ASIHTTPRequest *request;
@property (nonatomic,retain) NSMutableData *data;
@property (nonatomic) int statusLoading;
@property (nonatomic) int imgId;
@property (nonatomic,retain) NSString *imgname;
@property (nonatomic,retain) UITapGestureRecognizer *tap;

@property (nonatomic) CGRect fullFrame;
@property (nonatomic) CGRect smallFrame;

@property (nonatomic) int width;
@property (nonatomic) int height;

@property (nonatomic) NSInteger filmId;
@property(nonatomic, assign)BOOL crop;

@property (nonatomic,retain) NSString *fileName;
@property (nonatomic,retain) NSString *path;
@property (nonatomic,assign)CROP_IMAGE_MODE cropMode;
@property (nonatomic,retain) NSURL *url;

-(void)getImageViewFromURLByQueue:(NSURL *)url;
-(void)loadImageOnBackgroundWithUrl:(NSURL *)url;
-(void) loadImageOnBackgroundWithUrl:(NSURL *)urlStr saveToFile: (NSString *) fileName path: (NSString *)path cropMode: (CROP_IMAGE_MODE) cropMode;
-(void)getImageViewWithURL:(NSURL *)url;
-(void)getImageFinish;

-(void)setImageiewContentMode:(UIViewContentMode )mode;
-(void)autofixImageViewFrame:(float)width height:(float)height;
-(void)cancelDownload;


@end
