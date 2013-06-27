//
//  UIImagePreView.h
//  Wochuke
//
//  Created by he songhang on 13-6-26.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImagePreView : UIView<UIScrollViewDelegate>

@property(nonatomic,retain) UIImage *image;



+(void)showInView:(UIView *)view image:(UIImage *)image;

@end
