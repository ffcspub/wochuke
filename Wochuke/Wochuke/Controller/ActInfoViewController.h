//
//  ActInfoViewController.h
//  Wochuke
//
//  Created by he songhang on 13-7-3.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopViewController.h"

@interface ActInfoViewController : TopViewController

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) IBOutlet UILabel *lb_empty;

- (IBAction)typeChangeAction:(id)sender;

- (IBAction)ceateAction:(id)sender;
@end
