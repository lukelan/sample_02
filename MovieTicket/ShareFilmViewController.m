//
//  ShareFilmViewController.m
//  123Phim
//
//  Created by Phuc Phan on 3/13/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "ShareFilmViewController.h"
#import "ShareTemplateViewController.h"
#import "FacebookManager.h"
#import "CinemaNoteCell.h"
#import "CinemaRatingCell.h"
#import "APIManager.h"
#import "AutoScrollLabel.h"

@interface ShareFilmViewController ()
{
    NSArray *dataList;
    NSString *navTitle;
    NSInteger shareSourceIndex;
}
@end


@implementation ShareFilmViewController

@synthesize film,table;

-(void)dealloc
{
    film = nil;
    table = nil;
    dataList = nil;
    navTitle = nil;
    shareSourceIndex = nil;
    viewName = nil;
}
-(id)init{
    self = [super init];
    if (self) {
        viewName = FILM_SHARING_VIEW_NAME;
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
    [delegate setTitleLabelForNavigationController:self withTitle:@"Rủ bạn xem cùng"];
    
    dataList = [[NSArray alloc]initWithObjects:
                @"Tin nhắn",
                @"Email",
                @"Facebook",
                nil];

    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 460) style:UITableViewStyleGrouped];
    table.dataSource = self;
    table.delegate = self;
    table.backgroundView = nil;
    table.backgroundColor = [UIColor clearColor];
    [table setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    self.view.backgroundColor = [UIFont colorBackGroundApp];
    [self.view addSubview:table];
    self.trackedViewName = viewName;
    
//    NSString* previewView = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).currentView;
//    NSString* currentView = viewName;
//    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:currentView comeFrom:previewView withActionID:LOG_ACTION_ID_VIEW currentFilmID:self.film.film_id currentCinemaID:[NSNumber numberWithInt: NO_CINEMA_ID] returnCodeValue:0 context:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 2;
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 60 + 2 * MARGIN_EDGE_TABLE_GROUP;
        } else {
            NSString *thePath = [[NSBundle mainBundle] pathForResource:@"btnadd_to_watch_list" ofType:@"png"];
            UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
            return prodImg.size.height + MARGIN_EDGE_TABLE_GROUP;
        }
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell_%d", indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cellIdentifier = @"cinema_note_cell_id";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        switch (indexPath.section)
        {
            case 0:
            {
                if (indexPath.row == 0)
                {                    
//                    cell = [[[CinemaNoteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                    NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"CinemaNoteCell" owner:self options:nil];
                    cell = [arr objectAtIndex:0];
                    [(CinemaNoteCell *)cell layoutNoticeView:self.film];
                    
                    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else
                {
                    cell = [[CinemaRatingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [(CinemaRatingCell *)cell layoutCellCinemaHeader:self.film isViewShare:YES];
                    [(CinemaRatingCell *)cell setCommentDelegate:[MainViewController sharedMainViewController]];
                    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }                
            }
            break;
                
            default:
            {
                NSString *title = [dataList objectAtIndex:indexPath.row];
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.textLabel.font = [UIFont getFontBoldSize14];
                cell.textLabel.numberOfLines = 0;
                [cell.textLabel setText:title];
                
                [cell.imageView setBounds:CGRectMake(0, 0, 20, 20)];

                switch (indexPath.row)
                {
                    case 0:
                        cell.imageView.image = [UIImage imageNamed:@"share-sms.png"];
                        break;
                        
                    case 1:
                        cell.imageView.image = [UIImage imageNamed:@"share-email.png"];
                        break;
                    
                    default:
                        cell.imageView.image = [UIImage imageNamed:@"share-facebook.png"];
                        break;
                }
            }
            break;
        }
    }
    else
    {
        if ([cell isKindOfClass:[CinemaNoteCell class]])
        {            
            UIView *view = [(CinemaNoteCell *)cell viewWithTag:TAG_AUTO_SCROLL_LABEL];
            if ([view isKindOfClass:[AutoScrollLabel class]]) {
                AutoScrollLabel *autoLable = (AutoScrollLabel *)view;
                [autoLable refreshLabels];
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            
            break;
            
        default:
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            navTitle = cell.textLabel.text;
            shareSourceIndex = indexPath.row;

            if (indexPath.row == 2 && !FBSession.activeSession.isOpen)
            {
                FacebookManager *fbHandler = [FacebookManager shareMySingleton];
                [fbHandler loginFacebookWithResponseContext:self selector:@selector(didLoginFaceBookWithError:)];

            } else {
                
                [self pushToShareTemplateView];
            
            }
        }
        break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)didLoginFaceBookWithError: (NSError *) error
{
    if (!error)
    {
        [self pushToShareTemplateView];
    }
}

- (void)pushToShareTemplateView
{
    ShareTemplateViewController *shareTemplateViewController = [[ShareTemplateViewController alloc] init];
    [shareTemplateViewController setNavTitle:navTitle];
    [shareTemplateViewController setSource:shareSourceIndex];
    [shareTemplateViewController setFilm:self.film];
    [self.navigationController pushViewController:shareTemplateViewController animated:YES];
    
}

@end
