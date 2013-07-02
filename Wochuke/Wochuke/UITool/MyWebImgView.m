//
//  MyWebImg.m
//  AiBeiBao
//
//  Created by he songhang on 12-10-11.
//  Copyright (c) 2012年 ffcs. All rights reserved.
//

#import "MyWebImgView.h"
#import "DDProgressView.h"

@implementation UIImage (private)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    float verticalRadio = targetSize.height*1.0/height;
    float horizontalRadio = targetSize.width*1.0/width;
    
    float max = verticalRadio>horizontalRadio?verticalRadio:horizontalRadio;
    UIImage* temp1 = [self scaleToSize:CGSizeMake(width*max, height*max)];
    CGRect rect;
    if (verticalRadio<horizontalRadio) {
        rect= CGRectMake(0, (max*height-targetSize.height)/2, targetSize.width, targetSize.height);
    }else{
        rect= CGRectMake((max*width-targetSize.width)/2,0, targetSize.width, targetSize.height);
    }
    return [temp1 getSubImage:rect];
}

//截取部分图像
-(UIImage*)getSubImage:(CGRect)rect
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    return smallImage;
}

//等比例缩放
-(UIImage*)scaleToSize:(CGSize)size
{
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    
    float radio = 1;
    if(verticalRadio>1 && horizontalRadio>1)
    {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }
    else
    {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width = width*radio;
    height = height*radio;
    
    int xPos = (size.width - width)/2;
    int yPos = (size.height-height)/2;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(xPos, yPos, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

@end


@implementation MyWebImgView

@synthesize showProgress;
@synthesize noAutoResizeImage;

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    DDProgressView * progressView = (DDProgressView * )[self viewWithTag:209872];
    if (progressView) {
        progressView.center = self.center;
    }
}

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self cancelCurrentImageLoad];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    self.image = placeholder;
    
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
//    if (!noAutoResizeImage) {
//        if (self.frame.size.height != 0 && self.frame.size.width != 0) {
//            image = [image imageByScalingAndCroppingForSize:CGSizeMake(self.frame.size.width *2, self.frame.size.height *2)];
//        }
//    }
    self.image = image;
    self.alpha = 0.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.alpha = 1.0;
    }];
}

@end
