//
//  DriverManagerViewController.h
//  Wochuke
//
//  Created by hesh on 13-7-12.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+BeeUIGirdCell.h"

@interface DriverManagerViewController : UIViewController

@property (retain, nonatomic) IBOutlet UILabel *lb_empty;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)addDriverAction:(id)sender;

- (IBAction)backAction:(id)sender;

@end

