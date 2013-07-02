//
//  GuideInfoView.h
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Guide.h>
#import "MyWebImgView.h"
#import "Bee_UIGridCell.h"
#import "HPGrowingTextView.h"
#import "UIKeyboardViewController.h"

//简介页面
@interface GuideInfoView : UIView<HPGrowingTextViewDelegate>{
    UIImageView *backImageView;
    UIImageView *backTopImageView;
    HPGrowingTextView *tv_title;
    MyWebImgView *iv_photo;
    UILabel *lb_publisher;
    UIButton *btn_viewCount;
    UIButton *btn_favoriteCount;
    UIButton *btn_commentCount;
    HPGrowingTextView *tv_content;
}

@property(nonatomic,retain) JCGuide *guide;

@end

@interface GuideEditView : UIView<HPGrowingTextViewDelegate,UIKeyboardViewControllerDelegate>{
    UIImageView *backImageView;
    UIImageView *backTopImageView;
    HPGrowingTextView *tv_title;
    MyWebImgView *iv_photo;
    UILabel *lb_publisher;
    HPGrowingTextView *tv_content;
    UILabel *lb_empty;
    UIKeyboardViewController *keyBoardController;
    
    CGPoint oldCenter;
}

@end

@interface GuideInfoMinView : GuideInfoView

@end

@interface GuideInfoCell : BeeUIGridCell{
    UILabel *lb_title;
    UIImageView *backImageView;
    MyWebImgView *iv_photo;
    UILabel *lb_publisher;
    UIButton *btn_viewCount;
    UIButton *btn_favoriteCount;
    UIButton *btn_commentCount;
    UIView *line;
}

@end

@interface GuideInfoMinCell : GuideInfoCell

@end