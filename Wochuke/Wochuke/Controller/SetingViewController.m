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


@interface SetingViewController ()<UIAlertViewDelegate,SinaWeiboDelegate,SinaWeiboRequestDelegate>{
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }@catch (ICEException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:@"服务访问异常"];
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self upShareUI];
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
            });
        }
        
    });
    
}

- (void)switchChanged: (UISwitch *)senderSwitch
{
    if ([senderSwitch isEqual:self.sinaSwitch]) {
        if (self.sinaSwitch.on) {//点击后变为ON时
            [ShareVaule shareInstance].sinaweibo.delegate = self;
            [[ShareVaule shareInstance].sinaweibo logIn];
        } else {//点击后变为OFF时
            [[ShareVaule shareInstance].sinaweibo logOut];
            [ShareVaule shareInstance].sinaweiboName = nil;
            [_sinaName release];
            _sinaName = nil;
            [self bindSnsByKeyId:@"sinaId" valueId:@""];
        }
    }else if ([senderSwitch isEqual:self.qqSwitch]){
        if (self.qqSwitch.on) {
            [ShareVaule shareInstance].tencentOAuth.sessionDelegate = self;
            NSArray *authorize  = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, kOPEN_PERMISSION_ADD_ONE_BLOG, nil];
            [[ShareVaule shareInstance].tencentOAuth authorize:authorize inSafari:NO];
        } else {
            [[ShareVaule shareInstance].tencentOAuth logout:nil];
            [ShareVaule shareInstance].qqName = nil;
            [_qqName release];
            _qqName = nil;
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

-(void)upShareUI{
    if ([ShareVaule shareInstance].qqName) {
        [self.qqSwitch setOn:YES];
        if (_qqName) {
            [_qqName release];
            _qqName = nil;
        }
        _qqName = [[ShareVaule shareInstance].qqName retain];
        [self.qqSwitch setOn:YES];
    }else{
        [self.qqSwitch setOn:NO];
    }
    if ([ShareVaule shareInstance].sinaweiboName) {
        if (_sinaName) {
            [_sinaName release];
            _sinaName = nil;
        }
        _sinaName = [[ShareVaule shareInstance].sinaweiboName retain];
        [self.sinaSwitch setOn:YES];
    }else{
        [self.sinaSwitch setOn:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self upShareUI];
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
    [self upShareUI];
    //    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    //    [self removeAuthData];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo;{
    [self upShareUI];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
    [self upShareUI];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"证书过期!");
}

#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error;{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:@"绑定失败"];
        [self upShareUI];
    });
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"users/show.json"]) {
        [ShareVaule shareInstance].sinaweiboName = [result objectForKey:@"name"];
        _sinaName = [[ShareVaule shareInstance].sinaweiboName retain];
        
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
    [[ShareVaule shareInstance].tencentOAuth getUserInfo];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    [self upShareUI];
}

- (void)tencentDidNotNetWork
{
    [self upShareUI];
}

- (void)tencentDidLogout
{
    [self upShareUI];
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
        [ShareVaule shareInstance].qqName = _qqName;
        if (updateModel) {
            if ([ShareVaule shareInstance].user.id_.length
                >0) {
                [self bindSnsByKeyId:@"qqId" valueId:[ShareVaule shareInstance].tencentOAuth.openId];
            }
            updateModel = NO;
        }
        [_tableView reloadData];
    } else {
        
    }
}

- (void)dealloc {
    [ShareVaule shareInstance].sinaweibo.delegate = nil;
    [ShareVaule shareInstance].tencentOAuth.sessionDelegate = nil;
    [_sinaName release];
    [_qqName release];
    [_tableView release];
    [super dealloc];
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
