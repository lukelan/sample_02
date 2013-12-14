//
//  NSString+App.m
//  123Phim
//
//  Created by Nhan Mai on 5/22/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "NSString+App.h"

@implementation NSString (App)
- (NSString*) reverseString
{
    NSMutableString *reversedStr;
    int len = [self length];
    
    // auto released string
    reversedStr = [NSMutableString stringWithCapacity:len];
    
    // quick-and-dirty implementation
    while ( len > 0 )
        [reversedStr appendString:[NSString stringWithFormat:@"%C",[self characterAtIndex:--len]]];
    
    return reversedStr;
}

+ (NSString*)stringWithoutCharacterFrom: (NSString*)inStr
{
    NSArray* chacArray = [NSArray arrayWithObjects:
                          @"à",@"á",@"ạ",@"ả",@"ã",@"â",@"ầ",@"ấ",@"ậ",@"ẩ",@"ẫ",@"ă",@"ằ",@"ắ",@"ặ",@"ẳ",@"ẵ"
                          ,@"è",@"é",@"ẹ",@"ẻ",@"ẽ",@"ê",@"ề",@"ế",@"ệ",@"ể",@"ễ"
                          ,@"ì",@"í",@"ị",@"ỉ",@"ĩ"
                          ,@"ò",@"ó",@"ọ",@"ỏ",@"õ",@"ô",@"ồ",@"ố",@"ộ",@"ổ",@"ỗ",@"ơ",@"ờ",@"ớ",@"ợ",@"ở",@"ỡ"
                          ,@"ù",@"ú",@"ụ",@"ủ",@"ũ",@"ư",@"ừ",@"ứ",@"ự",@"ử",@"ữ"
                          ,@"ỳ",@"ý",@"ỵ",@"ỷ",@"ỹ"
                          ,@"đ"
                          ,@"À",@"Á",@"Ạ",@"Ả",@"Ã",@"Â",@"Ầ",@"Ấ",@"Ậ",@"Ẩ",@"Ẫ",@"Ă"
                          ,@"Ằ",@"Ắ",@"Ặ",@"Ẳ",@"Ẵ"
                          ,@"È",@"É",@"Ẹ",@"Ẻ",@"Ẽ",@"Ê",@"Ề",@"Ế",@"Ệ",@"Ể",@"Ễ"
                          ,@"Ì",@"Í",@"Ị",@"Ỉ",@"Ĩ"
                          ,@"Ò",@"Ó",@"Ọ",@"Ỏ",@"Õ",@"Ô",@"Ồ",@"Ố",@"Ộ",@"Ổ",@"Ỗ",@"Ơ"
                          ,@"Ờ",@"Ớ",@"Ợ",@"Ở",@"Ỡ"
                          ,@"Ù",@"Ú",@"Ụ",@"Ủ",@"Ũ",@"Ư",@"Ừ",@"Ứ",@"Ự",@"Ử",@"Ữ"
                          ,@"Ỳ",@"Ý",@"Ỵ",@"Ỷ",@"Ỹ"
                          ,@"Đ", nil];
    
    NSArray* noChacArray = [NSArray arrayWithObjects:
                            @"a",@"a",@"a",@"a",@"a",@"a",@"a",@"a",@"a",@"a",@"a",@"a",@"a",@"a",@"a",@"a",@"a"
                            ,@"e",@"e",@"e",@"e",@"e",@"e",@"e",@"e",@"e",@"e",@"e"
                            ,@"i",@"i",@"i",@"i",@"i"
                            ,@"o",@"o",@"o",@"o",@"o",@"o",@"o",@"o",@"o",@"o",@"o",@"o",@"o",@"o",@"o",@"o",@"o"
                            ,@"u",@"u",@"u",@"u",@"u",@"u",@"u",@"u",@"u",@"u",@"u"
                            ,@"y",@"y",@"y",@"y",@"y"
                            ,@"d"
                            ,@"A",@"A",@"A",@"A",@"A",@"A",@"A",@"A",@"A",@"A",@"A",@"A"
                            ,@"A",@"A",@"A",@"A",@"A"
                            ,@"E",@"E",@"E",@"E",@"E",@"E",@"E",@"E",@"E",@"E",@"E"
                            ,@"I",@"I",@"I",@"I",@"I"
                            ,@"O",@"O",@"O",@"O",@"O",@"O",@"O",@"O",@"O",@"O",@"O",@"O"
                            ,@"O",@"O",@"O",@"O",@"O"
                            ,@"U",@"U",@"U",@"U",@"U",@"U",@"U",@"U",@"U",@"U",@"U"
                            ,@"Y",@"Y",@"Y",@"Y",@"Y"
                            ,@"D", nil];
    
    NSString* retStr = @"";
    
    NSInteger length = inStr.length;
    for (int i=0; i<length; i++) {
        NSString* str = [NSString stringWithFormat:@"%C", [inStr characterAtIndex:i]];
        NSInteger index = -1;
        for (int j=0; j<chacArray.count; j++) {
            if ([str isEqual:[chacArray objectAtIndex:j]]) {
                index = j;
                break;
            }
        }
        if (index != -1) {
            NSString* replacingCha = [noChacArray objectAtIndex:index];
            retStr = [retStr stringByAppendingString:replacingCha];
        }else
        {
            retStr = [retStr stringByAppendingString:str];
        }
    }
    return retStr;
}

- (BOOL) isAllDigits
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [self rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound;
}

- (void)logMessage:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    id eachArg;
    while ((eachArg = va_arg(args, id)))
    {
//        LOG_123PHIM(@"gia tri = %@", eachArg);
    }
    va_end(args);
}

#pragma mark write parser text for may app
+ (NSString *)outStringWithKey:(NSString *)strkey
{
    NSString *fileNameTextDefine = [NSString stringWithFormat:@"%@/%@",DOCUMENTS_PATH, FILE_NAME_TEXT_DEFINE];
    NSDictionary *offDic = [NSDictionary dictionaryWithContentsOfFile:fileNameTextDefine];
    if (!offDic || !strkey || strkey.length < 1)
    {
        return @"123Phim";
    }
    NSString *strValue = [offDic objectForKey:strkey];
    if (!strValue)
    {
        return strkey;
    }
    return strValue;
}

//chuyen format cho dung de noi chuoi: hello [@] doi so name => hello %@
+ (NSString *)outParserConvertFormat:(NSString *)strkey
{
    NSString *fileNameTextDefine = [NSString stringWithFormat:@"%@/%@",DOCUMENTS_PATH, FILE_NAME_TEXT_DEFINE];
    NSDictionary *offDic = [NSDictionary dictionaryWithContentsOfFile:fileNameTextDefine];
    if (!offDic || !strkey || strkey.length < 1)
    {
        return @"123Phim";
    }
    NSString *strFormat = [offDic objectForKey:strkey];
    if (!strFormat)
    {
        return strkey;
    }
     NSMutableString *strResult = [[NSMutableString alloc] initWithString:strFormat];
    NSString *strPattern = @"[@]";
    NSUInteger lengPattern = [strPattern length];
    NSUInteger lengParam;
    NSUInteger length = [strResult length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [strResult rangeOfString:strPattern options:0 range:range];
        if(range.location != NSNotFound)
        {            
            NSString *strCurrentArg = @"%@";
            [strResult replaceCharactersInRange:range withString:strCurrentArg];
            //edit range when replace text pattern by text param
            lengParam = [strCurrentArg length];
            range.length += (lengParam - lengPattern);
            length = [strResult length];
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
        }
    }
    return strResult;
}

//default pattern to parse <@>
+ (NSString *)outParser:(NSString *)strFormat,...
{
    NSMutableString *strResult = [[NSMutableString alloc] initWithString:strFormat];
    va_list args;
    va_start(args, strFormat);
    va_end(args);
    NSString *strPattern = @"[@]";
    NSUInteger lengPattern = [strPattern length];
    NSUInteger lengParam;
    NSUInteger length = [strResult length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [strResult rangeOfString:strPattern options:0 range:range];
        if(range.location != NSNotFound)
        {
            NSString *strCurrentArg = va_arg(args, NSString *);
            if (strCurrentArg && [strCurrentArg isKindOfClass:[NSString class]])
            {
                [strResult replaceCharactersInRange:range withString:strCurrentArg];
                //edit range when replace text pattern by text param
                lengParam = [strCurrentArg length];
                range.length += (lengParam - lengPattern);
                length = [strResult length];
            }
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
        }
    }
    return strResult;
}

//path pattern to parse string by parameter
+ (NSString *)outParserWithPattern:(NSString *)strPattern withParam:(NSString *)strFormat,...
{
    NSMutableString *strResult = [[NSMutableString alloc] initWithString:strFormat];
    va_list args;
    va_start(args, strFormat);
    va_end(args);
    NSUInteger lengPattern = [strPattern length];
    NSUInteger lengParam;
    NSUInteger length = [strResult length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [strResult rangeOfString:strPattern options:0 range:range];
        if(range.location != NSNotFound)
        {
            NSString *strCurrentArg = va_arg(args, NSString *);
            if (strCurrentArg && [strCurrentArg isKindOfClass:[NSString class]])
            {
                [strResult replaceCharactersInRange:range withString:strCurrentArg];
                //edit range when replace text pattern by text param
                lengParam = [strCurrentArg length];
                range.length += (lengParam - lengPattern);
                length = [strResult length];
            }
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
        }
    }
    return strResult;
}

//Outparser(@"gia tri = <@String_001>) = > gia tri = askbills
+ (NSString *)outParserReplace:(NSString *)strFormat byKeyInDic:(NSDictionary *)dic
{
    if (!strFormat || !dic)
    {
        return @"";
    }
    NSMutableString *strResult = [[NSMutableString alloc] initWithString:strFormat];
    NSString *strPattern = @"[@";
    NSString *strendPattern = @"]";
    NSUInteger lengPattern;
    NSUInteger lengParam;
    NSUInteger length = [strResult length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [strResult rangeOfString:strPattern options:0 range:range];
        if(range.location != NSNotFound)
        {
            NSRange rangeEnd = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            rangeEnd = [strResult rangeOfString:strendPattern options:0 range:rangeEnd];
            if (rangeEnd.location != NSNotFound)
            {
                NSString *strKey = [strResult substringWithRange:NSMakeRange(range.location + range.length, rangeEnd.location - (range.location + range.length))];
                NSString *strCurrentArg = [dic objectForKey:strKey];//Gia tri la key doc tu file va replace vao chuoi
                if (!strCurrentArg || ![strCurrentArg isKindOfClass:[NSString class]])
                {
                    if ([strCurrentArg isKindOfClass:[NSNumber class]]) {
                        strCurrentArg = [NSString stringWithFormat:@"%d", [strCurrentArg intValue]];
                    } else {
                        strCurrentArg = @"askbills";//Gia tri default khi khong tim thay key trong file json define text
                    }
                }
                range.length = (rangeEnd.location - range.location + 1);
                lengPattern = range.length;
                [strResult replaceCharactersInRange:range withString:strCurrentArg];
                //edit range when replace text pattern by text param
                lengParam = [strCurrentArg length];
                range.length += (lengParam - lengPattern);
                length = [strResult length];
                range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            }
        }
    }
    return strResult;
}

+ (NSString *)outParserReplace:(NSString *)strFormat
{
    NSString *fileNameTextDefine = [NSString stringWithFormat:@"%@/%@",DOCUMENTS_PATH, FILE_NAME_TEXT_DEFINE];
    NSDictionary *offDic = [NSDictionary dictionaryWithContentsOfFile:fileNameTextDefine];
    if (!offDic || !strFormat || strFormat.length < 1)
    {
        return @"123Phim";
    }
    NSString *strValue = [offDic objectForKey:strFormat];
    if (!strValue)
    {
        return strFormat;
    }
    return [NSString outParserReplace:strValue byKeyInDic:offDic];
}
@end
