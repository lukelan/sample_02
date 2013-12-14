//
//  UIFont+App.m
//  123Phim
//
//  Created by phuonnm on 3/26/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "UIFont+App.h"

@implementation UIFont (App)

#pragma mark define font for app
+(UIFont *)getFontNormalSize10
{
    return [UIFont getFontStyleBold:NO withSize:10];
}
+(UIFont *)getFontNormalSize11
{
    return [UIFont getFontStyleBold:NO withSize:11];
}
+(UIFont *)getFontNormalSize12
{
    return [UIFont getFontStyleBold:NO withSize:12];
}
+(UIFont *)getFontNormalSize13
{
    return [UIFont getFontStyleBold:NO withSize:13];
}
+(UIFont *)getFontNormalSize14
{
    return [UIFont getFontStyleBold:NO withSize:14];
}
+(UIFont *)getFontNormalSize15
{
    return [UIFont getFontStyleBold:NO withSize:15];
}
+(UIFont *)getFontNormalSize16
{
    return [UIFont getFontStyleBold:NO withSize:16];
}
+(UIFont *)getFontNormalSize17
{
    return [UIFont getFontStyleBold:NO withSize:17];
}
+(UIFont *)getFontNormalSize18
{
    return [UIFont getFontStyleBold:NO withSize:18];
}
+(UIFont *)getFontNormalSize19
{
    return [UIFont getFontStyleBold:NO withSize:19];
}
+(UIFont *)getFontNormalSize23
{
    return [UIFont getFontStyleBold:NO withSize:23];
}
+(UIFont *)getFontNormalSize27
{
    return [UIFont getFontStyleBold:NO withSize:27];
}

//process font Helvetical Bold
+(UIFont *)getFontBoldSize10
{
    return [UIFont getFontStyleBold:YES withSize:10];
}

+(UIFont *)getFontBoldSize11
{
    return [UIFont getFontStyleBold:YES withSize:11];
}
+(UIFont *)getFontBoldSize12
{
    return [UIFont getFontStyleBold:YES withSize:12];
}
+(UIFont *)getFontBoldSize13
{
    return [UIFont getFontStyleBold:YES withSize:13];
}
+(UIFont *)getFontBoldSize14
{
    return [UIFont getFontStyleBold:YES withSize:14];
}
+(UIFont *)getFontBoldSize15
{
    return [UIFont getFontStyleBold:YES withSize:15];
}
+(UIFont *)getFontBoldSize16
{
    return [UIFont getFontStyleBold:YES withSize:16];
}
+(UIFont *)getFontBoldSize17
{
    return [UIFont getFontStyleBold:YES withSize:17];
}
+(UIFont *)getFontBoldSize18
{
    return [UIFont getFontStyleBold:YES withSize:18];
}
+(UIFont *)getFontBoldSize19
{
    return [UIFont getFontStyleBold:YES withSize:19];
}
+(UIFont *)getFontBoldSize23
{
    return [UIFont getFontStyleBold:YES withSize:23];
}
+(UIFont *)getFontBoldSize27
{
    return [UIFont getFontStyleBold:YES withSize:27];
}

+(UIFont *)getFontStyleBold:(BOOL)is_Bold withSize:(int)sizeFont
{
    if (is_Bold) {
        return [UIFont fontWithName:@"Helvetica-Bold" size:sizeFont];
    }
    return [UIFont fontWithName:@"Helvetica" size:sizeFont];
}

+(UIFont *)getFontCustomSize:(int)sizeFont
{
    return [UIFont fontWithName:@"QuartzMS" size:sizeFont];
}

#pragma mark calculate size of text depend on font
+(UIColor*) colorBackGroundApp
{
    return [UIColor colorWithRed:238 /255.0 green:238 /255.0 blue:238 /255.0 alpha:1.0];
}
@end
