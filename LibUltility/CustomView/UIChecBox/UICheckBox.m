//
//  UICheckBox.m
//  123Phim
//
//  Created by Le Ngoc Duy on 5/7/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "UICheckBox.h"

@implementation UICheckBox
@synthesize isChecked = _isChecked;

-(UIFont *)getFontContent
{
    return [UIFont getFontNormalSize13];
}

+(CGFloat)getDefaultHeight
{
    UIImage *imageDefault = [UIImage imageNamed:@"checkbox_not_ticked.png"];
    CGSize sizeText = [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]];
    int maxHeight = (imageDefault.size.height > sizeText.height) ? imageDefault.size.height : sizeText.height;
    return maxHeight;
}

-(id)initWithTitle:(NSString *)titleText colorTitle:(UIColor *)color
{
    if(self = [super init])
    {
        isInited = NO;
        title = titleText;
        textColor = color;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self addTarget:self action:@selector(checkBoxClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self setImage:[UIImage imageNamed:@"checkbox_not_ticked.png"] forState:UIControlStateNormal];
        [self addTarget:self action:@selector(checkBoxClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)layoutSubviews
{
    if (isInited) {
        return;
    }
    isInited = YES;
    NSString *name = @"checkbox_not_ticked.png";
    if(self.isChecked == YES)
    {
        name = @"checkbox_ticked.png";
    }
    
    UIImage *imageDefault = [UIImage imageNamed:name];
    CGSize sizeText = [title sizeWithFont:[self getFontContent]];
    int maxHeight = (imageDefault.size.height > sizeText.height) ? imageDefault.size.height : sizeText.height;
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, imageDefault.size.width + 5 + sizeText.width, maxHeight)];
    //init image Background
    UIImageView *imageViewBG = [[UIImageView alloc] initWithImage:imageDefault];
    [imageViewBG setFrame:CGRectMake(0, (maxHeight - imageDefault.size.height)/2, imageDefault.size.width, imageDefault.size.height)];
    [imageViewBG setTag:1];
    
    //Init tile lable
    UILabel *lblTitle = [[UILabel alloc] init];
    [lblTitle setText:title];
    [lblTitle setTextColor:textColor];
    [lblTitle setFont:[self getFontContent]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFrame:CGRectMake(imageViewBG.frame.origin.x + imageViewBG.frame.size.width + 5, (maxHeight - sizeText.height)/2, sizeText.width, sizeText.height)];
    [lblTitle setTag:2];
    
    //add subView
    [self addSubview:imageViewBG];
    [self addSubview:lblTitle];
}

-(void)checkBoxClicked
{
    UIView *view = [self viewWithTag:1];
    if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)view;
        if(self.isChecked == NO)
        {
            self.isChecked = YES;
            [imageView setImage:[UIImage imageNamed:@"checkbox_ticked.png"]];
        }
        else{
            self.isChecked = NO;
            [imageView setImage:[UIImage imageNamed:@"checkbox_not_ticked.png"]];
        }
    }
}

-(void) dealloc{
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
