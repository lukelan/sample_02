//
//  UIViewController+CaptureSceen.m
//  123Phim
//
//  Created by Nhan Mai on 6/28/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "UIViewController+CaptureSceen.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIViewController (CaptureSceen)

- (void)captureScreen
{
    //    LOG_123PHIM(@"time up");
    
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //save to Photo program
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    // add sound
    NSString *path = [[NSBundle mainBundle] pathForResource:@"capture" ofType:@"mp3"];
    AVAudioPlayer* sound =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    sound.delegate=nil;
    [sound play];
    
    // add cover screen
    self.coverWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.coverWindow.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
    self.coverWindow.windowLevel = UIWindowLevelAlert + 1;
    [self.coverWindow setHidden:NO];
    [NSTimer scheduledTimerWithTimeInterval: 0.3
                                     target: self
                                   selector: @selector(hideCoverWindow)
                                   userInfo: nil
                                    repeats: NO];
    
    
    // wait a moment to show pic shot alert
    [NSTimer scheduledTimerWithTimeInterval: 0.5
                                     target: self
                                   selector: @selector(showPicAlert)
                                   userInfo: nil
                                    repeats: NO];

}

- (void)showPicAlert
{
    UIAlertView* alertPic = [[UIAlertView alloc] initWithTitle:@"123Phim" message:@"Hình chụp đã được lưu vào Photos." delegate:self cancelButtonTitle:@"Đóng" otherButtonTitles: nil];
    alertPic.tag = 1;
    [alertPic show];
}

- (void)hideCoverWindow
{
    [self.coverWindow setHidden:YES];
    //self.coverWindow;
}

@end
