//
//  PageView.h
//  123Mua
//
//  Created by phuonnm on 2/1/13.
//  Copyright (c) 2013 phuonnm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageView : UIView
{
    NSString * _reuseIdentifier;
}
@property (nonatomic,copy) NSString *reuseIdentifier;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

@end
