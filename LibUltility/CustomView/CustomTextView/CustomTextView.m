//
//  CustomTextView.m
//  123Phim
//
//  Created by Le Ngoc Duy on 5/3/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
#define MAX_CHARACTER_TO_ADD_SPACE  4

#define ERROR_INPUT_DIFFER_NUMBER @"Chỉ chấp nhận ký tự số"
#define ERROR_INPUT_ASCII_ONLY @"Chỉ chấp nhận ký tự không dấu"

#import "CustomTextView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomTextView
@synthesize lblHolderDisplayReview;
@synthesize minCharacter, maxCharacter, enable;
@synthesize inputType = _inputType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initProperties];
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame inputType: (InputType) inputType
{
    self = [self initWithFrame:frame];
    if (self)
    {
        self.inputType = inputType;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self initProperties];
    }
    return self;
}

-(void)initProperties
{
    minCharacter = -1;
    maxCharacter = -1;
    iNextCharacter = -1;
    _contentString = @"";
    _maskString = @"*";
    _inputType = 0;
    _seperatorCharacter = ' ';
    _regexFormater = [[NSString stringWithFormat: @"(.{%d})", MAX_CHARACTER_TO_ADD_SPACE] copy];
    _maskRange = NSMakeRange(0, NSIntegerMax);
    _textView = [[UITextView alloc] init];
    _textView.clipsToBounds = NO;
    _textView.layer.masksToBounds = YES;
    _textView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    _textView.delegate=self;
    _textView.textColor=[UIColor blackColor];
    _textView.text  = @"";
    [_textView setFont:[UIFont getFontNormalSize13]];
    [_textView setBackgroundColor:[UIColor clearColor]];
    _textView.keyboardType = UIKeyboardTypeDefault;
    lblHolderDisplayReview =[[UILabel alloc] init];
    lblHolderDisplayReview.font=_textView.font;
    lblHolderDisplayReview.textColor=[UIColor lightGrayColor];
    [lblHolderDisplayReview setBackgroundColor:[UIColor clearColor]];
    [self addSubview:lblHolderDisplayReview];
    [self addSubview:_textView];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //Release resource
    _textView = nil;
    _ivInvalidIcon  = nil;
    self.holderText = nil;
    self.clearImage = nil;
    self.invalidImage = nil;
    lblHolderDisplayReview = nil;
}

#pragma mark define method
-(BOOL)hasText
{
    if (_textView) {
        return [_textView hasText];
    }
    return NO;
}

-(BOOL)resignFirstResponder
{
    if (_textView)
    {
        if (_textView.autocapitalizationType == UITextAutocapitalizationTypeAllCharacters)
        {
            NSString *str = [_textView.text uppercaseString];
            _contentString = str;
        }
        return [_textView resignFirstResponder];
    }
    return NO;
}

-(BOOL)becomeFirstResponder
{
    if (_textView) {
        return [_textView becomeFirstResponder];
    }
    return NO;
}

-(void)setEnable:(BOOL)editable
{
    if (_textView) {
        [_textView setEditable:editable];
    }
}

-(NSString *)getText
{
    return _contentString;
}

-(void)setText:(NSString *)textTitle
{
    if (textTitle && textTitle.length > 0)
    {
        [lblHolderDisplayReview setHidden:YES];
        _contentString = [textTitle copy];
        [self correctAndDisplayContentWithWillResign:NO];
    }
    else
    {
        _textView.text = @"";
        _contentString = @"";
        [lblHolderDisplayReview setHidden:NO];
        [self setClearButtonHidden:YES];
    }
}

-(void)setAutocapitalizationType:(UITextAutocapitalizationType) typeAuto
{
    if (_textView) {
        [_textView setAutocapitalizationType:typeAuto];
    }
}

-(void)setBackGroundImage:(UIImage *)imgBackGround
{
    UIImageView *imgViewBG = [[UIImageView alloc] initWithImage:imgBackGround];
    imgViewBG.frame = _textView.frame;
    [self insertSubview:imgViewBG atIndex:0];
}

-(void)setKeyBoardType:(UIKeyboardType)keyboardType
{
    if (_textView) {
        [_textView setKeyboardType:keyboardType];
        if (keyboardType == UIKeyboardTypeEmailAddress || keyboardType == UIKeyboardTypeNumberPad)
        {
            _acceptAnsciiCharacterOnly = YES;
        }
    }
}

-(void)setKeyBoardAppearType:(UIKeyboardAppearance)keyboardTypeAppear
{
    if (_textView) {
        [_textView setKeyboardAppearance:keyboardTypeAppear];
    }
}

-(void)setKeyBoardReturnKeyType:(UIReturnKeyType)keyboardTypeReturn
{
    if (_textView) {
        [_textView setReturnKeyType:keyboardTypeReturn];
    }
}

-(void)layoutWithRadius:(CGFloat)curRadius
{
    [self layoutWithRadius:curRadius andImageIcon:nil hoderText:self.holderText];
}

-(void)layoutWithRadius:(CGFloat)curRadius andImageIcon:(UIImage *)imageIcon hoderText:(NSString *)holderText
{
    [self.layer setCornerRadius:curRadius];
    [_textView.layer setCornerRadius:curRadius];
    lblHolderDisplayReview.text = holderText;
    [_textView setFrame:CGRectMake(0, 0,self.frame.size.width, self.frame.size.height)];
    CGRect size = _textView.frame;
    size.origin.x = curRadius;
    size.size.width -= curRadius;
    [lblHolderDisplayReview setFrame:size];
    if (imageIcon)
    {
        [self setInvalidImage:imageIcon];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(registerForKeyboardNotifications)])
    {
        [_delegate registerForKeyboardNotifications];
    }
}

#pragma mark textField delegate

-(void)maskCharInRange: (NSRange) range
{
    if (!_textView || _textView.text.length == 0)
    {
        return;
    }
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"." options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    if (range.location < [_textView.text length])
    {
        if (NSMaxRange(range) > [_textView.text length])
        {
            range = NSMakeRange(range.location, [_textView.text length] - range.location);
        }
        NSString *str = [regex stringByReplacingMatchesInString:_textView.text options:0 range:range withTemplate:_maskString];
        _textView.text = str;
    }
}

-(void)correctAndDisplayContentWithWillResign:(BOOL) willResign
{
    NSRange seletedRange = NSMakeRange([_textView selectedRange].location, 0);
    NSInteger len = _textView.text.length;
    _textView.text = _contentString;
    
    if (_textView.autocapitalizationType == UITextAutocapitalizationTypeAllCharacters)
    {
        _textView.text = [_contentString uppercaseString];
    }
    if (_inputType == INPUT_TYPE_PASSWORD)
    {
        [self maskCharInRange: NSMakeRange(0, _contentString.length)];
    }
    else if (_inputType == INPUT_TYPE_SEPERATION)
    {
        // update string
        // may be mask chars
        if (_isMaskCharacter)
        {
            _contentString = [[self removeSeperatorCharFromString:_contentString] copy];
            [self maskCharInRange:_maskRange];
            _textView.text = [self addSeperaterCharWithString:_textView.text];
        }
        else
        {
            _contentString = [[self removeSeperatorCharFromString:_textView.text] copy];
            _textView.text = [self addSeperaterCharWithString:_contentString]; // when set text
        }
    }
    // update selected range
    if (_acceptAnsciiCharacterOnly)
    {
        if (len < _textView.text.length)
        {
            // maybe unicode type
            int loc = seletedRange.location + _textView.text.length - len;
            if (loc <= _textView.text.length)
            {
                seletedRange = NSMakeRange(loc, 0);
            }
        }
        if (_inputType == INPUT_TYPE_SEPERATION)
        {
            // check seperator char
            if (len != _textView.text.length)
            {
                if (seletedRange.location - 1 < _textView.text.length)
                {
                    int ch = [_textView.text characterAtIndex:seletedRange.location - 1];
                    if (ch == _seperatorCharacter) {
                        seletedRange = NSMakeRange(seletedRange.location + 1, 0);
                    }
                }
            }
        }
    }
    if (NSMaxRange(seletedRange) <= _textView.text.length)
    {
        [_textView setSelectedRange:seletedRange];
    }

}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self correctAndDisplayContentWithWillResign:YES];
    [self setClearButtonHidden:YES];
    [self setInvalidImageHidden:[self isInputValidationAndShowErrorAlert:NO]];
    return YES;
}

-(void)maskLastCharacter
{
    [self maskCharInRange: NSMakeRange(_contentString.length - 1, 1)];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView hasText])
    {
        [self setClearButtonHidden:NO];
        // syn _contentString & textView.text
        if (_inputType == INPUT_TYPE_NORMAL && !_acceptAnsciiCharacterOnly)
        {
            //    recheck valid length for case: unicode
            if (maxCharacter < 0 || textView.text.length <= maxCharacter)
            {
                // unicode string mapped to textview.text but _contentString
                _contentString = [textView.text copy];
            }
        }
        [self correctAndDisplayContentWithWillResign:NO];
        [lblHolderDisplayReview setHidden:YES];
    }
    else
    {
        _contentString = @"";
        if (_inputType == INPUT_TYPE_MASK_SOME_CHARACTER) {
            _inputType = INPUT_TYPE_SEPERATION;
        }
        [lblHolderDisplayReview setHidden:NO];
    }
}

-(void)setClearButtonHidden:(BOOL)hidden
{
    if (!hidden)
    {
        if (!_btnClearIcon)
        {
            if (!self.clearImage)
            {
                self.clearImage = [UIImage imageNamed:@"clearIcon.png"];
            }
            _btnClearIcon = [UIButton buttonWithType:UIButtonTypeCustom];
            [_btnClearIcon setImage:self.clearImage forState:UIControlStateNormal];
            CGRect frame = CGRectMake(self.frame.size.width - self.clearImage.size.width, (self.frame.size.height - self.clearImage.size.height)/2, self.clearImage.size.width, self.clearImage.size.height);
            [_btnClearIcon setFrame:frame];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearText:)];
            [_btnClearIcon addGestureRecognizer:tap];
            [self addSubview:_btnClearIcon];
        }
    }
    [_btnClearIcon setHidden:hidden];
}

-(void)clearText:(id)sender
{
    [self setText:@""];
    [self setClearButtonHidden:YES];
}   

-(void)setInvalidImageHidden:(BOOL)hidden
{
    if (!hidden)
    {
        if (!_ivInvalidIcon)
        {
            if (!self.invalidImage)
            {
                self.invalidImage = [UIImage imageNamed:@"invalidIcon.png"];
            }
            _ivInvalidIcon = [[UIImageView alloc] initWithImage:self.invalidImage];
            [_ivInvalidIcon setFrame:CGRectMake(self.frame.size.width - self.layer.cornerRadius - self.invalidImage.size.width, (self.frame.size.height - self.invalidImage.size.height)/2, self.invalidImage.size.width, self.invalidImage.size.height)];
            [self addSubview:_ivInvalidIcon];
        }
    }
    [_ivInvalidIcon setHidden:hidden];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(setActiveInputView:)]) {
        [_delegate setActiveInputView:nil];
    }
    [self setInvalidImageHidden:YES];
    if (textView.hasText)
    {
        [self setClearButtonHidden:NO];
    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(setActiveInputView:)]) {
        [_delegate setActiveInputView:self];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)textContent
{
    if([textContent isEqualToString:@"\n"])
    {
        // return key
        [self resignFirstResponder];
        if (_delegate && [_delegate respondsToSelector:@selector(processKeyReturn:)])
        {
            [_delegate processKeyReturn:textView.keyboardType];
        }
        return NO;
    }
    
    if(_inputType == INPUT_TYPE_SEPERATION && _isMaskCharacter)
    {
        [self setIsMaskCharacter:NO];
        if ([self getText] && [self getText].length > 0)
        {
            [self setText:@""];
            return NO;
        }
    }
    
//    check acceptable
    if (_acceptAnsciiCharacterOnly)
    {
        
        // check valid
        if(textView.keyboardType == UIKeyboardTypeNumberPad)
        {
            // number only
            if (![textContent isAllDigits]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:ERROR_INPUT_DIFFER_NUMBER delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
                [alert show];
                return NO;
            }
        }
        else
        {
            for (int i = 0; i < textContent.length; i ++) {
                unichar c = [textContent characterAtIndex:i];
                if (c > 127)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:ERROR_INPUT_ASCII_ONLY delegate:nil cancelButtonTitle:nil otherButtonTitles:ALERT_BUTTON_OK, nil];
                    [alert show];
                    return NO;
                }
            }
        }
        
        // check length if only ansii
        NSString *newString;
        if (_isMaskCharacter)
        {
            newString = [[_contentString stringByReplacingCharactersInRange:range withString:textContent]copy];
        }
        else
        {
            newString = [[textView.text stringByReplacingCharactersInRange:range withString:textContent]copy];
            if (_inputType == INPUT_TYPE_SEPERATION)
            {
                NSString *str = [newString copy];
                newString = [[str stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c",_seperatorCharacter] withString:@""] copy];
            }
        }
        if (textContent && [textContent length] > 0) // except del key
        {
            if ( maxCharacter > 0 && newString.length > maxCharacter)
            {
                return NO;
            }
        }
        _contentString = [newString copy];
    }
    return YES;
}

-(BOOL) isInputValidationAndShowErrorAlert:(BOOL)isShowDialogError
{
    switch (_inputType)
    {
        case INPUT_TYPE_EMAIL:
            return [InputValidation validateEmail:[self getText] isShowError:isShowDialogError];
       case INPUT_TYPE_PHONE:
            return [InputValidation validatePhone:[self getText] withSize:CGSizeMake(minCharacter, maxCharacter)  isShowError:isShowDialogError];
        default:
            return [InputValidation validateLength:[self getText] withSize:CGSizeMake(minCharacter, maxCharacter) isShowErrorWithTitle:isShowDialogError? self.lblHolderDisplayReview.text : nil];
    }
}

- (BOOL)isValidateDataLength
{
    if (!_contentString
        || (minCharacter >= 0 && _contentString.length < minCharacter)
        || (maxCharacter >= 0 && _contentString.length > maxCharacter))
    {
       return NO;
    }
    return YES;
}

-(void)setMaskCharacter:(int)maskCharacter
{
    if (maskCharacter > 0)
    {
        _maskString = [NSString stringWithFormat:@"%c", maskCharacter];
        if (_textView && _textView.text.length > 0)
        {
            [self maskCharInRange:NSMakeRange(0, _textView.text.length)];
        }
    }
    else
    {
        _textView.text = _contentString;
    }
}

-(void)setFormatRegex: (NSString*)regex seperatorCharacter: (char) character;
{
    _regexFormater = [regex copy];
    _seperatorCharacter = character;
}

-(void)setInputType:(InputType)inputType
{
    _inputType = inputType;
    _acceptAnsciiCharacterOnly = (_acceptAnsciiCharacterOnly || (inputType == INPUT_TYPE_EMAIL) || (inputType ==INPUT_TYPE_PASSWORD) || (inputType ==INPUT_TYPE_SEPERATION));
    
    _isMaskCharacter = (_isMaskCharacter || (inputType ==INPUT_TYPE_PASSWORD) || (inputType ==INPUT_TYPE_MASK_SOME_CHARACTER));
    if (_inputType == INPUT_TYPE_EMAIL)
    {
        [self setKeyBoardType:UIKeyboardTypeEmailAddress];
    }
}

-(NSString *)addSeperaterCharWithString:(NSString *)string
{
    NSString *rs = [string copy];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_regexFormater options:NSRegularExpressionCaseInsensitive error:&error];
;
    NSString * seperator = [NSString stringWithFormat:@"%c", _seperatorCharacter];
    NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    if (matches)
    {
        for (NSInteger i = matches.count - 1; i >= 0; i--)
        {
            NSTextCheckingResult *match = [matches objectAtIndex:i];
            if (match.range.location + match.range.length >= rs.length)
            {
                continue;
            }
            NSString *substr;
            substr = [rs stringByReplacingCharactersInRange: NSMakeRange(match.range.location + match.range.length, 0) withString:seperator];
            rs = substr;
        }
    }
    return rs;
}

-(NSString *)removeSeperatorCharFromString:(NSString*)string
{
   NSString *rs = [string copy];
    NSString * seperator = [NSString stringWithFormat:@"%c", _seperatorCharacter];
    return [rs stringByReplacingOccurrencesOfString:seperator withString:@""];
}

-(void)setMaskRange:(NSRange)maskRange
{
    _maskRange = maskRange;
    _isMaskCharacter = YES;
}

-(void)setInputTypeWithString:(NSString *)strInputType
{
    if (strInputType && strInputType.length > 0)
    {
        NSArray *arr = [strInputType componentsSeparatedByString:@"|"];
        for (NSString *type in arr)
        {
            if ([type isEqualToString:INPUT_STRING_TYPE_ASCII])
            {
                [self setAcceptAnsciiCharacterOnly:YES];
            }
            else if ([type isEqualToString:INPUT_STRING_TYPE_STRING])
            {
                // normal
            }
            else if ([type isEqualToString:INPUT_STRING_TYPE_PASSWORD])
            {
                [self setInputType:INPUT_TYPE_PASSWORD];
            }
            else if ([type isEqualToString:INPUT_STRING_TYPE_SEPERATION])
            {
                [self setInputType:INPUT_TYPE_SEPERATION];
            }
            else if ([type isEqualToString:INPUT_STRING_TYPE_NUMBER])
            {
                [self setKeyBoardType:UIKeyboardTypeNumberPad];
            }
            else if ([type isEqualToString:INPUT_STRING_TYPE_PHONE])
            {
                [self setInputType:INPUT_TYPE_PHONE];
                [self setKeyBoardType:UIKeyboardTypeNumberPad];
            }
            else if ([type isEqualToString:INPUT_STRING_TYPE_UPPERCASE])
            {
                [self setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
            }
            else if ([type isEqualToString:INPUT_STRING_TYPE_EMAIL])
            {
                [self setInputType:INPUT_TYPE_EMAIL];
            }
            else
            {
                NSArray *arr1 = [type componentsSeparatedByString:@"~"];
                for (int i = 0; i < [arr1 count]; i++)
                {
                    NSString *type1 = [arr1 objectAtIndex:i];
                    if ([type1 isEqualToString:INPUT_STRING_TYPE_SET_MASK])
                    {
                        NSString *strRange = [arr1 objectAtIndex:++i];
                        NSRange range = NSRangeFromString(strRange);
                        [self setMaskRange:range];
                    }
                }
            }
        }
    }
}

@end
