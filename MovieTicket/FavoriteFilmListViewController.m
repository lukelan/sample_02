//
//  FavoriteFilmListViewController.m
//  123Phim
//
//  Created by Nhan Mai on 7/5/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "FavoriteFilmListViewController.h"
#import "Film.h"
#import "AppDelegate.h"

@interface FavoriteFilmListViewController ()

@end

@implementation FavoriteFilmListViewController
@synthesize user;

- (void)dealloc {
    
    user = nil;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    viewName = FAVORITE_FILM_VIEW_NAME;
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
	// Do any additional setup after loading the view.
    
    // set navigation
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [appDelegate setTitleLabelForNavigationController:self withTitle:self.naviTitle];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_123PHIM(@"data list: %@", self.dataList.description);
    Film* film = [self.dataList objectAtIndex:indexPath.row];
    static NSString* cellID = @"cellID";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.textLabel.font = [UIFont getFontBoldSize13];
    }
    cell.textLabel.text = film.film_name;
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
