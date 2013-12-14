//
//  LocationViewController.m
//  MovieTicket
//
//  Created by Phuong. Nguyen Minh on 12/6/12.
//  Copyright (c) 2012 Phuong. Nguyen Minh. All rights reserved.
//

#import "LocationViewController.h"
#import "MainViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface LocationViewController ()

@end

@interface LocationTableView ()

@end

@implementation LocationTableView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView * view in [self subviews]) {
        if (view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
            return YES;
        }
    }
    return YES;
}

@end


@implementation LocationViewController

@synthesize locationArray;
@synthesize locationDataController= _locationDataController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initProperties];
        
    }
    return self;
}

//-(void) did
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initProperties
{
    //    init location array
    locationArray = [[NSMutableArray alloc] init];
    tableRow = 0;
    [self.navigationController setTitle:LOCATION_VIEW_TITLE];
    self.navigationItem.hidesBackButton = YES;
}

-(void)addLocation:(Location *)location
{
    [locationArray addObject:location];
}

- (void) initView
{
//    [self.navigationItem setTitle:@"Select Location"];
    UIImage *background = [UIImage imageNamed:@"location_bg.png"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:background]];
    [self.view setAlpha:0.9];
    [self.view setUserInteractionEnabled:YES];
    if ([locationArray count] == 0)
    {
//        [self loadDefaultLocationList];
    }
    float tableHeigh = [locationArray count] * 43;
    CGRect frame = self.view.frame;
    frame.origin.y = -10;
    frame.size.height += 10;
    [self.view setFrame:frame];
    
    frame.origin.y = 10;
//    frame.size.width = 200;
    frame.size.height = 41;
    UILabel *title = [[UILabel alloc] initWithFrame:frame];
    [title setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navi_title_bg.png"]]];
//    [title setBackgroundColor:[UIColor redColor]];
    UIFont *fontTitle = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    [title setTextColor:[UIColor whiteColor]];
    [title setFont:fontTitle];
    [title setText:@"Chọn Nơi bạn đang ở"];
    [title setTextAlignment:UITextAlignmentCenter];
//    [title setAlpha:1.0];
    [self.view addSubview:title];
    [title release];
    frame.origin.x = frame.size.width / 2 - 100;
    frame.origin.y = 90;
    frame.size.width = 200;
    frame.size.height = tableHeigh;
    tableView = [[LocationTableView alloc] initWithFrame: frame style:UITableViewStylePlain];
    
//    tableView.sectionHeaderHeight = 80.0f;

    [tableView setDataSource:self];
    [tableView setDelegate:self];
//    [tableView setAlpha:0.9];
    [tableView setScrollEnabled:NO];
//    [tableView setBounces:YES];

    [tableView setBackgroundColor:[UIColor clearColor]];
    tableView.layer.borderWidth = 2.0f;
//    tableView.layer setBorderColor:[c]
    tableView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    tableView.layer.cornerRadius = 4.0f;
//    tableView.separatorColor = [UIColor darkGrayColor];
    [tableView.layer setMasksToBounds:YES];
    [self.view addSubview:tableView];
}

-(UITableViewCell*) createTableCell : (Location *) location
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
    [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"location_cell_bg.png"]]];
    CGRect lableFrame = CGRectMake(20, 0, 200, 43);
    UILabel *lbTitle = [[UILabel alloc]initWithFrame:lableFrame];
//    [lbTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"location_hochiminh.png"]]];
    [lbTitle setBackgroundColor:[UIColor clearColor]];
    [lbTitle setText:[location name]];
    [cell.contentView addSubview:lbTitle];
    [lbTitle release];
    
    return cell;
}

#pragma mark data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [locationArray count];
    }
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell =  [self createTableCell:[locationArray objectAtIndex:indexPath.row]];        // Configure the cell...
    }
    return cell;
    
}

// implementing tabel delegete


#pragma mark tabel delegete

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"Location List";
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Location *selectedLoc = (Location *)[locationArray objectAtIndex:indexPath.row];
    [self.locationDataController didSelectLocation:selectedLoc];
    [self.view removeFromSuperview];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 43;
}

@end
