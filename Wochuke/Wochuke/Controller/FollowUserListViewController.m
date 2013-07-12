//
//  FollowUserListViewController.m
//  Wochuke
//
//  Created by he songhang on 13-7-7.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "FollowUserListViewController.h"
#import "UserView.h"
#import "SVProgressHUD.h"
#import "SVPullToRefresh.h"
#import "ICETool.h"
#import "UITableView+BeeUIGirdCell.h"
#import <Guide.h>
#import "ReloadView.h"
#import "LoginViewController.h"
#import "UserViewController.h"
#import "NSObject+Notification.h"


@interface FollowUserListViewController ()<UITableViewDataSource,UITableViewDelegate,UserCellDeleagte>{
    NSMutableArray *_datas;
    int pageIndex;
    int pageSize;
    BOOL hasNextPage;
}
@end

@implementation FollowUserListViewController

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
    pageSize = 20;
    _datas = [[NSMutableArray alloc]init];
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [self loadDatas];
    }];
    [self.tableView addPullToRefreshWithActionHandler:^{
        [self reloadDatas];
    }];
    [self.tableView.pullToRefreshView setTitle:@"松开刷新" forState:SVPullToRefreshStateAll];
    [self.tableView.pullToRefreshView setTitle:@"下拉刷新" forState:SVPullToRefreshStateTriggered];
    [self.tableView.pullToRefreshView setTitle:@"正在加载" forState:SVPullToRefreshStateLoading];
    
    [self reloadDatas];
    if (_filterCode == 0) {
        _navBar.topItem.title = @"关注用户列表";
    }else if (_filterCode == 1){
        _navBar.topItem.title = @"粉丝列表";
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [_navBar release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [self setNavBar:nil];
    [super viewDidUnload];
}


#pragma mark- DataLoad

-(void)reloadDatas{
    if (_datas.count>0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    pageIndex = 0;
    [self loadDatas];
}

-(void)loadDatas{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
        @try {
            JCMutableUserList * list = nil;
            list = [proxy getUserListByUser:[ShareVaule shareInstance].user.id_ userId:_user.id_ filterCode:_filterCode timestamp:nil pageIdx:pageIndex pageSize:pageSize];
            if (list) {
                if (pageIndex == 0) {
                    [_datas removeAllObjects];
                    if (list.count == 0) {
                        [ReloadView showInView:self.tableView message:@"没有相关的内容" target:self action:@selector(reloadDatas)];
                    }
                }
                if (list.count > 0) {
                    [_datas addObjectsFromArray:list];
                }
                if (list.count == pageSize) {
                    pageIndex ++;
                    hasNextPage = YES;
                }else{
                    hasNextPage = NO;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [_tableView reloadData];
                [_tableView.infiniteScrollingView stopAnimating];
                [_tableView setTableHeaderView:nil];
                [_tableView setShowsPullToRefresh:YES];
                [_tableView.pullToRefreshView stopAnimating];
                if (!hasNextPage) {
                    [_tableView setShowsInfiniteScrolling:NO];
                }else{
                    [_tableView setShowsInfiniteScrolling:YES];
                }
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
        
    });
    
}

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithBeeUIGirdCellClass:[UserCell class]];
    cell.gridCell.cellData = [_datas objectAtIndex:indexPath.row];
    UserCell *userCell = (UserCell *)cell.gridCell;
    userCell.delegate  = self;
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}


#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UserCell sizeInBound:CGSizeMake(320, 60) forData:[_datas objectAtIndex:indexPath.row]].height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserViewController *vlc = [[UserViewController alloc]initWithNibName:@"UserViewController" bundle:nil];
    JCUser *user = [_datas objectAtIndex:indexPath.row];
    vlc.user = user;
    [self.navigationController pushViewController:vlc animated:YES];
    
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UserCellDelegate
-(void) followUser:(JCUser *)user;{
    if ([ShareVaule shareInstance].userId) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                NSString *userid = [ShareVaule shareInstance].userId;
                BOOL flag = (user.followState == 1 || user.followState == 3 );
                [proxy follow:userid userId:user.id_ flag:!flag];
                if (flag) {
                    user.followState = user.followState - 1;
                }else{
                    user.followState = user.followState + 1;
                }
                if (flag) {
                    user.followerCount --;
                    [ShareVaule shareInstance].user.followingCount --;
                }else{
                    user.followerCount ++;
                    [ShareVaule shareInstance].user.followingCount ++;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (flag) {
                        [SVProgressHUD showSuccessWithStatus:@"已取消关注"];
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"已关注"];
                    }
                    [self postNotification:NOTIFICATION_FOLLOWSTATECHANGE];
                    [self reloadDatas];
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
            
        });
    }else{
        LoginViewController *vlc = [[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil]autorelease];
        UINavigationController *navController = [[[UINavigationController alloc]initWithRootViewController:vlc]autorelease];
        [self presentViewController:navController animated:YES completion:nil];
    }
    
}


@end
