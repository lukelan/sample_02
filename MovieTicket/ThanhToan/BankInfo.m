//
//  BankInfo.m
//  123Phim
//
//  Created by Le Ngoc Duy on 5/10/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "BankInfo.h"
#import "VNGSegmentedControl.h"
#import "CustomTextView.h"
#import "MainViewController.h"
#import "DefineConstant.h"

@implementation BankInfo
@synthesize bank_code, bank_name, bank_code_mobile;
@synthesize viewInfo = _viewInfo;
@synthesize confirmViewInfo = _confirmViewInfo;

-(id)init
{
    if (self = [super init])
    {
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dic
{
    if (self = [self init])
    {
        self.bank_code = [dic objectForKey:@"bank_code"];
        self.bank_code_mobile = [dic objectForKey:@"bank_code_mobile"];
        self.bank_name = [dic objectForKey:@"bank_name"];
        self.bank_version = [[dic objectForKey:@"bank_version"] integerValue];
        self.dicBankInfo = [dic objectForKey:@"dicBankInfo"];
    }
    return self;
}

-(NSDictionary*)toDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    if (self.bank_code) {
        [dict setObject:self.bank_code forKey:@"bank_code"];
    }
    if (self.bank_code_mobile) {
        [dict setObject:self.bank_code_mobile forKey:@"bank_code_mobile"];
    }
    if (self.bank_name) {
        [dict setObject:self.bank_name forKey:@"bank_name"];
    }
    if (self.bank_version) {
        [dict setObject:[NSNumber numberWithInt:self.bank_version] forKey:@"bank_version"];
    }
    if (self.dicBankInfo) {
        [dict setObject:self.dicBankInfo forKey:@"dicBankInfo"];
    }
    return dict;
}

//atm input view
-(NSArray *)getParamNameListForConfirmView:(BOOL)forConfirmView
{
    if(forConfirmView)
    {
        return [self.dicBankInfo objectForKey:BANK_INFO_KEY_CONFIRM_PARAM_NAMES];
    }
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_PARAM_NAMES];
}

-(NSArray *)getParamTypeListForConfirmView:(BOOL)forConfirmView
{
    if(forConfirmView)
    {
        return [self.dicBankInfo objectForKey:BANK_INFO_KEY_CONFIRM_PARAM_TYPES];
    }
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_PARAM_TYPES];
}

-(NSArray *)getParamLimitListForConfirmView:(BOOL)forConfirmView
{
    if(forConfirmView)
    {
        return [self.dicBankInfo objectForKey:BANK_INFO_KEY_CONFIRM_PARAM_LIMITS];
    }
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_PARAM_LIMITS];
}

-(NSArray *)getParamTitleListForConfirmView:(BOOL)forConfirmView
{
    if(forConfirmView)
    {
        return [self.dicBankInfo objectForKey:BANK_INFO_KEY_CONFIRM_PARAM_TITLES];
    }
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_PARAM_TITLES];
}

-(NSArray *)getParamShortTitleListForConfirmView:(BOOL)forConfirmView
{
    if(forConfirmView)
    {
        return [self.dicBankInfo objectForKey:BANK_INFO_KEY_CONFIRM_PARAM_SHORT_TITLES];
    }
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_PARAM_SHORT_TITLES];
}

-(NSInteger)getUsingWebType
{
    return [[self.dicBankInfo objectForKey:BANK_INFO_KEY_USING_WEB] integerValue];
}

-(NSString *)getPattern123Pay
{
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_USING_WEB_PATTERN_123PAY];
}

-(NSString *)getPattern123PaySucess
{
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_USING_WEB_PATTERN_123PAY_SUCESS];
}

-(NSString *)getPattern123PayMIGS
{
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_USING_WEB_PATTERN_MIGS];
}

-(NSString *)getCaptchaURL
{
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_USING_WEB_GET_CAPTCHA_URL];
}

-(NSString *)getSMLVerifyCardURL
{
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_SML_VERIFY_CARD_URL];
}

-(NSString *)getSMLPattenError
{
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_SML_PATTERN_ERROR];
}

-(NSString *)getSMLPattenVerifyCardSuccess
{
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_SML_PATTERN_VERIFY_CARD_SUCCESS];
}

-(NSString *)getSMLPatternVerifyCardAgain
{
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_SML_PATTERN_VERIFY_CARD_AGAIN];
}

-(NSString *)getSMLPatternVerifyOTP
{
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_SML_PATTERN_VERIFY_OTP];
}

-(NSString *)getSMLPatternVerifyOTPSuccess
{
    return [self.dicBankInfo objectForKey:BANK_INFO_KEY_SML_PATTERN_VERIFY_OTP_SUCCESS];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.bank_code forKey:@"bank_code"];
    [encoder encodeObject:self.bank_code_mobile forKey:@"bank_code_mobile"];
    [encoder encodeObject:self.bank_name forKey:@"bank_name"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.bank_code = [decoder decodeObjectForKey:@"bank_code"];
        self.bank_code_mobile = [decoder decodeObjectForKey:@"bank_code_mobile"];
        self.bank_name = [decoder decodeObjectForKey:@"bank_name"];
    }
    return self;
}


#pragma mark dynamic input view
-(UIView *)viewAtParamIndex: (NSUInteger)paramIndex forConfirmView:(BOOL)forConfirmView
{
    int tag = TAG_ADDED_NUMBER + paramIndex;
    NSString *viewKey = [NSString stringWithFormat:@"viewWithTag_%d", tag];
    UIView *view = [self objectForKey:viewKey forConfirmView:forConfirmView];
    if (!view)
    {
        NSArray *paramNameList = [self getParamNameListForConfirmView:forConfirmView];
        id inputName = [paramNameList objectAtIndex:(paramIndex)];
        if ([inputName isKindOfClass:[NSArray class]] && [inputName count] > 1)
        {
            NSArray *paramTittleList = [self getParamShortTitleListForConfirmView:forConfirmView];
            if (!paramTittleList)
            {
                paramTittleList = [self getParamTitleListForConfirmView:forConfirmView];
            }
            if ([paramTittleList isKindOfClass:[NSArray class]])
            {
                if (paramIndex >= [paramTittleList count])
                {
                    return nil;
                }
                id inputShortName = [paramTittleList objectAtIndex:(paramIndex)];
                if ([inputShortName isKindOfClass:[NSArray class]] && [inputShortName count] > 1)
                {
                    NSArray *sortNameList = (NSArray*)inputShortName;
                    view = [[VNGSegmentedControl alloc] initWithSectionTitles:sortNameList];
                    VNGSegmentedControl *segment = (VNGSegmentedControl *)view;
                    [segment addTarget:self action:@selector(segmentControlChangedValue:) forControlEvents:UIControlEventValueChanged];
                    segment.crossFadeLabelsOnDrag = YES;
                    segment.font = [UIFont getFontNormalSize13];
                    segment.textColor = [UIColor lightGrayColor];
                    segment.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
                    segment.height = 40;
                    [segment setSelectedSegmentIndex:0 animated:NO];
                    [segment setBackgroundTintColor:[UIColor whiteColor]];
                    segment.thumb.tintColor = [UIColor orangeColor];
                    segment.thumb.textColor = [UIColor whiteColor];
                    segment.thumb.textShadowColor = [UIColor clearColor];
                    segment.thumb.textShadowOffset = CGSizeMake(0, 1);
                    segment.tag = tag;
                    [segment setFrame:CGRectMake(MARGIN_EDGE_TABLE_GROUP, 0, (TABLE_VIEW_WIDTH - (2 * MARGIN_EDGE_TABLE_GROUP)), SEGMENT_HEIGHT)];
                    [self setObject:segment forKey:viewKey forConfirmView:forConfirmView];
                }
            }
        }
        else if ([inputName isKindOfClass:[NSDictionary class]])
        {
            view = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN_EDGE_TABLE_GROUP, 0, (TABLE_VIEW_WIDTH - (2 * MARGIN_EDGE_TABLE_GROUP)), SEGMENT_HEIGHT)];
            [view setContentMode:UIViewContentModeScaleAspectFit];
            [self setObject:view forKey:viewKey forConfirmView:forConfirmView];
        }
    }
    return view;
}

-(NSString*)viewInfoKeyWithParamIndex:(NSUInteger)paramIndex segmentIndex:(NSUInteger)segmentIndex forConfirmView:(BOOL)forConfirmView
{
    NSArray *paramNameList = [self getParamNameListForConfirmView:forConfirmView];
    if (paramIndex > [paramNameList count])
    {
        return nil;
    }
    id inputName = [paramNameList objectAtIndex:(paramIndex)];
    NSString *viewInfoKey = @"";
    if ([inputName isKindOfClass:[NSArray class]])
    {
        //option
        NSArray *idParamName = [((NSArray*)inputName) objectAtIndex:segmentIndex];
        if ([idParamName isKindOfClass:[NSArray class]])
        {
            viewInfoKey = [NSString stringWithFormat:@"%@_%d",[idParamName objectAtIndex:0], segmentIndex];
        }
        else
        {
            viewInfoKey = (NSString*)idParamName;
        }
    }
    else if ([inputName isKindOfClass:[NSDictionary class]])
    {
        viewInfoKey = [((NSDictionary*)inputName) objectForKey:BANK_INFO_KEY_USING_WEB_GET_CAPTCHA_URL];    
    }
    else
    {
        viewInfoKey = (NSString*)inputName;
    }
    return viewInfoKey;
}

-(CustomTextView *)inputViewAtParamIndex: (NSInteger) paramIndex forConfirmView:(BOOL)forConfirmView
{
    NSInteger tag = TAG_ADDED_NUMBER + paramIndex;
    NSString *segmentKey = [NSString stringWithFormat:@"viewWithTag_%d", tag];
    VNGSegmentedControl *segment = [self objectForKey:segmentKey forConfirmView:forConfirmView];
    NSInteger selectedIndex = 0;
    if (segment && [segment isKindOfClass:[VNGSegmentedControl class]])
    {
        selectedIndex = segment.selectedSegmentIndex;
    }
    
    NSString *viewInfoKey = [self viewInfoKeyWithParamIndex:paramIndex segmentIndex:selectedIndex forConfirmView:forConfirmView];
    if (!viewInfoKey)
    {
        return nil;
    }
    CustomTextView *input = [self inputViewWithViewInfoKey:viewInfoKey forConfirmView:(BOOL)forConfirmView];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        [input layoutWithRadius:CORNER_RADIUS_TEXT_BOX_ACCOUNT];
    }
    else
    {
        [input layoutWithRadius:0];
    }
    return input;
}

-(CustomTextView *)inputViewWithViewInfoKey:(NSString*)viewInfoKey forConfirmView:(BOOL)forConfirmView
{
    NSMutableDictionary *info = [self objectForKey:viewInfoKey forConfirmView:forConfirmView];
    CustomTextView *input = [info valueForKey:@"INPUT_VIEW"];
    return input;
}

-(void)initInputViewWithViewInfoKey:(NSString *)viewInfoKey paramType:(NSString*) paramType paramLimit:(NSArray*)paramLimit paramTitle:(NSString*)paramTitle withHeight:(float)height forConfirmView:(BOOL)forConfirmView
{
    CustomTextView *input = [[CustomTextView alloc] initWithFrame:CGRectMake(0, 0, TABLE_VIEW_WIDTH - 2*MARGIN_EDGE_TABLE_GROUP, height)];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        input.frame = CGRectMake(0, 0, TABLE_VIEW_WIDTH, height);
    }
    [input setDelegate:[MainViewController sharedMainViewController]];
    if (paramLimit && [paramLimit isKindOfClass:[NSArray class]] &&[paramLimit count] == 2)
    {
        [input setMinCharacter:[[paramLimit objectAtIndex:0] integerValue]];
        [input setMaxCharacter:[[paramLimit objectAtIndex:1] integerValue]];
    }
    if (paramTitle && [paramTitle isKindOfClass:[NSString class]] && paramTitle.length > 0)
    {
        [input setHolderText:paramTitle];
    }
    if (paramType && [paramType isKindOfClass:[NSString class]] && paramType.length > 0)
    {
        if ([paramType rangeOfString:BANK_INFO_KEY_PARAM_TYPE_DISABLE].location != NSNotFound)
        {
            [input setEnable:NO];
            [input setBackgroundColor:[UIColor grayColor]];
        }
        if ([paramType rangeOfString:BANK_INFO_KEY_PARAM_TYPE_BEGIN_DATE].location != NSNotFound || [paramType rangeOfString:BANK_INFO_KEY_PARAM_TYPE_EXPIRED_DATE].location != NSNotFound)
        {
            [input setEnable:NO];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChooseDate:)];
            input.tag = TAG_EXPIRED_DATE;
            if ([paramType rangeOfString:BANK_INFO_KEY_PARAM_TYPE_BEGIN_DATE].location != NSNotFound)
            {
                input.tag = TAG_BEGIN_DATE;
            }
            if (forConfirmView)
            {
                input.tag += TAG_ADDED_NUMBER;
            }
            [input addGestureRecognizer:tapGesture];
        }
        else
        {
            [input setInputTypeWithString:paramType];
        }
    }
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:input forKey:@"INPUT_VIEW"];
    [self setObject:info forKey:viewInfoKey forConfirmView:forConfirmView];
}

-(void)initInputViewsWithLoadInfo:(NSMutableDictionary*)loadInfo forConfirmView:(BOOL)forConfirmView
{
    NSArray *paramNameList = [self getParamNameListForConfirmView:forConfirmView];
    NSArray *paramTypeList = [self getParamTypeListForConfirmView:forConfirmView];
    NSArray *paramLimitList = [self getParamLimitListForConfirmView:forConfirmView];
    NSArray *paramTitleList = [self getParamTitleListForConfirmView:forConfirmView];
    NSArray *paramShortTitleList = [self getParamShortTitleListForConfirmView:forConfirmView];
    for (int i = 0; i < [paramNameList count]; i++)
    {
        CGFloat height = SEGMENT_HEIGHT;
        id inputName = [paramNameList objectAtIndex:i];
        id inputType = [paramTypeList objectAtIndex:i];
        id inputLimit = [paramLimitList objectAtIndex:i];
        id inputTitle = [paramTitleList objectAtIndex:i];
        id inputShortTitle = [paramShortTitleList objectAtIndex:i];
        NSString *viewInfoKey;
        NSString *variableType;
        NSArray *variableLimit;
        NSString *variableTitle;
        NSString *variableShortTitle = nil;
        if ([inputName isKindOfClass:[NSArray class]])
        {
            //option
            VNGSegmentedControl *segment = (VNGSegmentedControl *)[self viewAtParamIndex:i forConfirmView:forConfirmView];
            for(int j = 0; j < [((NSArray*)inputName) count]; j++)
            {
                viewInfoKey = [self viewInfoKeyWithParamIndex:i segmentIndex:j forConfirmView:forConfirmView];
                variableType = [((NSArray*)inputType) objectAtIndex:j];
                variableLimit = [((NSArray*)inputLimit) objectAtIndex:j];
                variableTitle = [((NSArray*)inputTitle) objectAtIndex:j];
                if (inputShortTitle)
                {
                    variableShortTitle = [((NSArray*)inputShortTitle) objectAtIndex:j];
                }
                [self initInputViewWithViewInfoKey:viewInfoKey paramType:variableType paramLimit:variableLimit paramTitle:variableShortTitle?variableShortTitle:variableTitle withHeight:height forConfirmView:forConfirmView];
                if (loadInfo)
                {
                    NSString *loadValue = [loadInfo valueForKey:viewInfoKey];
                    if (loadValue)
                    {
                        [[self inputViewWithViewInfoKey:viewInfoKey forConfirmView:forConfirmView] setText:loadValue];
                        [segment setSelectedSegmentIndex:j animated:NO];
                    }
                }
            }
        }
        else if ([inputName isKindOfClass:[NSDictionary class]])
        {
            viewInfoKey = [((NSDictionary*)inputName) objectForKey:BANK_INFO_KEY_USING_WEB_GET_CAPTCHA_URL];
            variableType = (NSString*)inputType;
            variableLimit = (NSArray*)inputLimit;
            variableTitle = (NSString*)inputTitle;
            UIImageView *view = (UIImageView *)[self viewAtParamIndex:i forConfirmView:forConfirmView];
            [self initInputViewWithViewInfoKey:viewInfoKey paramType:variableType paramLimit:variableLimit paramTitle:variableTitle withHeight:height forConfirmView:forConfirmView];
            if (loadInfo)
            {
                UIImage *image = [loadInfo objectForKey:BANK_INFO_KEY_USING_WEB_GET_CAPTCHA_URL];
                view.image = image;
            }
        }
        else
        {
            viewInfoKey = (NSString*)inputName;
            variableType = (NSString*)inputType;
            variableLimit = (NSArray*)inputLimit;
            variableTitle = (NSString*)inputTitle;
            [self initInputViewWithViewInfoKey:viewInfoKey paramType:variableType paramLimit:variableLimit paramTitle:variableTitle withHeight:height forConfirmView:forConfirmView];
            if (loadInfo)
            {
                NSString *loadValue = [loadInfo valueForKey:viewInfoKey];
                if (loadValue)
                {
                    [[self inputViewWithViewInfoKey:viewInfoKey forConfirmView:forConfirmView] setText:loadValue];
                }
            }
        }
    }
//    return YES;
}

-(NSMutableDictionary *)dictionaryInputForSending:(BOOL)sending forConfirmView:(BOOL)forConfirmView
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSArray *arr = [self getParamNameListForConfirmView:forConfirmView];
    
    NSArray *arrTypes;
    arrTypes = [self getParamTypeListForConfirmView:forConfirmView];
    
    for (int i = 0; i < [arr count]; i++)
    {
        id name = [arr objectAtIndex:i];
        id type;
        type = [arrTypes objectAtIndex:i];
        NSString *viewInfoKey = nil;
        NSString *paramSendKey = nil;
        NSString *typeName = nil;
        if ([name isKindOfClass:[NSArray class]])
        {
            VNGSegmentedControl *segment = (VNGSegmentedControl *)[self viewAtParamIndex:i forConfirmView:forConfirmView];
            viewInfoKey = [self viewInfoKeyWithParamIndex:i segmentIndex:segment.selectedSegmentIndex forConfirmView:forConfirmView];
            paramSendKey = viewInfoKey;
            NSArray *idParamName = [((NSArray*)name) objectAtIndex: segment.selectedSegmentIndex];
            if ([idParamName isKindOfClass:[NSArray class]])
            {
                paramSendKey = [idParamName objectAtIndex:0];
                if (idParamName.count == 3) // type to send
                {
                    [dic setObject:[idParamName objectAtIndex:2] forKey:(NSString *)[idParamName objectAtIndex:1]];
                }
            }
            typeName = [((NSArray*)type) objectAtIndex: segment.selectedSegmentIndex];
            if (!sending)
            {
                paramSendKey = viewInfoKey;
            }
        }
        else if ([name isKindOfClass:[NSDictionary class]])
        {
            viewInfoKey = [((NSDictionary *)name) objectForKey:BANK_INFO_KEY_USING_WEB_GET_CAPTCHA_URL];
            paramSendKey = viewInfoKey;
        }
        else
        {
            viewInfoKey = (NSString *)name;
            paramSendKey = viewInfoKey;
            typeName = (NSString *)type;
        }
        NSDictionary *info = [self objectForKey:viewInfoKey forConfirmView:forConfirmView];
        
        if ([info isKindOfClass:[NSDictionary class]])
        {
            CustomTextView *input = [info objectForKey:@"INPUT_VIEW"];
            if ([input isKindOfClass:[CustomTextView class]])
            {
                if ([input isInputValidationAndShowErrorAlert:sending])
                {
                    if(sending || !typeName || [typeName rangeOfString:BANK_INFO_KEY_PARAM_TYPE_NOT_SAVED].location == NSNotFound)
                    {
                        NSString *str = [input getText];
                        if (sending)
                        {
                            if (input.tag == TAG_BEGIN_DATE || input.tag == TAG_EXPIRED_DATE || input.tag == TAG_BEGIN_DATE_CONFIRM || input.tag == TAG_EXPIRED_DATE_CONFIRM) {
                                NSArray *arr = [str componentsSeparatedByString:@"/"];
                                NSArray *splitName = [typeName componentsSeparatedByString:@"~"];
                                if (splitName && [splitName count] == 3)
                                {
                                    [dic setObject:[arr objectAtIndex:0] forKey:[splitName objectAtIndex:1]];
                                    [dic setObject:[arr objectAtIndex:1] forKey:[splitName objectAtIndex:2]];
                                    str = nil;
                                }
                                else
                                {
                                    NSString *str1 = [NSString stringWithFormat:@"%@%@", [arr objectAtIndex:1], [arr objectAtIndex:0]];
                                    str = str1;
                                }
                            }
                            else if ([typeName rangeOfString:BANK_INFO_KEY_PARAM_TYPE_FORMAT].location != NSNotFound)
                            {
                                NSArray *arr = [typeName componentsSeparatedByString:@"|"];
                                NSString *format = nil;
                                for (NSString *str in arr)
                                {
                                    if ([str rangeOfString:BANK_INFO_KEY_PARAM_TYPE_FORMAT].location != NSNotFound)
                                    {
                                        NSArray *arr1 = [str componentsSeparatedByString:@"~"];
                                        if (arr1.count == 2)
                                        {
                                            format = [arr1 objectAtIndex:1];
                                        }
                                    }
                                }
                                if (format)
                                {
                                    NSString *str1 = [NSString stringWithFormat:format, str];
                                    str = str1;
                                }
                            }
                        }
                        if (str)
                        {
                            [dic setObject:str forKey:paramSendKey];
                        }
                    }
                }
                else
                {
                    return nil;
                }
            }
            else
            {
                return nil;
            }
        }
        else
        {
            return nil;
        }
        
    }
    return dic;
}


#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return 12;
    }
    else if (component == 1)
    {
        return NUMBER_YEAR_TO_SHOW;
    }
    else
    {
    }
    return 0;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    { //month
        if (row < 9)
        {
            return [NSString stringWithFormat:@"0%d", row + 1];
        }
        return[ NSString stringWithFormat:@"%d",row + 1];
    }
    else if (component == 1)
    { //year
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:NSYearCalendarUnit fromDate:[NSDate date]];
        NSInteger year = [components year];
        if (pickerView.tag == TAG_BEGIN_DATE || pickerView.tag == TAG_BEGIN_DATE_CONFIRM)
        {
            year -= row;
        }
        else
        {
            year += row;
        }
        return [NSString stringWithFormat:@"%d", year];
    }
    else
    {
        
    }
    return nil;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0) {
        return 40.0;
    }else if (component == 1) {
        return 100.0;
    } else {
    }
    return 0;
}

- (void)handleChooseDate:(UITapGestureRecognizer*)tapGesture
{
    CustomTextView *input = (CustomTextView *)tapGesture.view;
    NSString *titleDate = @"Chọn ngày";
    if([input isKindOfClass:[CustomTextView class]])
    {
        titleDate = input.holderText;
        NSInteger tag = input.tag;
        NSString *key = @"expired_pickup_key";
        BOOL isConfirmView = (tag == TAG_EXPIRED_DATE_CONFIRM || tag == TAG_BEGIN_DATE_CONFIRM);
        if (tag == TAG_BEGIN_DATE || tag == TAG_BEGIN_DATE_CONFIRM)
        {
            key = @"begin_pickup_key";
        }
        
        [self setObject:input forKey:key forConfirmView:isConfirmView];
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:titleDate
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    CGRect pickerFrame = CGRectMake(0, 40, 320, 120);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.tag = input.tag;
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    
    [actionSheet addSubview:pickerView];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Chọn"]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260.0f, 7.0f, 50.0f, 30.0f);
    
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    closeButton.tag = input.tag;
    [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:closeButton];
    
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [actionSheet setBounds:CGRectMake(0, 0, 320, 365)];
}

- (void)dismissActionSheet:(UISegmentedControl*)sender
{
    NSInteger tag = sender.tag;
    NSString *key = @"expired_pickup_key";
    BOOL isConfirmView = (tag == TAG_EXPIRED_DATE_CONFIRM || tag == TAG_BEGIN_DATE_CONFIRM);
    if (tag == TAG_BEGIN_DATE || tag == TAG_BEGIN_DATE_CONFIRM)
    {
        key = @"begin_pickup_key";
    }
    CustomTextView *input = [self objectForKey:key forConfirmView:isConfirmView];
    
    UIActionSheet* acsheet = (UIActionSheet*)[sender superview];
    UIPickerView* picker = (UIPickerView*)[acsheet viewWithTag:tag];
    NSInteger month = [picker selectedRowInComponent:0] + 1;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components: NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger nowYear = [components year];
    NSInteger year = nowYear + [picker selectedRowInComponent:1];
    if (sender.tag == TAG_BEGIN_DATE || sender.tag == TAG_BEGIN_DATE_CONFIRM)
    {
        year = nowYear - [picker selectedRowInComponent:1];
    }
    int shortYear = (year % 1000) % 100;
    
    NSInteger nowMonth = [components month];
    BOOL valid = NO;
    if(tag == TAG_BEGIN_DATE || sender.tag == TAG_BEGIN_DATE_CONFIRM)
    {
        if(year <= nowYear)
        {
            if(year < nowYear || month <= nowMonth)
            {
                valid = YES;
            }
        }
    }
    else if(year >= nowYear)
    {
        if(year > nowYear || month >= nowMonth)
        {
            valid = YES;
        }
    }
    if (valid && [input isKindOfClass:[CustomTextView class]])
    {
        if (month < 10)
        {
            [input setText:[NSString stringWithFormat:@"0%d/%d", month, shortYear]];
        }
        else
        {
            [input setText:[NSString stringWithFormat:@"%d/%d", month, shortYear]];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:[NSString stringWithFormat:ERROR_DESCRIPTION_WRONG_DATE, input.holderText] delegate:nil cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil];
        [alert show];
    }
    [acsheet dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - UIControlEventValueChanged
- (void)segmentControlChangedValue:(VNGSegmentedControl*)segmentControl
{
    NSArray *arr = [_viewInfo allKeysForObject:segmentControl];
    BOOL forConfirmView = (!arr || arr.count == 0);
    if (forConfirmView)
    {
        if (self.confirmDelegate && [self.confirmDelegate respondsToSelector:@selector(segmentControl:didChangeAtParamIndex:)])
        {
            int index = segmentControl.tag - TAG_ADDED_NUMBER;
            [self.confirmDelegate segmentControl:segmentControl didChangeAtParamIndex: index];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(segmentControl:didChangeAtParamIndex:)])
        {
            int index = segmentControl.tag - TAG_ADDED_NUMBER;
            [self.delegate segmentControl:segmentControl didChangeAtParamIndex: index];
        }
    }
}

-(id)objectForKey:(NSString *)key forConfirmView:(BOOL)forConfirmView
{
    if (forConfirmView)
    {
        return [_confirmViewInfo objectForKey:key];
    }
    return [_viewInfo objectForKey:key];
}

-(void)setObject:(id)object forKey:(NSString*)key forConfirmView:(BOOL)forConfirmView
{
    if (forConfirmView)
    {
        [_confirmViewInfo setObject:object forKey:key];
    }
    else
    {
        [_viewInfo setObject:object forKey:key];
    }
}

#pragma mark dynamic input end
@end
