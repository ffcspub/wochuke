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
//#import <ShareSDK/ShareSDK.h>
#import "NSString+BeeExtension.h"
#import "SinaWeibo.h"

@interface LoginViewController ()<SinaWeiboDelegate,SinaWeiboRequestDelegate>{
    NSString *_faceUrl;
}


@end

@implementation LoginViewController{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //    if([ShareSDK hasAuthorizedWithType:ShareTypeSinaWeibo]){
    //        [ShareSDK getUserInfoWithType:ShareTypeSinaWeibo
    //                          authOptions:nil
    //                               result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error){
    //                                   if (result) {
    //                                       NSString *sinaId = userInfo.uid;
    //                                       _sinaId = [sinaId retain];
    //                                   }
    //                               }];
    //    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    UIImage *backImage = [[UIImage imageNamed:@"bg_register&login_card"]resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [_iv_back setImage:backImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginWithName:(NSString *)account andPassword:(NSString *)password
{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCUser *user = [proxy login:account password:[[password MD5]uppercaseString]];
                if (user.id_.length>0) {
                    NSMutableDictionary *snsId = [NSMutableDictionary dictionaryWithDictionary:user.snsIds];
                    NSString *qqId = [snsId objectForKey:@"qqId"];
                    if (qqId.length == 0) {
                        [ShareVaule shareInstance].qqName = nil;
                    }else if ([[ShareVaule shareInstance].tencentOAuth isSessionValid]) {
                        if (![qqId isEqual:[[ShareVaule shareInstance].tencentOAuth openId]]) {
                            [ShareVaule shareInstance].qqName = @" ";
                        }
                    }else{
                        [ShareVaule shareInstance].qqName = @" ";
                    }
                    NSString *sinaId = [snsId objectForKey:@"sinaId"];
                    if (sinaId.length == 0) {
                        [ShareVaule shareInstance].sinaweiboName = nil;
                    }else if ([[ShareVaule shareInstance].sinaweibo isAuthValid]) {
                        if (![sinaId isEqual:[[ShareVaule shareInstance].sinaweibo userID]]) {
                            [ShareVaule shareInstance].sinaweiboName = @" ";
                        }
                    }else{
                        [ShareVaule shareInstance].sinaweiboName = @" ";
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        [ShareVaule shareInstance].userId = user.id_;
                        [ShareVaule shareInstance].user = user;
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    });
                    
                }
            }
            @catch (NSException *exception) {
                [SVProgressHUD dismiss];
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
    [SVProgressHUD show];
    if ([idKey isEqualToString:@"qqId"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ShareVaule shareInstance].tencentOAuth getUserInfo];
        });
    }else{
        SinaWeibo *sinaweibo = [ShareVaule shareInstance].sinaweibo;
        dispatch_async(dispatch_get_main_queue(), ^{
            [sinaweibo requestWithURL:@"users/show.json"
                               params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                           httpMethod:@"GET"
                             delegate:self];
        });
    }
}

- (void)regiterByThirdUserInfo:(JCUser *)user idKey:(NSString *)idKey idValue:(NSString *)idValue
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCUser *userInfo = [proxy getUserBySns:idKey idValue:idValue];
                if (userInfo.id_.length == 0) {
                   userInfo = [proxy saveUser:user];
                    if (_faceUrl) {
                        NSString *fileId = userInfo.avatar.id_;
                        NSData *_blobImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:_faceUrl]];
                        int length = _blobImage.length;
                        int count =  ceil((float)length / FILEBLOCKLENGTH);
                        int loc = 0;
                        for (int i= 0; i<count; i++) {
                            NSData *data = [_blobImage subdataWithRange:NSMakeRange(loc, MIN(FILEBLOCKLENGTH,_blobImage.length - loc))];
                            JCFileBlock *fileBlock = [JCFileBlock fileBlock:fileId blockIdx:i blockSize:data.length isLastBlock:i==count-1 data:data];
                            [proxy saveFileBlock:fileBlock];
                            loc += FILEBLOCKLENGTH;
                        }
                    }
                    
                }
                if (userInfo.id_) {
                    NSMutableDictionary *snsId = [NSMutableDictionary dictionaryWithDictionary:userInfo.snsIds];
                    NSString *qqId = [snsId objectForKey:@"qqId"];
                    if (qqId.length == 0) {
                        [ShareVaule shareInstance].qqName = nil;
                    }else if ([[ShareVaule shareInstance].tencentOAuth isSessionValid]) {
                        if (![qqId isEqual:[[ShareVaule shareInstance].tencentOAuth openId]]) {
                            [ShareVaule shareInstance].qqName = @" ";
                        }
                    }else{
                        [ShareVaule shareInstance].qqName = @" ";
                    }
                    NSString *sinaId = [snsId objectForKey:@"sinaId"];
                    if (sinaId.length == 0) {
                        [ShareVaule shareInstance].sinaweiboName = nil;
                    }else if ([[ShareVaule shareInstance].sinaweibo isAuthValid]) {
                        if (![sinaId isEqual:[[ShareVaule shareInstance].sinaweibo userID]]) {
                            [ShareVaule shareInstance].sinaweiboName = @" ";
                        }
                    }else{
                        [ShareVaule shareInstance].sinaweiboName = @" ";
                    }
                    NSLog(@"regiterByThirdUserInfo userInfo存在 userInfo.id_ == %@",userInfo.id_);
                    [ShareVaule shareInstance].userId = userInfo.id_;
                    [ShareVaule shareInstance].user = userInfo;
                    NSLog(@"regiterByThirdUserInfo userInfo.id_ == %@",userInfo.id_);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
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
        }@catch (ICEException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"服务访问异常"];
            });
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
    [SVProgressHUD show];
    [ShareVaule shareInstance].tencentOAuth.sessionDelegate = self;
    NSArray *array = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, kOPEN_PERMISSION_ADD_ONE_BLOG, nil];
    BOOL flag = [[ShareVaule shareInstance].tencentOAuth authorize:array inSafari:NO];
    if (!flag) {
        [SVProgressHUD showErrorWithStatus:@"无法打开QQ客户端"];
    }
}

- (IBAction)loginAction:(id)sender {
    [self login];
}


- (IBAction)sinaLoginAction:(id)sender {
    [SVProgressHUD show];
    SinaWeibo *sinaweibo = [ShareVaule shareInstance].sinaweibo;
    sinaweibo.delegate = self;
    [sinaweibo logIn];
    //    [ShareSDK getUserInfoWithType:ShareTypeSinaWeibo
    //                      authOptions:nil
    //                           result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error){
    //                               if (result) {
    //                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    //                                       @try {
    //                                           id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
    //                                           @try {
    //                                               JCUser *user = [proxy getUserBySns:@"sinaId" idValue:userInfo.uid];
    //                                               if ([user.id_ isEqualToString:@""]) {
    //                                                   JCUser *jcUserInfo = [[JCUser alloc] init];
    //                                                   jcUserInfo.name = userInfo.nickname;
    //                                                   jcUserInfo.avatar.url = userInfo.icon;
    //                                                   NSDictionary *snsIds = [NSDictionary dictionaryWithObjectsAndKeys:userInfo.uid, @"sinaId", nil];
    //                                                   jcUserInfo.snsIds = snsIds;
    //                                                   NSLog(@"sinaLoginAction user不存在 userInfo.uid == %@",userInfo.uid);
    //                                                   NSLog(@"sinaLoginAction user不存在 user.snsIds == %@",user.snsIds);
    //                                                   [self regiterByThirdUserInfo:jcUserInfo idKey:@"sinaId"];
    //                                               }else{
    //                                                   NSLog(@"sinaLoginAction user存在 user.snsIds == %@",user.snsIds);
    //                                                   [ShareVaule shareInstance].userId = user.id_;
    //                                                   [ShareVaule shareInstance].user = user;
    //                                                   dispatch_async(dispatch_get_main_queue(), ^{
    //                                                       [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    //                                                   });
    //                                               }
    //                                           }
    //                                           @catch (NSException *exception) {
    //                                               if ([exception isKindOfClass:[JCGuideException class]]) {
    //                                                   JCGuideException *_exception = (JCGuideException *)exception;
    //                                                   if (_exception.reason_) {
    //                                                       dispatch_async(dispatch_get_main_queue(), ^{
    //                                                           [SVProgressHUD showErrorWithStatus:_exception.reason_];
    //                                                       });
    //                                                   }else{
    //                                                       dispatch_async(dispatch_get_main_queue(), ^{
    //                                                           [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
    //                                                       });
    //                                                   }
    //                                               }else{
    //                                                   dispatch_async(dispatch_get_main_queue(), ^{
    //                                                       [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
    //                                                   });
    //                                               }
    //                                           }
    //                                           @finally {
    //
    //                                           }
    //                                       }@catch (ICEException *exception) {
    //                                           dispatch_async(dispatch_get_main_queue(), ^{
    //                                               [SVProgressHUD showErrorWithStatus:@"服务访问异常"];
    //                                           });
    //                                       }
    //                                   });
    //                               }else{
    //                                   [SVProgressHUD showErrorWithStatus:@"新浪微博登录失败"];
    //                               }
    //                           }];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, -170, self.view.frame.size.width, self.view.frame.size.height);
    }];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _tf_name) {
        [_tf_password becomeFirstResponder];
    }else if (textField == _tf_password){
        [_tf_password resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }];
        if (_tf_password.text.length>0) {
            [self login];
        }
    }
    return YES;
}

-(void)logout{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SinaWeiboDelegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"走 sinaweiboDidLogIn ");
    //    [self storeAuthData];
    //    [self performSelectorOnMainThread:@selector(logout) withObject:nil waitUntilDone:NO];
    [sinaweibo requestWithURL:@"friendships/create.json"
                       params:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"沃厨客",@"screen_name",nil]
                   httpMethod:@"POST"
                     delegate:self];
    
    
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"走 sinaweiboDidLogOut ");
    //    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    //    [self removeAuthData];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
    [SVProgressHUD showErrorWithStatus:error.description];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"证书过期!");
}

#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"users/show.json"]) {
        SinaWeibo *sinaweibo = [ShareVaule shareInstance].sinaweibo;
        JCUser *user = [[JCUser alloc] init];
        NSLog(@"result == %@",result);
        NSString *profile_image_url = [result objectForKey:@"profile_image_url"];
        if (profile_image_url) {
            if (_faceUrl) {
                [_faceUrl release];
                _faceUrl = nil;
            }
            _faceUrl = [profile_image_url retain];
        }
        NSLog(@"sinaweibo.userID == %@",sinaweibo.userID);
        user.name = [result objectForKey:@"name"];
        user.avatar.url = [result objectForKey:@"profile_image_url"];
        NSDictionary *snsIds = [NSDictionary dictionaryWithObjectsAndKeys:sinaweibo.userID, @"sinaId", nil];
        user.snsIds = snsIds;
        [ShareVaule shareInstance].sinaweiboName = [result objectForKey:@"name"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self regiterByThirdUserInfo:user idKey:@"sinaId" idValue:sinaweibo.userID];
        });
        
    }else if([request.url hasSuffix:@"friendships/create.json"]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getUserByKey:@"sinaId" idValue:[ShareVaule shareInstance].sinaweibo.userID];
        });
        
    }
}

#pragma mark - TencentSessionDelegate

- (void)tencentDidLogin
{
    dispatch_async(dispatch_get_main_queue(), ^{
         [self getUserByKey:@"qqId" idValue:[[ShareVaule shareInstance].tencentOAuth openId]];
    });
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    [SVProgressHUD dismiss];
//    [SVProgressHUD showErrorWithStatus:@"未登录QQ"];
}

- (void)tencentDidNotNetWork
{
    [SVProgressHUD showErrorWithStatus:@"网络无法连接"];
}

//获取用户个人信息回调
- (void)getUserInfoResponse:(APIResponse *)response
{
    if (response.retCode == URLREQUEST_SUCCEED) {
        JCUser *user = [[JCUser alloc] init];
        user.name = [response.jsonResponse objectForKey:@"nickname"];
        NSString *profile_image_url = [response.jsonResponse objectForKey:@"figureurl_qq_2"];
        if (profile_image_url) {
            if (_faceUrl) {
                [_faceUrl release];
                _faceUrl = nil;
            }
            _faceUrl = [profile_image_url retain];
        }
        [ShareVaule shareInstance].qqName = [response.jsonResponse objectForKey:@"nickname"];
        user.avatar.url = [response.jsonResponse objectForKey:@"figureurl"];
        NSDictionary *snsIds = [NSDictionary dictionaryWithObjectsAndKeys:[[ShareVaule shareInstance].tencentOAuth openId], @"qqId", nil];
        user.snsIds = snsIds;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self regiterByThirdUserInfo:user idKey:@"qqId" idValue:[ShareVaule shareInstance].tencentOAuth.openId];
        });
    } else {
        [SVProgressHUD showErrorWithStatus:response.errorMsg];
    }
}


- (void)dealloc {
    [_faceUrl release];
    [ShareVaule shareInstance].sinaweibo.delegate = nil;
    [ShareVaule shareInstance].tencentOAuth.sessionDelegate = nil;
    [_tf_name release];
    [_tf_password release];
    [_iv_back release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTf_name:nil];
    [self setTf_password:nil];
    [self setIv_back:nil];
    [super viewDidUnload];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [UIView animateWithDuration:0.3 animations:^{
        [_tf_password resignFirstResponder];
        [_tf_name resignFirstResponder];
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}
@end
