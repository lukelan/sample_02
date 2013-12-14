//
//  DelegateDatasourceSawfilm.m
//  MovieTicket
//
//  Created by Nhan Mai on 2/21/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "DelegateDatasourceSawfilm.h"
#import "CustomImageView.h"
#import "Film.h"

@implementation DelegateDatasourceSawfilm
@synthesize delegate;


- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return  self;
    
}



- (void)dealloc
{
    [delegate release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([delegate.sawFilm count]<10?[delegate.sawFilm count]:10);
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString* cellIdentifier = @"cell";
//    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (nil == cell) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
//        cell.textLabel.text = [NSString stringWithFormat:@"string %d", indexPath.row];
//    }
//    return cell;
    
    static NSString* cellFilm = @"cellId0";
    
    UITableViewCell* filmCell = [tableView dequeueReusableCellWithIdentifier:cellFilm];
    if (nil == filmCell) {
        NSLog(@"create new cell");
        filmCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellFilm] autorelease];
        filmCell.textLabel.font = [self contentFont];
        filmCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        CustomImageView* poster = [[CustomImageView alloc] initWithFrame:CGRectMake(5, 7, 25, 30)];
        poster.layer.cornerRadius = 3.0;
        poster.layer.masksToBounds = YES;
        poster.tag = 123;
        [filmCell.contentView addSubview:poster];
        [poster release];
    }
    if ([delegate.sawFilm count]) {
        Film* film = [delegate.sawFilm objectAtIndex:indexPath.row];
        CustomImageView* imgView = (CustomImageView*)[filmCell.contentView viewWithTag:123];
        if (film.filmPosterImage) {
            NSLog(@"filmPosterImage");
            imgView.imgView.image = film.filmPosterImage;
        }else{
            
            // download and set image
            [imgView getImageViewFromURLByQueue:[NSURL URLWithString:film.poster_url]];
            // add the image to film object
            UIImage* downloadImage = imgView.imgView.image;
            film.filmPosterImage = downloadImage;
            NSLog(@"downloaded: %@", [downloadImage description]);
        }
        filmCell.textLabel.text = [NSString stringWithFormat:@"         %@", film.film_name];
    }
    
    return filmCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate pushFilmDetailViewController:[delegate.sawFilm objectAtIndex:indexPath.row] showDetail:YES];
}

- (UIFont*) contentFont
{
    return [UIFont fontWithName:@"Helvetica" size:13];
}

@end
