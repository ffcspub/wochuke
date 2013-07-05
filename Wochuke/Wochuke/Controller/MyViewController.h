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

- (IBAction)settingClick:(id)sender;
- (IBAction)loginAction:(id)sender;
@end
