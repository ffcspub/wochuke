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
#import "DriverManagerViewController.h"
#import "AboutViewController.h"
#import "FeedbackViewController.h"


@interface SetingViewController ()<UIAlertViewDelegate>{
    NSString *_qqName;
    NSString *_sinaName;
    BOOL updateModel;
}

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
                    [ShareVaule shareInstance].user.snsIds = userInfo.snsIds;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                } else {
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
                                               NSMutableDictionary *snsId = [NSMutableDictionary dictionaryWithDictionary:[ShareVaule shareInstance].user.snsIds];
                                               [snsId setObject:userInfo.uid forKey:@"sinaId"];
                                               JCUser *user = [JCUser user:[ShareVaule shareInstance].user.id_ name:[ShareVaule shareInstance].user.name email:[ShareVaule shareInstance].user.email password:[ShareVaule shareInstance].user.password  avatar:[ShareVaule shareInstance].user.avatar mobile:[ShareVaule shareInstance].user.mobile realname:[ShareVaule shareInstance].user.realname intro:[ShareVaule shareInstance].user.intro roleCode:[ShareVaule shareInstance].user.roleCode followerCount:[ShareVaule shareInstance].user.followerCount followingCount:[ShareVaule shareInstance].user.followingCount followState:[ShareVaule shareInstance].user.followState guideCount:[ShareVaule shareInstance].user.guideCount favoriteCount:[ShareVaule shareInstance].user.favoriteCount snsIds:snsId];
                                               [self saveUser:user idKey:@"sinaId" bind:YES];
                                           }else{
                                               [self.tableView reloadData];
                                           }
                                       }else{
                                           [SVProgressHUD showErrorWithStatus:@"新浪微博登录失败"];
                                       }
                                   }];
        } else {//点击后变为OFF时
            [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
            [_sinaName release];
            _sinaName = nil;
            if ([ShareVaule shareInstance].user) {
                NSMutableDictionary *snsId = [NSMutableDictionary dictionaryWithDictionary:[ShareVaule shareInstance].user.snsIds];
                [snsId setObject:@"" forKey:@"sinaId"];
                 JCUser *user = [JCUser user:[ShareVaule shareInstance].user.id_ name:[ShareVaule shareInstance].user.name email:[ShareVaule shareInstance].user.email password:[ShareVaule shareInstance].user.password  avatar:[ShareVaule shareInstance].user.avatar mobile:[ShareVaule shareInstance].user.mobile realname:[ShareVaule shareInstance].user.realname intro:[ShareVaule shareInstance].user.intro roleCode:[ShareVaule shareInstance].user.roleCode followerCount:[ShareVaule shareInstance].user.followerCount followingCount:[ShareVaule shareInstance].user.followingCount followState:[ShareVaule shareInstance].user.followState guideCount:[ShareVaule shareInstance].user.guideCount favoriteCount:[ShareVaule shareInstance].user.favoriteCount snsIds:snsId];
                [self.tableView reloadData];
                [self saveUser:user idKey:@"sinaId" bind:NO];
            } else {
                [self.tableView reloadData];
            }
            
        }
    }else if ([senderSwitch isEqual:self.qqSwitch]){
        if (self.qqSwitch.on) {
            [ShareVaule shareInstance].tencentOAuth.sessionDelegate = self;
            NSArray *authorize  = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, kOPEN_PERMISSION_ADD_ONE_BLOG, nil];
            [[ShareVaule shareInstance].tencentOAuth authorize:authorize inSafari:NO];
        } else {
            [[ShareVaule shareInstance].tencentOAuth logout:nil];
            [_qqName release];
            _qqName = nil;
            if ([ShareVaule shareInstance].user) {
                NSMutableDictionary *snsId = [NSMutableDictionary dictionaryWithDictionary:[ShareVaule shareInstance].user.snsIds];
                [snsId setObject:@"" forKey:@"qqId"];
                JCUser *user = [JCUser user:[ShareVaule shareInstance].user.id_ name:[ShareVaule shareInstance].user.name email:[ShareVaule shareInstance].user.email password:[ShareVaule shareInstance].user.password  avatar:[ShareVaule shareInstance].user.avatar mobile:[ShareVaule shareInstance].user.mobile realname:[ShareVaule shareInstance].user.realname intro:[ShareVaule shareInstance].user.intro roleCode:[ShareVaule shareInstance].user.roleCode followerCount:[ShareVaule shareInstance].user.followerCount followingCount:[ShareVaule shareInstance].user.followingCount followState:[ShareVaule shareInstance].user.followState guideCount:[ShareVaule shareInstance].user.guideCount favoriteCount:[ShareVaule shareInstance].user.favoriteCount snsIds:snsId];
                [self.tableView reloadData];
                [self saveUser:user idKey:@"qqId" bind:NO];
            } else {
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
    [ShareVaule shareInstance].tencentOAuth.sessionDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[ShareVaule shareInstance].tencentOAuth isSessionValid]) {
        [self.qqSwitch setOn:YES];
        [[ShareVaule shareInstance].tencentOAuth getUserInfo];
    }else{
        [self.qqSwitch setOn:NO];
    }
    if ([ShareSDK hasAuthorizedWithType:ShareTypeSinaWeibo]) {
        [self.sinaSwitch setOn:YES];
        [ShareSDK getUserInfoWithType:ShareTypeSinaWeibo authOptions:nil result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
            if (result) {
                _sinaName = [userInfo.nickname retain];
                [_tableView reloadData];
            }
        }];
    }else{
        [self.sinaSwitch setOn:NO];
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
            [ShareVaule shareInstance].tencentOAuth.sessionDelegate = nil;
            [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
            [ShareVaule shareInstance].user = nil;
            [ShareVaule shareInstance].userId = nil;
            [[ShareVaule shareInstance].tencentOAuth logout:nil];
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
            cell.detailTextLabel.text = _sinaName;
        }else if (indexPath.row ==1){
            cell.textLabel.text = @"绑定腾讯QQ";
            cell.detailTextLabel.text = _qqName;
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        DriverManagerViewController *vlc = [[DriverManagerViewController alloc]initWithNibName:@"DriverManagerViewController" bundle:nil];
        [self.navigationController pushViewController:vlc animated:YES];
        [vlc release];
    }else if(indexPath.section == 2){
        if (indexPath.row == 0) {
            //意见反馈
            FeedbackViewController *vlc = [[[FeedbackViewController alloc]initWithNibName:@"FeedbackViewController" bundle:nil]autorelease];
            [self.navigationController pushViewController:vlc animated:YES];
        }else if(indexPath.row == 1){
            //关于
            AboutViewController *vlc = [[[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil]autorelease];
            [self.navigationController pushViewController:vlc animated:YES];
        }
    }
}

#pragma mark - TencentSession Delegate

- (void)tencentDidLogin
{
    updateModel = YES;
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
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}



//获取用户个人信息回调
- (void)getUserInfoResponse:(APIResponse *)response
{
    if (response.retCode == URLREQUEST_SUCCEED) {
        if (_qqName) {
            [_qqName release];
            _qqName = nil;
        }
        _qqName = [[response.jsonResponse objectForKey:@"nickname"]retain];
        if (updateModel) {
            if ([ShareVaule shareInstance].user) {
                NSMutableDictionary *snsId = [NSMutableDictionary dictionaryWithDictionary:[ShareVaule shareInstance].user.snsIds];
                [snsId setObject:[[ShareVaule shareInstance].tencentOAuth openId] forKey:@"qqId"];
                JCUser *user = [JCUser user:[ShareVaule shareInstance].user.id_ name:[ShareVaule shareInstance].user.name email:[ShareVaule shareInstance].user.email password:[ShareVaule shareInstance].user.password  avatar:[ShareVaule shareInstance].user.avatar mobile:[ShareVaule shareInstance].user.mobile realname:[ShareVaule shareInstance].user.realname intro:[ShareVaule shareInstance].user.intro roleCode:[ShareVaule shareInstance].user.roleCode followerCount:[ShareVaule shareInstance].user.followerCount followingCount:[ShareVaule shareInstance].user.followingCount followState:[ShareVaule shareInstance].user.followState guideCount:[ShareVaule shareInstance].user.guideCount favoriteCount:[ShareVaule shareInstance].user.favoriteCount snsIds:snsId];
                [self saveUser:user idKey:@"qqId" bind:YES];
            }
            updateModel = NO;
        }
        [_tableView reloadData];
    } else {
        
    }
}

- (void)dealloc {
    [_sinaName release];
    [_qqName release];
    [_tableView release];
    [super dealloc];
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
