//
//  DownloadImageManager.m
//  UIImageViewAsynorous
//
//  Created by duong nguyen on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomImageView.h"

@implementation CustomImageView
@synthesize indicatorView,imgView,request,data,statusLoading,tap;
@synthesize width,height,fullFrame,smallFrame,delegate,imgId,imgname;
@synthesize origionImage, imageDownload;
@synthesize filmId;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    int x=self.bounds.origin.x + self.bounds.size.width/2 -32;
    int y=self.bounds.origin.y + self.bounds.size.height/2 -32;
    statusLoading=STATUS_INIT;
    width=height=0;
    if (self) {
        _crop = YES;
        indicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(x, y, 64, 64)];
        indicatorView.hidden=YES;
        [indicatorView setColor:[UIColor grayColor]];
//        [indicatorView startAnimating];
        
        imgView=[[UIImageView alloc]initWithFrame:self.bounds];
        imgView.layer.cornerRadius=5.0;

        origionImage = [[UIImage alloc] init];
        imageDownload = NO;
        
        //[imgView setBackgroundColor:[UIColor blueColor]];
        imgView.hidden=NO;
    
        
        data=[[NSMutableData alloc]init];     
        [self addSubview:indicatorView];
        [self addSubview:imgView];
    }
    return self;
}

-(void)tapImage{
   
}

-(void) getImageViewFromURLByQueue:(NSURL *)urlStr{
    self.imageDownload = NO;
    urlStr=[urlStr retain];
    imgView.hidden=YES;
    indicatorView.hidden=NO;
    [indicatorView startAnimating];
    if (!queue)
    {
        queue=[NSOperationQueue new];
    }
    NSInvocationOperation *operation=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadImage:) object:urlStr];
    [queue addOperation:operation];
    [operation release];
}

-(void)loadImageOnBackgroundWithUrl:(NSURL *)url
{
    [self loadImageOnBackgroundWithUrl:url saveToFile:nil path:nil cropMode:CROP_IMAGE_MODE_NONE];
}

-(void) setPropertiesWithUrl:(NSURL *)url saveToFile: (NSString *) fileName path: (NSString *)path cropMode:(CROP_IMAGE_MODE) cropMode
{
    
}

-(void) loadImageOnBackgroundWithUrl:(NSURL *)url saveToFile: (NSString *) fileName path: (NSString *)path cropMode: (CROP_IMAGE_MODE) cropMode
{
    if (fileName && fileName.length > 0)
    {
        [self performSelectorOnMainThread:@selector(setFileName:) withObject:fileName waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(setPath:) withObject:path waitUntilDone:YES];
//        _fileName = [NSString stringWithString:fileName];
//        _path = [NSString stringWithString:path];
    }
//    [self performSelectorOnMainThread:@selector(setCropMode:) withObject:cropMode waitUntilDone:YES];
    _cropMode = cropMode;
    self.imageDownload = NO;
    _url=[url retain];
    imgView.hidden=YES;
    indicatorView.hidden=NO;
    [indicatorView startAnimating];
    [self addToQueue];
}

-(void) addToQueue
{
    if (!queue)
    {
        queue=[NSOperationQueue new];
    }
    NSInvocationOperation *operation=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadImageWithUrl:) object:[self retain]];
    [queue addOperation:operation];
    
    [operation release];
}


-(void)loadImageWithUrl:(CustomImageView *) customImageView
{
    NSData *imgData=[[NSData alloc]initWithContentsOfURL:customImageView.url];
    if (customImageView.cropMode <= CROP_IMAGE_MODE_VIEW_ONLY)
    {
        [self saveImageToFile:customImageView.fileName path: customImageView.path withDataImage:imgData];
    }
    UIImage *img=[[UIImage alloc]initWithData:imgData];
    self.origionImage = img;
    self.imageDownload = YES;
    [imgData release];
    UIImage *image = img;
    if (customImageView.cropMode > 0)
    {
        image = [imgView croppedImageWithImage:img scale:YES];
        if (_cropMode == CROP_IMAGE_MODE_VIEW_AND_SAVE && _fileName && _fileName.length > 0)
        {
            imgData = UIImageJPEGRepresentation(image, 1.0);
            [self saveImageToFile:customImageView.fileName path: customImageView.path withDataImage:imgData];
            [imgData release];
        }
    }
    [self performSelectorOnMainThread:@selector(displayImage:) withObject:image waitUntilDone:NO];
    [img release];
}

-(void)loadImage:(NSURL *)url{

    NSData *imgData=[[NSData alloc]initWithContentsOfURL:url];
    NSString* fileName = [NSString stringWithFormat:@"%@", [[[url absoluteString] componentsSeparatedByString:@"/"] lastObject]];
    NSString* path = GALLERY_PATH;
    path = [path stringByAppendingString:[NSString stringWithFormat:@"/"GALLERY_FILM_FOLDER_PREFIX"",self.filmId]];
    [self saveImageToFile:fileName path: path withDataImage:imgData];
    UIImage *img=[[UIImage alloc]initWithData:imgData];
    self.origionImage = img;
    self.imageDownload = YES;
    [imgData release];
    UIImage *image = img;
    if (_crop)
    {
        image = [imgView croppedImageWithImage:img scale:YES];
    }
    [self performSelectorOnMainThread:@selector(displayImage:) withObject:image waitUntilDone:NO];
    [img release];
}

-(void)saveImageToFile:(NSString *)fileName path: (NSString *) path withDataImage:(NSData *)imgData
{
    if(!fileName || fileName.length == 0)
    {
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        
        NSError* error;
        if(  [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error])
            ;// success
        else
        {
            NSLog(@"[%@] ERROR: attempting to write create MyFolder directory", [self class]);
            NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
        }
    }
    [imgData writeToFile:[NSString stringWithFormat:@"%@/%@", path, fileName] atomically:YES];
}

-(void)displayImage:(UIImage *)image {

    // reduce size of image before add to view
    UIImage *newSizeImage = nil;
    CGSize targetSize = CGSizeMake(THUMBNAIL_W*2,THUMBNAIL_H*2);

    newSizeImage = [imgView reduceImage:image toRect:targetSize];
    [imgView setImage:newSizeImage];

    [self getImageFinish];
    imgView.hidden=NO;
}

-(void)getImageViewWithURL:(NSURL *)url1{
    statusLoading=STATUS_LOADING;
    
    //sleep(1);
    imgView.hidden=YES;
    indicatorView.hidden=NO;
    [indicatorView startAnimating];
        
    if (!request)
    {
        [request clearDelegatesAndCancel];
        [request release];
    }
    request=[[ASIHTTPRequest alloc]initWithURL:url1];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startAsynchronous];

}

-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)dt{
    [data appendData:dt];
}

-(void)requestFinished:(ASIHTTPRequest *)request2
{
    UIImage *img=[[UIImage alloc ] initWithData:data];
    width=img.size.width;
    height=img.size.height;
    if (img) {
        [self autofixImageViewFrame:img.size.width height:img.size.height];
        [imgView setImage:img];
    }
    
    [request2 clearDelegatesAndCancel];
    statusLoading=STATUS_SUCCESS;
    imgView.hidden=NO;;
    [self getImageFinish];
    [img release];
    
    if (delegate!=nil&&[delegate respondsToSelector:@selector(CustomImageFinishLoading:)]) {
        [self.delegate CustomImageFinishLoading:0];
    }
}

-(void)getImageFinish{
    [indicatorView stopAnimating];
    indicatorView.hidden=YES;
}

-(void) requestFailed:(ASIHTTPRequest *)request2{
    [request2 clearDelegatesAndCancel];
    statusLoading=STATUS_FAIL;
    [self getImageFinish];
    if (delegate!=nil&&[delegate respondsToSelector:@selector(CustomImageFinishLoading:)]) {
        [self.delegate CustomImageFinishLoading:0];
    }
}

-(void)cancelDownload{
    statusLoading=STATUS_CANCEL;
    
    if (request) {
        [request cancel];
        [request clearDelegatesAndCancel];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setImageiewContentMode:(UIViewContentMode)mode{
    imgView.contentMode=mode;
}

-(void)autofixImageViewFrame:(float)_width height:(float)_height{
    if (self.bounds.size.height<=_height&&self.bounds.size.width<=_width) {
        imgView.contentMode=UIViewContentModeScaleToFill;
    }else {
        if (_height < self.bounds.size.height && _width >= self.bounds.size.width) {
            imgView.contentMode=UIViewContentModeScaleAspectFill;
        }else {
            imgView.contentMode=UIViewContentModeScaleAspectFit;
        }
    }
}

-(void) dealloc
{
    if (queue)
    {
        for (ASIHTTPRequest *rq in queue.operations)
        {
            [rq setDelegate: nil];
            [rq setDidFinishSelector: nil];
        }
        [queue cancelAllOperations];
        [queue release];
    }
    if (request)
    {
        [request clearDelegatesAndCancel];
        [request release];
    }
    [indicatorView release];
    [imgView release];
    [data release];
    if (origionImage)
    {
        [origionImage release];
    }
    [_fileName release];
    [_path release];
    [_url release];
    [super dealloc];
}

@end
