//
//  CatoryViewController.h
//  Wochuke
//
//  Created by he songhang on 13-6-26.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopViewController.h"
#import "CycleScrollView.h"

@interface CatoryViewController : TopViewController<UIActionSheetDelegate>

@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) IBOutlet CycleScrollView *imageScrollView;

@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;

@property (retain, nonatomic) IBOutlet UILabel *lb_topic;

@property (retain, nonatomic) IBOutlet UIView *topView;

- (IBAction)catoryChangAction:(id)sender;

- (IBAction)searchAction:(id)sender;


@end
