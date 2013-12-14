//
//  FilmCinemaPageView.m
//  123Phim
//
//  Created by phuonnm on 8/20/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//
typedef enum
{
    SECTION_FILM_INFO = 0,
    SECTION_NEWS_BANNER,
    DEFAULT_SECTION_HEADER,
    MAX_SECTION_TABLE
} ENUM_FILM_CINEMA_SECTION;

#define kHeightCell 97

#import "FilmCinemaPageView.h"
#import "Session.h"
#import "CinemaHeaderCell.h"
#import "CinemaNoteCell.h"
#import "SelectDateCell.h"
#import "SelectSeatViewController.h"
#import "CheckoutWebViewController.h"
#import "FilmCinemaCell.h"
#import "NewsBannerCell.h"

@implementation FilmCinemaPageView
@synthesize tableView = _tableView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if (self) {
        frame.origin.y = 0;
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView setBackgroundColor:[UIFont colorBackGroundApp]];
        [_tableView setBackgroundView:nil];
        [self addSubview:_tableView];
    }
    return self;
}

- (void) initMyTable
{
    if (_tableView) {
        return;
    }
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setBackgroundColor:[UIFont colorBackGroundApp]];
    [_tableView setBackgroundView:nil];
    [self addSubview:_tableView];
}

- (void) reloadData
{
    if (!_tableView)
    {
        [self initMyTable];
    }
    [_tableView reloadData];
}

#pragma mark - Table view data source

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(self.numberOfBookingCinema > 0)
    {
        UIView* ret = [[UIView alloc] init];
        UILabel *lblRatingPoint = [[UILabel alloc] init];
        [lblRatingPoint setFont:[UIFont getFontBoldSize13]];
        [lblRatingPoint setBackgroundColor:[UIColor clearColor]];
        [lblRatingPoint setTextColor:[UIColor blackColor]];
        if (section == DEFAULT_SECTION_HEADER) {
            lblRatingPoint.text = TITLE_SUPPORT_BUY_TICKET_ONLINE_123PHIM;
            CGSize sizeText = [lblRatingPoint.text sizeWithFont:[UIFont getFontBoldSize18]];
            [lblRatingPoint setFrame:CGRectMake(MARGIN_EDGE_TABLE_GROUP + 5, MARGIN_EDGE_TABLE_GROUP/2, sizeText.width, sizeText.height)];
            [ret addSubview:lblRatingPoint];
            return ret;
        }
        if (section == (self.numberOfBookingCinema + DEFAULT_SECTION_HEADER)) {
            lblRatingPoint.text = @"Rạp xung quanh";
            CGSize sizeText = [lblRatingPoint.text sizeWithFont:[UIFont getFontBoldSize18]];
            [lblRatingPoint setFrame:CGRectMake(MARGIN_EDGE_TABLE_GROUP + 5, MARGIN_EDGE_TABLE_GROUP/2, sizeText.width, sizeText.height)];
            [ret addSubview:lblRatingPoint];
            return ret;
        }
    }
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.numberOfBookingCinema > 0)
    {
        CGSize sizeText = [@"ABC" sizeWithFont:[UIFont getFontBoldSize13]];
        if (section == DEFAULT_SECTION_HEADER) {
            return (sizeText.height + MARGIN_EDGE_TABLE_GROUP + 5);
        }
        if (section == (self.numberOfBookingCinema + DEFAULT_SECTION_HEADER)) {
            return (sizeText.height + MARGIN_EDGE_TABLE_GROUP + 5);
        }
    }
    
    if (section == 0) {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        return MARGIN_EDGE_TABLE_GROUP;
    }
    return MARGIN_EDGE_TABLE_GROUP/2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_FILM_INFO) {
        if (indexPath.row == 1) {
            NSString *thePath = [[NSBundle mainBundle] pathForResource:@"icon_date" ofType:@"png"];
            UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
            int height = prodImg.size.height;
            return (height + 2*MARGIN_EDGE_TABLE_GROUP);
        }
        return 60 + 2*MARGIN_CELL_SESSION;
    }
    
    if (indexPath.section == SECTION_NEWS_BANNER)
    {
        return NEWS_BANNER_CELL_HEIGHT;
    }

    int objectIndex = indexPath.section - DEFAULT_SECTION_HEADER;
    CinemaWithDistance *cinemaDistance = (CinemaWithDistance *)[self.cinemaListByGroupWithDistance objectAtIndex: objectIndex];
    CGFloat heightCell = kHeightCell;
    if (cinemaDistance.arraySessions)
    {
        int iNguyen = (cinemaDistance.arraySessions.count + MAX_ITEM_CELL_SESSION_LAYOUT - 1) /MAX_ITEM_CELL_SESSION_LAYOUT - 1; // -1 : added to kHeightCell
        NSString *thePath = [[NSBundle mainBundle] pathForResource:@"button_session" ofType:@"png"];
        UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
        heightCell += iNguyen *(prodImg.size.height + 1) + 1; // +1 for border
    }

    return heightCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  [self.cinemaListByGroupWithDistance count] + DEFAULT_SECTION_HEADER;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_FILM_INFO)
    {
        return 2;
    }
    if (section == SECTION_NEWS_BANNER)
    {
        if (self.news && self.news.bannerURL)
        {
            return 1;
        }
        return 0;
    }
    return 1;//2
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_NEWS_BANNER)
    {
        NewsBannerCell* cell = [tableView dequeueReusableCellWithIdentifier:@"news_banner_cell"];
        if (!cell)
        {
            NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"NewsBannerCell" owner:self options:nil];
            cell = (NewsBannerCell*)[arr objectAtIndex:0];
            cell.backgroundView = [[UIView alloc]init];
        }
        [cell.sdImageView setImageWithURL:[NSURL URLWithString:self.news.bannerURL]];
        return cell;
    }
    
    if (indexPath.section > SECTION_NEWS_BANNER)
    {
        int indexObjectGet = indexPath.section - DEFAULT_SECTION_HEADER;
        CinemaWithDistance *cinema_distance = (CinemaWithDistance *)[self.cinemaListByGroupWithDistance objectAtIndex:indexObjectGet];
        
        FilmCinemaCell *retCell = [tableView dequeueReusableCellWithIdentifier:@"film_cinema_cell"];
        if (retCell == nil)
        {
            NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"FilmCinemaCell" owner:self options:nil];
            retCell = [arr objectAtIndex:0];
            [retCell configLayout];
            [retCell setSessionDelegate:self];
            retCell.selectionStyle = UITableViewCellSelectionStyleNone;
            retCell.accessoryType = UITableViewCellAccessoryNone;
        }
        CGFloat heightCell = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        [retCell loadDataWithOnline:cinema_distance curFilm:self.film withMargin:MARGIN_EDGE_TABLE_GROUP/2 withHeight:heightCell];
        [retCell layoutCellSession:cinema_distance.arraySessions currentRow:indexObjectGet];
        return retCell;
    }
    

    NSString *CellIdentifier = [self getCellIdentifier:indexPath];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        if (indexPath.row == 0)
        {
            NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"CinemaNoteCell" owner:self options:nil];
            cell = [arr objectAtIndex:0];
            [(CinemaNoteCell *)cell layoutNoticeView:self.film];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            cell =  [[SelectDateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            NSString* dateString = [NSDate getStringFormatFromDateByStepDay:self.stepNextDayShowSession date:[NSDate date]];
            [(SelectDateCell *)cell layoutSelectDateCell:dateString];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else
    {
        if (self.tableView.isDecelerating) {
            return cell;
        }
        if (indexPath.row == 0)
        {
            if ([cell isKindOfClass:[CinemaNoteCell class]])
            {
                [(CinemaNoteCell *)cell setMyFilm:self.film];
            }
        }
        else
        {
            NSString* dateString = [NSDate getStringFormatFromDateByStepDay:self.stepNextDayShowSession date:[NSDate date]];
            [(SelectDateCell *)cell layoutSelectDateCell:dateString];
        }
        [cell refreshData];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == SECTION_FILM_INFO)
    {
        if (indexPath.row == 1)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSeletedDateViewController)])
            {
                [self.delegate showSeletedDateViewController];
            }
            return;
        }
    }
    if  (indexPath.section == SECTION_NEWS_BANNER)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(filmCinemaPage:didSelectNews:)])
        {
            [self.delegate filmCinemaPage:self didSelectNews:self.news];
        }
    }
    return;
}

- (NSString*)getCellIdentifier:(NSIndexPath*)index_path
{
    if (index_path.section == 0)
    {
        return [NSString stringWithFormat:@"cinema_and_date_%d", index_path.row];
    }
    else
    {
        if (index_path.row == 1)
        {
            int index = [self getIndexOfCinemaFromIndexPath:index_path];
            CinemaWithDistance* cinema = [self.cinemaListByGroupWithDistance objectAtIndex:index];
            return [NSString stringWithFormat:@"cinema_%d_%d_date_%d", [cinema.cinema.cinema_id intValue], [((Session*)[cinema.arraySessions  objectAtIndex:0]).version_id intValue], self.stepNextDayShowSession];
        }
    }
    return nil;
}

#pragma mark process delegate select session
- (void) didSelectCinemaSession:(int)indexOfSession curIndexCinema:(int)curCinema
{
    if (!self.cinemaListByGroupWithDistance && self.cinemaListByGroupWithDistance.count <= curCinema)
    {
        return;
    }
    CinemaWithDistance *curFilSes = [self.cinemaListByGroupWithDistance objectAtIndex:curCinema];
    if (!curFilSes || curFilSes.arraySessions.count <= indexOfSession) {
        return;
    }
    
    Session *currentSession = [curFilSes.arraySessions objectAtIndex:indexOfSession];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCinemaSession:film:cinemaWithDistance:)])
    {
        [self.delegate didSelectCinemaSession:currentSession film:self.film cinemaWithDistance:curFilSes];
    }
}

- (int)getIndexOfCinemaFromIndexPath:(NSIndexPath*)indexPath
{
    NSInteger index = 0;
    index = indexPath.section - 1;
    return index;
}


@end
