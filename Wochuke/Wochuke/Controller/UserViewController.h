//
//  UserViewController.h
//  Wochuke
//
//  Created by he songhang on 13-6-27.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopViewController.h"
#import <Guide.h>

@interface UserViewController : UIViewController

@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;

@property (retain, nonatomic) IBOutlet UILabel *lb_username;

@property (retain, nonatomic) IBOutlet UIButton *btn_follow;


@property (retain, nonatomic) IBOutlet UIImageView *iv_face;

@property (retain, nonatomic) IBOutlet UIView *bottomBackView;

@property (retain, nonatomic) IBOutlet UIImageView *iv_bottomBackView;

@property (retain, nonatomic) IBOutlet UIImageView *iv_topBackView;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) IBOutlet UILabel *lb_uploadCount;

@property (retain, nonatomic) IBOutlet UILabel *lb_favCount;

@property (retain, nonatomic) IBOutlet UILabel *lb_followCount;

@property (retain, nonatomic) IBOutlet UILabel *lb_fanceCount;

- (IBAction)uploadListAction:(id)sender;

- (IBAction)favListAction:(id)sender;

- (IBAction)followListAction:(id)sender;

- (IBAction)fanceListAction:(id)sender;

- (IBAction)backAction:(id)sender;

- (IBAction)followAction:(id)sender;

@property(nonatomic,retain) JCUser *user;


@end
