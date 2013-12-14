//
//  MyPageView.m
//  HGPageScrollViewSample
//
//  Created by Rotem Rubnov on 15/3/2011.
//  Copyright 2011 TomTom. All rights reserved.
//

#import "MyPageView.h"
#import "AppDelegate.h"



@implementation MyPageView

@synthesize isInitialized;
@synthesize displayDetail;
@synthesize normalView = _normalView;
@synthesize detailView = _detailView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        displayDetail = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
//-(id)initwithXibName:(NSString *) _nameXib{
//    self=[super initwithXibName:_nameXib];
//    return self;
//
//}


-(void)setContentViewWithAnimation: (Boolean) animation
{
    displayDetail = !displayDetail;
    if (animation)
    {
        UIView *toView;
        if (displayDetail)
        {
                toView = self.detailView;
            [toView.layer addSublayer:self.maskLayer];
        }
        else
        {
            toView = self.normalView;
            [toView.layer addSublayer:self.maskLayer];
        }
        [self doAnimationToView:toView ];
    }
    else
    {
        for (UIView *v in self.subviews)
        {
            [v removeFromSuperview];
        }
        if (displayDetail)
        {
            [self addSubview:self.detailView];
            [self.detailView.layer addSublayer:self.maskLayer];
        }
        else
        {
            [self addSubview:self.normalView];
            [self.normalView.layer addSublayer:self.maskLayer];
        }
    }

   }
-(void) doAnimationToView: (UIView *)toView 
{
   
    if (displayDetail)
    {        
        [self performActionAnimation:UIViewAnimationTransitionFlipFromLeft duration:0.6 delay:0.1];
    }
    else
    {
        [self performActionAnimation:UIViewAnimationTransitionFlipFromRight duration:0.6 delay:0.1];
    }
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.6 delay:0.1 options:UIViewAnimationTransitionFlipFromLeft animations:^{
      
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:toView cache:YES];
        Boolean needAdd = YES;
      
        for (UIView *v in self.subviews)
        {
            if (v == toView)
            {
           
                needAdd = NO;
                break;
            }
        }
        if (needAdd)
        {
      
             [self addSubview:toView];
     
            [toView.layer addSublayer:self.maskLayer];
        }
        else
        {
            [self bringSubviewToFront:toView];
       
         //[toView.layer addSublayer:self.maskLayer];
        }
    }completion:^(BOOL finished) {  
       // [toView.layer addSublayer:self.maskLayer];
       [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
        
     
}

@end
