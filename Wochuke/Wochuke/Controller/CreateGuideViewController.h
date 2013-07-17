//
//  CreateGuideViewController.h
//  Wochuke
//
//  Created by he songhang on 13-7-8.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PagedFlowView.h"
#import <Guide.h>

@interface CreateGuideViewController : BaseViewController<PagedFlowViewDataSource,PagedFlowViewDelegate>

@property (retain, nonatomic) IBOutlet PagedFlowView *pagedFlowView;

- (IBAction)popAction:(id)sender;

- (IBAction)nextAction:(id)sender;


@end
