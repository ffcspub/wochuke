//
//  MyViewController.m
//  Wochuke
//
//  Created by he songhang on 13-6-27.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "MyViewController.h"
#import "LoginViewController.h"
#import "SetingViewController.h"
#import <Guide.h>

@interface MyViewController ()

@end

@implementation MyViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    JCUser *userInfo = [ShareVaule shareInstance].user;
    if (userInfo) {
        
        _nickNameBtn.titleLabel.text = userInfo.name;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)settingClick:(id)sender {
    SetingViewController *vlc = [[[SetingViewController alloc] initWithNibName:@"SetingViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:vlc animated:YES];
}

- (IBAction)loginAction:(id)sender {
    LoginViewController *lvc = [[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
    UINavigationController *navController = [[[UINavigationController alloc]initWithRootViewController:lvc]autorelease];
    navController.navigationBarHidden = YES;
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}
- (void)dealloc {
    [_nickNameBtn release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setNickNameBtn:nil];
    [super viewDidUnload];
}
@end
