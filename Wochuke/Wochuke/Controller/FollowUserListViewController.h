//
//  FollowUserListViewController.h
//  Wochuke
//
//  Created by he songhang on 13-7-7.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Guide.h>

@interface FollowUserListViewController : BaseViewController

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic,retain) JCUser *user;

@property(nonatomic,assign) int filterCode;

@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;

@property (retain, nonatomic) IBOutlet UILabel *lb_empty;


- (IBAction)backAction:(id)sender;


@end
