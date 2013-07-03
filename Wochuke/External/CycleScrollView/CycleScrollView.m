//
//  CycleScrollView.m
//  CycleScrollDemo
//
//  Created by Weever Lu on 12-6-14.
//  Copyright (c) 2012年 linkcity. All rights reserved.
//

#import "CycleScrollView.h"
#define DEFAULT_SCROLLEDUATION 3.0
#define CSV_CACHESIZE 5

@interface CycleScrollView (){
    NSMutableDictionary *_cacheViewsDict;
}

@end

@implementation CycleScrollView
@synthesize delegate;
@synthesize dataSource = _dataSource;

-(void)layoutSubviews{
    [super layoutSubviews];
    [self refreshScrollView];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSelf];
    }
    return self;
}

-(void)initSelf{
    curPage = 1;                                    // 显示的是图片数组里的第一张图片
    curViews = [[NSMutableArray alloc] init];
    _cacheSize = CSV_CACHESIZE;
    scrollFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    
    _scrollDuration = DEFAULT_SCROLLEDUATION;
    
    [self addSubview:scrollView];
    scrollDirection = CycleDirectionLandscape;
    _cacheViewsDict = [[NSMutableDictionary alloc]initWithCapacity:CSV_CACHESIZE];
}

- (id)initWithFrame:(CGRect)frame cycleDirection:(CycleDirection)direction;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self initSelf];
        scrollDirection = direction;
    }
    
    return self;
}

-(void)reloadData{
    [_cacheViewsDict removeAllObjects];
    [self refreshScrollView];
}

- (void)refreshScrollView {
    
    NSArray *subViews = [scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    if ([_dataSource respondsToSelector:@selector(numberOfViewsInCycleScrollView:)]) {
        totalPage = [_dataSource numberOfViewsInCycleScrollView:self];
    }
    if (totalPage==0) {
        return;
    }
    // 在水平方向滚动
    if(scrollDirection == CycleDirectionLandscape) {
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * MIN(totalPage==1?1:3,3),
                                            scrollView.frame.size.height);
    }
    // 在垂直方向滚动
    if(scrollDirection == CycleDirectionPortait) {
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,
                                            scrollView.frame.size.height * MIN(totalPage==1?1:3,3));
    }
    [self getDisplayViewsWithCurpage:curPage];
    for (int i = 0; i < MIN(totalPage,3); i++) {
        UIView *view = [curViews objectAtIndex:i];
        view.frame = scrollFrame;
        
        // 水平滚动
        if(scrollDirection == CycleDirectionLandscape) {
            view.frame = CGRectOffset(view.frame, scrollFrame.size.width * i, 0);
        }
        // 垂直滚动
        if(scrollDirection == CycleDirectionPortait) {
            view.frame = CGRectOffset(view.frame, 0, scrollFrame.size.height * i);
        }
        [scrollView addSubview:view];
    }
    if (scrollDirection == CycleDirectionLandscape && totalPage>1) {
        [scrollView setContentOffset:CGPointMake(scrollFrame.size.width, 0)];
    }
    if (scrollDirection == CycleDirectionPortait && totalPage>1) {
        [scrollView setContentOffset:CGPointMake(0, scrollFrame.size.height)];
    }
    
    
}

-(void)setAutoScrollAble:(BOOL)autoScrollAble{
    _autoScrollAble = autoScrollAble;
    if (autoScrollAble) {
        [self setScrollTimer];
    }else{
        [self removeScrollTimer];
    }
}

- (void)autoScrollNextPage{
    if(scrollDirection == CycleDirectionLandscape && totalPage>1) {
        // 往下翻一张
       [scrollView setContentOffset:CGPointMake(scrollFrame.size.width*2, 0) animated:YES];
    }
    
    // 垂直滚动
    if(scrollDirection == CycleDirectionPortait && totalPage>1) {
        // 往下翻一张
          [scrollView setContentOffset:CGPointMake(0, scrollFrame.size.height*2) animated:YES];
    }
    
}

-(int) indexPath:(NSIndexPath *)indexPath subPage:(int)page{
    int index = [indexPath indexAtPosition:0];
    if (index > page) {
        return MIN(index - page,page+totalPage-index);
    }else{
        return MIN(page - index,index+totalPage-page);
    }
}

-(UIView *)getViewAtPage:(int)page{
    UIView *view = nil;
    if (_cacheSize>0) {
        view = [_cacheViewsDict objectForKey:[NSIndexPath indexPathWithIndex:page]];
        if (view) {
            return view;
        }
    }
    if (_cacheSize>0 && _cacheViewsDict.count >= _cacheSize) {
        NSArray *array = _cacheViewsDict.allKeys;
        NSIndexPath *tempPath = [array objectAtIndex:0];
        for (NSIndexPath *path in array) {
            if ([self indexPath:tempPath subPage:page] < [self indexPath:path subPage:page]) {
                tempPath = path;
            }
        }
        [_cacheViewsDict removeObjectForKey:tempPath];
    }
    
    if ([_dataSource respondsToSelector:@selector(cycleScrollView:viewAtPage:)]) {
        view = [_dataSource cycleScrollView:self viewAtPage:page];
        if (_cacheSize>0) {
            [_cacheViewsDict setValue:view forKey:[NSIndexPath indexPathWithIndex:page]];
        }
        return view;
    }
    return [[[UIView alloc]init]autorelease];
}

- (NSArray *)getDisplayViewsWithCurpage:(int)page {
    
    int pre = [self validPageValue:curPage-1];
    int last = [self validPageValue:curPage+1];
    
    if([curViews count] != 0) [curViews removeAllObjects];
    
    [curViews addObject:[self getViewAtPage:pre-1]];
    [curViews addObject:[self getViewAtPage:curPage-1]];
    [curViews addObject:[self getViewAtPage:last-1]];
    
    return curViews;
}

-(void)setPageIndex:(NSInteger)pageIndex{
    if (curPage != pageIndex+1) {
        curPage = pageIndex + 1;
        [self refreshScrollView];
    }
}

-(NSInteger)pageIndex{
    return curPage - 1;
}

- (int)defaultValidPageValue:(NSInteger)value {
    
    if(value < 0) value = totalPage-1;                   // value＝1为第一张，value = 0为前面一张
    if(value >= totalPage) value = 0;
    
    return value;
}

- (int)validPageValue:(NSInteger)value {
    if (_autoScrolling) {
        if ([_dataSource respondsToSelector:@selector(cycleScrollView:validPageValueAutoScrolling:)]) {
            return [_dataSource cycleScrollView:self validPageValueAutoScrolling:value-1]+1;
        }
    }
    return ([self defaultValidPageValue:value-1]+1);
}


- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if (totalPage <= 1) {
        return;
    }
     
    int x = aScrollView.contentOffset.x;
    int y = aScrollView.contentOffset.y;
    
    // 水平滚动
    if(scrollDirection == CycleDirectionLandscape) {
        // 往下翻一张
        if(x >= (2*scrollFrame.size.width)) {
            curPage = [self validPageValue:curPage+1];
            [self refreshScrollView];
        }
        if(x <= 0) {
            curPage = [self validPageValue:curPage-1];
            [self refreshScrollView];
        }
    }
    
    // 垂直滚动
    if(scrollDirection == CycleDirectionPortait) {
        // 往下翻一张
        if(y >= 2 * (scrollFrame.size.height)) { 
            curPage = [self validPageValue:curPage+1];
            [self refreshScrollView];
        }
        if(y <= 0) {
            curPage = [self validPageValue:curPage-1];
            [self refreshScrollView];
        }
    }
    
    if ([delegate respondsToSelector:@selector(cycleScrollView:didScrollView:)]) {
        [delegate cycleScrollView:self didScrollView:curPage-1];
    } 
    
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)ascrollView;{
    if (_autoScrollAble) {
        [self removeScrollTimer];
    }
}

-(void)setScrollTimer{
    if (_autoScrollAble) {
        if (!_timer) {
            _timer = [[NSTimer scheduledTimerWithTimeInterval:_scrollDuration target:self selector:@selector(autoScrollNextPage) userInfo:nil repeats:YES]retain];
            _autoScrolling = YES;
        }
    }
}

-(void) removeScrollTimer{
    _autoScrolling = NO;
    if (_timer) {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    
    if (scrollDirection == CycleDirectionLandscape) {
            [scrollView setContentOffset:CGPointMake(scrollFrame.size.width, 0) animated:YES];
    }
    if (scrollDirection == CycleDirectionPortait) {
        [scrollView setContentOffset:CGPointMake(0, scrollFrame.size.height) animated:YES];
    }
    
    [self setScrollTimer];
}

-(void)removeFromSuperview{
    delegate = nil;
    _dataSource = nil;
    scrollView.delegate = nil;
    if (_timer) {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
    }
    [super removeFromSuperview];
}

- (void)dealloc
{
    scrollView.delegate = nil;
    if (_timer) {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
    }
    delegate = nil;
    _dataSource = nil;
    [curViews release];
    [_cacheViewsDict release];
    [super dealloc];
}

@end
