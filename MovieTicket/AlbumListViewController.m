//
//  AlbumListViewController.m
//  123Phim
//
//  Created by phuonnm on 7/10/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "AlbumListViewController.h"
#import "AlbumContentsViewController.h"
#import "AppDelegate.h"
#import "MainViewController.h"

@interface AlbumListViewController ()

@end

@implementation AlbumListViewController
@synthesize delegate = _delegate;

- (void)dealloc
{
    _delegate = nil;
    assetsLibrary = nil;
    groups = nil;
    _tableView = nil;
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
    viewName = ALBUM_LIST_VIEW_CONTROLLER;
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
    [self.view setBackgroundColor:[UIFont colorBackGroundApp]];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app setCustomBackButtonForNavigationItem:self.navigationItem];
    [app setTitleLabelForNavigationController:self withTitle:ALBUM_LIST_VIEW_TITLE];
    
    if (!assetsLibrary) {
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (!groups) {
        groups = [[NSMutableArray alloc] init];
    } else {
        [groups removeAllObjects];
    }
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group)
        {
            [groups addObject:group];
        }
        else
        {
            if (!_tableView)
            {
                CGRect frame = self.view.frame;
                frame.origin.y = 0;
                _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
                [_tableView setDataSource:self];
                [_tableView setDelegate:self];
                [self.view addSubview: _tableView];
                _tableView.tableFooterView = [[UIView alloc] init];
            }
            [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = ERROR_DESCRIPTION_ACCESS_DECLINE;
                break;
            default:
                errorMessage = ERROR_DESCRIPTION_UNKNOWN;
                break;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorMessage delegate:self cancelButtonTitle:nil otherButtonTitles:ALERT_BUTTON_OK, nil];
        [alert show];
    };

    NSUInteger groupTypes = ALAssetsGroupAll; //ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces;
    [assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    self.trackedViewName = viewName;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        ALAssetsGroup *groupForCell = [groups objectAtIndex:indexPath.row];
        CGImageRef posterImageRef = [groupForCell posterImage];
        UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
        cell.imageView.image = posterImage;
        cell.textLabel.text = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (groups.count > indexPath.row) {
        AlbumContentsViewController *albumContentsViewController = [[AlbumContentsViewController alloc] init];
        albumContentsViewController.assetsGroup = [groups objectAtIndex:indexPath.row];
        albumContentsViewController.delegate = _delegate;
        [self.navigationController pushViewController:albumContentsViewController animated:YES];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
