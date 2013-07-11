//
//  PersonalSettingsViewController.m
//  Wochuke
//
//  Created by Geory on 13-7-7.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "PersonalSettingsViewController.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTf_nickname:nil];
    [self setTf_email:nil];
    [self setTf_password:nil];
    [self setTf_confirm:nil];
    [super viewDidUnload];
}
@end
