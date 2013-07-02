//
//  SearchViewController.m
//  Wochuke
//
//  Created by he songhang on 13-6-26.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "SearchViewController.h"
#import <Guide.h>
#import "ICETool.h"
#import "SVProgressHUD.h"
#import "SVPullToRefresh.h"
#import "GuideInfoView.h"
#import "UITableView+BeeUIGirdCell.h"
#import "GuideViewController.h"
#import "UIKeyboardViewController.h"

#define BTN_PADDING 20

@interface SearchViewController (){
    NSMutableArray *_hotWords;
    UITableView *_tableView;
    NSString *_word;
    
    NSMutableArray * _datas;
    int pageIndex;
    int pageSize;
    BOOL hasNextPage;
    UIKeyboardViewController *keyBoardController;
}
@end

@implementation SearchViewController

-(void)addEmptyView{
    [self hideEmptyView];
    UIView *view = [[[UIView alloc]initWithFrame:_scrollView.frame]autorelease];
    view.backgroundColor = [UIColor lightGrayColor];
    view.tag = 1909;
    UILabel *lable = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width , _scrollView.frame.size.height)]autorelease];
    lable.font = [UIFont systemFontOfSize:21];
    lable.backgroundColor = [UIColor clearColor];
    lable.textColor = [UIColor grayColor];
    lable.textAlignment = UITextAlignmentCenter;
    lable.text = @"没有相关的内容";
    [view addSubview:lable];
    [self.view addSubview:view];
}

-(void)hideEmptyView{
    UIView *view = [self.view viewWithTag:1909];
    if (view) {
        [view removeFromSuperview];
    }
}

-(void)reloadDatas{
    if (_datas.count > 0) {
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
            JCMutableGuideList * list = [proxy getGuideListByKeyword:nil keyword:_word pageIdx:pageIndex pageSize:pageSize];
            if (list) {
                if (pageIndex == 0) {
                    [_datas removeAllObjects];
                    if (list.count == 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self addEmptyView];
                        });
                    }
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
                [_tableView.infiniteScrollingView stopAnimating];
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


-(void)searchDatas{
    [_searchBar resignFirstResponder];
    [self hideEmptyView];
    if (!_word) {
        [self.view bringSubviewToFront:_scrollView];
        return;
    }else{
        [self.view bringSubviewToFront:_tableView];
        [self reloadDatas];
    }
}

-(void)searchBtnClicked:(id)sender{
    UIButton *btn = (UIButton *)sender;
    int tag = btn.tag;
    NSString *word = [_hotWords objectAtIndex:tag];
    if (_word) {
        [_word release];
        _word = nil;
    }
    _word = [word retain];
    _searchBar.text = _word;
    [self searchDatas];
}

-(void)addHotWordBtns{
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    CGFloat x_beging = BTN_PADDING;
    CGFloat y_begin = BTN_PADDING;
    CGFloat MAX_WIDTH = 300;
    int i = 0;
    for(NSString *word in _hotWords){
        UIButton *btn = [[UIButton alloc]init];
        btn.backgroundColor = [UIColor grayColor];
        btn.titleLabel.font =[UIFont boldSystemFontOfSize:17];
        CGSize theStringSize = [word sizeWithFont:[UIFont boldSystemFontOfSize:17]];
        theStringSize = CGSizeMake(theStringSize.width + BTN_PADDING, theStringSize.height + BTN_PADDING);
        if ((x_beging + theStringSize.width) > MAX_WIDTH) {
            x_beging = BTN_PADDING;
            y_begin += (theStringSize.height + BTN_PADDING);
        }
        btn.frame = CGRectMake(x_beging, y_begin, theStringSize.width, theStringSize.height);
        x_beging += (theStringSize.width + BTN_PADDING);
        [btn setTitle:word forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(searchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:btn];
        [btn release];
        btn = nil;
        i++;
    }
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, y_begin);

}

-(void)loadHotWords{
    if (_hotWords.count == 0) {
        [SVProgressHUD show];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
        @try {
            NSMutableArray *array = [proxy getHotWordList];
            [SVProgressHUD dismiss];
            if (_hotWords.count > 0) {
                [[NSUserDefaults standardUserDefaults]setObject:array forKey:@"HotWordList"];
                [_hotWords removeAllObjects];
                [_hotWords addObjectsFromArray:array];
                [self addHotWordBtns];
            }
        }
        @catch (ICEException *exception) {
            if ([exception isKindOfClass:[JCGuideException class]]) {
                JCGuideException *_exception = (JCGuideException *)exception;
                if (_exception.reason_) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (_hotWords.count == 0) {
                            [SVProgressHUD showErrorWithStatus:_exception.reason_];
                        }else{
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:_exception.reason_ delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            [alert show];
                            [alert release];
                        }
                        
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (_hotWords.count == 0) {
                            [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                        }else{
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:ERROR_MESSAGE delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            [alert show];
                            [alert release];
                        }
                    });
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_hotWords.count == 0) {
                        [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:ERROR_MESSAGE delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                        [alert show];
                        [alert release];
                    }
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

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	keyBoardController=[[UIKeyboardViewController alloc] initWithControllerDelegate:self];
	[keyBoardController addToolbarToKeyboard];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _hotWords = [[NSMutableArray alloc]init];
    _tableView = [[UITableView alloc]initWithFrame:_scrollView.frame];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView addInfiniteScrollingWithActionHandler:^{
        [self loadDatas];
    }];
    [_tableView addPullToRefreshWithActionHandler:^{
        [self reloadDatas];
    }];
    
    [_tableView.pullToRefreshView setTitle:@"松开刷新" forState:SVPullToRefreshStateAll];
    [_tableView.pullToRefreshView setTitle:@"下拉刷新" forState:SVPullToRefreshStateTriggered];
    [_tableView.pullToRefreshView setTitle:@"正在加载" forState:SVPullToRefreshStateLoading];

    [self.view addSubview:_tableView];
    
    
    
    NSArray *array = [[NSUserDefaults standardUserDefaults]arrayForKey:@"HotWordList"];
    if (array) {
        [_hotWords addObjectsFromArray:array];
        [self addHotWordBtns];
    }
    [self.view bringSubviewToFront:_scrollView];
    [self loadHotWords];
    _datas = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_scrollView release];
    [_hotWords release];
    [_datas release];
    [_tableView release];
    [_word release];
    [_searchBar release];
    [keyBoardController release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
}

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithBeeUIGirdCellClass:[GuideInfoMinCell class]];
    cell.gridCell.cellData = [_datas objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [GuideInfoMinCell sizeInBound:CGSizeMake(320, 70) forData:[_datas objectAtIndex:indexPath.row]].height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;{
    GuideViewController *vlc =[[[GuideViewController alloc]initWithNibName:@"GuideViewController" bundle:nil]autorelease];
    JCGuide *guide = [_datas objectAtIndex:indexPath.row];
    vlc.guide = guide;
    [self.navigationController pushViewController:vlc animated:YES];
}

#pragma mark -UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar; {
    if (_word) {
        [_word release];
        _word = nil;
    }
    _word = [searchBar.text retain];
    [self searchDatas];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;{
    if (searchText.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view bringSubviewToFront:_scrollView];
        });
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;{
    [searchBar resignFirstResponder];
}

@end
