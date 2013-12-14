//
//  ShowMapViewController.m
//  MovieTicket
//
//  Created by nhanmt on 1/25/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#import "ShowMapViewController.h"
#import "AppDelegate.h"
#import "CinemaFilmViewController.h"
#import "CinemaViewController.h"
#import "CustomePointAnnotation.h"
#import "SBJsonParser.h"
#import "MKPolyLine+MKPolyLine_MKPolyline_EncodedString.h"
#import "RegexKitLite.h"
#import "AppDelegate.h"
#import "APIManager.h"

@interface ShowMapViewController ()
-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded;
-(void) updateRouteView;
-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) from to: (CLLocationCoordinate2D) to;
-(void) centerMap;
@end

@implementation ShowMapViewController

@synthesize lineColor;
@synthesize myMap;
@synthesize currentLocationState;
@synthesize currentLocation, userLocation;
@synthesize startLocation = _startLocation;
@synthesize delegate;
@synthesize cinemaFilmViewDelegate;
@synthesize mapCenterCinemaGroup, mapSpanCinemaGroup, mapCenterUserChoice, mapSpanUserChoice;
@synthesize backButton;
@synthesize cinemaListWithDistance = _cinemaListWithDistance;
@synthesize typeOfMap;
@synthesize currentCinemaDistance = _currentCinema;
@synthesize isDirecting;

- (void)dealloc
{
    delegate = nil;
    cinemaFilmViewDelegate = nil;
    backButton = nil;
    _cinemaListWithDistance = nil;
    self.startLocation = nil;
    self.lineColor = nil;
    routes = nil;
    lineColor = nil;
    routeView = nil;
    
    [self applyMapViewMemoryHotFix];
    [myMap removeFromSuperview];
    [myMap removeAnnotations:myMap.annotations];
    [myMap.layer removeAllAnimations];
    myMap.showsUserLocation = NO;//This line does not make a difference in heapshot
    myMap.delegate = nil;
    myMap = nil;
    typeOfMap = nil;
    myMap = nil;
    backButton = nil;
    currentLocationState = nil;
}

- (void)applyMapViewMemoryHotFix{
    
    switch (myMap.mapType) {
        case MKMapTypeHybrid:
        {
            myMap.mapType = MKMapTypeStandard;
        }
            
            break;
        case MKMapTypeStandard:
        {
            myMap.mapType = MKMapTypeHybrid;
        }
            
            break;
        default:
            break;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        CGFloat mapHeight = [[UIScreen mainScreen] bounds].size.height - TITLE_BAR_HEIGHT;
        myMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, mapHeight)];
        myMap.userInteractionEnabled = YES;
        myMap.showsUserLocation = NO;
        myMap.delegate = self;
        _startLocation = [[Position alloc] init];
        backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cinemaListWithDistance = [[NSArray alloc] init];
        _currentCinema = [[CinemaWithDistance alloc] init];
        
        self.lineColor = [UIColor colorWithRed:16.0/225 green:27.0/255 blue:250.0/255 alpha:0.5];
        routeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, myMap.frame.size.width, myMap.frame.size.height)];
		routeView.userInteractionEnabled = NO;
		[myMap addSubview:routeView];
        
        
        viewName = MAP_VIEW_NAME;
        
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return userLocation;
}

- (void)handleBackButton
{
    // choose location
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        [self sendMapRegion];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)handleDirectionButton
{
    
    // send log to 123phim server
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:appDelegate.currentView
                                                          comeFrom:appDelegate.currentView
                                                      withActionID:ACTION_MAP_VIEW_DIRECTION
                                                     currentFilmID:[NSNumber numberWithInt:NO_FILM_ID]
                                                   currentCinemaID:self.currentCinemaDistance.cinema.cinema_id
                                                   returnCodeValue:0 context:nil];
    
    //check network on, if not not show direction guide
    if (![AppDelegate isNetWorkValiable]){
        UIAlertView* networkNoti = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:@"Vui lòng kết nối internet để thực hiện chức năng này" delegate:nil cancelButtonTitle:@"Tiếp tục" otherButtonTitles: nil];
        [networkNoti show];
        return;  
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        CinemaViewController* cinemaViewController = [CinemaViewController sharedCinemaViewController];
        CLLocationCoordinate2D cityCenter = CLLocationCoordinate2DMake(cinemaViewController.yourCity.latitude, cinemaViewController.yourCity.longtitude);
        [AppDelegate setPresentPoint: cityCenter];
    }
    
    self.isDirecting = YES;
//    // show alert when user turn off "Bat dinh vi"
//    BOOL locationOn = [APIManager getBooleanInAppForKey:KEY_STORE_IS_SHOW_MY_LOCATION];
//    if (!locationOn) {
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: nil message:@"Vui lòng \"Bật định vị\" để có thông tin chính xác hơn." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Đồng ý", @"Huỷ", nil];
//        [alert show];
//        [alert release];
//    }    
    
    [self addIconForCityCenter];
    
    Place* fromP = [[Place alloc] init];
    //        fromP.name = @"Home";
    //        fromP.description = @"Sweet home";
    fromP.latitude = [AppDelegate getPresentPoint].latitude;
    fromP.longitude = [AppDelegate getPresentPoint].longitude;
    
    Place* toP = [[Place alloc] init];
    //        office.name = @"Office";
    //        office.description = @"Bad office";
    toP.latitude = [self.currentCinemaDistance.cinema.cinema_latitude floatValue];
    toP.longitude = [self.currentCinemaDistance.cinema.cinema_longtitude floatValue];
    
    [self showRouteFrom:fromP to:toP];
    
    for (int i = 0; i < self.myMap.annotations.count; i++) {
        [self.myMap deselectAnnotation:[self.myMap.annotations objectAtIndex:i] animated:NO];
    }

}

- (void)addIconForCityCenter
{
    if (![[CinemaViewController sharedCinemaViewController] isDistanceFromYourPos]) {
        Location* city = [CinemaViewController sharedCinemaViewController].yourCity;
        CustomePointAnnotation* annotationCity = [[CustomePointAnnotation alloc] init];
        annotationCity.index = 12345;
        annotationCity.coordinate = CLLocationCoordinate2DMake(city.latitude, city.longtitude);
        annotationCity.title = city.center_name;
        [self.myMap addAnnotation:annotationCity];
    }
}

- (void)displayMapWithCenter:(CLLocationCoordinate2D)center span:(MKCoordinateSpan)span animation:(BOOL)animation
{
    MKCoordinateRegion region;
    region.center = center;
    region.span = span;
    
    [self.myMap setRegion:region animated:animation];
//    [self.myMap regionThatFits:region];
}

- (void)showUserLocationIcon:(BOOL)isShow
{
    self.myMap.showsUserLocation = isShow;
}

- (void)getCurrentLocation
{
//    LOG_123PHIM(@"getCurrentLocation");
    self.currentLocation = self.myMap.userLocation.coordinate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Duydph - 04/12/2013 - Add Remarketing Code
    PINGREMARKETING
    
	// Do any additional setup after loading the view.
//    LOG_123PHIM(@"map size: %f, %f", myMap.frame.size.width, myMap.frame.size.height);
    //add Map
    [self.view addSubview:myMap];
    
    //add Back Buton
    [self.backButton setTitle:@"Trở về" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0] forState:UIControlEventTouchDown];
    self.backButton.frame = CGRectMake(10, 10, 60, 30);
    [self.backButton addTarget:self action:@selector(handleBackButton) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.titleLabel.textColor = [UIColor blackColor];
    self.backButton.titleLabel.font = [UIFont getFontBoldSize13];
    CALayer* layer1 = self.backButton.layer;
    layer1.cornerRadius = 6.0;
    layer1.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
    layer1.borderColor = [UIColor darkGrayColor].CGColor;
    layer1.borderWidth = 0.5;
    [myMap addSubview:self.backButton];
    
    if (self.typeOfMap == MapTypeCinemaIndividual) {
        UIButton* directionButton = [[UIButton alloc] init];
        [directionButton setTitle:@"Chỉ đường" forState:UIControlStateNormal];
        [directionButton setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0] forState:UIControlEventTouchDown];
        directionButton.frame = CGRectMake(0, 10, 85, 30);
        CGRect frame = directionButton.frame;
        frame.origin.x = [UIScreen mainScreen].bounds.size.width - directionButton.frame.size.width - 10;
        directionButton.frame = frame;
        [directionButton addTarget:self action:@selector(handleDirectionButton) forControlEvents:UIControlEventTouchUpInside];
        directionButton.titleLabel.textColor = [UIColor blackColor];
        directionButton.titleLabel.font = [UIFont getFontBoldSize13];
        CALayer* layer2 = directionButton.layer;
        layer2.cornerRadius = 6.0;
        layer2.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        layer2.borderColor = [UIColor darkGrayColor].CGColor;
        layer2.borderWidth = 0.5;
        
        [myMap addSubview:directionButton];
    }
    
    
    UILabel* infoText = [[UILabel alloc] init];
    infoText.backgroundColor = [UIColor clearColor];
    infoText.textAlignment = UITextAlignmentRight;
    infoText.font = [UIFont fontWithName:@"Helvetica-Oblique" size:11];
    infoText.text = @"Dữ liệu được lấy từ Google Map";
    infoText.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    infoText.frame = CGRectMake(0, 10, 310, 25);
    CGRect frame = infoText.frame;
    frame.origin.x = 0;
    frame.origin.y = myMap.bounds.size.height - infoText.frame.size.height;
    infoText.frame = frame;
    [myMap addSubview:infoText];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        myMap.frame = CGRectMake(myMap.frame.origin.x, myMap.frame.origin.y + TITLE_BAR_HEIGHT, myMap.frame.size.width, myMap.frame.size.height);
    }
    [self displayMapWithCenter:self.mapCenterUserChoice span:self.mapSpanUserChoice animation:YES];
    self.trackedViewName = viewName;
//    NSString* previewView = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).currentView;
//    NSString* currentView = viewName;
//    [[APIManager sharedAPIManager] sendLogToSever123PhimRequestURL:currentView comeFrom:previewView withActionID:LOG_ACTION_ID_VIEW currentFilmID:[NSNumber numberWithInt: NO_FILM_ID] currentCinemaID:[NSNumber numberWithInt: NO_CINEMA_ID] returnCodeValue:0 context:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showUserLocationIcon:[[CinemaViewController sharedCinemaViewController] isDistanceFromYourPos]];
    
    //add annotations
    [self removeAllAnnotations];
    if (self.typeOfMap == MapTypeCinemaGroup) {
        for (CinemaWithDistance* item in self.cinemaListWithDistance ) {
            CustomePointAnnotation* annotation = [[CustomePointAnnotation alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake([item.cinema.cinema_latitude doubleValue], [item.cinema.cinema_longtitude doubleValue]);
            annotation.index = [self.cinemaListWithDistance indexOfObject:item];
            annotation.title = item.cinema.cinema_name;
//            annotation.title = [NSString stringWithFormat:@"index: %d - %@", annotation.index, item.cinema.cinema_name];
            annotation.subtitle = item.cinema.cinema_address;
            [self.myMap addAnnotation:annotation];
        }
        if (![[CinemaViewController sharedCinemaViewController] isDistanceFromYourPos]) {
            [self addIconForCityCenter];
        }
    
    }else if (self.typeOfMap == MapTypeCinemaIndividual){
        CustomePointAnnotation* annotation = [[CustomePointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake([self.currentCinemaDistance.cinema.cinema_latitude doubleValue], [self.currentCinemaDistance.cinema.cinema_longtitude doubleValue]);
        annotation.title = self.currentCinemaDistance.cinema.cinema_name;
        annotation.subtitle = self.currentCinemaDistance.cinema.cinema_address;
        [self.myMap addAnnotation:annotation];
        
    }else{}
    
    //show text of annotation when view appear
    if (self.typeOfMap == MapTypeCinemaIndividual) {
        [self.myMap selectAnnotation:[self.myMap.annotations objectAtIndex:0] animated:YES];

    }else if (self.typeOfMap == MapTypeCinemaGroup){
        for (id<MKAnnotation> annotation in self.myMap.annotations) {
            if ([annotation isKindOfClass:[MKUserLocation class]] || ((CustomePointAnnotation*)annotation).index == 12345) {
//                [self.myMap selectAnnotation:annotation animated:YES];
            }
        }
        
    }else{
    }
    
    if (self.isDirecting) {
        [self handleDirectionButton];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    MKCoordinateRegion region;
//    region.center = self.mapCenterUserChoice;
//    LOG_123PHIM(@"center: (%f, %f)", region.center.latitude, region.center.longitude);
//    region.span = self.mapSpanUserChoice;
//    LOG_123PHIM(@"span: (%f, %f)", region.span.latitudeDelta, region.span.longitudeDelta);
//    
//    [self.myMap setRegion:region animated:animated];
//    [self.myMap regionThatFits:region];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)sendMapRegion
{
    if (self.delegate == nil || ![self.delegate respondsToSelector:@selector(receiveLocationData:andMapStatusOfCenter:andMapStatusOfSpan:)]) {
       
        return;
    }
    [self.delegate receiveLocationData: nil andMapStatusOfCenter:self.mapCenterUserChoice andMapStatusOfSpan:self.mapSpanUserChoice];
}

-(void)removeAllAnnotations
{
    id userAnnotation = self.myMap.userLocation;
    
    NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.myMap.annotations];
    [annotations removeObject:userAnnotation];
    
    [self.myMap removeAnnotations:annotations];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{    
    //store currently map center and span when visible map change
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(mapView.region.center.latitude, mapView.region.center.longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);

    if (YES == self.currentLocationState) {
        self.mapCenterCinemaGroup = center;
        self.mapSpanCinemaGroup = span;
    }else{
        self.mapCenterUserChoice = center;
        self.mapSpanUserChoice = span;
    }
    
    
    [self updateRouteView];
	routeView.hidden = NO;
	[routeView setNeedsDisplay];

}

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        self.myMap.userLocation.title = @"Bạn đang ở đây";
    
    }else if (((CustomePointAnnotation*)annotation).index == 12345){
        static NSString *identifier = @"MyCity";
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:identifier];
            annotationView.image = [UIImage imageNamed:@"star.png"];
        } else {
            annotationView.annotation = annotation;
        }
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        
        return annotationView;
        
    }else{
        static NSString *identifier = @"MyLocation";    
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:identifier];
            annotationView.image = [UIImage imageNamed:@"footer-button-theater-active.png"];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        if (self.typeOfMap == MapTypeCinemaGroup){
            annotationView.tag = ((CustomePointAnnotation*)annotation).index;
            // Create a UIButton object to add on the
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [annotationView setRightCalloutAccessoryView:rightButton];
        }
        
        return annotationView;
    }
    
    return nil;

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([(UIButton*)control buttonType] == UIButtonTypeDetailDisclosure){
        
//        CinemaFilmViewController *cinemaFilm=[[CinemaFilmViewController alloc] init];
        CinemaFilmViewController* cinemaFilm = [[CinemaFilmViewController alloc] initWithNibName:@"CinemaFilmTable" bundle:[NSBundle mainBundle]];
        cinemaFilm.curCinemaDistance = [self.cinemaListWithDistance objectAtIndex:view.tag];
        [self.navigationController pushViewController:cinemaFilm animated:YES];
        
        
        
//        // Do your thing when the detailDisclosureButton is touched
//        UIViewController *mapDetailViewController = [[UIViewController alloc] init];
//        [[self navigationController] pushViewController:mapDetailViewController animated:YES];
        
//        CinameFilmView *cinemaFilm=[[CinameFilmView alloc] init];
//        CinemaViewController* cinemaViewControllerDelegate = [CinemaViewController sharedCinemaViewController];
//        cinemaViewControllerDelegate 
//        cinemaFilm.curCienmaDistance = [cinemaListWithDistance objectAtIndex:[indexPath row]];
//        [cinemaFilm setIndexOfCurrentCinemaDistancesInArray:indexPath.row];
//        [cinemaFilm.arrFilmSessionTime removeAllObjects];
//        [self.navigationController pushViewController:cinemaFilm animated:YES];
//        [cinemaFilm release];
        
    } 
}

#pragma mark Draw route
- (void)drawRouteFromPoints: (NSArray*)path //path: lat0, long0, lat1, long1, ...
{ 
    NSInteger numberOfSteps = path.count/2;
    CLLocationCoordinate2D coordinates[numberOfSteps];
    
    int i = 0;
    for (NSInteger index = 0; index < path.count; index+=2) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[path objectAtIndex:index] doubleValue], [[path objectAtIndex:(index+1)] doubleValue]);
        coordinates[i] = coordinate;
//        LOG_123PHIM(@"(%f, %f)", coordinates[i].latitude, coordinates[i].longitude);
        i++;
    }
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    [self.myMap setVisibleMapRect:polyLine.boundingMapRect animated:YES];
    [self.myMap addOverlay:polyLine];
    

}

- (MKOverlayView*)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineView* retView = [[MKPolylineView alloc] initWithPolyline:overlay];
    retView.lineWidth = 5;
    retView.strokeColor = [UIColor purpleColor];
    retView.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1f];
    return  retView;
}

- (void)getDirectionDataWithStartPoint: (CLLocationCoordinate2D)startP endPoint:(CLLocationCoordinate2D)endP
{
    static NSInteger time = 0;
//    NSString* link = @"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false";
//    NSString* link = @"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&alternatives=true";
    NSString* link = @"http://maps.google.com/maps?output=dragdir&saddr=%f,%f&daddr=%f,%f";
    
    NSString* api = [NSString stringWithFormat:link, startP.latitude, startP.longitude, endP.latitude, endP.longitude];
    
    NSURL* url = [NSURL URLWithString:api];    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString* encodedPoints = [string stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
            NSMutableString *endcodeString = [encodedPoints mutableCopy];
            MKPolyline* polyline = [MKPolyline polylineWithEncodedString:endcodeString];
            [self.myMap setVisibleMapRect:polyline.boundingMapRect animated:YES];
            [self.myMap addOverlay:polyline];
            
//            NSDictionary* rawData = [parsor objectWithString:string];
//            if ([[rawData objectForKey:@"status"] isEqual:@"OK"]) {
//                
//                NSMutableArray* routes = [rawData objectForKey:@"routes"];
//                NSMutableArray* legs = [[routes objectAtIndex:0] objectForKey:@"legs"];
//                NSMutableArray* overview_polyline = [[routes objectAtIndex:0] objectForKey:@"overview_polyline"];
//                NSString* points = [overview_polyline objectForKey:@"points"];
//                MKPolyline* polyline = [MKPolyline polylineWithEncodedString:points];
//                [self.myMap setVisibleMapRect:polyline.boundingMapRect animated:YES];
//                [self.myMap addOverlay:polyline];
//                
//                NSMutableArray* steps = [[legs objectAtIndex:0] objectForKey:@"steps"];
//                for(int i = 0; i<steps.count;i++){
//                    NSDictionary* startLocation = [[steps objectAtIndex:i] objectForKey:@"start_location"];                    
//                    LOG_123PHIM(@"Start %@", startLocation);
//                    NSNumber* lat = [startLocation objectForKey:@"lat"];
//                    NSNumber* lng = [startLocation objectForKey:@"lng"];
//                    [listPoints addObject:lat];
//                    [listPoints addObject:lng];
//                }
////                [self getgetDirectionDataFinish:[listPoints autorelease]];
//            }
            
        }else{
            if (time < 3) {
                [self getDirectionDataWithStartPoint:startP endPoint:endP];
            }
            time++;
        }
    }];

    
}

- (void)getgetDirectionDataFinish:(NSMutableArray*)points
{
    [self drawRouteFromPoints:points];
    
}

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
		NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
		printf("[%f,", [latitude doubleValue]);
		printf("%f]", [longitude doubleValue]);
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
		[array addObject:loc];
	}
	
	return array;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
	NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
	NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
	
	NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
	NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    NSError *error;
	NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSStringEncodingConversionAllowLossy error:&error];
	NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    NSMutableString *stringEndcode = [encodedPoints mutableCopy];
    NSMutableArray * array = [self decodePolyLine:stringEndcode];
	return array;
}

-(void) centerMap {
	MKCoordinateRegion region;
    
	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	for(int idx = 0; idx < routes.count; idx++)
	{
		CLLocation* currentLoc = [routes objectAtIndex:idx];
		if(currentLoc.coordinate.latitude > maxLat)
			maxLat = currentLoc.coordinate.latitude;
		if(currentLoc.coordinate.latitude < minLat)
			minLat = currentLoc.coordinate.latitude;
		if(currentLoc.coordinate.longitude > maxLon)
			maxLon = currentLoc.coordinate.longitude;
		if(currentLoc.coordinate.longitude < minLon)
			minLon = currentLoc.coordinate.longitude;
	}
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;    
	region.span.latitudeDelta  = (maxLat - minLat)*1.5555555555;
	region.span.longitudeDelta = (maxLon - minLon)*1.5555555555;

//	[self.myMap setCenterCoordinate:region.center animated:YES];
    [self.myMap setRegion:region animated:YES];

}

-(void) showRouteFrom: (Place*) f to:(Place*) t {
	
	
	PlaceMark* from = [[PlaceMark alloc] initWithPlace:f];
	PlaceMark* to = [[PlaceMark alloc] initWithPlace:t];
	
//	[self.myMap addAnnotation:from];
//	[self.myMap addAnnotation:to];
	
	routes = [self calculateRoutesFrom:from.coordinate to:to.coordinate];
	
	[self updateRouteView];
	[self centerMap];
    
}

-(void) updateRouteView {
    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = 	CGBitmapContextCreate(nil,
												  routeView.frame.size.width,
												  routeView.frame.size.height,
												  8,
												  4 * routeView.frame.size.width,
												  colorRef,
												  kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorRef);
	CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 4.0);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
	
	for(int i = 0; i < routes.count; i++) {
		CLLocation* location = [routes objectAtIndex:i];
		CGPoint point = [self.myMap convertCoordinate:location.coordinate toPointToView:routeView];
		
		if(i == 0) {
			CGContextMoveToPoint(context, point.x, routeView.frame.size.height - point.y);
		} else {
			CGContextAddLineToPoint(context, point.x, routeView.frame.size.height - point.y);
		}
	}
	
	CGContextStrokePath(context);
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	UIImage* img = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
	
	routeView.image = img;
	CGContextRelease(context);
    
}

#pragma mark mapView delegate functions
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	routeView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    //     LOG_123PHIM(@"didAddAnnotationViews");
//    //show text of annotation when view appear
//    
//    for (MKAnnotationView *annotationView in views)
//    {
//        if (self.typeOfMap == MapTypeCinemaIndividual) {
////            [self.myMap selectAnnotation:annotationView.annotation animated:YES];
//            return;
//            
//        }
//        else if (self.typeOfMap == MapTypeCinemaGroup){
//                if ([annotationView.annotation isKindOfClass:[MKUserLocation class]] || ((CustomePointAnnotation*)annotationView.annotation).index == 12345) {
//                    LOG_123PHIM(@"point: (%f, %f)", annotationView.annotation.coordinate.latitude, annotationView.annotation.coordinate.longitude);
////                    [self displayMapWithCenter:CLLocationCoordinate2DMake(annotationView.annotation.coordinate.latitude, annotationView.annotation.coordinate.longitude) span:MKCoordinateSpanMake(0.01, 0.01) animation:YES];
////                    [self.myMap selectAnnotation:annotationView.annotation animated:YES];
//                }
//            return;
//            
//        }else{
//        }
//    }
//    
////    for (MKAnnotationView *annotationView in views)
////    {
////        if (self.typeOfMap == MapTypeCinemaGroup && [annotationView.annotation isKindOfClass:[MKUserLocation class]]){
////            LOG_123PHIM(@"point: (%f, %f)", annotationView.annotation.coordinate.latitude, annotationView.annotation.coordinate.longitude);
////            [self.myMap selectAnnotation:annotationView.annotation animated:YES];
////            return;
////        }
////    }

}

#pragma mark Alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [APIManager setBooleanInApp:YES ForKey:KEY_STORE_IS_SHOW_MY_LOCATION];
        [[CinemaViewController sharedCinemaViewController] updateDisplayLocation];
        [self viewDidAppear:YES];
        [self handleDirectionButton];
    }else if (buttonIndex == 1)
    {
        return;
    }else{}
}


@end
