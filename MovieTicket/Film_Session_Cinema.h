//
//  Film_Session_Cinema.h
//  MovieTicket
//
//  Created by Nhan Ho Thien on 1/29/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Film.h"
#import "Cinema.h"
#import "Session.h"
@interface Film_Session_Cinema : NSObject{
    Film *filmCurr;
    Cinema *cinemaCurr;
    Session *sessionCur;
    NSMutableArray *arrSessionCurr;
}
@property (nonatomic,retain)  Film *filmCurr;
@property (nonatomic,retain)     Session *sessionCur;
@property (nonatomic,retain)  Cinema *cinemaCurr;
@property (nonatomic,retain)  NSMutableArray *arrSessionCurr;
@end
