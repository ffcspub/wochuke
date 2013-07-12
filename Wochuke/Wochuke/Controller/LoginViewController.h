//
//  LoginViewController.h
//  Wochuke
//
//  Created by he songhang on 13-6-27.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface LoginViewController : UIViewController<TencentSessionDelegate,UITextFieldDelegate>{
    TencentOAuth *_tencentOAuth;
    NSMutableArray *_permissions;
}

@property (retain, nonatomic) IBOutlet UIImageView *iv_back;

@property (retain, nonatomic) IBOutlet UITextField *tf_name;
@property (retain, nonatomic) IBOutlet UITextField *tf_password;
- (IBAction)backAction:(id)sender;
- (IBAction)regiterAction:(id)sender;
- (IBAction)qqLoginAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)sinaLoginAction:(id)sender;
@end
