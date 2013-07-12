//
//  ActInfoViewController.m
//  Wochuke
//
//  Created by he songhang on 13-7-3.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "ActInfoViewController.h"
#import "SVProgressHUD.h"
#import "ICETool.h"
#import "SVPullToRefresh.h"
#import "UITableView+BeeUIGirdCell.h"
#import "UIImageView+WebCache.h"
#import "GuideViewController.h"
#import "CreateGuideViewController.h"
#import "LoginViewController.h"

@interface ActInfoCell : BeeUIGridCell{
    UIImageView *iv_heard;
    UILabel *lb_message;
    UILabel *lb_comment;
    UILabel *lb_time;
}
@end

@implementation ActInfoCell

+ (CGSize)sizeInBound:(CGSize)bound forData:(NSObject *)data
{
	return bound;
}

- (void)layoutInBound:(CGSize)bound forCell:(BeeUIGridCell *)cell
{
    iv_heard.frame = CGRectMake(5, 5, bound.height - 10, bound.height -10);
    lb_message.frame = CGRectMake(5 + bound.height - 10 + 10, 5, bound.width/2 + 20, 30);
    lb_comment.frame = CGRectMake(5 + bound.height - 10 + 10, bound.height - 25 , bound.width/2 , 20);
    lb_time.frame = CGRectMake(bound.width - 70-10,bound.height - 25,70,20);
}

- (void)dataDidChanged
{
    if (self.cellData) {
        JCActInfo *_info = self.cellData;
        [iv_heard setImageWithURL:[NSURL URLWithString:_info.userAvatar.url] placeholderImage:[UIImage imageNamed:@"ic_user_top"]];
        NSString *actionname = nil;
        switch (_info.actCode) {
            case 0:
                actionname = @"发布";
                break;
            case 1:
                actionname = @"查看";
                break;
            case 2:
                actionname = @"收藏";
                break;
            case 3:
                actionname = @"评论";
                break;
            default:
                break;
        }
        lb_message.text = [NSString stringWithFormat:@"%@%@了%@",_info.userName,actionname,_info.guideInfo.title];
        lb_comment.text = _info.actSummary;

        lb_time.text = [_info.timestamp substringWithRange:NSMakeRange(5, 11)];
    }
}

- (void)load
{
    iv_heard = [[[UIImageView alloc]init]autorelease];
    
    lb_message = [[[UILabel alloc]init]autorelease];
    lb_message.font = [UIFont boldSystemFontOfSize:13];
    lb_message.backgroundColor = [UIColor clearColor];
    lb_message.textColor = [UIColor darkTextColor];
    lb_message.textAlignment = UITextAlignmentLeft;
    lb_message.numberOfLines = 2;
    
    
    lb_comment = [[[UILabel alloc]init]autorelease];
    lb_comment.font = [UIFont systemFontOfSize:12];
    lb_comment.backgroundColor = [UIColor clearColor];
    lb_comment.textColor = [UIColor darkTextColor];
    lb_comment.textAlignment = UITextAlignmentLeft;
    
    lb_time = [[[UILabel alloc]init]autorelease];
    lb_time.font = [UIFont systemFontOfSize:11];
    lb_time.backgroundColor = [UIColor clearColor];
    lb_time.textColor = [UIColor darkTextColor];
    lb_time.textAlignment = UITextAlignmentRight;
    
    
    [self addSubview:iv_heard];
    [self addSubview:lb_message];
    [self addSubview:lb_comment];
    [self addSubview:lb_time];
}


@end


@interface ActInfoViewController (){
    NSMutableArray * _datas;
    int pageIndex;
    int pageSize;
    BOOL hasNextPage;
    int filterCode;
}

@end

@implementation ActInfoViewController


#pragma mark -DataLoad

-(void)reloadDatas{
    if (_datas.count>0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    pageIndex = 0;
    [self loadDatas];
}

-(void)loadDatas{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
        @try {
            JCMutableGuideList * list = [proxy getActInfoList:[ShareVaule shareInstance].user.id_ filterCode:filterCode timestamp:nil pageIdx:pageIndex pageSize:pageSize];
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
    filterCode = 0;
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

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)typeChangAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 1 && [ShareVaule shareInstance].user.id_.length == 0) {
        LoginViewController *vlc = [[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil]autorelease];
        UINavigationController *navController = [[[UINavigationController alloc]initWithRootViewController:vlc]autorelease];
        navController.navigationBarHidden = YES;
        [self presentViewController:navController animated:YES completion:nil];
        
        return;
    }
    filterCode = btn.tag;
    [_btn_new setBackgroundImage:[UIImage imageNamed:@"btn_classify_top_1"] forState:UIControlStateNormal];
    [_btn_flow setBackgroundImage:[UIImage imageNamed:@"btn_classify_top_2"] forState:UIControlStateNormal];
    if (filterCode == 0) {
        [_btn_new setBackgroundImage:[UIImage imageNamed:@"btn_classify_top_1_pressed"] forState:UIControlStateNormal];
    }else{
        [_btn_flow setBackgroundImage:[UIImage imageNamed:@"btn_classify_top_2_pressed"] forState:UIControlStateNormal];
    }
    [self reloadDatas];
}

- (IBAction)ceateAction:(id)sender {
    if ([ShareVaule shareInstance].user.id_) {
        CreateGuideViewController *vlc = [[[CreateGuideViewController alloc]initWithNibName:@"CreateGuideViewController" bundle:nil]autorelease];
        UINavigationController *navController = [[[UINavigationController alloc]initWithRootViewController:vlc]autorelease];
        navController.navigationBarHidden = YES;
        [self presentViewController:navController animated:YES completion:^{
            
        }];
    }else{
        LoginViewController *vlc = [[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil]autorelease];
        
        UINavigationController *navController = [[[ UINavigationController alloc]initWithRootViewController:vlc]autorelease];
        navController.navigationBarHidden = YES;
        [self presentModalViewController:navController animated:YES];
    }
    
}

- (void)dealloc {
    [_tableView release];
    [_btn_new release];
    [_btn_flow release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setBtn_new:nil];
    [self setBtn_flow:nil];
    [super viewDidUnload];
}


#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithBeeUIGirdCellClass:[ActInfoCell class]];
    cell.gridCell.cellData = [_datas objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ActInfoCell sizeInBound:CGSizeMake(320, 60) forData:[_datas objectAtIndex:indexPath.row]].height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GuideViewController *vlc = [[GuideViewController alloc]initWithNibName:@"GuideViewController" bundle:nil];
    JCActInfo *info = [_datas objectAtIndex:indexPath.row];
    vlc.guide = info.guideInfo;
    [self.navigationController pushViewController:vlc animated:YES];
    [vlc release];
}


@end
