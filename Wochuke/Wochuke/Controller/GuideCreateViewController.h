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

@interface GuideCreateViewController : UIViewController<PagedFlowViewDataSource,PagedFlowViewDelegate>

@property (retain, nonatomic) IBOutlet PagedFlowView *pagedFlowView;

@property(nonatomic,retain) JCGuide *guide;

- (IBAction)popAction:(id)sender;

- (IBAction)showPreviewAction:(id)sender;

@end

