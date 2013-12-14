//
//  Comment.m
//  MovieTicket
//
//  Created by Le Ngoc Duy on 1/17/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "Comment.h"


@implementation Comment

@dynamic comment_id;
@dynamic content;
@dynamic date_add;
@dynamic date_update;
@dynamic film_id;
@dynamic user_name;
@dynamic avatar;
@dynamic ratingFilm;
@dynamic order_id;
@dynamic list_image;
@dynamic film;

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.comment_id forKey:@"comment_id"];
    [encoder encodeObject:self.film_id forKey:@"film_id"];
    [encoder encodeObject:self.ratingFilm forKey:@"ratingFilm"];
    [encoder encodeObject:self.content forKey:@"content"];
    [encoder encodeObject:self.user_name forKey:@"user_name"];
    [encoder encodeObject:self.avatar forKey:@"avatar"];
    [encoder encodeObject:self.date_add forKey:@"date_add"];
    [encoder encodeObject:self.date_update forKey:@"date_update"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.comment_id = [decoder decodeObjectForKey:@"comment_id"];
        self.film_id = [decoder decodeObjectForKey:@"film_id"];
        self.ratingFilm = [decoder decodeObjectForKey:@"ratingFilm"];
        self.content = [decoder decodeObjectForKey:@"content"];
        self.user_name = [decoder decodeObjectForKey:@"user_name"];
        self.avatar = [decoder decodeObjectForKey:@"avatar"];
        self.date_add = [decoder decodeObjectForKey:@"date_add"];
        self.date_update = [decoder decodeObjectForKey:@"date_update"];
    }
    return self;
}

@end
