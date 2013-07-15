//
//  UIImagePreView.m
//  Wochuke
//
//  Created by he songhang on 13-6-26.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "UIImagePreView.h"
#import <QuartzCore/QUartzCore.h>

@interface UIImagePreView (){
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    CGRect viewRect;
}
@end

@implementation UIImagePreView

-(void)showInVIew:(UIView *)view image:(UIImage *)image;{
    self.image = image;
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
    
    for (UIWindow *window in frontToBackWindows){
        if (window.windowLevel == UIWindowLevelNormal) {
//            viewRect = [view convertRect:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) toView:window];
            viewRect = CGRectMake(window.frame.size.width, window.frame.size.height, 0, 0);
            [window addSubview:self];
            break;
        }
    }
    self.layer.opacity = 0;
    self.frame = viewRect;
    [UIView animateWithDuration:0.5 animations:^{
        self.layer.opacity = 1;
        self.frame = self.superview.frame;
    } completion:^(BOOL finished) {
        self.backgroundColor = [UIColor darkTextColor];
    }];

}


-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _imageView.frame = _scrollView.frame;
    
    /*
     ** 设置UIScrollView的最大和最小放大级别（注意如果MinimumZoomScale == MaximumZoomScale，
     ** 那么UIScrllView就缩放不了了
     */
    [_imageView setImage:_image];
    [_scrollView setMinimumZoomScale:2];
    [_scrollView setMaximumZoomScale:5];
    // 设置UIScrollView初始化缩放级别
    [_scrollView setZoomScale:0];
}

// 让UIImageView在UIScrollView缩放后居中显示
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                            scrollView.contentSize.height * 0.5 + offsetY);
}

// 设置UIScrollView中要缩放的视图

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)closeTap{
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = viewRect;
    } completion:^(BOOL finished) {
        self.layer.opacity = 0;
        [self removeFromSuperview];
    }];
}

-(id)init{
    self = [super init];
    if (self) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];
        _imageView = [[UIImageView alloc]init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer* singleRecognizer;  
        singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTap)];
        singleRecognizer.numberOfTapsRequired = 1; // 单击  
        [_imageView addGestureRecognizer:singleRecognizer];
        [_scrollView addSubview:_imageView];
    }
    return self;
}

-(void)dealloc{
    [_scrollView release];
    [_imageView release];
    [super dealloc];
}

+(void)showInView:(UIView *)view image:(UIImage *)image;{
    UIImagePreView *preView = [[[UIImagePreView alloc]init]autorelease];
    [preView showInVIew:view image:image];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
