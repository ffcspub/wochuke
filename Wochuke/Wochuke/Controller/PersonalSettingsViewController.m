//
//  PersonalSettingsViewController.m
//  Wochuke
//
//  Created by Geory on 13-7-7.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "PersonalSettingsViewController.h"
#import "UIImageView+WebCache.h"
#import <Guide.h>

@interface PersonalSettingsViewController ()

@end

@implementation PersonalSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImage *backImage = [[UIImage imageNamed:@"bg_register&login_card"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [_iv_back setImage:backImage];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_user) {
        self.user = [ShareVaule shareInstance].user;
    }
    
    if (_user.id_) {
        [_iv_face setImageWithURL:[NSURL URLWithString:_user.avatar.url] placeholderImage:[UIImage imageNamed:@"ic_user_top"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)faceAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _tf_nickname) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -10, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }else if (textField == _tf_email){
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -126, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }else if (textField == _tf_password){
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -142, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }else if (textField == _tf_confirm){
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -158, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _tf_confirm) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc {
    [_tf_nickname release];
    [_tf_email release];
    [_tf_password release];
    [_tf_confirm release];
    [_iv_back release];
    [_iv_face release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTf_nickname:nil];
    [self setTf_email:nil];
    [self setTf_password:nil];
    [self setTf_confirm:nil];
    [self setIv_back:nil];
    [self setIv_face:nil];
    [super viewDidUnload];
}
@end
