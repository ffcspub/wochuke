//
//  GuideViewController.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "GuideViewController.h"
#import <Ice/Ice.h>
#import "ICETool.h"
#import "SVProgressHUD.h"
#import "GuideInfoView.h"
#import "SuppliesView.h"
#import "StepView.h"
#import "StepPreviewController.h"
#import "JSBadgeView.h"
#import "LoginViewController.h"
#import "CommentViewController.h"
#import "GuideUserListViewController.h"
#import "CommentViewController.h"
#import "DriverManagerViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "UserViewController.h"


//#import "StepEditController.h"

@interface GuideViewController ()<StepViewDelegate,UIActionSheetDelegate>{
    JCGuideDetail *_detail;
    JSBadgeView *_badgeView;
}

@end

@implementation GuideViewController

-(void)loadDetail{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCGuideDetail *detail = [proxy getGuideDetail:[ShareVaule shareInstance].userId guideId:_guide.id_];
                if (detail) {
                    _detail = [detail retain];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (_detail.favorited) {
                        [_btn_like setImage:[UIImage imageNamed:@"ic_cook_like_bottom_pressed"] forState:UIControlStateNormal];
                    }else{
                        [_btn_like setImage:[UIImage imageNamed:@"ic_cook_like_bottom"] forState:UIControlStateNormal];
                    }
                    [_pagedFlowView reloadData];
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _badgeView.badgeText = [NSString stringWithFormat:@"%d", _guide.commentCount];
    [self postNotification:NOTIFICATION_HIDETOOLBAR];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _pagedFlowView.delegate = self;
    _pagedFlowView.dataSource = self;
    _pagedFlowView.minimumPageAlpha = 1.0;
    _pagedFlowView.minimumPageScale = 1.0;
    if (_guide.commentCount>0) {
        _badgeView = [[[JSBadgeView alloc] initWithParentView:_btn_comment alignment:JSBadgeViewAlignmentTopRight]autorelease];
        _badgeView.badgePositionAdjustment = CGPointMake(-10, 10);
    }
    [self observeNotification:StepPreviewController.TAP];
    [self loadDetail];
    // Do any additional setup after loading the view from its nib.
}


-(void)viewWillUnload{
    [self unobserveNotification:StepPreviewController.TAP];
    [super viewWillUnload];
}

-(void)handleNotification:(NSNotification *)notification{
    if ([notification is:StepPreviewController.TAP]) {
        NSNumber *index = (NSNumber *)notification.object;
        [_pagedFlowView scrollToPage:[index integerValue] animation:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_pagedFlowView release];
    [_btn_comment release];
    [_btn_share release];
    [_btn_like release];
    [_btn_driver release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setPagedFlowView:nil];
    [self setBtn_comment:nil];
    [self setBtn_share:nil];
    [self setBtn_like:nil];
    [self setBtn_driver:nil];
    [super viewDidUnload];
}

- (IBAction)popAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showPreviewAction:(id)sender {
    StepPreviewController *vlc = [[[StepPreviewController alloc]initWithNibName:@"StepPreviewController" bundle:nil]autorelease];
    vlc.guide = _guide;
    vlc.detail = _detail;
    [self.navigationController pushViewController:vlc animated:YES];
}


#pragma mark -PagedFlowViewDelegate
- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView{
    return  CGSizeMake(flowView.frame.size.width - 50, flowView.frame.size.height - 10);
}


#pragma mark -PagedFlowViewDataSource
//返回显示View的个数
- (NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView{
    if (_detail.supplies.count>0) {
        return _detail.steps.count + 2;
    }
    return _detail.steps.count + 1;
}

//返回给某列使用的View
- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    if (index == 0) {
        GuideInfoView *view = (GuideInfoView *)[flowView dequeueReusableCellWithClass:[GuideInfoView class]];
        if (!view) {
            view = [[[GuideInfoView alloc]init]autorelease];
        }
        view.guide = _guide;
        view.delegate = self;
        return view;
    }else if(_detail.supplies.count>0 && index == 1){
        SuppliesView *view = (SuppliesView *)[flowView dequeueReusableCellWithClass:[SuppliesView class]];
        if (!view) {
            view = [[[SuppliesView alloc]init]autorelease];
        }
        view.list = _detail.supplies;
        return view;
    }else{
        StepView *view = (StepView *)[flowView dequeueReusableCellWithClass:[StepView class]];
        if (!view) {
            view = [[[StepView alloc]init]autorelease];
        }
        int indextemp = index - 1;
        if (_detail.supplies.count>0) {
            indextemp = index - 2;
        }
        view.step = [_detail.steps objectAtIndex:indextemp];
        view.stepCount = _detail.steps.count;
        view.delegate = self;
        return view;
    }
    return nil;
}

#pragma mark - StepViewDelegate
-(void)commentStep:(JCStep *)step;{
    CommentViewController *vlc = [[[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil]autorelease];
    vlc.guide = _guide;
    vlc.step = step;
    [self.navigationController pushViewController:vlc animated:YES];
}


#pragma mark - Actions

-(void)followGudie{
//    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                [proxy favorite:[ShareVaule shareInstance].userId guideId:_guide.id_ flag:!_detail.favorited];
                _detail.favorited = !_detail.favorited;
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                [SVProgressHUD dismiss];
                    if (_detail.favorited) {
                        [SVProgressHUD showSuccessWithStatus:@"已收藏"];
                        [_btn_like setImage:[UIImage imageNamed:@"ic_cook_like_bottom_pressed"] forState:UIControlStateNormal];
                        _guide.favoriteCount++ ;
                        [ShareVaule shareInstance].user.favoriteCount ++;
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"已取消收藏"];
                        [_btn_like setImage:[UIImage imageNamed:@"ic_cook_like_bottom"] forState:UIControlStateNormal];
                        _guide.favoriteCount -- ;
                        [ShareVaule shareInstance].user.favoriteCount --;
                    }
                    [self postNotification:NOTIFICATION_FAVORITECOUNT];
                    [_pagedFlowView reloadData];
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


- (IBAction)commentAction:(id)sender {
    if ([ShareVaule shareInstance].user.id_) {
        CommentViewController *vlc = [[[CommentViewController alloc]init]autorelease];
        vlc.guide = _guide;
        [self.navigationController pushViewController:vlc animated:YES];
    }else{
        LoginViewController *vlc = [[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil]autorelease];
        UINavigationController *navController = [[[UINavigationController alloc]initWithRootViewController:vlc ]autorelease];
        navController.navigationBarHidden = YES;
        [self presentModalViewController:navController animated:YES];
    }
    
}

-(NSString *)paramFormGuide{
    for (JCStep *step in _detail.steps) {
        if (step.param.length>0) {
            return step.param;
        }
    }
    return nil;
}

#pragma mark - ControlDriver
-(void)controlDriverByName:(NSString *)name{
    NSString *param = [self paramFormGuide];
    if (![self paramFormGuide]) {
        [SVProgressHUD showErrorWithStatus:@"不是智能食谱，无法启动智能烹饪！"];
        return;
    }
    int fire = 0;
    int second = 0;
    NSArray *params = [param componentsSeparatedByString:@"::"];
    if (params.count == 2) {
        if ([[params objectAtIndex:0] isEqual:@"00"]) {
            NSString *valuetemp = [params objectAtIndex:1] ;
            NSArray *temparray = [valuetemp componentsSeparatedByString:@"|"];
            NSString *value = [temparray objectAtIndex:0];
            NSArray *temps = [value componentsSeparatedByString:@"="];
            NSString *fireString = [temps objectAtIndex:0];
            NSString *secondString = [temps objectAtIndex:1];
            fire = [fireString integerValue];
            second = [secondString integerValue];
        }
    }
    NSString *devId = [ShareVaule devIdByName:name];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAgentLocatorPrx> proxy = [[ICETool shareInstance] createLocalProxy];
            @try {
                id<JCCookAgentPrx> agentPrx = [[ICETool shareInstance]createCookAgentPrx:devId localProxy:proxy];
                if (!agentPrx) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:@"请求的设备没有联机"];
                    });
                }else{
                    NSMutableString *_token = nil;
                    BOOL *online = nil;
                   int res =  [agentPrx bind:nil token:&_token online:online];
                    if (!online) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:@"请求的设备没有联机"];
                        });
                    }else{
                        res = [agentPrx start:_token fire:fire seconds:second];
                        switch (res) {
                            case -2:
                                [SVProgressHUD showErrorWithStatus:@"请求的设备没有联机"];
                                break;
                            case -1:
                            case 1:
                                [SVProgressHUD showErrorWithStatus:@"请求操作失败"];
                                break;
                            default:
                                break;
                        }
                    }
                    
                }
            }
            @catch (ICEException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:@"服务无法访问"];
                });
            }
        }
        @catch (ICEException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"服务无法访问"];
            });

        }
    });
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;{
    if (actionSheet.tag == 10086) {
        return;
    }
    NSArray *driveNames = [ShareVaule allDriverNames];
    int count = driveNames.count;
    if (buttonIndex < count ) {
        NSString *name = [driveNames objectAtIndex:buttonIndex];
        [self controlDriverByName:name];
    }else{
        if((buttonIndex - count) == 0){
            DriverManagerViewController *vlc = [[ DriverManagerViewController alloc]initWithNibName:@"DriverManagerViewController" bundle:nil];
            [self.navigationController pushViewController:vlc animated:YES];
            [vlc release];
        }
    }
}

/**
 *	@brief	简单分享全部
 *
 *	@param 	sender 	事件对象
 */
- (void)simpleShare
{
    //定义菜单分享列表
//    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeTwitter, ShareTypeFacebook, ShareTypeSinaWeibo, ShareTypeTencentWeibo, ShareTypeRenren, ShareTypeKaixin, ShareTypeSohuWeibo, ShareType163Weibo, nil];
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeSinaWeibo,ShareTypeQQSpace,ShareTypeWeixiSession,ShareTypeWeixiTimeline,
                          nil];
    
    //创建分享内容
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:CONTENT,_guide.title]
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"分享"
                                                  url:@"http://www.wochuke.com"
                                          description:@""
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //创建容器
    id<ISSContainer> container = [ShareSDK container];
//    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    [ShareSDK ssoEnabled:YES];
    //显示分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                          oneKeyShareList:shareList
                                                           qqButtonHidden:NO
                                                    wxSessionButtonHidden:NO
                                                   wxTimelineButtonHidden:NO
                                                     showKeyboardOnAppear:NO
                                                        shareViewDelegate:nil
                                                      friendsViewDelegate:nil
                                                    picViewerViewDelegate:nil]
                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
//                                    [SVProgressHUD showSuccessWithStatus:@"分享成功"];
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
//                                    [SVProgressHUD showErrorWithStatus:@"分享失败"];
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}


#pragma mark -Action
- (IBAction)shareAction:(id)sender {
    [self simpleShare];
//    [ShareSDK oneKeyShareContent:(id<ISSContent>)content
//                       shareList:(NSArray *)shareList
//                     authOptions:(id<ISSAuthOptions>)authOptions
//                   statusBarTips:(BOOL)statusBarTips
//                          result:(SSPublishContentEventHandler)result;
//    
//    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"分享" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"新浪微博" otherButtonTitles:@"QQ", nil];
//    sheet.tag = 10086;
//    [sheet showInView:self.view];
//    [sheet release];
}

- (IBAction)likeAction:(id)sender {
    if ([ShareVaule shareInstance].user.id_) {
         [self followGudie];
    }else{
        LoginViewController *vlc = [[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil]autorelease];
        UINavigationController *navController = [[[UINavigationController alloc]initWithRootViewController:vlc ]autorelease];
        navController.navigationBarHidden = YES;
        [self presentModalViewController:navController animated:YES];
    }
}

- (IBAction)driverAction:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc]init];
    sheet.delegate = self;
    NSArray *driveNames = [ShareVaule allDriverNames];
    int i = 0;
    if (driveNames) {
        for (NSString *name in driveNames) {
            [sheet addButtonWithTitle:name];
            i++;
        }
    }
    [sheet addButtonWithTitle:@"厨具管理"];
    i++;
    [sheet addButtonWithTitle:@"取消"];
    sheet.cancelButtonIndex = i;
    [sheet showInView:self.view];
    [sheet release];
}

#pragma mark -GuideInfoViewDelegate
-(void)guideInfoViewViewcount:(GuideInfoView *)infoView{
    GuideUserListViewController *vlc = [[GuideUserListViewController alloc]initWithNibName:@"GuideUserListViewController" bundle:nil];
    vlc.guide = _guide;
    vlc.actCode = 1;
    [self.navigationController pushViewController:vlc animated:YES];
    [vlc release];
}

-(void)guideInfoViewFavorite:(GuideInfoView *)infoView{
    GuideUserListViewController *vlc = [[GuideUserListViewController alloc]initWithNibName:@"GuideUserListViewController" bundle:nil];
    //    vlc.actCode = 2;
    vlc.guide = _guide;
    vlc.actCode = 2;
    [self.navigationController pushViewController:vlc animated:YES];
    [vlc release];
}

-(void)guideInfoViewComment:(GuideInfoView *)infoView{
    [self commentAction:nil];
}

-(void)guideInfoViewUserShow:(GuideInfoView *)infoView{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCUser *user = [proxy getUserById:[ShareVaule shareInstance].userId userId:_guide.userId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    UserViewController *vlc = [[UserViewController alloc]initWithNibName:@"UserViewController" bundle:nil];
                    vlc.user = user;
                    [self.navigationController pushViewController:vlc animated:YES];
                    [vlc release];
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

@end
