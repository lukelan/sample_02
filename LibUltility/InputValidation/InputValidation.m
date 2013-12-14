//
//  InputValidation.m
//  123Phim
//
//  Created by phuonnm on 5/14/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "InputValidation.h"

@implementation InputValidation

+ (BOOL)validateEmail:(NSString *)inputText isShowError:(BOOL)isShow
{
    if (!inputText || inputText.length == 0) {
        return NO;
    }
    NSString *emailRegex = @"[A-Z0-9a-z][A-Z0-9a-z._%+-]*@[A-Za-z0-9][A-Za-z0-9.-]*\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    NSRange aRange;
    if([emailTest evaluateWithObject:inputText]) {
        aRange = [inputText rangeOfString:@"." options:NSBackwardsSearch range:NSMakeRange(0, [inputText length])];
        int indexOfDot = aRange.location;
        //NSLog(@"aRange.location:%d - %d",aRange.location, indexOfDot);
        if(aRange.location != NSNotFound) {
            NSString *topLevelDomain = [inputText substringFromIndex:indexOfDot];
            topLevelDomain = [topLevelDomain lowercaseString];
            //NSLog(@"topleveldomains:%@",topLevelDomain);
            NSSet *TLD;
            TLD = [NSSet setWithObjects:@".aero", @".asia", @".biz", @".cat", @".com", @".coop", @".edu", @".gov", @".info", @".int", @".jobs", @".mil", @".mobi", @".museum", @".name", @".net", @".org", @".pro", @".tel", @".travel", @".ac", @".ad", @".ae", @".af", @".ag", @".ai", @".al", @".am", @".an", @".ao", @".aq", @".ar", @".as", @".at", @".au", @".aw", @".ax", @".az", @".ba", @".bb", @".bd", @".be", @".bf", @".bg", @".bh", @".bi", @".bj", @".bm", @".bn", @".bo", @".br", @".bs", @".bt", @".bv", @".bw", @".by", @".bz", @".ca", @".cc", @".cd", @".cf", @".cg", @".ch", @".ci", @".ck", @".cl", @".cm", @".cn", @".co", @".cr", @".cu", @".cv", @".cx", @".cy", @".cz", @".de", @".dj", @".dk", @".dm", @".do", @".dz", @".ec", @".ee", @".eg", @".er", @".es", @".et", @".eu", @".fi", @".fj", @".fk", @".fm", @".fo", @".fr", @".ga", @".gb", @".gd", @".ge", @".gf", @".gg", @".gh", @".gi", @".gl", @".gm", @".gn", @".gp", @".gq", @".gr", @".gs", @".gt", @".gu", @".gw", @".gy", @".hk", @".hm", @".hn", @".hr", @".ht", @".hu", @".id", @".ie", @" No", @".il", @".im", @".in", @".io", @".iq", @".ir", @".is", @".it", @".je", @".jm", @".jo", @".jp", @".ke", @".kg", @".kh", @".ki", @".km", @".kn", @".kp", @".kr", @".kw", @".ky", @".kz", @".la", @".lb", @".lc", @".li", @".lk", @".lr", @".ls", @".lt", @".lu", @".lv", @".ly", @".ma", @".mc", @".md", @".me", @".mg", @".mh", @".mk", @".ml", @".mm", @".mn", @".mo", @".mp", @".mq", @".mr", @".ms", @".mt", @".mu", @".mv", @".mw", @".mx", @".my", @".mz", @".na", @".nc", @".ne", @".nf", @".ng", @".ni", @".nl", @".no", @".np", @".nr", @".nu", @".nz", @".om", @".pa", @".pe", @".pf", @".pg", @".ph", @".pk", @".pl", @".pm", @".pn", @".pr", @".ps", @".pt", @".pw", @".py", @".qa", @".re", @".ro", @".rs", @".ru", @".rw", @".sa", @".sb", @".sc", @".sd", @".se", @".sg", @".sh", @".si", @".sj", @".sk", @".sl", @".sm", @".sn", @".so", @".sr", @".st", @".su", @".sv", @".sy", @".sz", @".tc", @".td", @".tf", @".tg", @".th", @".tj", @".tk", @".tl", @".tm", @".tn", @".to", @".tp", @".tr", @".tt", @".tv", @".tw", @".tz", @".ua", @".ug", @".uk", @".us", @".uy", @".uz", @".va", @".vc", @".ve", @".vg", @".vi", @".vn", @".vu", @".wf", @".ws", @".ye", @".yt", @".za", @".zm", @".zw", nil];
            if(topLevelDomain != nil && ([TLD containsObject:topLevelDomain])) {
                //NSLog(@"TLD contains topLevelDomain:%@",topLevelDomain);
                return YES;
            }
            /*else {
             NSLog(@"TLD DOEST NOT contains topLevelDomain:%@",topLevelDomain);
             }*/
            
        }
    }
    if (isShow) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:THANHTOAN_ERROR_WRONG_EMAIL_FORMAT delegate:nil cancelButtonTitle:nil otherButtonTitles:ALERT_BUTTON_OK, nil];
        [alert show];
    }
    return NO;
}

+ (BOOL)validatePhone:(NSString *)phoneNumber withSize: (CGSize) size  isShowError:(BOOL)isShow
{
    if (!phoneNumber || (phoneNumber.length < size.width || phoneNumber.length > size.height))
    {
        if (isShow)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:[NSString stringWithFormat:ERROR_DESCRIPTION_WRONG_LENG_PHONE, [NSString stringWithFormat:@"%d", (int)size.width], [NSString stringWithFormat:@"%d", (int)size.height]] delegate:nil cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil , nil];
            [alert show];
        }
        return NO;
    }
    NSMutableString *strConvert = [[NSMutableString alloc] initWithString:phoneNumber];
    NSString *strHeaderPhone = @"";
    if ([[phoneNumber substringToIndex:2] isEqualToString:@"84"])
    {
        strHeaderPhone = [strConvert substringWithRange:NSMakeRange(2, 3)];
    }
    else if ([[phoneNumber substringToIndex:1] isEqualToString:@"0"]) {
        strHeaderPhone = [strConvert substringWithRange:NSMakeRange(1, 3)];
    }
    else
    {
        if (isShow)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:ERROR_DESCRIPTION_WRONG_SUPPORT_PHONE delegate:nil cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil , nil];
            [alert show];
        }
        return NO;
    }
    @try
    {
        // do something that might throw an exception
        NSString *fileNameTextDefine = [NSString stringWithFormat:@"%@/%@",DOCUMENTS_PATH, FILE_NAME_TEXT_DEFINE];
        NSDictionary *offDic = [NSDictionary dictionaryWithContentsOfFile:fileNameTextDefine];
        if (!offDic) {
            return YES;
        }
        NSArray *listPhoneSupport = [offDic objectForKey:LIST_PHONE_SUPPORT];
        if (!listPhoneSupport || ![listPhoneSupport isKindOfClass:[NSArray class]]) {
            return YES;
        }
        BOOL isValid = [listPhoneSupport containsObject:strHeaderPhone];//neu ma ko nam trong list support => failed
        if (!isValid && isShow)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:ERROR_DESCRIPTION_WRONG_SUPPORT_PHONE delegate:nil cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil , nil];
            [alert show];
        }
        return isValid;
    }
    @catch (NSException *exception)
    {
        // deal with the exception
        NSLog(@"Exception = %@", exception.description);
    }
    @finally
    {
        // optional block of clean-up code
        // executed whether or not an exception occurred        
    }    
    return NO;
}

+ (BOOL)validateLength:(NSString *)text withSize: (CGSize) size isShowErrorWithTitle:(NSString*)inputTitle
{
    if (!text || text.length == 0)
    {
        if (size.width >= 0)
        {
            if (inputTitle && inputTitle.length > 0)
            {
                NSString *des = [NSString stringWithFormat:ERROR_DESCRIPTION_WRONG_INPUT_EMPTY, inputTitle];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:des delegate:nil cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil , nil];
                [alert show];
            }
            return NO;
        }
        return YES;
    }

    if ((size.width >= 0 && text.length < size.width) || (size.height >= 0 && text.length > size.height))
    {
        if (inputTitle && inputTitle.length > 0)
        {
            NSString *des = [NSString stringWithFormat:ERROR_DESCRIPTION_WRONG_RANGE_LENGTH_INPUT, inputTitle, [NSString stringWithFormat:@"%d", (int)size.width], [NSString stringWithFormat:@"%d", (int)size.height]];
            if (size.width == size.height)
            {
                des = [NSString stringWithFormat:ERROR_DESCRIPTION_WRONG_FORCE_LENGTH_INPUT, inputTitle, [NSString stringWithFormat:@"%d", (int)size.width]];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:des delegate:nil cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles:nil , nil];
            [alert show];
        }
        return NO;
    }
    return YES;
}
@end
