//
//  PlusViewController.m
//  123Phim
//
//  Created by Le Ngoc Duy on 12/11/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
typedef enum
{
    SECTION_FILM_INFO,
    SECTION_PLUS_INFO,
    MAX_SECTION_TABLE
}ENUM_PLUS_SECTION;

#import "PlusViewController.h"
#import "CellInfoThanhToan.h"
#import "CinemaNoteCell.h"
#import "CellPlusInfo.h"
#import "AppDelegate.h"
#import "MainViewController.h"

@interface PlusViewController ()

@end

@implementation PlusViewController

- (void)dealloc
{
    self.myTable = nil;
    self.btnThanhToan = nil;
    self.buyInfo = nil;
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
    // Do any additional setup after loading the view from its nib.
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:_buyInfo.chosenFilm.film_name];
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    if (![delegate isUserLoggedIn])
    {
        [self.viewOTP setHidden:YES];
    }
    
    [_textViewInputOTP setDelegate:[MainViewController sharedMainViewController]];
    [_textViewInputOTP layoutWithRadius:CORNER_RADIUS_TEXT_BOX_ACCOUNT andImageIcon:nil hoderText:@"Mã OTP"];
    [_textViewInputOTP setKeyBoardType:UIKeyboardTypeNumberPad];
    [_textViewInputOTP setMinCharacter:5];
    [_textViewInputOTP setMaxCharacter:10];
    viewName = PLUS_VIEW_CONTROLLER;
    PINGREMARKETING
    self.trackedViewName = viewName;
    
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureTapOnView:)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)processThanhToan:(id)sender
{
//    NSLog(@"---Call API confirm thanh toan---");
}

- (IBAction)processGetOTP:(id)sender
{
//    NSLog(@"---Call API request get OTP---");
}

#pragma mark handle touch event
-(void)handleGestureTapOnView:(UIGestureRecognizer*)gesture
{
    if (_textViewInputOTP)
    {
        [_textViewInputOTP resignFirstResponder];
    }
}
#pragma mark -
#pragma mark UITableViewDatasource method
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MAX_SECTION_TABLE;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_FILM_INFO)
    {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell_thanhToan_%d_%d", indexPath.section, indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cellIdentifier = @"cinema_note_cell_id";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        switch (indexPath.section)
        {
            case SECTION_FILM_INFO:
            {
                if (indexPath.row == 0)
                {
                    NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"CinemaNoteCell" owner:self options:nil];
                    cell = [arr objectAtIndex:0];
                    [(CinemaNoteCell *)cell layoutNoticeView:_buyInfo.chosenFilm];
                    [cell setEditingAccessoryType:UITableViewCellAccessoryNone];
                }
                else
                {
                    cell =  [[CellInfoThanhToan alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [(CellInfoThanhToan *)cell layoutInfoCell:self.buyInfo];
                }
                break;
            }
            case SECTION_PLUS_INFO:
                {
                    NSArray* arr = [[NSBundle mainBundle] loadNibNamed:[[CellPlusInfo class] description] owner:self options:nil];
                    cell = [arr objectAtIndex:0];
                    [cell setBackgroundColor:[UIColor clearColor]];
                    [cell setBackgroundView:nil];
                }
                break;
            default:
                break;
        }
    }
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate method
#pragma mark -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_FILM_INFO)
    {
        if (indexPath.row == 1)
        {
            CGFloat height = [@"ABC" sizeWithFont:[UIFont getFontNormalSize13]].height;
            height += [@"ABC" sizeWithFont:[UIFont getFontBoldSize12]].height;
            return (height + 2*MARGIN_EDGE_TABLE_GROUP);
        }
        return 60 + 2*MARGIN_CELL_SESSION;
    }
    else if (indexPath.section == SECTION_PLUS_INFO)
    {
        return 120;
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_FILM_INFO) {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == MAX_SECTION_TABLE - 1) {
        return 1;
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
@end
