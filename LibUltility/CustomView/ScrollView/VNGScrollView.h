//
//  VNGScrollView.h
//  PayDemo
//
//  Created by HienNM on 3/29/13.
//  Copyright (c) 2013 VNG Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VNGScrollView  : UIScrollView
- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;

@end
