//
//  CatoryViewController.m
//  Wochuke
//
//  Created by he songhang on 13-6-26.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "CatoryViewController.h"
#import <Guide.h>
#import "ICETool.h"
#import "SVProgressHUD.h"
#import "SVPullToRefresh.h"
#import "GuideInfoView.h"
#import "UITableView+BeeUIGirdCell.h"
#import "GuideViewController.h"

@interface CatoryViewController (){
    JCTypeFilter filter;
    NSMutableArray * _datas;
    int pageIndex;
    int pageSize;
    NSString *typeId;
    BOOL hasNextPage;
}

@end

@implementation CatoryViewController

-(void)reloadDatas{
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    pageIndex = 0;
    [self loadDatas];
}

-(void)loadDatas{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
        @try {
            JCMutableGuideList * list = [proxy getGuideListByType:typeId filter:filter timestamp:nil pageIdx:pageIndex pageSize:pageSize];
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
    filter = JCFEATURED;
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
    
    [self loadDatas];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [_datas release];
    [typeId release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (IBAction)catoryChangAction:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
    filter = control.selectedSegmentIndex;
    [self reloadDatas];
}

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithBeeUIGirdCellClass:[GuideInfoCell class]];
    cell.gridCell.cellData = [_datas objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [GuideInfoCell sizeInBound:CGSizeMake(320, 250) forData:[_datas objectAtIndex:indexPath.row]].height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;{
    GuideViewController *vlc =[[[GuideViewController alloc]initWithNibName:@"GuideViewController" bundle:nil]autorelease];
    JCGuide *guide = [_datas objectAtIndex:indexPath.row];
    vlc.guide = guide;
    [self.navigationController pushViewController:vlc animated:YES];
    
}


@end
