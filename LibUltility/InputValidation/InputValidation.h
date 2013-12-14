//
//  InputValidation.h
//  123Phim
//
//  Created by phuonnm on 5/14/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InputValidation : NSObject

+ (BOOL)validateEmail:(NSString *)inputText isShowError:(BOOL)isShow;
+ (BOOL)validatePhone:(NSString *)phoneNumber withSize: (CGSize) size isShowError:(BOOL)isShow;
+ (BOOL)validateLength:(NSString *)text withSize: (CGSize) size isShowErrorWithTitle:(NSString*)inputTitle;

@end
