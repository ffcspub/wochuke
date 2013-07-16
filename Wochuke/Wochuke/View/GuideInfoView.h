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

@protocol GuideInfoViewDelegate;

//简介页面
@interface GuideInfoView : UIView<HPGrowingTextViewDelegate>{
    UIImageView *backImageView;
    UIImageView *backTopImageView;
    UIImageView *tagImageView;
    UILabel *lb_tag;
    UITextView *tv_title;
    UIView *iv_photoback;
    MyWebImgView *iv_photo;
    UILabel *lb_publisher;
    UIButton *btn_viewCount;
    UIButton *btn_favoriteCount;
    UIButton *btn_commentCount;
    UIImageView *iv_contentBackView;
    UITextView *tv_content;
    
}

@property(nonatomic,assign) id<GuideInfoViewDelegate> delegate;
@property(nonatomic,retain) JCGuide *guide;

@end

@protocol GuideInfoViewDelegate <NSObject>

-(void)guideInfoViewViewcount:(GuideInfoView *)infoView;
-(void)guideInfoViewFavorite:(GuideInfoView *)infoView;
-(void)guideInfoViewComment:(GuideInfoView *)infoView;
-(void)guideInfoViewUserShow:(GuideInfoView *)infoView;
@end

@interface GuideEditView : UIView<HPGrowingTextViewDelegate,UIKeyboardViewControllerDelegate>{
    UIImageView *backImageView;
    UIImageView *backTopImageView;
    HPGrowingTextView *tv_title;
    UIView *iv_photoback;
    MyWebImgView *iv_photo;
    UILabel *lb_publisher;
    UIImageView *iv_contentBackView;
    HPGrowingTextView *tv_content;
    UILabel *lb_empty;
    UIKeyboardViewController *keyBoardController;
    UIPanGestureRecognizer *panGestureRecognizer;
    CGPoint oldCenter;
}

-(void)beginEdit;

@end

@interface GuideInfoMinView : GuideInfoView

@end


@interface GuideInfoCell : BeeUIGridCell{
    UILabel *lb_title;
    UIImageView *backImageView;
    MyWebImgView *iv_photo;
    UILabel *lb_publisher;
    UIImageView *gradImageView;
    UIButton *btn_viewCount;
    UIButton *btn_favoriteCount;
    UIButton *btn_commentCount;
    UIView *line;
}

@end

@interface GuideInfoMinCell : GuideInfoCell

@end


@protocol GuideInfoEditCellDelegate;

@interface GuideInfoEditCell : GuideInfoMinCell{
    UIButton *btn_edit;
}

@property(nonatomic,assign) id<GuideInfoEditCellDelegate> delegate;

@end

@protocol GuideInfoEditCellDelegate<NSObject>

@optional

-(void) guideInfoEditCellEdit:(GuideInfoEditCell *) cell;

@end
