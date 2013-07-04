//
//  GuideListViewController.m
//  Wochuke
//
//  Created by he songhang on 13-7-3.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "GuideListViewController.h"
#import "GuideViewController.h"
#import "GuideInfoView.h"
#import "UITableView+BeeUIGirdCell.h"
#import "ICETool.h"
#import "SVProgressHUD.h"
#import "SVPullToRefresh.h"

@interface GuideListViewController (){
    int filter;
    NSMutableArray * _datas;
    int pageIndex;
    int pageSize;
    BOOL hasNextPage;
}

-(void)loadDatas;

@end

@implementation GuideListViewController

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
    NSMutableArray *array = [NSMutableArray array];
    if (_type) {
        UINavigationItem *item = [[[UINavigationItem alloc]initWithTitle:_type.name]autorelease];
        item.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(backAction:)];
        [array addObject:item];
        
    }else if(_topic){
        UINavigationItem *item = [[[UINavigationItem alloc]initWithTitle:_topic.name]autorelease];
        item.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(backAction:)];
        [array addObject:item];
    }
    [_navBar setItems:array];
    
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

#pragma mark -DataLoad

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
            JCMutableGuideList * list = nil;
            if (_type) {
                list = [proxy getGuideListByType:_type.id_ filterCode:filter timestamp:nil pageIdx:pageIndex pageSize:pageSize];
            }else if (_topic){
                list = [proxy getGuideListByTopic:_topic.id_ timestamp:nil pageIdx:pageIndex pageSize:pageSize];
            }
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

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithBeeUIGirdCellClass:[GuideInfoCell class]];
    cell.gridCell.cellData = [_datas objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [GuideInfoCell sizeInBound:CGSizeMake(320, 250) forData:[_datas objectAtIndex:indexPath.row]].height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GuideViewController *vlc =[[[GuideViewController alloc]initWithNibName:@"GuideViewController" bundle:nil]autorelease];
    JCGuide *guide = [_datas objectAtIndex:indexPath.row];
    vlc.guide = guide;
    [self.navigationController pushViewController:vlc animated:YES];
    
}

- (void)dealloc {
    [_navBar release];
    [_tableView release];
    [_datas release];
    [_type release];
    [_topic release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setNavBar:nil];
    [self setTableView:nil];
    [self setType:nil];
    [self setTopic:nil];
    [super viewDidUnload];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
