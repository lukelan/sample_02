//
//  VNGDropDown.h
//  VNGPayGateDemo
//
//  Created by HienNM on 3/26/13.
//  Copyright (c) 2013 VNG Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VNGDropDown;
@protocol VNGDropDownDelegate
- (void) VNGDropDownDelegateMethod: (VNGDropDown *) sender;
@end

@interface VNGDropDown : UIView <UITableViewDelegate, UITableViewDataSource>
{
    NSString *animationDirection;
}
@property (nonatomic, retain) id <VNGDropDownDelegate> delegate;
@property (nonatomic, retain) NSString *animationDirection;

-(void)hideDropDown:(UIButton *)b;
-(void)hideDropDownWithoutAnimation:(UIButton *)b;
- (id)initShowDropDown:(UIButton *)b height:(CGFloat *)height arr:(NSArray *)arr direction:(NSString *)direction;
@end
