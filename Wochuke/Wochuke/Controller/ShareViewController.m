//
//  ShareViewController.m
//  Wochuke
//
//  Created by hesh on 13-7-15.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "ShareViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import <TencentOpenAPI/TencentOAuthObject.h>

@interface ShareViewController ()<HPGrowingTextViewDelegate,SinaWeiboRequestDelegate,TencentSessionDelegate>

@end

@implementation ShareViewController

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
    _tv_content.text = _titleText;
    _tv_content.textMaxLength = 200;
    _tv_content.delegate = self;
    
    _lb_count.layer.cornerRadius = 6;
    _lb_count.layer.masksToBounds = YES;
    _lb_count.text = [NSString stringWithFormat:@"%d",150 - _titleText.length];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareAction:(id)sender {
    if (_tv_content.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请输入内容 " delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else{
        if (_type == 0) {
            [[ShareVaule shareInstance].sinaweibo requestWithURL:@"statuses/update.json"
                                                          params:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                  _tv_content.text, @"status",
                                                                  @"0",@"visible", nil]
                                                      httpMethod:@"POST"
                                                        delegate:self];
        }else{
            [ShareVaule shareInstance].tencentOAuth.sessionDelegate =self;
            TCAddShareDic *params = [TCAddShareDic dictionary];
            params.paramTitle = _tv_content.text;
            params.paramComment = @"电厨具烹饪指南";
            params.paramSummary =  _content;
            params.paramUrl = @"http://wochuke.com";
            [[ShareVaule shareInstance].tencentOAuth addShareWithParams:params];
        }
    }
}

- (void)dealloc {
    [ShareVaule shareInstance].tencentOAuth.sessionDelegate = nil;
    [ShareVaule shareInstance].sinaweibo.delegate = nil;
    [_titleText release];
    [_content release];
    [_tv_content release];
    [_lb_count release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTv_content:nil];
    [self setLb_count:nil];
    [super viewDidUnload];
}

#pragma mark -HPGrowingTextViewDelegate
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    _lb_count.text = [NSString stringWithFormat:@"%d",150 - growingTextView.text.length];
}

#pragma mark - SinaWeiboRequestDelegate
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error;{
   if ([request.url hasSuffix:@"statuses/update.json"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"分享失败"];
        });
    }
}
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result;{
    if ([request.url hasSuffix:@"statuses/update.json"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"分享成功"];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    }
   
}

#pragma mark - TencentSessionDelegate
/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin;{
    
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled;{
    
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork;{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:@"网络不正常"];
    });
}

- (void)addShareResponse:(APIResponse*) response;{
    if (response.retCode == URLREQUEST_SUCCEED) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"分享成功"];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }else if (response.retCode == URLREQUEST_FAILED){
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"分享失败"];
        });
    }
}


@end
