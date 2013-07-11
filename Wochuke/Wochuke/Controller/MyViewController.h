//
//  MyViewController.h
//  Wochuke
//
//  Created by he songhang on 13-6-27.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopViewController.h"

@interface MyViewController : TopViewController

@property (retain, nonatomic) IBOutlet UIButton *nickNameBtn;

@property (retain, nonatomic) IBOutlet UIImageView *iv_face;

@property (retain, nonatomic) IBOutlet UIView *bottomBackView;

@property (retain, nonatomic) IBOutlet UIImageView *iv_bottomBackView;

@property (retain, nonatomic) IBOutlet UIImageView *iv_topBackView;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *loginButton;

@property (retain, nonatomic) IBOutlet UILabel *lb_uploadCount;

@property (retain, nonatomic) IBOutlet UILabel *lb_favCount;

@property (retain, nonatomic) IBOutlet UILabel *lb_followCount;

@property (retain, nonatomic) IBOutlet UILabel *lb_fanceCount;

- (IBAction)settingClick:(id)sender;

- (IBAction)loginAction:(id)sender;

- (IBAction)uploadListAction:(id)sender;

- (IBAction)favListAction:(id)sender;

- (IBAction)followListAction:(id)sender;

- (IBAction)fanceListAction:(id)sender;

@property(nonatomic,retain) JCUser *user;


@end
