//
//  CycleScrollView.h
//  CycleScrollDemo
//
//  Created by Weever Lu on 12-6-14.
//  Copyright (c) 2012年 linkcity. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CycleDirectionPortait,          // 垂直滚动
    CycleDirectionLandscape         // 水平滚动
}CycleDirection;

@protocol CycleScrollViewDelegate;
@protocol CycleScrollViewDataSource;

@interface CycleScrollView : UIView <UIScrollViewDelegate> {
    
    UIScrollView *scrollView;
    UIView *curView;
    int totalPage;
    int curPage;
    CGRect scrollFrame;
    
    CycleDirection scrollDirection;     // scrollView滚动的方向
    NSMutableArray *curViews;          // 存放当前滚动的三张图片
  
    
    id delegate;
    
    NSTimer *_timer;
    BOOL _autoScrolling;
}

@property (nonatomic, assign) IBOutlet id delegate;
@property (nonatomic, assign) IBOutlet id dataSource;
@property (nonatomic, assign) BOOL autoScrollAble;
@property (nonatomic, assign) NSTimeInterval scrollDuration;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) int cacheSize;


- (int)defaultValidPageValue:(NSInteger)value;
- (id)initWithFrame:(CGRect)frame cycleDirection:(CycleDirection)direction;
- (void)reloadData;

@end

@protocol CycleScrollViewDelegate <NSObject>
@optional

- (void)cycleScrollView:(CycleScrollView *)cycleScrollView didScrollView:(int)index;

@end

@protocol CycleScrollViewDataSource <NSObject>

@optional
- (int)cycleScrollView:(CycleScrollView *)cycleScrollView validPageValueAutoScrolling:(NSInteger)value;

- (UIView *)cycleScrollView:(CycleScrollView *)cycleScrollView viewAtPage:(NSInteger)page;

- (NSInteger)numberOfViewsInCycleScrollView:(CycleScrollView *)cycleScrollView ;

@end