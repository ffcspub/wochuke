//
//  RegiterViewController.h
//  Wochuke
//
//  Created by he songhang on 13-6-27.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegiterViewController : BaseViewController<UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UITextField *tf_mail;
@property (retain, nonatomic) IBOutlet UITextField *tf_password;
@property (retain, nonatomic) IBOutlet UITextField *tf_confirm;
@property (retain, nonatomic) IBOutlet UITextField *tf_nickname;
@property (retain, nonatomic) IBOutlet UIImageView *iv_back;

- (IBAction)backAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)regiterAction:(id)sender;
@end
