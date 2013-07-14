//
//  HomeViewController.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "HomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MyWebImgView.h"
#import <Ice/Ice.h>
#import <Guide.h>
#import "SVProgressHUD.h"
#import "GuideCoverView.h"
#import "GuideViewController.h"
#import "ICETool.h"
#import "ReloadView.h"

@interface HomeViewController (){
    JCMutableGuideList *_datas;
   
}

-(void)loadDatas;
-(void)loadSlogon;

@end

@implementation HomeViewController

-(void)reloadDatas{
    [self loadSlogon];
    [self loadDatas];
}

-(void)viewDidLoad
{
    _lb_sLogon.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"SLOGON"];
    _pageFlowView.delegate = self;
    _pageFlowView.dataSource = self;
    _pageFlowView.minimumPageAlpha = 0.3;
    _pageFlowView.minimumPageScale = 0.9;
}


-(void)loadUser{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCUser * user = [proxy getUserById:[ShareVaule shareInstance].userId userId:[ShareVaule shareInstance].userId];
                if (user) {
                    [ShareVaule shareInstance].user = user;
                }
            }
            @catch (ICEException *exception) {
                
            }
            @finally {
                
            }
        }@catch (ICEException *exception) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD showErrorWithStatus:@"服务访问异常"];
//            });
        }
    });
        
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![ShareVaule shareInstance].user && [ShareVaule shareInstance].userId) {
        [self loadUser];
    }
    if (_datas.count == 0) {
        [self reloadDatas];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_pageFlowView release];
    [_datas release];
    [_lb_sLogon release];
    [super dealloc];
}


#pragma mark -

-(void)loadSlogon{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                NSString *slogon = [proxy getSlogon];
                [[NSUserDefaults standardUserDefaults]setObject:slogon forKey:@"SLOGON"];
                _lb_sLogon.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"SLOGON"];
            }
            @catch (ICEException *exception) {
                if ([exception isKindOfClass:[JCGuideException class]]) {
                    JCGuideException *_exception = (JCGuideException *)exception;
                    if (_exception.reason_) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:_exception.reason_ delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            //                        [alert show];
                            //                        [alert release];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:ERROR_MESSAGE delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            //                        [alert show];
                            //                        [alert release];
                        });
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:ERROR_MESSAGE delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                        //                    [alert show];
                        //                    [alert release];
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

-(void)loadDatas{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCMutableGuideList * list = [proxy getGuideListByType:nil filterCode:0 timestamp:nil pageIdx:0 pageSize:20];
                if (list) {
                    _datas = [list retain];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [_pageFlowView reloadData];
                });
            }
            @catch (ICEException *exception) {
                if ([exception isKindOfClass:[JCGuideException class]]) {
                    JCGuideException *_exception = (JCGuideException *)exception;
                    if (_exception.reason_) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:_exception.reason_];
                            [ReloadView showInView:self.view message:@"加载失败，点击重新加载" target:self action:@selector(reloadDatas)];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                            [ReloadView showInView:self.view message:@"加载失败，点击重新加载" target:self action:@selector(reloadDatas)];
                        });
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                        [ReloadView showInView:self.view message:@"加载失败，点击重新加载" target:self action:@selector(reloadDatas)];
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

#pragma mark -PagedFlowViewDelegate
- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView;{
    return  CGSizeMake(flowView.frame.size.width/5*4, flowView.frame.size.height/8*7);
}

- (void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index;{
    GuideViewController *vlc =[[[GuideViewController alloc]initWithNibName:@"GuideViewController" bundle:nil]autorelease];
    JCGuide *guide = [_datas objectAtIndex:index];
    vlc.guide = guide;
    [self.navigationController pushViewController:vlc animated:YES];
}

#pragma mark -PagedFlowViewDataSource

//返回显示View的个数
- (NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView{
    return [_datas count];
}

//返回给某列使用的View
- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index;{
    GuideCoverView *coverView = (GuideCoverView *)[flowView dequeueReusableCell];
    if (!coverView) {
        coverView = [[[GuideCoverView alloc]init]autorelease];
    }
    JCGuide *guide = [_datas objectAtIndex:index];
    [coverView upGuide:guide];
    return coverView;
}

- (void)viewDidUnload {
    _pageFlowView = nil;
    _datas = nil;
    _lb_sLogon = nil;
    [super viewDidUnload];
}
@end
