//
//  GuideViewController.h
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagedFlowView.h"
#import "GuideInfoView.h"
#import <Guide.h>

@interface GuideViewController : UIViewController<PagedFlowViewDataSource,PagedFlowViewDelegate,GuideInfoViewDelegate>

@property (retain, nonatomic) IBOutlet PagedFlowView *pagedFlowView;

@property(nonatomic,retain) JCGuide *guide;


- (IBAction)popAction:(id)sender;

- (IBAction)showPreviewAction:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *btn_comment;

@property (retain, nonatomic) IBOutlet UIButton *btn_share;

@property (retain, nonatomic) IBOutlet UIButton *btn_like;

@property (retain, nonatomic) IBOutlet UIButton *btn_driver;

- (IBAction)commentAction:(id)sender;

- (IBAction)shareAction:(id)sender;

- (IBAction)likeAction:(id)sender;

- (IBAction)driverAction:(id)sender;


@end

