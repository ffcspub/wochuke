//
//  LoginViewController.m
//  Wochuke
//
//  Created by he songhang on 13-6-27.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "LoginViewController.h"
#import "RegiterViewController.h"
#import <Ice/Ice.h>
#import <Guide.h>
#import "ICETool.h"
#import "ShareVaule.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

#define QQAPPID @"100454485"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAPPID andDelegate:self];
    _permissions = [[NSArray arrayWithObjects:kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, kOPEN_PERMISSION_ADD_ONE_BLOG, nil] retain];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (SinaWeibo *)sinaweibo
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.sinaweibo;
}

- (void)removeAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

- (void)storeAuthData
{
    SinaWeibo *sinaweibo = [self sinaweibo];
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loginWithName:(NSString *)account andPassword:(NSString *)password
{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
        @try {
            JCUser *user = [proxy login:account password:password];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if (user.id_) {
                    [ShareVaule shareInstance].userId = user.id_;
                    [ShareVaule shareInstance].user = user;
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [SVProgressHUD showErrorWithStatus:@"该用户不存在"];
                }
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
    });
}

- (void)login
{
    if ([_tf_name.text length] == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"请输入邮箱或昵称"
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }
    if ([_tf_password.text length] == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"请输入密码"
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }
    [self loginWithName:_tf_name.text andPassword:_tf_password.text];
}

- (void)getUserByKey:(NSString *)idKey idValue:(NSString *)idValue
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
        @try {
            JCUser *user = [proxy getUserBySns:idKey idValue:idValue];
            if ([user.id_ isEqualToString:@""]) {
                NSLog(@"getUserByKey user不存在 user.id_ == %@",user.id_);
                if ([idKey isEqualToString:@"qqId"]) {
                    [_tencentOAuth getUserInfo];
                }else if ([idKey isEqualToString:@"sinaId"]){
                    NSLog(@"getUserByKey user不存在 走新浪微博");
                    SinaWeibo *sinaweibo = [self sinaweibo];
                    [sinaweibo requestWithURL:@"users/show.json"
                                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                                   httpMethod:@"GET"
                                     delegate:self];
                }
            }else{
                NSLog(@"getUserByKey user存在 user.id_ == %@",user.id_);
                NSLog(@"getUserByKey user存在 user.snsIds == %@",user.snsIds);
                [ShareVaule shareInstance].userId = user.id_;
                [ShareVaule shareInstance].user = user;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                });
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
    });
}

- (void)regiterByThirdUserInfo:(JCUser *)user
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
        @try {
            JCUser *userInfo = [proxy saveUser:user];
            if (userInfo.id_) {
                NSLog(@"regiterByThirdUserInfo userInfo存在 userInfo.id_ == %@",userInfo.id_);
                [ShareVaule shareInstance].userId = userInfo.id_;
                [ShareVaule shareInstance].user = userInfo;
                NSLog(@"regiterByThirdUserInfo userInfo.id_ == %@",userInfo.id_);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                });
            } else {
                NSLog(@"regiterByThirdUserInfo userInfo不存在 userInfo.id_ == %@",userInfo.id_);
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
        
    });
}

#pragma mark - IBAction

- (IBAction)backAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)regiterAction:(id)sender {
    RegiterViewController *rvc = [[[RegiterViewController alloc] initWithNibName:@"RegiterViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:rvc animated:YES];
}

- (IBAction)qqLoginAction:(id)sender {
    [_tencentOAuth authorize:_permissions inSafari:NO];
}

- (IBAction)loginAction:(id)sender {
    [self login];
}

- (IBAction)sinaLoginAction:(id)sender {
    SinaWeibo *sinaweibo = [self sinaweibo];
    [sinaweibo logIn];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, -150, self.view.frame.size.width, self.view.frame.size.height);
    }];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _tf_password) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _tf_name) {
        [_tf_password becomeFirstResponder];
    }else if (textField == _tf_password){
        [_tf_password resignFirstResponder];
        [self login];
    }
    return YES;
}

#pragma mark - TencentSession Delegate

- (void)tencentDidLogin
{
    [self getUserByKey:@"qqId" idValue:[_tencentOAuth openId]];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    
}

- (void)tencentDidNotNetWork
{
    
}

//获取用户个人信息回调
- (void)getUserInfoResponse:(APIResponse *)response
{
    if (response.retCode == URLREQUEST_SUCCEED) {
        JCUser *user = [[JCUser alloc] init];
        user.name = [response.jsonResponse objectForKey:@"nickname"];
        user.avatar.url = [response.jsonResponse objectForKey:@"figureurl"];
        NSDictionary *snsIds = [NSDictionary dictionaryWithObjectsAndKeys:[_tencentOAuth openId], @"qqId", nil];
        user.snsIds = snsIds;
        [self regiterByThirdUserInfo:user];
        
    } else {
        
    }
}

#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"走 sinaweiboDidLogIn ");
    [self storeAuthData];
    [self getUserByKey:@"sinaId" idValue:sinaweibo.userID];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"走 sinaweiboDidLogOut ");
    [self removeAuthData];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"证书过期!");
}

#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"users/show.json"]) {
        SinaWeibo *sinaweibo = [self sinaweibo];
        JCUser *user = [[JCUser alloc] init];
        NSLog(@"result == %@",result);
        NSLog(@"sinaweibo.userID == %@",sinaweibo.userID);
        user.name = [result objectForKey:@"name"];
        user.avatar.url = [result objectForKey:@"profile_image_url"];
        NSDictionary *snsIds = [NSDictionary dictionaryWithObjectsAndKeys:sinaweibo.userID, @"sinaId", nil];
        user.snsIds = snsIds;
        [self regiterByThirdUserInfo:user];
    }
}

- (void)dealloc {
    [_tf_name release];
    [_tf_password release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTf_name:nil];
    [self setTf_password:nil];
    [super viewDidUnload];
}
@end
