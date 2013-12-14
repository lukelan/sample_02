//
//  FavoriteFilmViewController.m
//  MovieTicket
//
//  Created by Nhan Mai on 2/26/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "FavoriteFilmViewController.h"
#import "APIManager.h"

#import "Film.h"
#import "MainViewController.h"

@interface FavoriteFilmViewController ()

@end

@implementation FavoriteFilmViewController
@synthesize table;
@synthesize delegate = _delegate;

-(void)dealloc
{
    _delegate = nil;
    table = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - TITLE_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
        table.delegate = self;
        table.dataSource = self;
        
        viewName = FAVORITE_FILM_VIEW_NAME;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:@"Phim phải xem"];
    [self.view addSubview:self.table];
    [self.table setTableFooterView:[[UIView alloc] init]];
    self.trackedViewName = viewName;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.table reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [((AppDelegate*)[[UIApplication sharedApplication] delegate]).arrayFilmFavorite count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
//    if ([self.filmList count] > 0)
    if ([appDelegate.arrayFilmFavorite count] > 0)
    {
        Film* film = [appDelegate.arrayFilmFavorite objectAtIndex:indexPath.row];
        NSString* cellFilm = [NSString stringWithFormat:@"cell_%d_%d_%d", indexPath.section, indexPath.row,[film.film_id intValue]];
        UITableViewCell* filmCell = [tableView dequeueReusableCellWithIdentifier:cellFilm];
        
        if (filmCell == nil)
        {
            filmCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellFilm];
            filmCell.textLabel.font = [UIFont getFontBoldSize14];
            filmCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            SDImageView* poster = [[SDImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 48)];
            poster.layer.cornerRadius = 3.0;
            poster.layer.borderColor = [UIColor grayColor].CGColor;
            poster.layer.masksToBounds = YES;
            [poster setImageWithURL:[NSURL URLWithString:film.poster_url]];
            [filmCell.contentView addSubview:poster];
            
            filmCell.textLabel.text = [NSString stringWithFormat:@"          %@", film.film_name];
            [filmCell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        return filmCell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pushVCFilmDetailWithFilm:isFavorite:)]) {
        [self.delegate pushVCFilmDetailWithFilm:[((AppDelegate*)[[UIApplication sharedApplication] delegate]).arrayFilmFavorite objectAtIndex:indexPath.row]isFavorite:YES];
    }
    UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
    if (cell)
    {
        [cell setSelected:NO animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
