//
//  UIButton+ImageCache.h
//  SmartCity
//
//  Created by yuxin on 11-10-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SDWebImageCompat.h"
#import "SDWebImageManagerDelegate.h"

@interface UIButton (ImageCache) <SDWebImageManagerDelegate>


- (void)setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

- (void)setImageWithURLSize:(NSURL *)url placeholderImage:(UIImage *)placeholder;

- (void)cancelCurrentImageLoad;

@end
