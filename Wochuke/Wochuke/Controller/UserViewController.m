//
//  UserViewController.m
//  Wochuke
//
//  Created by he songhang on 13-6-27.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "UserViewController.h"
#import "LoginViewController.h"
#import "SetingViewController.h"
#import <Guide.h>
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "UserView.h"
#import "GuideInfoView.h"
#import "ICETool.h"
#import "SVPullToRefresh.h"
#import "UITableView+BeeUIGirdCell.h"
#import "GuideViewController.h"
#import "UserViewController.h"
#import "StepEditController.h"
#import "CreateGuideViewController.h"
#import "FollowUserListViewController.h"
#import "NSObject+Notification.h"

@interface UserViewController ()<GuideInfoEditCellDelegate>{
    int type;
    NSMutableArray *_datas;
    int pageSize;
    int pageIndex;
    BOOL hasNextPage;
}

@end

@implementation UserViewController

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
    _datas = [[NSMutableArray alloc]init];
    pageSize = 20;
    if (_user.id_ == [ShareVaule shareInstance].user.id_) {
        [_btn_follow setHidden:YES];
    }
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [self loadDatas];
    }];
    [self.tableView addPullToRefreshWithActionHandler:^{
        [self reloadDatas];
    }];
    [self.tableView.pullToRefreshView setTitle:@"松开刷新" forState:SVPullToRefreshStateAll];
    [self.tableView.pullToRefreshView setTitle:@"下拉刷新" forState:SVPullToRefreshStateTriggered];
    [self.tableView.pullToRefreshView setTitle:@"正在加载" forState:SVPullToRefreshStateLoading];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_user) {
        _lb_uploadCount.text = [NSString stringWithFormat:@"%d",_user.guideCount];
        _lb_favCount.text = [NSString stringWithFormat:@"%d",_user.favoriteCount];
        _lb_followCount.text = [NSString stringWithFormat:@"%d",_user.followingCount];
        _lb_fanceCount.text = [NSString stringWithFormat:@"%d",_user.followerCount];
    }
    
    UIImage *backImage = [[UIImage imageNamed:@"bg_classify_card"]resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [_iv_bottomBackView setImage:backImage];
    
    if (_user.id_) {
        [_bottomBackView setHidden:NO];
        _lb_username.text = _user.name;
        [_iv_face setImageWithURL:[NSURL URLWithString:_user.avatar.url] placeholderImage:[UIImage imageNamed:@"ic_user_top"]];
        UIImage *backImage = [[UIImage imageNamed:@"btn_grad"]resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12) ];
        [_btn_follow setBackgroundImage:backImage forState:UIControlStateNormal];
        if (_user.followState == 1 || _user.followState == 3) {
            [_btn_follow setTitle:@"取消关注" forState:UIControlStateNormal];
        }else{
            [_btn_follow setTitle:@"添加关注" forState:UIControlStateNormal];
        }
    }
    
    [self reloadDatas];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)upCountLableColor{
    [_lb_uploadCount setTextColor:[UIColor darkGrayColor]];
    [_lb_favCount setTextColor:[UIColor darkGrayColor]];
    [_lb_followCount setTextColor:[UIColor darkGrayColor]];
    [_lb_fanceCount setTextColor:[UIColor darkGrayColor]];
    if (type == 0) {
        [_lb_uploadCount setTextColor:[UIColor redColor]];
    }else if(type == 1){
        [_lb_favCount setTextColor:[UIColor redColor]];
    }else if(type == 2){
        [_lb_followCount setTextColor:[UIColor redColor]];
    }else if(type == 3){
        [_lb_fanceCount setTextColor:[UIColor redColor]];
    }
}

- (IBAction)uploadListAction:(id)sender {
    [_iv_topBackView setImage:[UIImage imageNamed:@"bg_card_user_top_1"]];
    type = 0;
    [self upCountLableColor];
    [self reloadDatas];
}

- (IBAction)favListAction:(id)sender {
    [_iv_topBackView setImage:[UIImage imageNamed:@"bg_card_user_top_2"]];
    type = 1;
    [self upCountLableColor];
    [self reloadDatas];
}

- (IBAction)followListAction:(id)sender {
//    [_iv_topBackView setImage:[UIImage imageNamed:@"bg_card_user_top_3"]];
//    type = 2;
//    [self upCountLableColor];
//    [self reloadDatas];
    FollowUserListViewController *vlc = [[FollowUserListViewController alloc]initWithNibName:@"FollowUserListViewController" bundle:nil];
    vlc.user = _user;
    vlc.filterCode = 0;
    [self.navigationController pushViewController:vlc animated:YES];
    [vlc release];
}

- (IBAction)fanceListAction:(id)sender {
//    [_iv_topBackView setImage:[UIImage imageNamed:@"bg_card_user_top_4"]];
//    type = 3;
//    [self upCountLableColor];
//    [self reloadDatas];
    FollowUserListViewController *vlc = [[FollowUserListViewController alloc]initWithNibName:@"FollowUserListViewController" bundle:nil];
    vlc.user = _user;
    vlc.filterCode = 1;
    [self.navigationController pushViewController:vlc animated:YES];
    [vlc release];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)followAction:(id)sender {
    [self followUser:_user];
}

-(void)loadUploadGuides{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCMutableGuideList * list = nil;
                list = [proxy getGuideListByUser:_user.id_ filterCode:1 timestamp:nil pageIdx:pageIndex pageSize:pageSize];
                if (list) {
                    if (pageIndex == 0) {
                        [_datas removeAllObjects];
                    }
                    if (list.count > 0) {
                        [_datas addObjectsFromArray:list];
                    }
                    if (list.count == 20) {
                        pageIndex ++;
                        hasNextPage = YES;
                    }else{
                        hasNextPage = NO;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (pageIndex==0) {
                        _bottomBackView.hidden = YES;
                    }else{
                        _bottomBackView.hidden = NO;
                    }
                    [_tableView reloadData];
                    [self.tableView.infiniteScrollingView stopAnimating];
                    [self.tableView.pullToRefreshView stopAnimating];
                    if (!hasNextPage) {
                        [self.tableView setShowsInfiniteScrolling:NO];
                    }else{
                        [self.tableView setShowsInfiniteScrolling:YES];
                    }
                });
            }
            @catch (ICEException *exception) {
                if ([exception isKindOfClass:[JCGuideException class]]) {
                    JCGuideException *_exception = (JCGuideException *)exception;
                    if (_exception.reason_) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:_exception.reason_];
                            [self.tableView.infiniteScrollingView stopAnimating];
                            [self.tableView.pullToRefreshView stopAnimating];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                            [self.tableView.infiniteScrollingView stopAnimating];
                            [self.tableView.pullToRefreshView stopAnimating];
                        });
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                        [self.tableView.infiniteScrollingView stopAnimating];
                        [self.tableView.pullToRefreshView stopAnimating];
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

-(void)loadFavGuides{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCMutableGuideList * list = nil;
                list = [proxy getGuideListByUser:_user.id_ filterCode:2 timestamp:nil pageIdx:pageIndex pageSize:pageSize];
                if (list) {
                    if (pageIndex == 0) {
                        [_datas removeAllObjects];
                    }
                    if (list.count > 0) {
                        [_datas addObjectsFromArray:list];
                    }
                    if (list.count == 20) {
                        pageIndex ++;
                        hasNextPage = YES;
                    }else{
                        hasNextPage = NO;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (pageIndex==0 && list.count==0) {
                        _bottomBackView.hidden = YES;
                    }else{
                        _bottomBackView.hidden = NO;
                    }
                    [_tableView reloadData];
                    [self.tableView.infiniteScrollingView stopAnimating];
                    [self.tableView.pullToRefreshView stopAnimating];
                    if (!hasNextPage) {
                        [self.tableView setShowsInfiniteScrolling:NO];
                    }else{
                        [self.tableView setShowsInfiniteScrolling:YES];
                    }
                });
            }
            @catch (ICEException *exception) {
                if ([exception isKindOfClass:[JCGuideException class]]) {
                    JCGuideException *_exception = (JCGuideException *)exception;
                    if (_exception.reason_) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:_exception.reason_];
                            [self.tableView.infiniteScrollingView stopAnimating];
                            [self.tableView.pullToRefreshView stopAnimating];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                            [self.tableView.infiniteScrollingView stopAnimating];
                            [self.tableView.pullToRefreshView stopAnimating];
                        });
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                        [self.tableView.infiniteScrollingView stopAnimating];
                        [self.tableView.pullToRefreshView stopAnimating];
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

-(void)loadFollowUsers{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCMutableGuideList * list = nil;
                list = [proxy getUserListByUser:_user.id_ userId:_user.id_ filterCode:0 timestamp:nil pageIdx:pageIndex pageSize:pageSize];
                if (list) {
                    if (pageIndex == 0) {
                        [_datas removeAllObjects];
                    }
                    if (list.count > 0) {
                        [_datas addObjectsFromArray:list];
                    }
                    if (list.count == 20) {
                        pageIndex ++;
                        hasNextPage = YES;
                    }else{
                        hasNextPage = NO;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (pageIndex==0 && list.count==0) {
                        _bottomBackView.hidden = YES;
                    }else{
                        _bottomBackView.hidden = NO;
                    }
                    [_tableView reloadData];
                    [self.tableView.infiniteScrollingView stopAnimating];
                    [self.tableView.pullToRefreshView stopAnimating];
                    if (!hasNextPage) {
                        [self.tableView setShowsInfiniteScrolling:NO];
                    }else{
                        [self.tableView setShowsInfiniteScrolling:YES];
                    }
                });
            }
            @catch (ICEException *exception) {
                if ([exception isKindOfClass:[JCGuideException class]]) {
                    JCGuideException *_exception = (JCGuideException *)exception;
                    if (_exception.reason_) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:_exception.reason_];
                            [self.tableView.infiniteScrollingView stopAnimating];
                            [self.tableView.pullToRefreshView stopAnimating];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                            [self.tableView.infiniteScrollingView stopAnimating];
                            [self.tableView.pullToRefreshView stopAnimating];
                        });
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                        [self.tableView.infiniteScrollingView stopAnimating];
                        [self.tableView.pullToRefreshView stopAnimating];
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

-(void)loadFances{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCMutableGuideList * list = nil;
                list = [proxy getUserListByUser:_user.id_ userId:_user.id_ filterCode:1 timestamp:nil pageIdx:pageIndex pageSize:pageSize];
                if (list) {
                    if (pageIndex == 0 ) {
                        [_datas removeAllObjects];
                    }
                    if (list.count > 0) {
                        [_datas addObjectsFromArray:list];
                    }
                    if (list.count == 20) {
                        pageIndex ++;
                        hasNextPage = YES;
                    }else{
                        hasNextPage = NO;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (pageIndex==0 && list.count==0) {
                        _bottomBackView.hidden = YES;
                    }else{
                        _bottomBackView.hidden = NO;
                    }
                    [_tableView reloadData];
                    [self.tableView.infiniteScrollingView stopAnimating];
                    [self.tableView.pullToRefreshView stopAnimating];
                    if (!hasNextPage) {
                        [self.tableView setShowsInfiniteScrolling:NO];
                    }else{
                        [self.tableView setShowsInfiniteScrolling:YES];
                    }
                });
            }
            @catch (ICEException *exception) {
                if ([exception isKindOfClass:[JCGuideException class]]) {
                    JCGuideException *_exception = (JCGuideException *)exception;
                    if (_exception.reason_) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:_exception.reason_];
                            [self.tableView.infiniteScrollingView stopAnimating];
                            [self.tableView.pullToRefreshView stopAnimating];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                            [self.tableView.infiniteScrollingView stopAnimating];
                            [self.tableView.pullToRefreshView stopAnimating];
                        });
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                        [self.tableView.infiniteScrollingView stopAnimating];
                        [self.tableView.pullToRefreshView stopAnimating];
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


- (void)dealloc {
    [_user release];
    [_iv_face release];
    [_bottomBackView release];
    [_tableView release];
    [_iv_bottomBackView release];
    [_iv_topBackView release];
    [_lb_uploadCount release];
    [_lb_favCount release];
    [_lb_followCount release];
    [_lb_fanceCount release];
    [_navBar release];
    [_lb_username release];
    [_btn_follow release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setIv_face:nil];
    [self setBottomBackView:nil];
    [self setTableView:nil];
    [self setIv_bottomBackView:nil];
    [self setIv_topBackView:nil];
    [self setLb_uploadCount:nil];
    [self setLb_favCount:nil];
    [self setLb_followCount:nil];
    [self setLb_fanceCount:nil];
    [self setNavBar:nil];
    [self setLb_username:nil];
    [self setBtn_follow:nil];
    [super viewDidUnload];
}

#pragma mark -DataLoad
-(void)reloadDatas{
    if (!_user) {
        return;
    }
//    if (_datas.count>0) {
//        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
//    }
    pageIndex = 0;
    [self loadDatas];
}

-(void)loadDatas{
    switch (type) {
        case 0:
            [self loadUploadGuides];
            break;
        case 1:
            [self loadFavGuides];
            break;
        case 2:
            [self loadFollowUsers];
            break;
        case 3:
            [self loadFances];
            break;
        default:
            break;
    }
}
#pragma mark -GuideInfoEditCellDelegate
-(void) guideInfoEditCellEdit:(GuideInfoEditCell *) cell;{
    JCGuide *guide = (JCGuide *)cell.cellData;
    StepEditController *vlc = [[StepEditController alloc]initWithNibName:@"StepEditController" bundle:nil];
    vlc.guide = guide;
    [self.navigationController pushViewController:vlc animated:YES];
    [vlc release];
}

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    if (type < 2) {
        cell = [tableView dequeueReusableCellWithBeeUIGirdCellClass:[GuideInfoMinCell class]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else if(type == 2 || type == 3){
        cell = [tableView dequeueReusableCellWithBeeUIGirdCellClass:[UserCell class]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.gridCell.cellData = [_datas objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (type == 0) {
        return [GuideInfoMinCell sizeInBound:CGSizeMake(320, 60) forData:[_datas objectAtIndex:indexPath.row]].height;
    }else if(type == 1){
        return [GuideInfoMinCell sizeInBound:CGSizeMake(320, 60) forData:[_datas objectAtIndex:indexPath.row]].height;
    }else{
        return [UserCell sizeInBound:CGSizeMake(320, 60) forData:[_datas objectAtIndex:indexPath.row]].height;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (type < 2) {
        GuideViewController *vlc =[[[GuideViewController alloc]initWithNibName:@"GuideViewController" bundle:nil]autorelease];
        JCGuide *guide = [_datas objectAtIndex:indexPath.row];
        vlc.guide = guide;
        [self.navigationController pushViewController:vlc animated:YES];
    }else{
        UserViewController *vlc = [[UserViewController alloc]initWithNibName:@"UserViewController" bundle:nil];
        vlc.user = [_datas objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:vlc animated:YES];
    }
}

#pragma mark -
-(void) followUser:(JCUser *)user{
    if ([ShareVaule shareInstance].userId) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            @try {
                id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
                @try {
                    NSString *userid = [ShareVaule shareInstance].userId;
                    BOOL flag = (user.followState == 1 || user.followState == 3);
                    [proxy follow:userid userId:_user.id_ flag:!flag];
                    if (flag) {
                        user.followState = user.followState - 1;
                    }else{
                        user.followState = user.followState + 1;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (flag) {
                            [SVProgressHUD showSuccessWithStatus:@"已取消关注"];
                        }else{
                            [SVProgressHUD showSuccessWithStatus:@"已关注"];
                        }
                        if (_user.followState == 1 || _user.followState == 3) {
                            [_btn_follow setTitle:@"取消关注" forState:UIControlStateNormal];
                        }else{
                            [_btn_follow setTitle:@"添加关注" forState:UIControlStateNormal];
                        }
                        [self postNotification:NOTIFICATION_FOLLOWSTATECHANGE];
                    });
                }
                @catch (ICEException *exception) {
                    if ([exception isKindOfClass:[JCGuideException class]]) {
                        JCGuideException *_exception = (JCGuideException *)exception;
                        if (_exception.reason_) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //                                [SVProgressHUD showErrorWithStatus:_exception.reason_];
                            });
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //                                [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                            });
                        }
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //                            [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
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
    }else{
        LoginViewController *vlc = [[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil]autorelease];
        UINavigationController *navController = [[[UINavigationController alloc]initWithRootViewController:vlc]autorelease];
        navController.navigationBarHidden = YES;
        [self presentViewController:navController animated:YES completion:nil];
    }
    
}
@end
