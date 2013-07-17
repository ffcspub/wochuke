//
//  BaseViewController.m
//  Wochuke
//
//  Created by hesh on 13-7-16.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "BaseViewController.h"
#import "SVProgressHUD.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

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
	// Do any additional setup after loading the view.
}


-(void)viewWillDisappear:(BOOL)animated{
    if (![SVProgressHUD isVisibleByImage]) {
         [SVProgressHUD dismiss];
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
