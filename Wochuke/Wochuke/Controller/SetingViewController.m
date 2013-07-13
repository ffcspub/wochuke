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
#import "ICETool.h"
#import "LoginViewController.h"

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

-(void)saveUser:(JCUser *)user idKey:(NSString *)idKey bind:(BOOL)bind
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCUser *userInfo = [proxy saveUser:user];
                if (userInfo.id_) {
                    NSLog(@"saveUser:idKey:bind: userInfo存在 userInfo.snsIds == %@",userInfo.snsIds);
                    [ShareVaule shareInstance].userId = userInfo.id_;
                    [ShareVaule shareInstance].user = userInfo;
                    if ([idKey isEqualToString:@"qqId"]) {
                        if (bind) {
                            [ShareVaule shareInstance].bindForQQ = YES;
                        } else {
                            [ShareVaule shareInstance].bindForQQ = NO;
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"nameForBindQQ"];
                        }
                    }else if ([idKey isEqualToString:@"sinaId"]){
                        if (bind) {
                            [ShareVaule shareInstance].bindForSina = YES;
                        } else {
                            [ShareVaule shareInstance].bindForSina = NO;
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"nameForBindSina"];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                } else {
                    if ([idKey isEqualToString:@"qqId"]) {
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"nameForBindQQ"];
                    }else if ([idKey isEqualToString:@"sinaId"]){
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"nameForBindSina"];
                    }
                    [SVProgressHUD showErrorWithStatus:@"该用户不存在"];
                }
            }
            @catch (NSException *exception) {
                if ([exception isKindOfClass:[JCGuideException class]]) {
                    JCGuideException *_exception = (JCGuideException *)exception;
                    if (_exception.reason_) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:_exception.reason_];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                        });
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                    });
                }
            }
            @finally {
                
            }
        }@catch (ICEException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"服务访问异常"];
            });
        }
        
    });
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
                                               JCUser *user = [ShareVaule shareInstance].user;
                                               NSMutableDictionary *snsId = user.snsIds;
                                               [snsId setObject:userInfo.uid forKey:@"sinaId"];
                                               user.snsIds = snsId;
                                               [ShareVaule shareInstance].nameForBindSina = userInfo.nickname;
                                               [self saveUser:user idKey:@"sinaId" bind:YES];
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
            [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
            if ([ShareVaule shareInstance].user) {
                JCUser *user = [ShareVaule shareInstance].user;
                NSMutableDictionary *snsId = user.snsIds;
                [snsId setObject:@"" forKey:@"sinaId"];
                user.snsIds = snsId;
                [ShareVaule shareInstance].bindForSina = NO;
                [self.tableView reloadData];
                [self saveUser:user idKey:@"sinaId" bind:NO];
            } else {
                [ShareVaule shareInstance].bindForSina = NO;
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"nameForBindSina"];
                [self.tableView reloadData];
            }
            
        }
    }else if ([senderSwitch isEqual:self.qqSwitch]){
        if (self.qqSwitch.on) {
            [ShareVaule shareInstance].tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAPPID andDelegate:self];
            [ShareVaule shareInstance].permissions = [[NSArray arrayWithObjects:kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, kOPEN_PERMISSION_ADD_ONE_BLOG, nil] retain];
            [[ShareVaule shareInstance].tencentOAuth authorize:[ShareVaule shareInstance].permissions inSafari:NO];
        } else {
            [[ShareVaule shareInstance].tencentOAuth logout:self];
            if ([ShareVaule shareInstance].user) {
                JCUser *user = [ShareVaule shareInstance].user;
                NSMutableDictionary *snsId = user.snsIds;
                [snsId setObject:@"" forKey:@"qqId"];
                user.snsIds = snsId;
                [ShareVaule shareInstance].bindForQQ = NO;
                [self.tableView reloadData];
                [self saveUser:user idKey:@"qqId" bind:NO];
            } else {
                [ShareVaule shareInstance].bindForQQ = NO;
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"nameForBindQQ"];
                [self.tableView reloadData];
            }
            
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
            [ShareVaule shareInstance].bindForSina = YES;
        }else{
            [self.sinaSwitch setOn:NO];
            [ShareVaule shareInstance].bindForSina = NO;
        }
        if (![qqId isEqualToString:@""]) {
            [self.qqSwitch setOn:YES];
            [ShareVaule shareInstance].bindForQQ = YES;
        }else{
            [self.qqSwitch setOn:NO];
            [ShareVaule shareInstance].bindForQQ = NO;
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
            LoginViewController *lvc = [[[LoginViewController alloc] init] autorelease];
            [[ShareVaule shareInstance].tencentOAuth logout:lvc];
            [[ShareVaule shareInstance].tencentOAuth logout:self];
            [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
            [ShareVaule shareInstance].user = nil;
            [ShareVaule shareInstance].bindForQQ = NO;
            [ShareVaule shareInstance].bindForSina = NO;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userId"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"nameForBindSina"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"nameForBindQQ"];
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

#pragma mark - TencentSession Delegate

- (void)tencentDidLogin
{
    [[ShareVaule shareInstance].tencentOAuth getUserInfo];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    
}

- (void)tencentDidNotNetWork
{
    
}

- (void)tencentDidLogout
{
    [ShareVaule shareInstance].nameForBindQQ = nil;
    [ShareVaule shareInstance].bindForQQ = NO;
    
}

//获取用户个人信息回调
- (void)getUserInfoResponse:(APIResponse *)response
{
    if (response.retCode == URLREQUEST_SUCCEED) {
        if ([ShareVaule shareInstance].user) {
            JCUser *user = [ShareVaule shareInstance].user;
            NSMutableDictionary *snsId = user.snsIds;
            [snsId setObject:[[ShareVaule shareInstance].tencentOAuth openId] forKey:@"qqId"];
            user.snsIds = snsId;
            [ShareVaule shareInstance].nameForBindQQ = [response.jsonResponse objectForKey:@"nickname"];
            [self saveUser:user idKey:@"qqId" bind:YES];
        } else {
            [ShareVaule shareInstance].bindForQQ = YES;
            [ShareVaule shareInstance].nameForBindQQ = [response.jsonResponse objectForKey:@"nickname"];
            [self.tableView reloadData];
        }
        
    } else {
        
    }
}

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
