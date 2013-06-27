//
//  MyWebImg.h
//  AiBeiBao
//
//  Created by he songhang on 12-10-11.
//  Copyright (c) 2012年 ffcs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDWebImageManagerDelegate.h"
#import "SDWebImageManager.h"
#import <QuartzCore/QuartzCore.h>

@interface MyWebImgView : UIImageView <SDWebImageManagerDelegate>

- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;
- (void)cancelCurrentImageLoad;

@property(nonatomic,assign) BOOL showProgress;
@property(nonatomic,assign) BOOL noAutoResizeImage;

@end


@interface UIImage (private)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end
