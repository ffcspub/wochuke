//
//  MyWebButton.m
//  AiBeiBao
//
//  Created by he songhang on 12-10-13.
//  Copyright (c) 2012年 ffcs. All rights reserved.
//

#import "MyWebButton.h"
#import "SDWebImageManager.h"
#import "DDProgressView.h"


@implementation MyWebButton

@synthesize showProgress;
@synthesize noAutoResizeImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    
    [self setImage:nil forState:UIControlStateNormal];
    [self setImage:nil forState:UIControlStateHighlighted];
    [self setBackgroundImage:placeholder forState:UIControlStateNormal];
    [self setBackgroundImage:placeholder forState:UIControlStateHighlighted];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    if (url)
    {
        if (self.showProgress) {
            DDProgressView * progressView = (DDProgressView *)[self viewWithTag:209872];
            if (!progressView) {
                progressView = [[DDProgressView alloc] initWithFrame: CGRectZero] ;
                [progressView setOuterColor: [UIColor colorWithRed:44.0/255 green:168.0/255 blue:253.0/255 alpha:0.5]] ;
                [progressView setInnerColor: [UIColor colorWithRed:44.0/255 green:168.0/255 blue:253.0/255 alpha:1.0]] ;
                progressView.tag = 209872;
                [self addSubview:progressView];
                [progressView setCenter:self.center];
                [progressView release];
            }
        }else{
            [self hideAndRemove];
        }
        [manager downloadWithURL:url delegate:self];
    }else{
        [self hideAndRemove];
    }
}

-(void) hideAndRemove{
    DDProgressView * progressView = (DDProgressView * )[self viewWithTag:209872];
    if (progressView) {
        [progressView removeFromSuperview];
        progressView = nil;
    }
}

- (void)cancelCurrentImageLoad
{
    [self hideAndRemove];
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didReceiveData:(SDWebImageDownloader *)downloader{
     DDProgressView * progressView = (DDProgressView * )[self viewWithTag:209872];
    if (progressView) {
        [progressView setProgress: (float)downloader.receiveDataLength/(float)downloader.totalDateLength] ;
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error{
    [self hideAndRemove];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    [self hideAndRemove];
    if (!noAutoResizeImage) {
        if (self.frame.size.height != 0 && self.frame.size.width != 0) {
//            image = [image imageByScalingAndCroppingForSize:CGSizeMake(self.frame.size.width *2, self.frame.size.height *2)];
        }
    }
    
    [self setImage:image forState:UIControlStateNormal];
    self.alpha = 0.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.alpha = 1.0;
    }];
    
}



@end
