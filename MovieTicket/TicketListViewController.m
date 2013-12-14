//
//  TicketListViewController.m
//  123Phim
//
//  Created by Nhan Mai on 5/16/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "TicketListViewController.h"
#import "TicketCell.h"
#import "Ticket.h"
#import "AppDelegate.h"
#import "APIManager.h"

#import "CheckoutResultViewController.h"

@interface TicketListViewController ()<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation TicketListViewController

-(void) dealloc
{
    [listOfTicket removeAllObjects];
    
    [NSFetchedResultsController deleteCacheWithName:@"ticket"];
    layoutTable = nil;
    listOfTicket = nil;
}
@synthesize layoutTable, listOfTicket;
@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController{
    
    if (!_fetchedResultsController)
    {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Ticket class])];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"order_id" ascending:YES]];
        
        NSFetchedResultsController *myFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:@"ticket"];
        [myFetchedResultsController setDelegate:self];
        self.fetchedResultsController = myFetchedResultsController;
        
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
                
        NSAssert(!error, @"Error performing fetch request: %@", error);
    }
    return _fetchedResultsController;
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self executeLoadingLayout];
}

- (void)executeLoadingLayout
{
    if (listOfTicket) {
        [listOfTicket removeAllObjects];
    }
    self.listOfTicket = [NSMutableArray arrayWithArray:self.fetchedResultsController.fetchedObjects];
    [self.layoutTable reloadData];
}

#pragma mark init resource for view
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        viewName = TICKET_LIST_VIEW_NAME;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
	// Do any additional setup after loading the view.
    
    //set navigation bar
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:@"Vé đã mua"];
    
    layoutTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height - TITLE_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    self.layoutTable.delegate = self;
    self.layoutTable.dataSource = self;
    [self.view addSubview:self.layoutTable];
    
    
    AppDelegate* appDelegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self executeLoadingLayout];
    if ([AppDelegate isNetWorkValiable] && [appDelegate isUserLoggedIn]) {
        [[APIManager sharedAPIManager] getListTicketWithUser:appDelegate.userProfile.user_id context:self];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - For Tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [listOfTicket count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Ticket* currentTicket = [listOfTicket objectAtIndex:indexPath.row];
    NSString* cellId = [NSString stringWithFormat:@"ticketCell_%@", currentTicket.ticket_code];
    TicketCell* retCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (retCell == nil) {
        retCell = [[TicketCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        retCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        retCell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        SDImageView* avatar = [[SDImageView alloc] initWithFrame:retCell.image.frame];
        UIImage *imageData = [[UIImage alloc] initWithData:currentTicket.ticket_data];
        if (!imageData)
        {
            [avatar setImageWithURL:[NSURL URLWithString:currentTicket.film_poster_url]];
        }
        else
        {
            [avatar setImage:imageData];
        }
        [retCell.contentView addSubview:avatar];
        retCell.label1.text = currentTicket.film_name;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd H:mm:ss"];
        NSDate *date = [dateFormatter dateFromString:currentTicket.date_show];
        double timeDouble = [date timeIntervalSinceReferenceDate];
        retCell.label2.text = [NSString stringWithFormat:@"Ngày chiếu: %@", [NSDate getStringFormatFromTimeTamp:timeDouble format:@"H:mm dd/MM/yyyy"]];
        
        date = [dateFormatter dateFromString:currentTicket.date_buy];
        timeDouble = [date timeIntervalSinceReferenceDate];
        retCell.label3.text = [NSString stringWithFormat:@"Ngày mua: %@", [NSDate getStringFormatFromTimeTamp:timeDouble format:@"H:mm dd/MM/yyyy"]];
        int iphanNguyen = [currentTicket.ticket_total_price intValue]/1000;
        int iPhanDu = [currentTicket.ticket_total_price intValue]%1000;
        NSString *strMoney = @"";
        if (iPhanDu > 0) {
            strMoney = [[NSString alloc] initWithFormat:@"Tổng tiền: %d.%dđ", iphanNguyen, iPhanDu];
        }
        else
        {
            strMoney = [[NSString alloc] initWithFormat:@"Tổng tiền: %d.000đ", iphanNguyen];
        }

        retCell.label4.text = strMoney;
        NSDate *currentDate = [NSDate date];
        NSDate *date_show = [NSDate dateWithTimeIntervalSinceReferenceDate:[currentTicket.date_show doubleValue]];
        NSTimeInterval distance_time = [currentDate timeIntervalSinceDate:date_show];
        if (distance_time > 0) {
            [retCell.label1 setTextColor:[UIColor grayColor]];
            [retCell.label2 setTextColor:[UIColor grayColor]];
            [retCell.label3 setTextColor:[UIColor grayColor]];
            [retCell.label4 setTextColor:[UIColor grayColor]];
        }
    }
    return retCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // send log to 123phim server
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:NSStringFromClass([CheckoutResultViewController class])
                                                          comeFrom:delegate.currentView
                                                      withActionID:ACTION_TICKET_VIEW
                                                     currentFilmID:[NSNumber numberWithInt:NO_FILM_ID]
                                                   currentCinemaID:[NSNumber numberWithInt:NO_CINEMA_ID]
                                                   returnCodeValue:0 context:nil];
    
    CheckoutResultViewController* ticketDetailController = [[CheckoutResultViewController alloc] init];
    ticketDetailController.ticketInfo = [listOfTicket objectAtIndex:indexPath.row];
    [ticketDetailController setIsCommingFromTicketList:YES];
    [self.navigationController pushViewController:ticketDetailController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}
@end
