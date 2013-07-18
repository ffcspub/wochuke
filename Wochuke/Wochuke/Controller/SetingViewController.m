//
//  SetingViewController.m
//  Wochuke
//
//  Created by Geory on 13-6-28.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "SetingViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "SVProgressHUD.h"
#import <Guide.h>
#import "ICETool.h"
#import "LoginViewController.h"
#import "DriverManagerViewController.h"
#import "AboutViewController.h"
#import "FeedbackViewController.h"
#import "SDImageCache.h"


@interface SetingViewController ()<UIAlertViewDelegate,SinaWeiboDelegate,SinaWeiboRequestDelegate>{
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

- (void)switchChanged: (UISwitch *)senderSwitch
{
    if ([senderSwitch isEqual:self.sinaSwitch]) {
        if ([ShareVaule shareInstance].sinaweiboName.length == 0) {//点击后变为ON时
            [ShareVaule shareInstance].sinaweibo.delegate = self;
            [[ShareVaule shareInstance].sinaweibo logIn];
        } else {//点击后变为OFF时
            [[ShareVaule shareInstance].sinaweibo logOut];
            [ShareVaule shareInstance].sinaweiboName = nil;
            [self bindSnsByKeyId:@"sinaId" valueId:@""];
        }
    }else if ([senderSwitch isEqual:self.qqSwitch]){
        if ([ShareVaule shareInstance].qqName.length == 0) {
            [ShareVaule shareInstance].tencentOAuth.sessionDelegate = self;
            NSArray *authorize  = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, kOPEN_PERMISSION_ADD_ONE_BLOG, nil];
            [[ShareVaule shareInstance].tencentOAuth authorize:authorize inSafari:NO];
        } else {
            [[ShareVaule shareInstance].tencentOAuth logout:nil];
            [ShareVaule shareInstance].qqName = nil;
            [self bindSnsByKeyId:@"qqId" valueId:@""];
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
    [_tableView reloadData];
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
            [ShareVaule shareInstance].user = nil;
            [ShareVaule shareInstance].userId = nil;
            [[ShareVaule shareInstance].tencentOAuth logout:nil];
            [ShareVaule shareInstance].qqName = nil;
            [ShareVaule shareInstance].sinaweiboName = nil;
            [[ShareVaule shareInstance].sinaweibo logOut];
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
        return 3;
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
            cell.detailTextLabel.text = [ShareVaule shareInstance].sinaweiboName;
        }else if (indexPath.row ==1){
            cell.textLabel.text = @"绑定腾讯QQ";
            cell.detailTextLabel.text = [ShareVaule shareInstance].qqName;
        }
    }else if (indexPath.section == 1){
        cell.textLabel.text = @"厨具管理";
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"意见反馈";
        }else if (indexPath.row ==1){
            cell.textLabel.text = @"清除缓存";
        }else if (indexPath.row ==2){
            cell.textLabel.text = @"关于";
        }
    }
    
    if (indexPath.section ==0) {
        if (indexPath.row == 0) {
            cell.accessoryView = self.sinaSwitch;
            if ([ShareVaule shareInstance].sinaweiboName) {
                [self.sinaSwitch setOn:YES];
            }else{
                [self.sinaSwitch setOn:NO];
            }
        }else if (indexPath.row == 1){
            cell.accessoryView = self.qqSwitch;
            if ([ShareVaule shareInstance].qqName) {
                [self.qqSwitch setOn:YES];
            }else{
                [self.qqSwitch setOn:NO];
            }
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
            [[SDImageCache sharedImageCache]cleanDisk];
            [SVProgressHUD showSuccessWithStatus:@"缓存已清除"];
        }else if(indexPath.row == 2){
            //关于
            AboutViewController *vlc = [[[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil]autorelease];
            [self.navigationController pushViewController:vlc animated:YES];
        }
    }
}

#pragma mark - SinaWeiboDelegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"走 sinaweiboDidLogIn ");
    //    [self storeAuthData];
    //    [self performSelectorOnMainThread:@selector(logout) withObject:nil waitUntilDone:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [sinaweibo requestWithURL:@"friendships/create.json"
                           params:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"沃厨客",@"screen_name",nil]
                       httpMethod:@"POST"
                         delegate:self];
    });
    
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"走 sinaweiboDidLogOut ");
//    [_tableView reloadData];
    //    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    //    [self removeAuthData];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo;{
    [_tableView reloadData];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
    [_tableView reloadData];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"证书过期!");
}

#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error;{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:@"绑定失败"];
        [_tableView reloadData];
    });
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"users/show.json"]) {
        [ShareVaule shareInstance].sinaweiboName = [result objectForKey:@"name"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.sinaSwitch setOn:YES];
            [_tableView reloadData];
            if ([ShareVaule shareInstance].user.id_.length
                >0) {
                [self bindSnsByKeyId:@"sinaId" valueId:[ShareVaule shareInstance].sinaweibo.userID];
            }
        });
        
    }else if([request.url hasSuffix:@"friendships/create.json"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ShareVaule shareInstance].sinaweibo requestWithURL:@"users/show.json"
                                                          params:[NSMutableDictionary dictionaryWithObject:[ShareVaule shareInstance].sinaweibo.userID forKey:@"uid"]
                                                      httpMethod:@"GET"
                                                        delegate:self];
        });
    }
}

#pragma mark - TencentSession Delegate

- (void)tencentDidLogin
{
    updateModel = YES;
    [SVProgressHUD show];
    [[ShareVaule shareInstance].tencentOAuth getUserInfo];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    [_tableView reloadData];
    [SVProgressHUD dismiss];
}

- (void)tencentDidNotNetWork
{
    [_tableView reloadData];
    [SVProgressHUD showErrorWithStatus:@"网络无法连接"];
}

- (void)tencentDidLogout
{
//    [_tableView reloadData];
    //    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}



//获取用户个人信息回调
- (void)getUserInfoResponse:(APIResponse *)response
{
    if (response.retCode == URLREQUEST_SUCCEED) {
        NSString *_qqName = [response.jsonResponse objectForKey:@"nickname"];
        [ShareVaule shareInstance].qqName = _qqName;
        if (updateModel) {
            if ([ShareVaule shareInstance].user.id_.length
                >0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self bindSnsByKeyId:@"qqId" valueId:[ShareVaule shareInstance].tencentOAuth.openId];
                });
            }
            updateModel = NO;
        }
    } else {
        [SVProgressHUD showErrorWithStatus:response.errorMsg];
    }
}

-(void)bindSnsByKeyId:(NSString *)keyId valueId:(NSString *)valueId{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableDictionary *snsId = [NSMutableDictionary dictionaryWithDictionary:[ShareVaule shareInstance].user.snsIds];
        if (![[snsId valueForKey:keyId] isEqual:valueId]) {
            [snsId setObject:valueId forKey:keyId];
            JCUser *_user = [JCUser user:[ShareVaule shareInstance].user.id_ name:[ShareVaule shareInstance].user.name email:[ShareVaule shareInstance].user.email password:[ShareVaule shareInstance].user.password  avatar:[ShareVaule shareInstance].user.avatar mobile:[ShareVaule shareInstance].user.mobile realname:[ShareVaule shareInstance].user.realname intro:[ShareVaule shareInstance].user.intro roleCode:[ShareVaule shareInstance].user.roleCode followerCount:[ShareVaule shareInstance].user.followerCount followingCount:[ShareVaule shareInstance].user.followingCount followState:[ShareVaule shareInstance].user.followState guideCount:[ShareVaule shareInstance].user.guideCount favoriteCount:[ShareVaule shareInstance].user.favoriteCount snsIds:snsId];
            @try {
                id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
                @try {
                    JCUser *user = [proxy saveUser:_user];
                    if (user) {
                        [[ShareVaule shareInstance].user.snsIds setValue:valueId forKey:keyId];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        [_tableView reloadData];
                    });
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
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [_tableView reloadData];
            });
        }
        
    });
    
}


- (void)dealloc {
    [ShareVaule shareInstance].sinaweibo.delegate = nil;
    [ShareVaule shareInstance].tencentOAuth.sessionDelegate = nil;
    [_tableView release];
    [super dealloc];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
