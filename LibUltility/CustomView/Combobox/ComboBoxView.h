//
//  ComboBoxView.h
//  123Mua
//
//  Created by Le Ngoc Duy on 11/26/12.
//  Copyright (c) 2012 Le Ngoc Duy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ComboBoxView : UIView < UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
//	UILabel			*_selectContentLabel;
    UITextField			*_selectContentLabel;
	UIButton		*_pulldownButton;
	UIButton		*_hiddenButton;
	UITableView		*_comboBoxTableView;
	NSArray			*_comboBoxDatasource;
	BOOL			_showComboBox;
    int _iconWidth;
    int _iconHeight;
}

@property (nonatomic, retain) NSArray *comboBoxDatasource;

- (void)initVariables;
- (void)initCompentWithFrame:(CGRect)frame;
- (void)setContent:(NSString *)content;
- (void)show;
- (void)hidden;
- (void)drawListFrameWithFrame:(CGRect)frame withContext:(CGContextRef)context;

@end
