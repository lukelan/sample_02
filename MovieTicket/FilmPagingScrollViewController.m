
#import "FilmPagingScrollViewController.h"
#import "MyPageData.h"
#import "MyPageView.h"
#import "Film.h"

#import "AppDelegate.h"
#import "FilmPosterPageView.h"
#import "MainViewController.h"
#import "PlayTrailerViewController.h"
#import "APIManager.h"
//#import "DefinePath.h"
#define TAG_INDEX 10000

@interface FilmPagingScrollViewController(internal)
- (UIViewController*) headerInfoForPageAtIndex : (NSInteger) index;
- (void) addPagesAtIndexSet : (NSIndexSet *) indexSet;
- (void) removePagesAtIndexSet : (NSIndexSet *) indexSet;
@end


#define kPlatformSupportsViewControllerHeirarchy ([self respondsToSelector:@selector(childViewControllers)] && [self.childViewControllers isKindOfClass:[NSArray class]])

@implementation FilmPagingScrollViewController

@synthesize delegate = _delegate;
@synthesize pageScrollView = _myPageScrollView;
@synthesize myFilmDataArray = _myFilmDataArray;
@synthesize bannerInfoList = _bannerInfoList;

- (void)dealloc {
    SAFE_RELEASE(_allDataList)
    [indexesToDelete removeAllIndexes];
    [indexesToInsert removeAllIndexes];
    [indexesToReload removeAllIndexes];
    [_allDataList removeAllObjects];
    [_bannerInfoList removeAllObjects];
    
    self.bannerInfoList = nil;
    selectedPage = nil;
    _delegate = nil;
    indexesToDelete = nil;
    indexesToInsert = nil;
    indexesToReload = nil;
    _bannerInfoList = nil;
    _allDataList = nil;
    _myPageScrollView = nil;
    _myFilmDataArray = nil;
}
-(NSInteger) getCurrentSelectedPageIndex
{
    if (_myPageScrollView)
    {
        return [_myPageScrollView indexForSelectedPage];
    }
    return 0;
}

-(void) setCurrentSelectedPage:(int)index
{
    if (_myPageScrollView) {
        return [_myPageScrollView setStartPageIndex:index];
    }
}

-(id)init
{
    if (self = [super init])
    {
        selectedPage = NSIntegerMin;
    }
    return  self;
}

#pragma mark -
#pragma mark HGPageScrollViewDataSource

-(void)reloadData
{
    if (!self.pageScrollView.dataSource)
    {
        [self.pageScrollView setDataSource:self];
        [self.pageScrollView setDelegate:self];
    }
    [self.pageScrollView reloadData];
}

- (NSInteger)numberOfPagesInScrollView:(HGPageScrollView *)scrollView;   // Default is 0 if not implemented
{
	return [_allDataList count];
}

- (UIFont *)getFontLargeName
{
    return [UIFont getFontBoldSize14];
}

- (HGPageView *)pageScrollView:(HGPageScrollView *)scrollView viewForPageAtIndex:(NSInteger)index;
{   
    Film *curFilm = (Film *)[_allDataList objectAtIndex:index];
    selectedPage=index;
    NSString *pageId = [NSString stringWithFormat:@"FilmPage"];
    MyPageView *pageView = (MyPageView*)[scrollView dequeueReusablePageWithIdentifier:pageId];
    CGRect fr = CGRectZero;
    fr.size = scrollView.pageSize;
    if (!pageView)
    {
        // set the pageView frame height
        pageView = [[MyPageView alloc] initWithFrame:fr];
        pageView.reuseIdentifier = pageId;
        pageView.frame = fr;
        pageView.identityFrame = fr;
    }
    FilmPosterPageView *posterView = (FilmPosterPageView *)pageView.normalView;
    if (!posterView)
    {
        posterView = [[[NSBundle mainBundle] loadNibNamed:@"FilmPosterPageView" owner:self options:nil] objectAtIndex:0];
        pageView.normalView.frame =fr;
        posterView.lbScrollFilmTitle.font=[self getFontLargeName];
        posterView.lbScrollFilmTitle.textColor = [UIColor whiteColor];
        posterView.lbScrollFilmTitle.textAlignment = UITextAlignmentCenter;
        pageView.normalView = posterView;
    }
    NSString *url = @"";
    BOOL newHidden = YES;
    BOOL bomtanHidden = YES;
    BOOL titleHidden = YES;
    if([curFilm isKindOfClass:[Film class]])
    {
        url = curFilm.poster_url;
        newHidden = ![curFilm.is_new boolValue];
        bomtanHidden = ([curFilm.type_id intValue] != 2);
        titleHidden = NO;
        [posterView.viewSaleOff setHidden:NO];
        if (curFilm.discount_type.intValue == ENUM_DISCOUNT_PERCENT)
        {
            [posterView.lblSaleOff setText:[NSString stringWithFormat:@"-%d%@", curFilm.discount_value.intValue,@"%"]];
        }
        else if (curFilm.discount_type.intValue == ENUM_DISCOUNT_MONEY)
        {
            [posterView.lblSaleOff setText:[NSString stringWithFormat:@"-%dK", curFilm.discount_value.intValue/1000]];
        }
        else
        {
            [posterView.viewSaleOff setHidden:YES];
        }
    }
    else  if ([curFilm isKindOfClass:[NSDictionary class]])
    {
        url = [((NSDictionary *)curFilm) objectForKey:@"poster_url"];
    }
    [posterView.viewCustom setImageWithURL:[NSURL URLWithString:url]];
    
    //Kiem tra de add image water mask bomtan or new
    [posterView.ivNew setHidden: newHidden];
    if (![posterView.viewSaleOff isHidden] && !newHidden) {
        [posterView.ivNew setHidden:YES];
    }
    [posterView.ivBomTan setHidden: bomtanHidden];
    [posterView.lbTilteRate_Show setHidden:titleHidden];
    [posterView.lbValueRate_Show setHidden:titleHidden];
    [posterView.lbScrollFilmTitle setHidden:titleHidden];
    [posterView.ivPosterTitle setHidden:titleHidden];
    //---------------End water mask---------------------//
    
    // title of rate or showing
    if ([curFilm isKindOfClass:[Film class]])
    {
        if ([curFilm.status_id intValue] == ID_REQUEST_FILM_LIST_COMMING) {
            posterView.lbTilteRate_Show.text = @"Khởi chiếu";
        }
        else
        {
            posterView.lbTilteRate_Show.text = @"Đánh giá";
        }
        
        if ([curFilm.status_id intValue] == ID_REQUEST_FILM_LIST_COMMING)
        {
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"d/M"];
            NSString* dateString = [dateFormat stringFromDate:curFilm.publish_date];
            [posterView.lbValueRate_Show setText: dateString];
        }
        else
        {
            float pointValue = 0;
            if ([curFilm.film_point_rating floatValue] > 0) {
                pointValue = [curFilm.film_point_rating floatValue];
            }
            else
            {
                pointValue = arc4random()%10;
                if (pointValue == 0) {
                    pointValue = 1;
                }
            }
            [posterView.lbValueRate_Show setText:[NSString stringWithFormat:@"%.01f",pointValue]];
        }
        posterView.lbScrollFilmTitle.text = curFilm.film_name;
    }

//    [autoLable refreshLabels];
    [pageView setContentViewWithAnimation:NO];
    if (pageView.displayDetail)
    {
        [pageView setContentViewWithAnimation:NO];
    }
    return pageView;
}

#pragma mark - 
#pragma mark HGPageScrollViewDelegate
- (void)pageScrollView:(HGPageScrollView *)scrollView willSelectPageAtIndex:(NSInteger)index;
{
  //  MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    
 //   if (!pageData.navController) {
        MyPageView *page = (MyPageView*)[scrollView pageAtIndex:index];
        UIScrollView *pageContentsScrollView = (UIScrollView*)[page viewWithTag:10];
        
       // if (!page.isInitialized) {
            // prepare the page for interaction. This is a "second step" initialization of the page 
            // which we are deferring to just before the page is selected. While the page is initially
            // requeseted (pageScrollView:viewForPageAtIndex:) this extra step is not required and is preferably 
            // avoided due to performace reasons.  
            
            // asjust text box height to show all text
            UITextView *textView = (UITextView*)[page viewWithTag:3];
            CGFloat margin = 12;
            CGSize size = [textView.text sizeWithFont:textView.font
                                    constrainedToSize:CGSizeMake(textView.frame.size.width, 2000) //very large height
                                        lineBreakMode:UILineBreakModeWordWrap];
            CGRect frame = textView.frame;
            frame. size.height = size.height + 4*margin;
            textView.frame = frame;
            
            // adjust content size of scroll view
            pageContentsScrollView.contentSize = CGSizeMake(pageContentsScrollView.frame.size.width, frame.origin.y + frame.size.height);
            
            // mark the page as initialized, so that we don't have to do all of the above again 
            // the next time this page is selected
            page.isInitialized = YES;  
      //  }
        
        // enable scroll
        pageContentsScrollView.scrollEnabled = YES;
}

- (void) pageScrollView:(HGPageScrollView *)scrollView didSelectPageAtIndex:(NSInteger)index
{
    Film *film = [_allDataList objectAtIndex:index];
    NSUInteger arrIndex;
    if ([film isKindOfClass:[Film class]])
    {
        arrIndex = [_myFilmDataArray indexOfObject:film];
        if(self.delegate && [self.delegate respondsToSelector:@selector(filmPageScrollViewController:didSelectFilm:atIndex:)])
        {
            [ self.delegate filmPageScrollViewController:self didSelectFilm:film atIndex:arrIndex];
        }
    }
    else
    {
        arrIndex = [self.bannerInfoList indexOfObject:film];
        if(self.delegate && [self.delegate respondsToSelector:@selector(filmPageScrollViewController:didSelectBanner:atIndex:)])
        {
            [ self.delegate filmPageScrollViewController:self didSelectBanner:(NSDictionary *)film atIndex:arrIndex];
        }
    }
}


- (void)pageScrollView:(HGPageScrollView *)scrollView didDeselectPageAtIndex:(NSInteger)index
{
    // Now the page scroller is in DECK mode. 
    // Complete an add/remove pages request if one is pending
    if (indexesToDelete) {
        [self removePagesAtIndexSet:indexesToDelete];
        indexesToDelete = nil;
    }
    if (indexesToInsert) {
        [self addPagesAtIndexSet:indexesToInsert];
        indexesToInsert = nil;
    }
}

-(CGSize)pageSizeForScrollview:(HGPageScrollView *)scrollView
{
    return CGSizeMake(231, 348);
}

-(CGFloat)separatorWidthForScrollView:(HGPageScrollView *)scrollView
{
    CGSize size = [scrollView pageSize];
    return (460 - NAVIGATION_BAR_HEIGHT - TAB_BAR_HEIGHT - size.height) / 2; // key is iphone 4
}

-(void)setMyFilmDataArray:(NSArray *)myFilmDataArray
{
    _myFilmDataArray = myFilmDataArray;
    SAFE_RELEASE(_allDataList)
    _allDataList = [[NSMutableArray alloc] initWithArray:_myFilmDataArray];
}

-(void)setBannerInfoList:(NSMutableArray *)bannerInfoList
{
    SAFE_RELEASE(_bannerInfoList)
    if (bannerInfoList)
    {
        _bannerInfoList = [[NSMutableArray alloc] initWithArray:bannerInfoList];
        [_bannerInfoList sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {
            if ([[obj1 objectForKey:@"index"] integerValue] > [[obj2 objectForKey:@"index"] integerValue])
            {
                return NSOrderedAscending;
            }
            return NSOrderedDescending;
        }];
        for (NSDictionary *dict in _bannerInfoList) {
            NSUInteger index = [[dict objectForKey:@"index"] integerValue];
            if (_allDataList && [_allDataList count] >= index)
            {
                [_allDataList insertObject:dict atIndex:index];
            }
        }
    }
}

@end

