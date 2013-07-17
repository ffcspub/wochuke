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

@interface CreateStepViewController : BaseViewController<PagedFlowViewDataSource,PagedFlowViewDelegate>

@property (retain, nonatomic) IBOutlet PagedFlowView *pagedFlowView;

- (IBAction)popAction:(id)sender;

- (IBAction)saveAction:(id)sender;


@end

