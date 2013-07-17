//
//  PersonalSettingsViewController.h
//  Wochuke
//
//  Created by Geory on 13-7-7.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalSettingsViewController : BaseViewController<UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UITextField *tf_nickname;

@property (retain, nonatomic) IBOutlet UITextField *tf_email;

@property (retain, nonatomic) IBOutlet UITextField *tf_password;

@property (retain, nonatomic) IBOutlet UITextField *tf_confirm;

@property (retain, nonatomic) IBOutlet UIImageView *iv_back;

@property (retain, nonatomic) IBOutlet UIImageView *iv_face;

- (IBAction)backAction:(id)sender;

- (IBAction)faceAction:(id)sender;

- (IBAction)saveAction:(id)sender;

@end
