//
//  UICheckBox.h
//  123Phim
//
//  Created by Le Ngoc Duy on 5/7/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICheckBox : UIButton
{
    BOOL isInited;
    BOOL _isChecked;
    NSString *title;
    UIColor *textColor;
}
@property (nonatomic, assign) BOOL isChecked;
-(void)checkBoxClicked;
-(id)initWithTitle:(NSString *)titleText colorTitle:(UIColor *)color;
+(CGFloat)getDefaultHeight;
@end
