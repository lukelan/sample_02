//
//  DynamicViewController.m
//  123Phim
//
//  Created by phuonnm on 6/24/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "DynamicViewController.h"
#import "DynamicView.h"
#import "CustomUIResponder.h"

@interface DynamicViewController ()

@end

@implementation DynamicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect f = self.view.frame;
    f.origin.x = 0;
    f.origin.y = TITLE_BAR_HEIGHT;
    self.view.frame = f;
    [self.view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    [self.view setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [tapGesture setDelegate:self];
    [self.view addGestureRecognizer:tapGesture];
    [self.view addSubview:_dynamicView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sendActionWithView: (DynamicView *)view
{
    BOOL close = NO;
    if ([view isKindOfClass:[DynamicView class]])
    {
        close = YES;
        NSDictionary *objectInfo = view.properties;
        NSDictionary *actionInfo = [objectInfo objectForKey:DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_ACTION];
        if (actionInfo.count > 0)
        {
            [self pushViewControllerWithActionInfo:actionInfo];
        }
    }
    if (!view || close)
    {
        //            close this
        [_dynamicView removeFromSuperview];
        [self.view removeFromSuperview];
    }
}

-(void)setProperties:(NSDictionary *)properties
{
    _properties = properties;
    _dynamicView = [[DynamicView alloc] init];
    [_dynamicView setProperties:properties];
    [_dynamicView setDelegate:self];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self.view];
    if ([_dynamicView pointInside:point withEvent:nil]) {
        return NO;
    }
    return YES;
}
-(void)handleTapGesture: (UIGestureRecognizer*)gesture
{
    [self sendActionWithView:nil];
}

-(void)pushViewControllerWithActionInfo:(NSDictionary *)actionInfo
{
    if (_resourceController && [_resourceController respondsToSelector:@selector(pushViewControllerWithActionInfo:)])
    {
        [_resourceController pushViewControllerWithActionInfo:actionInfo];
        return;
    }
    UIViewController *vc = nil;
    NSString *viewControllerNameToPush = [actionInfo objectForKey:DYNAMIC_VIEW_CONTROLLER_PROPERTY_NAME_ACTION_VIEW_CONTROLLER_NAME];
    if (viewControllerNameToPush && _navigationControllerToPush)
    {
        Class theClass = NSClassFromString(viewControllerNameToPush);
        vc = [[theClass alloc] init];
    }
    if (vc)
    {
        [_navigationControllerToPush pushViewController:vc animated:YES];
    }

}

-(void)dealloc
{
    _properties = nil;
    _dynamicView = nil;
}

@end
