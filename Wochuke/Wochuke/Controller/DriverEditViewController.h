//
//  DriverEditViewController.h
//  Wochuke
//
//  Created by hesh on 13-7-12.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DriverEditViewController : UIViewController

@property (retain, nonatomic) IBOutlet UINavigationItem *navBar;

@property(nonatomic,retain) NSString *name;

@property (retain, nonatomic) IBOutlet UITextField *tf_name;

@property (retain, nonatomic) IBOutlet UITextField *tf_devid;

- (IBAction)saveAction:(id)sender;

@end
