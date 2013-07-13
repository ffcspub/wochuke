//
//  SetingViewController.m
//  Wochuke
//
//  Created by Geory on 13-6-28.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "SetingViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "SVProgressHUD.h"
#import <Guide.h>

@interface SetingViewController ()<UIAlertViewDelegate>

@property (nonatomic, retain) UISwitch *sinaSwitch;

@property (nonatomic, retain) UISwitch *qqSwitch;

@property (nonatomic, retain) UIButton *cancelBtn;

@end

@implementation SetingViewController

@synthesize sinaSwitch = _sinaSwitch;
@synthesize qqSwitch = _qqSwitch;
@synthesize cancelBtn = _cancelBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)switchChanged: (UISwitch *)senderSwitch
{
    if ([senderSwitch isEqual:self.sinaSwitch]) {
        if (self.sinaSwitch.on) {//点击后变为ON时
            [ShareSDK getUserInfoWithType:ShareTypeSinaWeibo
                              authOptions:nil
                                   result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error){
                                       if (result) {
                                           if ([ShareVaule shareInstance].user) {
                                               
                                           }else{
                                               [ShareVaule shareInstance].bindForSina = YES;
                                               [ShareVaule shareInstance].nameForBindSina = userInfo.nickname;
                                               [self.tableView reloadData];
                                           }
                                       }else{
                                           [SVProgressHUD showErrorWithStatus:@"新浪微博登录失败"];
                                       }
                                   }];
        } else {//点击后变为OFF时
            
        }
    }else if ([senderSwitch isEqual:self.qqSwitch]){
        if (self.qqSwitch.on) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"QQ"
                                                         message:@"腾讯QQ登陆"
                                                        delegate:nil
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:nil];
            [av show];
        } else {
            
        }
    }
}

- (void)showSureAlert
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"是否退出登录？"
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:@"确定"
                                       otherButtonTitles:@"取消", nil];
    av.tag = 10000;
    [av show];
    [av release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sinaSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero]autorelease];
    [self.sinaSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.qqSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero]autorelease];
    [self.qqSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    if ([ShareVaule shareInstance].user) {
        UIView *view = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)]autorelease];
        _cancelBtn = [[[UIButton alloc] initWithFrame:CGRectMake(10, 5, 300, 43)]autorelease];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"btn_setting_quit.png"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(logoutClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:_cancelBtn];
        self.tableView.tableFooterView = view;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    JCUser *_user = [ShareVaule shareInstance].user;
    
    if (_user.id_) {
        NSString *sinaId = [_user.snsIds objectForKey:@"sinaId"];
        NSString *qqId = [_user.snsIds objectForKey:@"qqId"];
        if (![sinaId isEqualToString:@""]) {
            [self.sinaSwitch setOn:YES];
        }else{
            [self.sinaSwitch setOn:NO];
        }
        if (![qqId isEqualToString:@""]) {
            [self.qqSwitch setOn:YES];
        }else{
            [self.qqSwitch setOn:NO];
        }
    }else{
        if ([ShareVaule shareInstance].bindForSina) {
            [self.sinaSwitch setOn:YES];
        }else{
            [self.sinaSwitch setOn:NO];
        }
        if ([ShareVaule shareInstance].bindForQQ) {
            [self.qqSwitch setOn:YES];
        }
    }
}

- (void)logoutClick:(id)sender
{
    [self showSureAlert];
}

- (void)viewDidUnload
{
    self.sinaSwitch = nil;
    self.qqSwitch = nil;
    self.cancelBtn = nil;
    
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10000) {
        if (buttonIndex == 0) {
            [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
            [ShareVaule shareInstance].user = nil;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userId"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }else if (section == 1){
        return 1;
    }else if (section == 2){
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"绑定新浪微博";
            if ([ShareVaule shareInstance].bindForSina) {
                cell.detailTextLabel.text = [ShareVaule shareInstance].nameForBindSina;
            }
        }else if (indexPath.row ==1){
            cell.textLabel.text = @"绑定腾讯QQ";
            if ([ShareVaule shareInstance].bindForQQ) {
                cell.detailTextLabel.text = [ShareVaule shareInstance].nameForBindQQ;
            }
        }
    }else if (indexPath.section == 1){
        cell.textLabel.text = @"厨具管理";
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"意见反馈";
        }else if (indexPath.row ==1){
            cell.textLabel.text = @"关于";
        }
    }
    
    if (indexPath.section ==0) {
        if (indexPath.row == 0) {
            cell.accessoryView = self.sinaSwitch;
        }else if (indexPath.row == 1){
            cell.accessoryView = self.qqSwitch;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    tableView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
