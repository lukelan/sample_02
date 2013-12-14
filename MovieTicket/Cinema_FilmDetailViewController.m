   //
//  Cinema_FilmDetailViewController.m
//  MovieTicket
//
//  Created by phuonnm on 1/4/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "Cinema_FilmDetailViewController.h"
#import "APIManager.h"
#import "DefinePath.h"
#import "CommentFilmView.h"
#import "CinemaWithDistance.h"
#import "SliderViewImage.h"
#import "EntertainmentViewController.h"
#import "ImageIconViewController.h"

@interface Cinema_FilmDetailViewController ()

@end

@implementation Cinema_FilmDetailViewController

@synthesize showDetailView,btnFilmDetail,footer,btnMuave,yPosCurrent,yPosEnd,yPosStart,yPosLastSample,viewRecieve,isLoadingCinemaSessionComplete,isLoadingCinemaSessionBefore,cinemaGroupList,arrCinemaSessionDistance;

-(void)didSelectCinemaSession:(Session *)session
{
    EntertainmentViewController *viewCommingSoon = [[EntertainmentViewController alloc] init];
    [viewCommingSoon setTitleForApp:film.film_name];
    UIImage *imgBG = [UIImage imageNamed:@"page_coming_soon.jpg"];
    UIImageView *imageViewBG = [[UIImageView alloc] initWithImage:imgBG];
    [imageViewBG setFrame:CGRectMake(0, 0, imgBG.size.width, imgBG.size.height)];
    [viewCommingSoon.view addSubview:imageViewBG];
    [viewCommingSoon setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:viewCommingSoon animated:YES];
    [viewCommingSoon performPushViewControllerAndHideTaBar];
//    AppDelegate* appDelagate = [[UIApplication sharedApplication] delegate];
//    [appDelagate.tabBarController.tabBar setHidden:YES];

    [imageViewBG release];
    [viewCommingSoon release];
}

-(id)init
{
    self = [super init];
    if (self) {
        arrCinemaSessionDistance = [[NSMutableArray alloc] init];
        cinemaGroupList = [[NSMutableArray alloc] init];
        // Custom initialization
        cinemaViewController = [[FilmCinemaViewController alloc]initWithStyle:UITableViewStyleGrouped];
        cinemaViewController.sessionDelegate = self;
        [cinemaViewController.view setBackgroundColor:[UIColor whiteColor]];
        filmDetailViewController = [[FilmDetailViewController alloc] init];
        filmDetailViewController.delegate = self;
        UIImage *selectedImage = [UIImage imageNamed:@"rapchieu_hl.png"];
        [self.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:[UIImage imageNamed:@"rapchieu.png"]];
        [self.tabBarItem setTitle:@"Rạp Chiếu"];
        isLoadingCinemaSessionComplete = NO;
        isLoadingCinemaSessionBefore = NO;
    }
    return  self;
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//        cinemaViewController = [[FilmCinemaViewController alloc]initWithStyle:UITableViewStylePlain];
//        cinemaViewController.delegate = self;
//        [cinemaViewController.view setBackgroundColor:[UIColor whiteColor]];
//        filmDetailViewController = [[FilmDetailViewController alloc] init];
//        filmDetailViewController.delegate = self;
//        UIImage *selectedImage = [UIImage imageNamed:@"rapchieu_hl.png"];
//        [self.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:[UIImage imageNamed:@"rapchieu.png"]];
//        [self.tabBarItem setTitle:@"Rạp Chiếu"];
//        isLoadingCinemaSessionComplete = NO;
//    }
//    return self;
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
	// Do any additional setup after loading the view.
    CGRect frame = self.view.frame;
    frame.origin.y=0;
    self.view.frame = frame;
    cinemaViewController.view.frame = frame;
    [self.view addSubview:cinemaViewController.view];
    filmDetailViewController.view.frame = frame;
    [self.view addSubview:filmDetailViewController.view];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setCustomBackButtonForNavigationItem:self.navigationItem];
    [delegate setTitleLabelForNavigationController:self withTitle:film.film_name];
    
    UIImage *img = [UIImage imageNamed:@"button-detail.png"];
    imageFooter = [UIImage imageNamed:@"button-pull-up.png"];
    imageHeader = [UIImage imageNamed:@"button-pull-down.png"];
    
    // NSLog(@"view_y: %f", self.view.frame.origin.y);
    if (YES == showDetailView) {
        footer = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, imageHeader.size.height)];
    }else{
        footer = [[UIImageView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - imageFooter.size.height - NAVIGATION_BAR_HEIGHT - TITLE_BAR_HEIGHT, self.view.frame.size.width, imageFooter.size.height)];
    }
    footer.image = imageFooter;
    UIImage * imageFilmDetail = [UIImage imageNamed:@"cinema_footer_btn.png"];
    CGRect frameimg = CGRectMake((self.view.frame.size.width - imageFilmDetail.size.width) - 5, [[UIScreen mainScreen] bounds].size.height - NAVIGATION_BAR_HEIGHT - TITLE_BAR_HEIGHT - imageFilmDetail.size.height - self.footer.frame.size.height, imageFilmDetail.size.width, imageFilmDetail.size.height);
    //UIView
    btnFilmDetail= [[UIButton alloc] initWithFrame:frameimg];
    [btnFilmDetail setBackgroundImage:img forState:UIControlStateNormal];
    [btnFilmDetail setBackgroundColor:[UIColor yellowColor]];
    btnFilmDetail.backgroundColor = [UIColor colorWithPatternImage:imageFilmDetail];
    [btnFilmDetail addTarget:self action:@selector(filmDetail_Click) forControlEvents:UIControlEventTouchUpInside];
    [btnFilmDetail setAdjustsImageWhenHighlighted:NO];
    
    UISwipeGestureRecognizer *recognizerUp;    
    recognizerUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizerUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.btnFilmDetail addGestureRecognizer:recognizerUp];
    
    if (YES == self.showDetailView) {
        self.btnFilmDetail.hidden = YES;
        self.footer.hidden = NO;
        self.footer.image = imageHeader;
    }   
    [self.view addSubview:footer];
    [self.view addSubview:btnFilmDetail];

    UIImage *imageMuaVe = [UIImage imageNamed:@"mua_ve.png"];
    if (YES == self.showDetailView) {
        btnMuave= [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - imageMuaVe.size.width) - 5, 5, imageMuaVe.size.width, imageMuaVe.size.height)];
        btnMuave.hidden = NO;
    }else{
        btnMuave= [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - imageMuaVe.size.width) - 5, [[UIScreen mainScreen] bounds].size.height - imageFooter.size.height - NAVIGATION_BAR_HEIGHT - TITLE_BAR_HEIGHT - imageMuaVe.size.height, imageMuaVe.size.width, imageMuaVe.size.height)];
        btnMuave.hidden = YES;
    }

    [btnMuave setBackgroundImage:img forState:UIControlStateNormal];
    [btnMuave setBackgroundImage:imageMuaVe forState:UIControlStateNormal];
    [btnMuave addTarget:self action:@selector(dissmisFilmDetail) forControlEvents:UIControlEventTouchUpInside];
    
    [btnMuave setAdjustsImageWhenHighlighted:NO];
    [self.view addSubview:btnMuave];

    
    UISwipeGestureRecognizer * recognizerDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromDown:)];
    [recognizerDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.btnMuave addGestureRecognizer:recognizerDown];
    [recognizerDown release];
    [recognizerUp release];
    viewRecieve=[[UIView alloc] initWithFrame:frameimg];
}

-(void)dealloc
{
    [arrCinemaSessionDistance release];
    [cinemaGroupList release];
    [filmDetailViewController release];
    [cinemaViewController release];
    [btnMuave release];
    [btnFilmDetail release];
    [footer release];
    [imageHeader release];
    [imageFooter release];
    [super dealloc];
}

#pragma mark Touch 
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.btnFilmDetail];
    yPosStart=touchPoint.y;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

// show or hide sliding view based on swipe direction

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}
-(void)handleSwipeFromDown:(UISwipeGestureRecognizer *) sender{
    // NSLog(@"swipe gesdown");
    [self dissmisFilmDetail];
    
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *) sender{
    // NSLog(@"swipe ges");
  
     [self filmDetail_Click];
   
}
-(void)pushFilmDetailController:(UITapGestureRecognizer*) sender{
    // NSLog(@"dafafsdfs");
   
}
-(void) filmDetail_Click
{
    // NSLog(@"Show film detail here");
    [self pushFilmDetailController];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setFilm:(Film *)theFilm
{
    film = theFilm;
    [cinemaViewController setFilm: theFilm];
    [filmDetailViewController setFilm: theFilm];
}

- (void)pushFilmDetailController
{
    [self.btnMuave setHidden:YES];
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationCurveLinear animations:^{        
        CGRect frame = filmDetailViewController.view.frame;
        frame.origin.y = 0;
        filmDetailViewController.view.frame = frame;
        showDetailView = YES;        
        
        CGRect frame2 = footer.frame;
        frame2.origin.y = 0;
        self.footer.frame=frame2;
        
        CGRect frame1 = btnFilmDetail.frame;
        frame1.origin.y = -20;
        self.btnFilmDetail.frame=frame1;
        
        CGRect frame4 = btnMuave.frame;
        frame4.origin.y = -20;
        self.btnMuave.frame=frame4;
        footer.image = imageHeader;        
    } completion:^(BOOL finished) {
        // NSLog(@"fdsfsdfsdfS");
        [self.btnFilmDetail setHidden:YES];
        [self.btnMuave setHidden:NO];
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationCurveLinear animations:^{
           
            CGRect frame1 = btnMuave.frame;
            frame1.origin.y = 5;
            self.btnMuave.frame=frame1;
            //viewRecieve.frame=btnMuave.frame ;
        } completion:^(BOOL finished) {
            // NSLog(@"push view");
      
        }];        
    }];
    
}

- (void)dissmisFilmDetail
{    
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationCurveLinear animations:^{    
        CGRect frame = filmDetailViewController.view.frame;
        frame.origin.y = [[UIScreen mainScreen] bounds].size.height - 20 - NAVIGATION_BAR_HEIGHT;
        filmDetailViewController.view.frame=frame;
        showDetailView = NO;
        CGRect frame2 = footer.frame;
        frame2.origin.y = [[UIScreen mainScreen] bounds].size.height - 20 - NAVIGATION_BAR_HEIGHT - 5;
        self.footer.frame=frame2;
        self.footer.image = imageFooter;
        
        CGRect frame1 = btnMuave.frame;
        frame1.origin.y = [[UIScreen mainScreen] bounds].size.height - 20 - NAVIGATION_BAR_HEIGHT;
        self.btnMuave.frame=frame1;        
    } completion:^(BOOL finished) {
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationCurveLinear animations:^{
            [self.btnMuave setHidden:YES];
            [self.btnFilmDetail setHidden:NO];
            self.btnFilmDetail.frame=self.btnMuave.frame;
           CGRect frame1 = btnFilmDetail.frame;
            frame1.origin.y = [[UIScreen mainScreen] bounds].size.height - 20 - NAVIGATION_BAR_HEIGHT -25;
            self.btnFilmDetail.frame=frame1;
        } completion:^(BOOL finished) {
        }];
    }];

}

-(void)setCinemaGroupList
{
    [cinemaViewController setCinemaGroupList:self.cinemaGroupList];
//    [cinemaViewController loadCenemaGroupList];
}

-(void)setCinemaSessionDistanceList:(int)cinema_id andSessionVersionID:(int)versionid
{
//    [cinemaViewController setCinemaGroupList:self.arrCinemaSessionDistance];
    [cinemaViewController setCinema_id_fromCinemaFilmView:cinema_id];
    [cinemaViewController setSession_version_id_fromCinemaFilmView:versionid];
}

-(void)setIndexForCurrentCienmaDistance:(int) index
{
    [cinemaViewController setIndexOfCurrentCienmaDistance:index];
    [cinemaViewController setIsLoadingSessionFromCinema:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    if (!showDetailView)
    {
        CGRect sreenRect = [[UIScreen mainScreen] bounds];
        CGRect frame = self.view.frame;
        frame.origin.y = sreenRect.size.height;
        [filmDetailViewController.view setFrame:frame];
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(!self.isLoadingCinemaSessionComplete)
    {
        [delegate settingAddIconProcessForLoading];
    }
    if(!self.isLoadingCinemaSessionBefore)
    {
        [cinemaViewController requestAPIGetListCinemaSession];
    }
    [super viewWillAppear:YES];
//    [cinemaViewController.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if(self.cinemaGroupList != nil & [self.cinemaGroupList count] > 0)
    {
        [delegate checkingAndDisableIndicatorWhenComplete];
        return;
    }
//    if (filmDetailViewController.isLoadCommentView)
//    {
//        [filmDetailViewController setIsLoadCommentView:NO];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"film_id=%d",[film.film_id intValue]];
//        NSMutableArray *arrComments = [delegate fetchRecords:@"Comment" sortWithKey:@"comment_id" withPredicate:predicate];
//        if ([arrComments count] > [filmDetailViewController.comments count]) {
//            filmDetailViewController.comments = arrComments;
//            [filmDetailViewController reloadViewComment];
//            [filmDetailViewController.layoutTable reloadData];
//        }
//    }
        [[APIManager sharedMySingleton] getListCommentByID:[film.film_id intValue] withLimit:[APIManager sharedMySingleton].userId context:filmDetailViewController];

//    self.isLoadingCinemaSessionBefore = NO;
    self.isLoadingCinemaSessionComplete = YES;
    [delegate disableIconProcessForLoading];
}

//-(void)getListSessionOfCinemaByFilm:(NSDate *)today
//{
//    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//    self.cinemaGroupList = [[NSMutableArray alloc] init];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    NSString *tempDate = [[NSString alloc] initWithFormat:@"%@ %@",[dateFormatter stringFromDate:today],@"23:59:59"];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *tomorrow = [dateFormatter dateFromString:tempDate];
//    NSTimeInterval currentTimeInterval = [today timeIntervalSinceReferenceDate];
//    NSTimeInterval limitTimeInterval = [tomorrow timeIntervalSinceReferenceDate];
//    
//    NSArray *arraycinemaGroup = [delegate fetchRecords:@"Cinema_group" sortWithKey:@"cinema_group_id" withPredicate:nil];
//    for (int i = 0; i < [arraycinemaGroup count]; i++)
//    {
//        Cinema_group *cinemaGroup = [arraycinemaGroup objectAtIndex:i];
//        NSString *strFilmID = [[NSString alloc] initWithFormat:@"%d",[film.film_id intValue]];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cinema_group_id=%d and (%@) IN cinema_list_film",[cinemaGroup.cinema_group_id intValue],strFilmID];
//        cinemaGroup.cinemalist = [[NSMutableArray alloc] init];
//        NSArray *arrayCinemaOfGroup= [delegate fetchRecords:@"Cinema" sortWithKey:@"cinema_id" withPredicate:predicate];
//        [strFilmID release];
//        for (int j = 0; j < [arrayCinemaOfGroup count]; j++)
//        {
//            Cinema *curCinema = [arrayCinemaOfGroup objectAtIndex:j];
//            predicate = [NSPredicate predicateWithFormat:@"cinema_id=%d and film_id=%d and version_id=%d and session_time>%lf and session_time<%lf",[curCinema.cinema_id intValue],[film.film_id intValue],3,currentTimeInterval,limitTimeInterval];
//            NSMutableArray *arraySessionVer = [delegate fetchRecords:@"Session" sortWithKey:@"session_time" withPredicate:predicate];
//            if([arraySessionVer count] > 0)
//            {
//                curCinema.arraySessions = arraySessionVer;
//                [cinemaGroup.cinemalist addObject:curCinema];
//            }
//            predicate = [NSPredicate predicateWithFormat:@"cinema_id=%d and film_id=%d and version_id!=%d and session_time>%lf and session_time<%lf",[curCinema.cinema_id intValue],[film.film_id intValue],3,currentTimeInterval,limitTimeInterval];
//            arraySessionVer = [delegate fetchRecords:@"Session" sortWithKey:@"session_time" withPredicate:predicate];
//            if([arraySessionVer count] > 0)
//            {
//                curCinema.arraySessions = arraySessionVer;
//                [cinemaGroup.cinemalist addObject:curCinema];
//            }
//        }
//        if ([cinemaGroup.cinemalist count] > 0) {
//            [self.cinemaGroupList addObject:cinemaGroup];
//        }
//    }
//    [dateFormatter release];
//}

-(void)getListSessionOfCinemaByFilm:(NSDate *)today
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.arrCinemaSessionDistance = [[[NSMutableArray alloc] init] autorelease];
    int numOfCinema = [[delegate arrayCinemaDistance] count];
    if(numOfCinema == 0)
    {
        return;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *tempDate = [[NSString alloc] initWithFormat:@"%@ %@",[dateFormatter stringFromDate:today],@"23:59:59"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *tomorrow = [dateFormatter dateFromString:tempDate];
    [tempDate release];
    NSTimeInterval currentTimeInterval = [today timeIntervalSinceReferenceDate];
    NSTimeInterval limitTimeInterval = [tomorrow timeIntervalSinceReferenceDate];
    for (int i = 0; i < numOfCinema; i++)
    {
        CinemaWithDistance *curCinemaDistance = [[delegate arrayCinemaDistance] objectAtIndex:i];
        curCinemaDistance.cinema.arraySessions = [[[NSMutableArray alloc] init] autorelease];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cinema_id=%d and film_id=%d and version_id=%d and session_time>%lf and session_time<%lf",[curCinemaDistance.cinema.cinema_id intValue],[film.film_id intValue],3,currentTimeInterval,limitTimeInterval];
        NSMutableArray *arraySessionVer = [delegate fetchRecords:@"Session" sortWithKey:@"session_time" withPredicate:predicate];
        if([arraySessionVer count] > 0)
        {
            CinemaWithDistance *cinemaDistance = [[CinemaWithDistance alloc] init];
            Cinema *cinema = [Cinema copy:curCinemaDistance.cinema];
            cinema.arraySessions = arraySessionVer;
            cinemaDistance.cinema = cinema;
            [cinema release];
            cinemaDistance.distance = curCinemaDistance.distance;
            [self.arrCinemaSessionDistance addObject:cinemaDistance];
            [cinemaDistance release];
        }
        predicate = [NSPredicate predicateWithFormat:@"cinema_id=%d and film_id=%d and version_id!=%d and session_time>%lf and session_time<%lf",[curCinemaDistance.cinema.cinema_id intValue],[film.film_id intValue],3,currentTimeInterval,limitTimeInterval];
        arraySessionVer = [delegate fetchRecords:@"Session" sortWithKey:@"session_time" withPredicate:predicate];
        if([arraySessionVer count] > 0)
        {
            CinemaWithDistance *cinemaDistance = [[CinemaWithDistance alloc] init];
            Cinema *cinema = [Cinema copy:curCinemaDistance.cinema];
            cinema.arraySessions = arraySessionVer;
            cinemaDistance.cinema = cinema;
            [cinema release];
            [self.arrCinemaSessionDistance addObject:cinemaDistance];
            [cinemaDistance release];        
        }
    }
    [dateFormatter release];
}

#pragma mark SelectView comment 
-(void)didSelectFilmComment:(Film*)Film{
  //  NSLog(@"alo view comment");
   // film_id=film.film_id;
    CommentFilmView *cmtView=[[[CommentFilmView alloc] init] autorelease];
    [cmtView set_film_id:Film.film_id];
    [self.navigationController pushViewController:cmtView animated:YES];

}
-(void)showGallaryViewOfFilm:(NSString*) filmTittle withListOfImages:(NSArray*)imageList{
    ImageIconViewController* gallary = [[ImageIconViewController alloc] init];
    gallary.filmTitle = filmTittle;
    gallary.listOfImageURL = imageList;
    [self.navigationController pushViewController:gallary animated:YES];
    [gallary release];
}

-(void)didSelectFilmToViewSlider:(Film*)theFilm{
    SliderViewImage *sliderView=[[SliderViewImage alloc] init];
    
    [sliderView setFilm:theFilm];
    UINavigationController *navbar=[[UINavigationController alloc]initWithRootViewController:sliderView];
    
    [self.navigationController presentModalViewController:navbar animated:YES];
    [sliderView release];
    [navbar release];
  //  [self.navigationController pushViewController:sliderView animated:YES];
    //[self presentModalViewController:navbar animated:YES];
  //  NSLog(@"silder view");
}
@end
