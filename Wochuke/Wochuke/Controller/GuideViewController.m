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
#import "UserViewController.h"
#import "AWActionSheet.h"
#import "ShareViewController.h"
#import "WXApi.h"

//#import "StepEditController.h"

@interface GuideViewController ()<StepViewDelegate,UIActionSheetDelegate,AWActionSheetDelegate,SinaWeiboDelegate,TencentSessionDelegate>{
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




#pragma mark -Action
- (IBAction)shareAction:(id)sender {
    AWActionSheet *sheet = [[AWActionSheet alloc] initwithIconSheetDelegate:self ItemCount:[self numberOfItemsInActionSheet]];
    [sheet showInView:self.view];
    [sheet release];
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

#pragma mark -AWActionSheetDelegate
-(int)numberOfItemsInActionSheet
{
    return 4;
}

-(AWActionSheetCell *)cellForActionAtIndex:(NSInteger)index
{
    AWActionSheetCell* cell = [[[AWActionSheetCell alloc] init] autorelease];
    if (index == 0) {
        [cell.iconView setImage:[UIImage imageNamed:@"sns_icon_1"]];
//        cell.titleLabel.text = @"新浪微博";
    }else if(index == 1){
        [cell.iconView setImage:[UIImage imageNamed:@"sns_icon_6"]];
//        cell.titleLabel.text = @"QQ空间";
    }else if(index == 2){
        [cell.iconView setImage:[UIImage imageNamed:@"sns_icon_22"]];
//        cell.titleLabel.text = @"微信好友圈";
    }else if(index == 3){
        [cell.iconView setImage:[UIImage imageNamed:@"sns_icon_23"]];
//        cell.titleLabel.text= @"微信社交";
    }
    cell.index = index;
    return cell;
}

-(void)DidTapOnItemAtIndex:(NSInteger)index
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (index == 0) {
            [ShareVaule shareInstance].sinaweibo.delegate = self ;
            if ([[ShareVaule shareInstance].sinaweibo isAuthValid]) {
                [ShareVaule shareInstance].sinaweibo.delegate = nil ;
                [self loadShareViewController:0];
            }else{
                [[ShareVaule shareInstance].sinaweibo logIn];
            }
        }else if(index == 1){
            if ([[ShareVaule shareInstance].tencentOAuth isSessionValid]) {
                [self loadShareViewController:1];
            }else{
                [ShareVaule shareInstance].tencentOAuth.sessionDelegate = self;
                NSArray *array = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, kOPEN_PERMISSION_ADD_SHARE, nil];
                [[ShareVaule shareInstance].tencentOAuth authorize:array inSafari:NO];
            }
        }else if(index == 2){
            SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
            req.bText = YES;
            req.text = [NSString stringWithFormat:SHARE_CONTENT,_guide.title];
            req.scene = WXSceneSession;
            BOOL flag = [WXApi sendReq:req];
            if (flag) {
                [SVProgressHUD showSuccessWithStatus:@"分享成功"];
            }else{
                [SVProgressHUD showErrorWithStatus:@"分享失败"];
            }
        }else if(index == 3){
            SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
            req.bText = YES;
            req.text = [NSString stringWithFormat:SHARE_CONTENT,_guide.title];
            req.scene = WXSceneTimeline;
            BOOL flag = [WXApi sendReq:req];
            if (!flag) {
                [SVProgressHUD showErrorWithStatus:@"无法打开微信客户端"];
            }
        }

    });
}

-(void)loadShareViewController:(int)type{
    ShareViewController *vlc = [[ShareViewController alloc]initWithNibName:@"ShareViewController" bundle:nil];
    vlc.type = type;
    if (type == 1) {
        vlc.titleText = [NSString stringWithFormat:SHARE_CONTENT1,_guide.title];
    }else{
        vlc.titleText = [NSString stringWithFormat:SHARE_CONTENT,_guide.title];
    }
    
    vlc.content = _guide.description_;
    [self.navigationController pushViewController:vlc animated:YES];
    [vlc release];
}

#pragma mark SinaWeiboDelegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadShareViewController:0];
    });
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo;{
    
}
- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo;{
    
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error;{
    
}

#pragma mark - TencentSession Delegate

- (void)tencentDidLogin
{
    [self loadShareViewController:1];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    
}

- (void)tencentDidNotNetWork
{
    
}

@end
