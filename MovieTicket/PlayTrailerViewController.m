//
//  PlayTrailerViewController.m
//  PlayVideo
//
//  Created by Nhan Mai on 1/12/13.
//  Copyright (c) 2013 Thanh Nhan Mai. All rights reserved.
//

#import "PlayTrailerViewController.h"
#import "DefineConstant.h"

@interface PlayTrailerViewController ()

@end

@implementation PlayTrailerViewController

-(void)dealloc
{
    viewName = nil;
}
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        viewName = PLAY_TRAILER_VIEW_NAME;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    }
    else
    {
        self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    }
}

- (BOOL)shouldAutorotate
{
//    LOG_123PHIM(@"shouldAutorotate");
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}
@end
