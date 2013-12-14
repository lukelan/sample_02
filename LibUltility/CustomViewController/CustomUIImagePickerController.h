//
//  CustomUIImagePickerController.h
//  123Phim
//
//  Created by phuonnm on 6/3/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUIImagePickerController : UIImagePickerController

- (BOOL)shouldAutorotate;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

@end
