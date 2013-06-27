//
//  UIButton+ImageCache.m
//  SmartCity
//
//  Created by yuxin on 11-10-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIButton+ImageCache.h"
#import "SDWebImageManager.h"
static int flag = 0;

@implementation UIButton (ImageCache)


- (void)setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    flag = 1;
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    [self setBackgroundImage:placeholder forState:UIControlStateNormal];
    
    if (url)
    {
        [manager downloadWithURL:url delegate:self];
    }
}

- (void)setImageWithURLSize:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    flag = 2;
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    [self setImage:placeholder forState:UIControlStateNormal];
    
    if (url)
    {
        [manager downloadWithURL:url delegate:self];
    }

}
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    flag = 2;
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    [self setImage:placeholder forState:UIControlStateNormal];
    
    if (url)
    {
        [manager downloadWithURL:url delegate:self];
    }
}
- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

-(UIImage*)scaleToSize:(CGSize)size image:(UIImage*)image
{  
    // 创建一个bitmap的context  
    // 并把它设置成为当前正在使用的context  
    UIGraphicsBeginImageContext(size);  
    
    // 绘制改变大小的图片  
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];  
    
    // 从当前context中创建一个改变大小后的图片  
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();  
    
    // 使当前的context出堆栈  
    UIGraphicsEndImageContext();  
    
    // 返回新的改变大小后的图片  
    return scaledImage;  
}  

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    if(flag==2)
    {
        UIImage* img = self.imageView.image;
        if(img != nil)
        {
            //NSLog(@"w:%f,h:%f.", img.size.width, img.size.height);
            UIImage *image_Fin= [self scaleToSize:CGSizeMake(img.size.width, img.size.height) image:image];
            [self setImage:image_Fin forState:UIControlStateNormal];
        }
        else
        {
            [self setImage:image forState:UIControlStateNormal];
        }
        
    }
    else{
        [self setBackgroundImage:image forState:UIControlStateNormal];
    }
    
    
}

@end
