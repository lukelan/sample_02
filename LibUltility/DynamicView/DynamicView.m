//
//  DynamicView.m
//  123Phim
//
//  Created by phuonnm on 6/21/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "DynamicView.h"

@implementation DynamicView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(DynamicView *)parseObjectWithInfo: (NSDictionary*) objectInfo
{
//    frame
    NSString *str = nil;
    str = [objectInfo objectForKey:DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_FRAME];
    if (!str || str.length == 0)
    {
        return nil;
    }
    CGRect frame = CGRectFromString(str);
    DynamicView *view = self;//[[DynamicView alloc] initWithFrame:frame];
    view.frame = frame;
//    background color
    UIColor *backgroundColor = nil;
    view.backgroundColor = [UIColor clearColor];
    NSArray *colorProperties = nil;
    colorProperties = [objectInfo objectForKey:DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_BACKGROUND_COLOR];
    if (colorProperties && colorProperties.count == 4)
    {
        backgroundColor = [UIColor colorWithRed:[[colorProperties objectAtIndex:0] floatValue] green:[[colorProperties objectAtIndex:1] floatValue] blue:[[colorProperties objectAtIndex:2] floatValue] alpha:[[colorProperties objectAtIndex:3] floatValue]];
        view.backgroundColor = backgroundColor;
    }
    
//    background image
    NSString *bgImageName = [objectInfo objectForKey:DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_BACKGROUND_IMAGE];
    if (bgImageName)
    {
        CGRect f = self.frame;
        f.origin.x = 0;
        f.origin.y = 0;
        _backgroundImageView = [[UIImageView alloc] initWithFrame:f];
        _backgroundImageView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        [self addSubview:_backgroundImageView];
        NSString* fileName = [NSString stringWithFormat:@"%@", [[bgImageName componentsSeparatedByString:@"/"] lastObject]];
        NSString* path = GALLERY_PATH;
        path = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
        NSData *imgData = nil;
//        check exist
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path])
        {
            imgData = [[NSData alloc] initWithContentsOfFile:path];
            UIImage *image = [UIImage imageWithData:imgData];
            [self setBackgroundImage: image];
        }
        else
        {
            if (!queue)
            {
                queue=[NSOperationQueue new];
            }
            NSInvocationOperation *operation=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadBackGroundImageQueueWithUrl:) object:bgImageName];
            [queue addOperation:operation];
        }
    }
    
//    title
    NSString *title = [objectInfo valueForKey:DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_TITLE_TEXT];
    if (title && title.length > 0)
    {
        frame.origin.x = 0;
        frame.origin.y = 0;
        UILabel *lbTitle= [[UILabel alloc] initWithFrame:frame];
        lbTitle.text = title;
        lbTitle.font = [UIFont getFontNormalSize13];
        lbTitle.textAlignment = UITextAlignmentCenter;
        lbTitle.backgroundColor = [UIColor clearColor];
        NSArray *colors = nil;
        colors = [objectInfo objectForKey:DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_TITLE_TEXT_COLOR];
        if (colors && colors.count == 4)
        {
            UIColor *color = [UIColor colorWithRed:[[colors objectAtIndex:0] floatValue] green:[[colors objectAtIndex:1] floatValue] blue:[[colors objectAtIndex:2] floatValue] alpha:[[colors objectAtIndex:3] floatValue]];
            lbTitle.textColor = color;
        }
        [view addSubview:lbTitle];
    }
//    action
    NSDictionary *actionInfo = [objectInfo objectForKey:DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_ACTION];
    if (actionInfo)
    {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(sendActionWithGesture:)];
        [view addGestureRecognizer:tapGesture];
    }
    
//    sub view
    NSArray *lstSubViewInfo = nil;
    lstSubViewInfo = [objectInfo objectForKey:DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_SUB_VIEW];
    if (lstSubViewInfo)
    {
        for (int i = 0; i < lstSubViewInfo.count; i++) {
            NSDictionary *properties = [lstSubViewInfo objectAtIndex:i];
            DynamicView *subView = [[DynamicView alloc] init];
            [subView setProperties:properties];
            subView.delegate = self.delegate;
            [view addSubview:subView];
        }
    }
    return view;
}

-(void)layoutView
{
    [self parseObjectWithInfo:_properties];
}

-(void)sendActionWithGesture: (UIGestureRecognizer *)gesture
{
    DynamicView *view = nil;
    if (gesture)
    {
        view = (DynamicView *)gesture.view;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(sendActionWithView:)])
    {
        [_delegate sendActionWithView: view];
    }
}

-(void)willMoveToWindow:(UIWindow *)newWindow
{
    if (newWindow)
    {
        [self layoutView];
    }
}

-(void)loadBackGroundImageQueueWithUrl: (NSString *) strUrl
{
    NSURL *url = [NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSData *imgData=[[NSData alloc]initWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imgData];
    [self performSelectorOnMainThread:@selector(setBackgroundImage:) withObject:image waitUntilDone:YES];
    NSString* fileName = [NSString stringWithFormat:@"%@", [[strUrl componentsSeparatedByString:@"/"] lastObject]];
    NSString* path = GALLERY_PATH;
    path = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
    [imgData writeToFile:path atomically:YES];
}

-(void)setBackgroundImage:(UIImage*)image
{
    _backgroundImageView.image = image;
}

-(void)dealloc
{
    if (queue)
    {
        [queue cancelAllOperations];
        queue = nil;
    }
    _properties = nil;

}

@end
