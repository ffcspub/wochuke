//
//  GuideViewController.h
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagedFlowView.h"
#import <Guide.h>

@protocol GuideEditViewControllerDelegate;


@interface GuideEditViewController : BaseViewController<PagedFlowViewDataSource,PagedFlowViewDelegate>

@property (retain, nonatomic) IBOutlet PagedFlowView *pagedFlowView;
@property (nonatomic,assign) id<GuideEditViewControllerDelegate> controllerDelegate;

-(void)scrollToIndex:(int)index;

- (IBAction)pubishAction:(id)sender;

- (IBAction)popAction:(id)sender;

@end

@protocol GuideEditViewControllerDelegate <NSObject>

-(void) controllerWillHide;

@end

