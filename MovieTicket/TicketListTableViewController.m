//
//  TicketListViewController.m
//  123Phim
//
//  Created by Nhan Mai on 5/16/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "TicketListTableViewController.h"
#import "TicketCell.h"
#import "Ticket.h"
#import "AppDelegate.h"
#import "APIManager.h"
#import "CheckoutResultViewController.h"
#import "DefinePath.h"
#import "NSDate+App.h"
#import "SDImageView.h"

@interface TicketListTableViewController ()

@end

@implementation TicketListTableViewController

-(void) dealloc
{
    user = nil;
}

@synthesize user;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
	// Do any additional setup after loading the view.
    
    // set navigation
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [appDelegate setTitleLabelForNavigationController:self withTitle:self.naviTitle];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - For Tableview

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Ticket* currentTicket = [self.dataList objectAtIndex:indexPath.row];
    NSString* cellId = [NSString stringWithFormat:@"ticketCell_%@", currentTicket.ticket_code];
    TicketCell* retCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (retCell == nil) {
        retCell = [[TicketCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        retCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
//        NSString *formatDate = @"07-06-2013 18:15";
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"dd-MM-yyyy H:mm"];
//        NSDate *currentDate = [dateFormatter dateFromString:formatDate];       
        
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

@end
