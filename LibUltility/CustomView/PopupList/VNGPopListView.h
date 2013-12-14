//
//  VNGPopListView.h
//  VNGPayGateDemo
//
//  Created by HienNM on 3/21/13.
//  Copyright (c) 2013 VNG Corporation. All rights reserved.
//

@protocol VNGPopListViewDelegate;
@interface VNGPopListView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, unsafe_unretained) id<VNGPopListViewDelegate> delegate;
@property (copy, nonatomic) void(^handlerBlock)(NSInteger anIndex);

// The options is a NSArray, contain some NSDictionaries, the NSDictionary contain 2 keys, one is "img", another is "text".
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions height:(CGFloat)aHeight;
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions height:(CGFloat)aHeight handler:(void (^)(NSInteger))aHandlerBlock;

// If animated is YES, PopListView will be appeared with FadeIn effect.
- (void)showInView:(UIView *)aView animated:(BOOL)animated;
@end

@protocol VNGPopListViewDelegate <NSObject>
- (void)VNGPopListView:(VNGPopListView *)popListView didSelectedIndex:(NSInteger)anIndex;
@optional
- (void)VNGPopListViewDidCancel;
@end