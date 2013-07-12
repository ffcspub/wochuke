//
//  GuideListViewController.h
//  Wochuke
//
//  Created by he songhang on 13-7-3.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Guide.h>

@interface GuideListViewController : UIViewController

@property (retain, nonatomic) IBOutlet UILabel *lb_empty;

@property(nonatomic,strong) JCType *type;

@property(nonatomic,strong) JCTopic *topic;

@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)backAction:(id)sender;

@end
