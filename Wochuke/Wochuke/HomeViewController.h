//
//  HomeViewController.h
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopViewController.h"
#import "PagedFlowView.h"

@interface HomeViewController : TopViewController<PagedFlowViewDelegate,PagedFlowViewDataSource>

@property (retain, nonatomic) IBOutlet PagedFlowView *pageFlowView;

@property (retain, nonatomic) IBOutlet UILabel *lb_sLogon;

@end
