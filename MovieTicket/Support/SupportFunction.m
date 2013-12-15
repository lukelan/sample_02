/*
 * $Author: kidbaw $
 * $Revision: 59 $
 * $Date: 2012-03-23 22:44:48 +0700 (Fri, 23 Mar 2012) $
 *
 */

#import "SupportFunction.h"
#import "DefineString.h"

@implementation SupportFunction

void ALERT(NSString* title, NSString* message) {
	UIAlertView *_alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:STRING_ALERT_OK otherButtonTitles:nil];  [_alert show];
}

+ (NSMutableDictionary *)repairingDictionaryWith:(NSDictionary *)dictionary
{
    NSMutableDictionary *muDictionary = [[NSMutableDictionary alloc] init];
    NSArray *allKeys = [dictionary allKeys];
    for (int i = 0; i < [allKeys count]; i ++) {
        NSMutableDictionary *childDictionary = [dictionary objectForKey:[allKeys objectAtIndex:i]];
        NSString *key = [allKeys objectAtIndex:i];
        if ([childDictionary isKindOfClass:[NSDictionary class]]) {
            [muDictionary setValue:[self repairingDictionaryWith:[dictionary objectForKey:[allKeys objectAtIndex:i]]] forKey:key];
        } else {
            if ((NSNull *)[dictionary objectForKey:[allKeys objectAtIndex:i]] == [NSNull null]) {
                [muDictionary setObject:@"" forKey:[allKeys objectAtIndex:i]];
            }
            else {
                [muDictionary setObject:[dictionary objectForKey:[allKeys objectAtIndex:i]] forKey:[allKeys objectAtIndex:i]];
            }
        }
    }
    return muDictionary;
}
@end
