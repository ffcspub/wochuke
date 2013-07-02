//
//  StepView.h
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Guide.h>
#import "MyWebImgView.h"
#import "NSObject+Notification.h"
#import "HPGrowingTextView.h"

@interface StepView : UIView{
    UIImageView *backImageView;
    UIImageView *tagImageView;
    UILabel *lb_step;
    MyWebImgView *imageView;
    UILabel *lb_text;
    UIButton *btn_comment;
    UILabel *lb_comment;
}

@property(nonatomic,retain) JCStep *step;
@property(nonatomic,assign) int stepCount;

@end

@protocol StepEditViewDelegate;

@interface StepEditView : UIView<HPGrowingTextViewDelegate>{
    UIImageView *backImageView;
    UIImageView *tagImageView;
    UILabel *lb_step;
    MyWebImgView *imageView;
    HPGrowingTextView *tv_text;
    CGPoint oldCenter;
    UIPanGestureRecognizer *panGestureRecognizer;
}

@property(nonatomic,assign) id<StepEditViewDelegate> delegate;
@property(nonatomic,retain) JCStep *step;

-(void)upImage;

@end

@protocol StepEditViewDelegate <NSObject>

@optional
-(void)imageTapFromStepEditView:(StepEditView *)editView;
@end

@interface StepMinView : StepView

@end