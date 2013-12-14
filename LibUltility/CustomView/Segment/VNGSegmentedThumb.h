//
//  VNGSegmentedThumb.h
//  VNGPayGateDemo
//
//  Created by HienNM on 3/26/13.
//  Copyright (c) 2013 VNG Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VNGSegmentedControl;

@interface VNGSegmentedThumb : UIView

@property (nonatomic, retain) UIImage *backgroundImage; // default is nil;
@property (nonatomic, strong) UIImage *highlightedBackgroundImage; // default is nil;

@property (nonatomic, retain) UIColor *tintColor; // default is [UIColor grayColor]
@property (nonatomic, retain) UIColor *textColor; // default is [UIColor whiteColor]
@property (nonatomic, retain) UIColor *textShadowColor; // default is [UIColor blackColor]
@property (nonatomic, readwrite) CGSize textShadowOffset; // default is CGSizeMake(0, -1)
@property (nonatomic, readwrite) BOOL shouldCastShadow; // default is YES (NO when backgroundImage is set)
@property (nonatomic, assign) CGFloat gradientIntensity; // default is 0.15

@end
