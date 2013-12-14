/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "objc/runtime.h"
#import "SupportFunction.h"

static char operationKey;

@implementation UIImageView (WebCache)
static char UIB_PROPERTY_KEY;
@dynamic scaleOption;

- (void)setScaleOption:(NSString *)option
{
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY, option, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)scaleOption
{
    return (NSString *)objc_getAssociatedObject(self, &UIB_PROPERTY_KEY);
}

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock;
{
    [self cancelCurrentImageLoad];

    self.image = placeholder;
    
    if (url)
    {
        __weak UIImageView *wself = self;
        id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
        {
            if (!wself) return;
            void (^block)(void) = ^
            {
                __strong UIImageView *sself = wself;
                if (!sself)
                {
                    return;
                }
                
                if (image)
                {
                    // scale image
                    if ([sself.scaleOption isEqual: enumWebImageScaleOption_FullFill]) {
                        [sself setImage:image];
                    }
                    else if ([sself.scaleOption isEqual: enumWebImageScaleOption_ScaleToFill]) {
                        
                        [sself setImage:[image imageByScalingToSize:sself.frame.size withOption:enumImageScalingType_Center_ScaleSize]];
                    }
                    else if ([sself.scaleOption isEqual: enumWebImageScaleOption_ScaleToWidth_Top]) {
                        [sself setImage:[image imageByScalingToSize:sself.frame.size withOption:enumImageScalingType_Top]];
                    }
                    else if ([sself.scaleOption isEqual: enumWebImageScaleOption_ScalePhotoToSize]) {
                        
                        UIImage *thumbnailPhoto = [sself cropCenterAndScaleImageToSize:CGSizeMake(85.0,85.0) selectedImage:image];
                        
                        [sself setImage:thumbnailPhoto];
                    }
                    else if ([sself.scaleOption isEqual: enumWebImageScaleOption_ScalePhotoToSizeLarger]) {
                        //UIImage *thumbnailPhoto = [self cropCenterAndScaleImageToSize:CGSizeMake(240.0,195.0) selectedImage:image];
                        UIImage *thumbnailPhoto = [sself cropCenterAndScaleImageToSize:CGSizeMake(240.0,220.0) selectedImage:image];
                        [sself setImage:thumbnailPhoto];
                    }
                    
                    else if ([sself.scaleOption isEqual: enumWebImageScaleOption_ScalePhotoFullSize]) {
                        UIImage *thumbnailPhoto = [sself cropCenterAndScaleImageToSize:CGSizeMake(320.0,220.0) selectedImage:image];
                        [sself setImage:thumbnailPhoto];
                    } else if ([sself.scaleOption isEqual: enumWebImageScaleOption_ScalePhotoCenterFullSize]) {
                        UIImage *thumbnailPhoto = [image imageByScalingToSize:CGSizeMake(sself.frame.size.width,sself.frame.size.height) withOption:enumImageScalingType_Center_FullSize];
                        [sself setImage:thumbnailPhoto];
                    }
                    else {
                        [sself setImage:image];
                    }
                    
                    //                    sself.image = image;
                    [sself setNeedsLayout];
                }
                
                if (completedBlock && finished)
                {
                    completedBlock(image, error, cacheType);
                }
            };
            if ([NSThread isMainThread])
            {
                block();
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), block);
            }
        }];
        objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (UIImage*) rotateImageAppropriately:(UIImage*) imageToRotate withDirection:(UIImageOrientation)imageOrientationWhenAddedToScreen
{
    //This method will properly rotate our image, we need to make sure that
    CGImageRef imageRef = [imageToRotate CGImage];
    UIImage* properlyRotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:imageOrientationWhenAddedToScreen];
    return properlyRotatedImage;
}

- (void)cancelCurrentImageLoad
{
    // Cancel in progress downloader from queue
    id<SDWebImageOperation> operation = objc_getAssociatedObject(self, &operationKey);
    if (operation)
    {
        [operation cancel];
        objc_setAssociatedObject(self, &operationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma mark - Utilities methods
- (UIImage *)cropCenterAndScaleImageToSize:(CGSize)cropSize selectedImage:(UIImage*) image {
	UIImage *scaledImage = [self rescaleImageToSize:[self calculateNewSizeForCroppingBox:cropSize selectedImage:image] selectedImage:image];
    
    NSLog(@"width:%f height:%f",scaledImage.size.width,scaledImage.size.height);
    
    CGRect cropedImageRect = CGRectMake((scaledImage.size.width-cropSize.width)/2, (scaledImage.size.height-cropSize.height)/2, cropSize.width, cropSize.height);
    
    //CGRect cropedImageRect = CGRectMake((image.size.width-cropSize.width)/2, (image.size.height-cropSize.height)/2, cropSize.width, cropSize.height);
    
	return [self cropImageToRect:cropedImageRect selectedImage:scaledImage];
}

- (UIImage *)cropImageToRect:(CGRect)cropRect selectedImage:(UIImage*)image {
	// Begin the drawing (again)
	UIGraphicsBeginImageContext(cropRect.size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	// Tanslate and scale upside-down to compensate for Quartz's inverted coordinate system
	CGContextTranslateCTM(ctx, 0.0, cropRect.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	// Draw view into context
	CGRect drawRect = CGRectMake(-cropRect.origin.x, cropRect.origin.y - (image.size.height - cropRect.size.height) , image.size.width, image.size.height);
	CGContextDrawImage(ctx, drawRect, image.CGImage);
	
	// Create the new UIImage from the context
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// End the drawing
	UIGraphicsEndImageContext();
	
	return newImage;
}

- (CGSize)calculateNewSizeForCroppingBox:(CGSize)croppingBox selectedImage:(UIImage*)image {
	// Make the shortest side be equivalent to the cropping box.
	CGFloat newHeight, newWidth;
	if (image.size.width < image.size.height) {
		newWidth = croppingBox.width;
		newHeight = (image.size.height / image.size.width) * croppingBox.width;
	} else {
		newHeight = croppingBox.height;
		newWidth = (image.size.width / image.size.height) *croppingBox.height;
	}
	
	return CGSizeMake(newWidth, newHeight);
}

- (UIImage *)rescaleImageToSize:(CGSize)size selectedImage:(UIImage*)image {
	CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
	UIGraphicsBeginImageContext(rect.size);
	[image drawInRect:rect];  // scales image to rect
	UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resImage;
}

@end
