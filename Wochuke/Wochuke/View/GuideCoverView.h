//
//  GuideCoverView.h
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Guide.h>

@class MyWebImgView;

//封面
@interface GuideCoverView : UIView{
    UIImageView *backImageView;
    UIImageView *tagImageView;
    MyWebImgView *imageView;
    UIImageView *_gradView;
    UILabel *lb_type;
    UILabel *lb_name;
    UILabel *lb_publisher;
}

@property(nonatomic,retain) JCGuide *guide;

-(void)upGuide:(JCGuide *)guide;

@end

