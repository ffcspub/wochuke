//
//  CatoryViewController.h
//  Wochuke
//
//  Created by he songhang on 13-6-26.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopViewController.h"

@interface CatoryViewController : TopViewController

@property (retain, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)catoryChangAction:(id)sender;


@end
