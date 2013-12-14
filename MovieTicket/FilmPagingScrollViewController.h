//
//  HGPageScrollViewSampleViewController.h
//  HGPageScrollViewSample
//
//  Created by Rotem Rubnov on 13/3/2011.
//	Copyright (C) 2011 TomTom
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//
//

#import <UIKit/UIKit.h>
#import "HGPageScrollView.h"
#import "AppDelegate.h"
#import "GAI.h"
#import "DefineDataType.h"

@class FilmPagingScrollViewController;

@protocol FilmPageScrollViewControllerDelegate <NSObject>

-(void)filmPageScrollViewController: (FilmPagingScrollViewController*) vcFilmPageScrollView didSelectFilm: (Film *) film atIndex: (NSUInteger) index;
-(void)filmPageScrollViewController: (FilmPagingScrollViewController*) vcFilmPageScrollView didSelectBanner: (NSDictionary *) dict atIndex: (NSUInteger) index;

@end

@interface FilmPagingScrollViewController : NSObject <HGPageScrollViewDelegate, HGPageScrollViewDataSource>
{
    NSInteger selectedPage;
    __weak id<FilmPageScrollViewControllerDelegate> _delegate;
    NSMutableIndexSet *indexesToDelete, *indexesToInsert, *indexesToReload;
    CGRect _viewFrame;
    NSMutableArray *_allDataList;
}
@property (nonatomic, assign) CGRect pageFrame;
@property (nonatomic, weak) id<FilmPageScrollViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *myFilmDataArray; //global variable, no need retain
@property (nonatomic, strong) NSMutableArray *bannerInfoList;
@property (nonatomic, strong) IBOutlet HGPageScrollView *pageScrollView;

-(NSInteger) getCurrentSelectedPageIndex;
-(void) setCurrentSelectedPage:(int)index;
-(void)reloadData;

@end

