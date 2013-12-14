
#import "AlbumContentsViewController.h"
#import "AlbumContentsTableViewCell.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "CommentFilmView.h"

@implementation AlbumContentsViewController

@synthesize assetsGroup;
@synthesize delegate = _delegate;

-(void)dealloc
{
    [assets removeAllObjects];
    [_lstSelectedImages removeAllObjects];
    _tableView = nil;
    assetsGroup = nil;
    assets = nil;
    lastSelectedRow = nil;
    _lstSelectedImages = nil;
    assetsGroup = nil;
    _delegate = nil;
}

- (void)awakeFromNib {
    lastSelectedRow = NSNotFound;
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!assets) {
        assets = [[NSMutableArray alloc] init];
    } else {
        [assets removeAllObjects];
    }
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            [assets addObject:result];
        }
    };

    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [assetsGroup setAssetsFilter:onlyPhotosFilter];
    [assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return ceil((float)assets.count / 4); // there are four photos per row.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return THUMBNAIL_H + 10;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    AlbumContentsTableViewCell *cell = (AlbumContentsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[AlbumContentsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
        cell.selectionDelegate = self;   
    }
    // Configure the cell...
    NSUInteger firstPhotoInCell = indexPath.row * 4;
    NSUInteger lastPhotoInCell  = firstPhotoInCell + 4;
    
    if (assets.count <= firstPhotoInCell) {
        LOG_123PHIM(@"Out of range, start with photo %d but we only have %d", firstPhotoInCell, assets.count);
        return nil;
    }
    
    [cell clearAllImage];
    NSUInteger currentPhotoIndex = 0;
    NSUInteger lastPhotoIndex = MIN(lastPhotoInCell, assets.count);
    for ( ; firstPhotoInCell + currentPhotoIndex < lastPhotoIndex ; currentPhotoIndex++)
    {
        ALAsset *asset = [assets objectAtIndex:firstPhotoInCell + currentPhotoIndex];
        CGImageRef thumbnailImageRef = [asset thumbnail];
        UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
        [cell addImage:thumbnail];
    }

    return cell;
}


#pragma mark -
#pragma mark AlbumContentsTableViewCellSelectionDelegate

- (void)albumContentsTableViewCell:(AlbumContentsTableViewCell *)cell didSelectImage: (UIImage*) image atIndex:(NSUInteger)index
{
    if (_lstSelectedImages && [_lstSelectedImages containsObject:image])
    {
        [_lstSelectedImages removeObject:image];
//        disable right button if need
        if (_lstSelectedImages.count == 0)
        {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    else
    {
        if (!_lstSelectedImages)
        {
            _lstSelectedImages = [[NSMutableArray alloc] init];
        }
        [_lstSelectedImages addObject:image];
//        enable right button
        if (!self.navigationItem.rightBarButtonItem.enabled)
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    viewName = ALBUM_CONTENT_VIEW_CONTROLLER;
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    //set navigation tittle
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:[assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
    
//    right button
    UIImage *imageDone = [UIImage imageNamed:@"header-button-done.png"];
    CGSize sizeBtn = imageDone.size;
    UIButton *btnDone=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setBackgroundImage: imageDone forState:UIControlStateNormal];
    [btnDone setFrame:CGRectMake(0,0, sizeBtn.width, sizeBtn.height)];
    [btnDone addTarget:self action:@selector(handleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:btnDone];
    self.navigationItem.rightBarButtonItem = right;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    frame.size.height -= (NAVIGATION_BAR_HEIGHT);
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view setBackgroundColor:[UIFont colorBackGroundApp]];
    [self.view addSubview:_tableView];
    self.trackedViewName = viewName;
}

-(void)handleButtonClick: (UIButton *) button
{
    if (_delegate && [_delegate respondsToSelector:@selector(albumContentsViewController:didSelectImageList:)])
    {
        [_delegate albumContentsViewController:self didSelectImageList:_lstSelectedImages];
    }
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app popToViewController:[CommentFilmView class] animated:YES];
}


@end

