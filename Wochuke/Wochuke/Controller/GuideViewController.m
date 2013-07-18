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
#import "UIImageView+WebCache.h"
#import "JSONKit.h"
#import "SDImageCache.h"
#import "YYJSONHelper.h"
//#import "StepEditController.h"

@interface GuideViewController ()<StepViewDelegate,UIActionSheetDelegate,AWActionSheetDelegate,SinaWeiboDelegate,TencentSessionDelegate,SinaWeiboRequestDelegate>{
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
                    _guide.commentCount = _detail.commentCount;
                    _guide.viewCount = _detail.viewCount;
                    _guide.favoriteCount  = _detail.favoriteCount;
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
    if (!_detail) {
        [self loadDetail];
    }
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
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (IBAction)showPreviewAction:(id)sender {
    StepPreviewController *vlc = [[[StepPreviewController alloc]initWithNibName:@"StepPreviewController" bundle:nil]autorelease];
    vlc.guide = _guide;
    vlc.detail = _detail;
    [self.navigationController pushViewController:vlc animated:YES];
}


#pragma mark -PagedFlowViewDelegate
- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView{
    return  CGSizeMake(flowView.frame.size.width - 20, flowView.frame.size.height - 10);
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
                        _guide.favoriteCount ++;
                        [SVProgressHUD showSuccessWithStatus:@"已收藏"];
                        [_btn_like setImage:[UIImage imageNamed:@"ic_cook_like_bottom_pressed"] forState:UIControlStateNormal];
                    }else{
                        _guide.favoriteCount --;
                        [SVProgressHUD showSuccessWithStatus:@"已取消收藏"];
                        [_btn_like setImage:[UIImage imageNamed:@"ic_cook_like_bottom"] forState:UIControlStateNormal];
                    }
                    [self postNotification:NOTIFICATION_FAVORITECOUNT];
//                    [_pagedFlowView reloadData];
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
    CommentViewController *vlc = [[[CommentViewController alloc]init]autorelease];
    vlc.guide = _guide;
    [self.navigationController pushViewController:vlc animated:YES];
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
        [self presentViewController:navController animated:YES completion:nil];
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
        cell.titleLabel.text = @"新浪微博";
    }else if(index == 1){
        [cell.iconView setImage:[UIImage imageNamed:@"sns_icon_6"]];
        cell.titleLabel.text = @"QQ空间";
    }else if(index == 2){
        [cell.iconView setImage:[UIImage imageNamed:@"sns_icon_22"]];
        cell.titleLabel.text = @"微信会话";
    }else if(index == 3){
        [cell.iconView setImage:[UIImage imageNamed:@"sns_icon_23"]];
        cell.titleLabel.text= @"微信朋友圈";
    }
    cell.index = index;
    return cell;
}


#define BUFFER_SIZE 1024
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
            // 发送内容给微信
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = [NSString stringWithFormat:@"%@",_guide.title];
            message.description = _guide.description_;
            
            WXAppExtendObject *ext = [WXAppExtendObject object];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValuesForKeysWithDictionary:[_guide YYJSONDictionary]];
            NSDictionary *smallCoverdict = [_guide.smallCover YYJSONDictionary];
            NSDictionary *userAvatardict = [_guide.userAvatar YYJSONDictionary];
            NSDictionary *coverdict = [_guide.cover YYJSONDictionary];
            [dict setValue:smallCoverdict forKey:@"smallCover"];
            [dict setValue:userAvatardict forKey:@"userAvatar"];
            [dict setValue:coverdict forKey:@"cover"];
            NSString *jsonString = [dict JSONString];
            ext.extInfo = jsonString;
            if (_guide.cover.url.length>0) {
                UIImage *image = [[SDImageCache sharedImageCache]imageFromKey:[[NSURL URLWithString:_guide.cover.url]absoluteString]];
                NSData *data = UIImageJPEGRepresentation(image, 0.5);
                if (data.length > 32 *1024 ) {
                    data = UIImageJPEGRepresentation(image, 0.25);
                }
                [message setThumbData:data];
//                ext.fileData =  data;
            }
            message.mediaObject = ext;
            
            GetMessageFromWXResp* resp = [[[GetMessageFromWXResp alloc] init] autorelease];
            resp.message = message;
            resp.bText = NO;
            BOOL flag =[WXApi sendResp:resp];
            if (!flag) {
                [SVProgressHUD showErrorWithStatus:@"无法打开客户端"];
            }
        }else if(index == 3){
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = [NSString stringWithFormat:@"%@",_guide.title];
            message.description = _guide.description_;
            if (_guide.cover.url.length>0) {
                UIImage *image = [[SDImageCache sharedImageCache]imageFromKey:[[NSURL URLWithString:_guide.cover.url]absoluteString]];
                NSData *data = UIImageJPEGRepresentation(image, 0.5);
                if (data.length > 32 *1024 ) {
                    data = UIImageJPEGRepresentation(image, 0.25);
                }
                [message setThumbData:data];
            }
            
            WXWebpageObject *ext = [WXWebpageObject object];
            ext.webpageUrl = @"http://wochuke.com";
            message.mediaObject = ext;
            SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
            req.bText = NO;
            req.message = message;
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
    if (_guide.cover.url) {
        UIImageView *view = [[[UIImageView alloc]init]autorelease];
        [view setImageWithURL:[NSURL URLWithString:_guide.cover.url]];
        vlc.imageUrl = _guide.cover.url;
    }
    vlc.content = _guide.description_;
    [self.navigationController pushViewController:vlc animated:YES];
    [vlc release];
}


-(void)bindSnsByKeyId:(NSString *)keyId valueId:(NSString *)valueId{
    [SVProgressHUD show];
    [ShareVaule shareInstance].sinaweibo.delegate = nil ;
    [ShareVaule shareInstance].tencentOAuth.sessionDelegate = nil;
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
                        if ([keyId isEqual:@"qqId"]) {
                            [self loadShareViewController:1];
                        }else{
                            [self loadShareViewController:0];
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                }
            }@catch (ICEException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:@"服务访问异常"];
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if ([keyId isEqual:@"qqId"]) {
                    [self loadShareViewController:1];
                }else{
                    [self loadShareViewController:0];
                }
            });
        }
        
    });
    
}


#pragma mark - SinaWeiboDelegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"走 sinaweiboDidLogIn ");
    //    [self storeAuthData];
    //    [self performSelectorOnMainThread:@selector(logout) withObject:nil waitUntilDone:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD show];
        [sinaweibo requestWithURL:@"friendships/create.json"
                           params:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"沃厨客",@"screen_name",nil]
                       httpMethod:@"POST"
                         delegate:self];
        //        [sinaweibo requestWithURL:@"users/show.json"
        //                           params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
        //                       httpMethod:@"GET"
        //                         delegate:self];
    });
    
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"走 sinaweiboDidLogOut ");
    //    [self upShareUI];
    //    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    //    [self removeAuthData];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo;{
    //    [self upShareUI];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
    //    [self upShareUI];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"证书过期!");
}

#pragma mark - SinaWeiboRequestDelegate
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error;{
    if ([request.url hasSuffix:@"statuses/update.json"] || [request.url hasSuffix:@"statuses/upload.json"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"分享失败"];
        });
    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"users/show.json"]) {
        [ShareVaule shareInstance].sinaweiboName = [result objectForKey:@"name"];
        if ([ShareVaule shareInstance].user.id_.length
            >0) {
            [self bindSnsByKeyId:@"sinaId" valueId:[ShareVaule shareInstance].sinaweibo.userID];
        }else{
            [SVProgressHUD dismiss];
            [self loadShareViewController:0];
        }
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
    [[ShareVaule shareInstance].tencentOAuth getUserInfo];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    //    [self upShareUI];
}

- (void)tencentDidNotNetWork
{
    //    [self upShareUI];
}

- (void)tencentDidLogout
{
    //    [self upShareUI];
    //    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}



//获取用户个人信息回调
- (void)getUserInfoResponse:(APIResponse *)response
{
    if (response.retCode == URLREQUEST_SUCCEED) {
        NSString *qqname = [response.jsonResponse objectForKey:@"nickname"];
        [ShareVaule shareInstance].qqName = qqname;
        if ([ShareVaule shareInstance].user.id_.length
            >0) {
            [self bindSnsByKeyId:@"qqId" valueId:[ShareVaule shareInstance].tencentOAuth.openId];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self loadShareViewController:1];
            });
            
        }
    } else{
        [SVProgressHUD showErrorWithStatus:response.errorMsg];
    }
}

@end
