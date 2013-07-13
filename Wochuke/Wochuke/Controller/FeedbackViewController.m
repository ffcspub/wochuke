//
//  FeedbackViewController.m
//  Wochuke
//
//  Created by Geory on 13-7-7.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "FeedbackViewController.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "ICETool.h"
#import <Guide.h>

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

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
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(26, 75, 269, 153)];
    textView.placeholder = @"欢迎向我们反馈您在软件使用中遇到的任何问题，或者意见和建议";
    [self.view addSubview:textView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_iv_back release];
    [_tf_phone release];
    [textView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setIv_back:nil];
    [self setTf_phone:nil];
    [super viewDidUnload];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendAction:(id)sender {
    if (textView.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"您还未输入内容" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                NSString *userid = [ShareVaule shareInstance].userId;
                [proxy saveFeedback:textView.text contact:_tf_phone.text termId:nil curUserId:userid];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [SVProgressHUD showSuccessWithStatus:@"提交成功，感谢您的反馈"];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            @catch (ICEException *exception) {
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

- (IBAction)backgroundClick:(id)sender {
    [textView resignFirstResponder];
    [_tf_phone resignFirstResponder];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (IS_SCREEN_35_INCH) {
        if (textField == _tf_phone){
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = CGRectMake(0, -100, self.view.frame.size.width, self.view.frame.size.height);
            }];
        }
    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_tf_phone == textField) {
        [_tf_phone resignFirstResponder];
    }
    return YES;
}

@end
