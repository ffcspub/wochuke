//
//  FollowUserListViewController.h
//  Wochuke
//
//  Created by he songhang on 13-7-7.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Guide.h>

@interface GuideUserListViewController : BaseViewController

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic,retain) JCGuide *guide;

@property(nonatomic,assign) int actCode;

@property (retain, nonatomic) IBOutlet UILabel *lb_empty;

@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;

- (IBAction)backAction:(id)sender;


@end
