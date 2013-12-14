//
//  CustomTextView.h
//  123Phim
//
//  Created by Le Ngoc Duy on 5/3/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputValidation.h"

#define INPUT_STRING_TYPE_ASCII @"ASCII"
#define INPUT_STRING_TYPE_STRING @"STRING"
#define INPUT_STRING_TYPE_PASSWORD @"PASSWORD"
#define INPUT_STRING_TYPE_SEPERATION @"SEPERATION"
#define INPUT_STRING_TYPE_NUMBER @"NUMBER"
#define INPUT_STRING_TYPE_PHONE @"PHONE"
#define INPUT_STRING_TYPE_UPPERCASE @"UPPERCASE"
#define INPUT_STRING_TYPE_EMAIL @"EMAIL"
#define INPUT_STRING_TYPE_SET_MASK @"SET_MASK"


typedef NS_ENUM(NSInteger, InputType)
{
    INPUT_TYPE_NORMAL = 0,
    INPUT_TYPE_PHONE,
    INPUT_TYPE_EMAIL,
    INPUT_TYPE_PASSWORD,
    INPUT_TYPE_SEPERATION,
    INPUT_TYPE_MASK_SOME_CHARACTER,
    INPUT_TYPE_SUPPORT_UNICODE
};

@class CustomTextView;
@protocol CustomTextViewDelegate <NSObject>

@required

-(void)setActiveInputView: (CustomTextView*) inputView;

@optional

-(void)registerForKeyboardNotifications;
-(void)processKeyReturn:(UIReturnKeyType)returnType;

@end

@interface CustomTextView : UIView<UITextViewDelegate>
{
    int iNextCharacter;
    int radius;
    InputType _inputType;
    UITextView *_textView;
    NSString *_contentString;
    NSTimer *_timer;
    NSString *_maskString;
    int _seperatorCharacter;
    NSString *_regexFormater;
    UIImageView *_ivInvalidIcon;
    UIButton *_btnClearIcon;
}

@property int minCharacter;
@property int maxCharacter;
@property (nonatomic) BOOL enable;
@property(nonatomic, retain) UILabel *lblHolderDisplayReview;
@property (nonatomic, assign) id<CustomTextViewDelegate> delegate;
@property (nonatomic, assign) InputType inputType;
@property (nonatomic, assign) BOOL acceptAnsciiCharacterOnly;
@property (nonatomic, assign) BOOL isMaskCharacter;
@property (nonatomic, assign) NSRange maskRange;
@property(nonatomic, retain)UIImage *invalidImage;
@property(nonatomic, retain)UIImage *clearImage;
@property(nonatomic, copy)NSString *holderText;

//Define method
-(BOOL)hasText;
-(BOOL)becomeFirstResponder;
-(BOOL)resignFirstResponder;
-(NSString *)getText;
-(void)setText:(NSString *)text;
-(void)setAutocapitalizationType:(UITextAutocapitalizationType) typeAuto;
-(void)setBackGroundImage:(UIImage *)imgBackGround;
-(void)setKeyBoardType:(UIKeyboardType)keyboardType;
-(void)setKeyBoardAppearType:(UIKeyboardAppearance)keyboardTypeAppear;
-(void)setKeyBoardReturnKeyType:(UIReturnKeyType)keyboardTypeReturn;
-(void)layoutWithRadius:(CGFloat)curRadius andImageIcon:(UIImage *)imageIcon hoderText:(NSString *)holderText;

-(id) initWithFrame:(CGRect)frame inputType: (InputType) inputType;
-(BOOL)isInputValidationAndShowErrorAlert:(BOOL)isShowDialogError;
-(void)setMaskCharacter:(int)maskCharacter;
-(void)setInputTypeWithString:(NSString*)strInputType;
-(void)layoutWithRadius:(CGFloat)curRadius;
@end
