//
//  BankInfo.h
//  123Phim
//
//  Created by Le Ngoc Duy on 5/10/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#define BANK_INFO_KEY_CODE @"bank_code"
#define BANK_INFO_KEY_MOBILE_CODE @"bank_code_mobile"
#define BANK_INFO_KEY_NAME @"bank_name"
#define BANK_INFO_KEY_VERSION @"version"
#define BANK_INFO_KEY_USING_WEB @"using_web"
#define BANK_INFO_KEY_USING_WEB @"using_web"
#define BANK_INFO_KEY_USING_WEB_PATTERN_123PAY @"pattern_123pay"
#define BANK_INFO_KEY_USING_WEB_PATTERN_123PAY_SUCESS @"pattern_123pay_sucess"
#define BANK_INFO_KEY_USING_WEB_PATTERN_MIGS @"pattern_migs"
#define BANK_INFO_KEY_USING_WEB_GET_CAPTCHA_URL @"captcha_url"
#define BANK_INFO_KEY_PARAM_NAMES @"param_names"
#define BANK_INFO_KEY_PARAM_SHORT_TITLES @"param_short_titles"
#define BANK_INFO_KEY_PARAM_TYPES @"param_types"
#define BANK_INFO_KEY_PARAM_LIMITS @"param_limits"
#define BANK_INFO_KEY_PARAM_TITLES @"param_titles"
#define BANK_INFO_KEY_PARAM_TYPE_NOT_SAVED @"NOT_SAVED"
#define BANK_INFO_KEY_PARAM_TYPE_DISABLE @"DISABLE"
#define BANK_INFO_KEY_PARAM_TYPE_EXPIRED_DATE @"EXPIRED_DATE"
#define BANK_INFO_KEY_PARAM_TYPE_BEGIN_DATE @"BEGIN_DATE"
#define BANK_INFO_KEY_PARAM_TYPE_FORMAT @"FORMAT"
#define BANK_INFO_KEY_PARAM_TYPE_ASCII INPUT_STRING_TYPE_ASCII
#define BANK_INFO_KEY_PARAM_TYPE_STRING INPUT_STRING_TYPE_STRING
#define BANK_INFO_KEY_PARAM_TYPE_PASSWORD INPUT_STRING_TYPE_PASSWORD
#define BANK_INFO_KEY_PARAM_TYPE_SEPERATION INPUT_STRING_TYPE_SEPERATION
#define BANK_INFO_KEY_PARAM_TYPE_NUMBER INPUT_STRING_TYPE_NUMBER
#define BANK_INFO_KEY_PARAM_TYPE_PHONE INPUT_STRING_TYPE_PHONE
#define BANK_INFO_KEY_PARAM_TYPE_UPPERCASE INPUT_STRING_TYPE_UPPERCASE
#define BANK_INFO_KEY_PARAM_TYPE_EMAIL INPUT_STRING_TYPE_EMAIL
#define BANK_INFO_KEY_PARAM_TYPE_SET_MASK INPUT_STRING_TYPE_SET_MASK
#define BANK_INFO_KEY_CONFIRM_PARAM_NAMES @"confirm_param_names"
#define BANK_INFO_KEY_CONFIRM_PARAM_TYPES @"confirm_param_types"
#define BANK_INFO_KEY_CONFIRM_PARAM_LIMITS @"confirm_param_limits"
#define BANK_INFO_KEY_CONFIRM_PARAM_TITLES @"confirm_param_titles"
#define BANK_INFO_KEY_CONFIRM_PARAM_SHORT_TITLES @"confirm_param_short_titles"

#define BANK_INFO_KEY_SML_VERIFY_CARD_URL @"sml_verify_card_url"
#define BANK_INFO_KEY_SML_PATTERN_VERIFY_CARD_SUCCESS @"sml_pattern_verify_card_success"
#define BANK_INFO_KEY_SML_PATTERN_ERROR @"sml_pattern_error"
#define BANK_INFO_KEY_SML_PATTERN_VERIFY_CARD_AGAIN @"sml_pattern_verify_card_again"
#define BANK_INFO_KEY_SML_PATTERN_VERIFY_OTP @"sml_pattern_verify_otp"
#define BANK_INFO_KEY_SML_PATTERN_VERIFY_OTP_SUCCESS @"sml_pattern_verify_otp_successs"

#define BANK_CODE_VISA_MASTER @"CREDITCARD"

#define TAG_ADDED_NUMBER 1003

#define TABLE_VIEW_WIDTH 320
#define SEGMENT_HEIGHT 40
#define NUMBER_YEAR_TO_SHOW 10
#define TAG_BEGIN_DATE   1001
#define TAG_EXPIRED_DATE   1002
#define TAG_BEGIN_DATE_CONFIRM   (TAG_BEGIN_DATE + TAG_ADDED_NUMBER)
#define TAG_EXPIRED_DATE_CONFIRM   (TAG_EXPIRED_DATE + TAG_ADDED_NUMBER)

typedef NS_ENUM(NSInteger, BANK_STATUS)
{
    BANK_STATUS_ATM_HIDDEN = -1,
    BANK_STATUS_VISA_DISABLE = -1,
    BANK_STATUS_ATM_DISABLE,
    BANK_STATUS_ATM_AVAILABLE,
    BANK_STATUS_VISA_AVAILABLE
};

typedef NS_ENUM(NSInteger, BANK_USING_WEB_TYPE)
{
    BANK_USING_WEB_TYPE_NONE = 0,
    BANK_USING_WEB_TYPE_YES,
    BANK_USING_WEB_TYPE_OVERLAY_LAYOUT,
};

#import "CustomTextView.h"
#import <Foundation/Foundation.h>
#import "VNGSegmentedControl.h"

/*
 sample: BIDV
 {
    bank_code:BIDV,
    bank_code_mobile:BIDV_M,
    bank_name:BIDV,
    param_names: // will send when verify as param name
    [
        cardHolderName,
        [cardNumber, passport, phone, custCode],
        cardPass
    ],
    param_types: //ANSCII|SEPERATION|SET_MASK~[0,12], STRING, NUMBER, ANSCII|PASSWORD, NUMBER|PASSWORD|NOT_SAVED
    [
        ANSCII,
        [NUMBER, NUMBER, NUMBER, NUMBER],
        ANSCII|PASSWORD
    ],
    param_limits: //[min,max]
    [
        [1,-1], // -1: unlimit
        [[16,16], [9,9], [10,11], [4,4]]
        [1,-1]
 
    ]
    param_titles:
    [
        "Tên chủ tài khoản in hoa không dấu",
        ["Số thẻ", "Số CMND", "Số điện thoại", "Mã khách hàng"]
        "Mật khẩu"
    ]
 }
 */
@class VNGSegmentedControl;
@protocol BankInfoDelegate <NSObject>

@required
-(void)segmentControl:(VNGSegmentedControl *) segment didChangeAtParamIndex:(NSUInteger)paramIndex;

@end

@interface BankInfo : NSObject<NSCoding, UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate>

@property (nonatomic, copy) NSString *bank_code;
@property (nonatomic, copy) NSString *bank_code_mobile;
@property (nonatomic, copy) NSString *bank_name;
@property (nonatomic, copy) NSString *bank_logo_URL;
@property (nonatomic, assign) NSInteger bank_version;
@property (nonatomic, assign) NSInteger bank_status;
@property (nonatomic, copy) NSString *bankStatusDesc;
@property (nonatomic, strong) NSDictionary *dicBankInfo;
@property (nonatomic, strong) NSMutableDictionary *viewInfo;
@property (nonatomic, strong) NSMutableDictionary *confirmViewInfo;
@property (nonatomic, weak) id<BankInfoDelegate> delegate;
@property (nonatomic, weak) id<BankInfoDelegate> confirmDelegate;

-(NSArray *)getParamNameListForConfirmView:(BOOL)forConfirmView;
-(NSArray *)getParamTypeListForConfirmView:(BOOL)forConfirmView;
-(NSArray *)getParamLimitListForConfirmView:(BOOL)forConfirmView;
-(NSArray *)getParamTitleListForConfirmView:(BOOL)forConfirmView;
-(NSArray *)getParamShortTitleListForConfirmView:(BOOL)forConfirmView;

-(NSDictionary*)toDictionary;
-(NSInteger)getUsingWebType;
-(NSString*)getPattern123Pay;
-(NSString *)getPattern123PaySucess;
-(NSString *)getPattern123PayMIGS;
-(NSString *)getCaptchaURL;
-(NSString *)getSMLVerifyCardURL;
-(NSString *)getSMLPattenVerifyCardSuccess;
-(NSString *)getSMLPattenError;
-(NSString *)getSMLPatternVerifyOTP;
-(NSString *)getSMLPatternVerifyCardAgain;
-(NSString *)getSMLPatternVerifyOTPSuccess;
-(id)initWithDictionary:(NSDictionary*) dic;

-(UIView *)viewAtParamIndex:(NSUInteger)paramIndex forConfirmView:(BOOL)forConfirmView;
-(CustomTextView *)inputViewAtParamIndex:(NSInteger) paramIndex forConfirmView:(BOOL)forConfirmView;
-(void)initInputViewsWithLoadInfo:(NSDictionary*)loadInfo forConfirmView:(BOOL)forConfirmView;
-(NSMutableDictionary *)dictionaryInputForSending:(BOOL)sending forConfirmView:(BOOL)forConfirmView;

@end
