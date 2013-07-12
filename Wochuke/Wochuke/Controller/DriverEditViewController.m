//
//  DriverEditViewController.m
//  Wochuke
//
//  Created by hesh on 13-7-12.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "DriverEditViewController.h"

@interface DriverEditViewController ()

@end

@implementation DriverEditViewController

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField;{
    [textField resignFirstResponder];
    return YES;
}

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
    if (_name) {
        _navBar.title = @"编辑厨具";
        _tf_name.text = _name;
        _tf_devid.text = [ShareVaule devIdByName:_name];
    }else{
        _navBar.title = @"添加厨具";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_navBar release];
    [_tf_name release];
    [_tf_devid release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setNavBar:nil];
    [self setTf_name:nil];
    [self setTf_devid:nil];
    [super viewDidUnload];
}

- (IBAction)saveAction:(id)sender {
    if (_tf_name.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请输入自定义名称" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    if (_tf_devid.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请输入厨具设备号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    if (!_name) {
        if ([ShareVaule devNameExits:_tf_name.text]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"该自定义名称已存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [alert release];
            return;
        }
    }
    [ShareVaule addDriverByName:_tf_name.text devId:_tf_devid.text];
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
