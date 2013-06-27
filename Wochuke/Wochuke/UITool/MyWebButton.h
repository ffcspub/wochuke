//
//  MyWebButton.h
//  AiBeiBao
//
//  Created by he songhang on 12-10-13.
//  Copyright (c) 2012年 ffcs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManagerDelegate.h"
#import "SDWebImageManager.h"

@interface MyWebButton : UIButton<SDWebImageManagerDelegate>

- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)cancelCurrentImageLoad;

@property(nonatomic,assign) BOOL showProgress;
@property(nonatomic,assign) BOOL noAutoResizeImage;

@end
