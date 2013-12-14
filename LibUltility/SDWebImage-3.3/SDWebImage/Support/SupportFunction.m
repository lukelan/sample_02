/*
 * $Author: kidbaw $
 * $Revision: 59 $
 * $Date: 2012-03-23 22:44:48 +0700 (Fri, 23 Mar 2012) $
 *
 */

#import "SupportFunction.h"
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMoviePlayerController.h>


#pragma mark - UIDevice

@implementation UIDevice (Resolutions)

- (UIDeviceResolution)resolution
{
    UIDeviceResolution resolution = UIDeviceResolution_Unknown;
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat scale = ([mainScreen respondsToSelector:@selector(scale)] ? mainScreen.scale : 1.0f);
    CGFloat pixelHeight = (CGRectGetHeight(mainScreen.bounds) * scale);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if (scale == 2.0f) {
            if (pixelHeight == 960.0f)
                resolution = UIDeviceResolution_iPhoneRetina35;
            else if (pixelHeight == 1136.0f)
                resolution = UIDeviceResolution_iPhoneRetina4;
            
        } else if (scale == 1.0f && pixelHeight == 480.0f)
            resolution = UIDeviceResolution_iPhoneStandard;
        
    } else {
        if (scale == 2.0f && pixelHeight == 2048.0f) {
            resolution = UIDeviceResolution_iPadRetina;
            
        } else if (scale == 1.0f && pixelHeight == 1024.0f) {
            resolution = UIDeviceResolution_iPadStandard;
        }
    }
    
    return resolution;
}

@end

#pragma mark - UIImage

@implementation UIImage (Extras)

- (UIImage *)imageByScalingToSize:(CGSize)size withOption:(enumImageScalingType)type {
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize targetSize;
    CGRect drawRect;
    
    if (type == enumImageScalingType_Top) {
        targetSize = CGSizeMake(sourceImage.size.width, size.height*sourceImage.size.width/size.width);
        drawRect = CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height);
    }
    else if (type == enumImageScalingType_TargetSize) {
        targetSize = CGSizeMake(sourceImage.size.width, size.height*sourceImage.size.width/size.width);
        drawRect = CGRectMake(0, 0, targetSize.width, targetSize.height);
    }
    else if (type == enumImageScalingType_Center_ScaleSize) {
        CGFloat scaleFactor;
        CGFloat widthFactor = sourceImage.size.width/size.width;
        CGFloat heightFactor = sourceImage.size.height/size.height;
        
        if (widthFactor < heightFactor)
            scaleFactor = heightFactor;
        else
            scaleFactor = widthFactor;
        
        CGFloat scaledWidth  = size.width*scaleFactor;
        CGFloat scaledHeight = size.height*scaleFactor;
        targetSize = CGSizeMake(scaledWidth, scaledHeight);
        
        drawRect = CGRectMake((scaledWidth - sourceImage.size.width)/2, (scaledHeight - sourceImage.size.height)/2, sourceImage.size.width, sourceImage.size.height);
    }
    else if (type == enumImageScalingType_Center_FullSize) {

        
        //update scale full size, just scale one side (width or height)
        CGFloat scaleFactor;
        CGFloat widthFactor = sourceImage.size.width/size.width;
        CGFloat heightFactor = sourceImage.size.height/size.height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        CGFloat scaledWidth  = sourceImage.size.width/scaleFactor;
        CGFloat scaledHeight = sourceImage.size.height/scaleFactor;
        
        targetSize = size;
        drawRect = CGRectMake(-(scaledWidth - size.width)/2, -(scaledHeight - size.height)/2, scaledWidth, scaledHeight);
    } else if (type == enumImageScalingType_FullSize) {
        CGFloat scaleFactor;
        CGFloat widthFactor = sourceImage.size.width/size.width;
        CGFloat heightFactor = sourceImage.size.height/size.height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        CGFloat scaledWidth  = sourceImage.size.width/scaleFactor;
        CGFloat scaledHeight = sourceImage.size.height/scaleFactor;

        drawRect = CGRectMake(0, 0, scaledWidth, scaledHeight);
        targetSize = drawRect.size;
    }
    else {
        targetSize = CGSizeMake(size.width*sourceImage.size.height/size.height, sourceImage.size.height);
        drawRect = CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height);
    }
    
    if ([[UIDevice currentDevice] resolution] != UIDeviceResolution_iPhoneStandard) {
        UIGraphicsBeginImageContextWithOptions(targetSize, NO, 2.0f);
    } else {
        UIGraphicsBeginImageContext(targetSize);
    }
    
    // draw image
    [sourceImage drawInRect:drawRect];
    
    // grab image
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    return newImage;
}

@end

