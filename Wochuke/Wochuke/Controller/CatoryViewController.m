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
#import "KxMenu.h"
#import "UIImageView+WebCache.h"
#import "SearchViewController.h"
#import "GuideListViewController.h"

@interface CatoryViewController (){
    int filter;
    NSMutableArray * _datas;
    NSMutableArray * _types;
    NSMutableArray * _topics;
    int pageIndex;
    int pageSize;
    NSString *typeId;
    BOOL hasNextPage;
}

-(void)loadDatas;
-(void)loadTypes;

@end

@implementation CatoryViewController

////选择分类
//-(void)menuItemSelected:(id)sender{
//    KxMenuItem *item = (KxMenuItem *)sender;
//    int index = item.tag;
//    NSString *_typeId = nil;
//    if (index == 0) {
//        _typeId = nil;
//        [_btn_type setTitle:@"全部分类" forState:UIControlStateNormal];
//    }else{
//        JCType *type = [_types objectAtIndex:index-1];
//        _typeId = type.id_;
//        [_btn_type setTitle:type.name forState:UIControlStateNormal];
//    }
//    if ([typeId isEqual:_typeId] || _typeId==typeId) {
//        return;
//    }
//    if(typeId){
//        [typeId release];
//        typeId = nil;
//    }
//    typeId = [_typeId retain];
//    [self reloadDatas];
//}
//

//-(void)showTypes{
//    NSMutableArray *menuItems = [NSMutableArray array];
//    
//    KxMenuItem *item = [KxMenuItem menuItem:@"全部分类"
//                                      image:nil
//                                     target:self
//                                     action:@selector(menuItemSelected:)];
//    item.tag = 0;
//    if (typeId == nil) {
//        item.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
//    }
//    [menuItems addObject:item ];
//    
//    int i = 1;
//    for (JCType *type in _types) {
//        KxMenuItem *item = [KxMenuItem menuItem:type.name
//                                          image:nil
//                                         target:self
//                                         action:@selector(menuItemSelected:)];
//        item.tag = i;
//        
//        if ([type.id_ isEqual:typeId]) {
//           item.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
//        }
//        [menuItems addObject:item ];
//        i++;
//    }
//    [KxMenu showMenuInView:self.view
//                  fromRect:_btn_type.frame
//                 menuItems:menuItems];
//    
//}

-(void)reloadDatas{
    if (_datas.count>0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    pageIndex = 0;
    [self loadDatas];
}

-(void)loadTopics{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
        @try {
            JCTopicList * list = [proxy getTopicList:nil];
            if (list.count>0) {
                [_topics removeAllObjects];
                [_topics addObjectsFromArray:list];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _pageControl.numberOfPages = list.count;
                    _pageControl.currentPage = 0;
                    CGSize size = [_pageControl sizeForNumberOfPages:list.count];
                    CGRect rect = _pageControl.frame;
                    rect.origin.x = _imageScrollView.frame.size.width - size.width - 10;
                    rect.size.width = size.width;
                    _pageControl.frame = rect;
                    _imageScrollView.autoScrollAble = YES;
                    [_imageScrollView reloadData];
                });
            }
       }@catch (ICEException *exception) {
            if ([exception isKindOfClass:[JCGuideException class]]) {
                JCGuideException *_exception = (JCGuideException *)exception;
                if (_exception.reason_) {
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [SVProgressHUD showErrorWithStatus:_exception.reason_];
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                    });
                }
            }else{
                
            }
        }
        @finally {
            
        }
        
    });
}


-(void)loadDatas{
    if (filter == 0) {
        [self loadTypes];
    }else{
        [self loadGuides];
    }
}

-(void)loadTypes;{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
        @try {
            JCTypeList * list = [proxy getTypeList:nil];
            if (list) {
                if (pageIndex == 0) {
                    [_types removeAllObjects];
                }
                if (list.count > 0) {
                    [_types addObjectsFromArray:list];
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
                [self.tableView setTableHeaderView:_topView];
                [_tableView reloadData];
                [self.tableView.infiniteScrollingView stopAnimating];
                [self.tableView setShowsPullToRefresh:NO];
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
                
            }
        }
        @finally {
            
        }
        
    });
}



-(void)loadGuides{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
        @try {
            JCMutableGuideList * list = [proxy getGuideListByType:nil filterCode:filter timestamp:nil pageIdx:pageIndex pageSize:pageSize];
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
                [self.tableView setTableHeaderView:nil];
                [self.tableView setShowsPullToRefresh:YES];
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

-(void)hideTopView{
    [UIView animateWithDuration:0.5 animations:^{
        _topView.frame = CGRectMake(_topView.frame.origin.x, -_topView.frame.size.height, _topView.frame.size.width, _topView.frame.size.height);
    } completion:^(BOOL finished) {
        [_topView setHidden:YES];
    }];
}

-(void)showTopView{
    [_topView setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^{
        _topView.frame = CGRectMake(_topView.frame.origin.x, 48, _topView.frame.size.width, _topView.frame.size.height);
    } completion:^(BOOL finished) {
//        [_topView setHidden:YES];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    filter = 0;
    pageSize = 20;
    _datas = [[NSMutableArray alloc]init];
    _types = [[NSMutableArray alloc]init];
    _topics = [[NSMutableArray alloc]init];
//    NSArray *array = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),KEY_TYPELIST]];
////    [[NSUserDefaults standardUserDefaults]arrayForKey:KEY_TYPELIST];
//    if (array) {
//        [_types addObjectsFromArray:array];
//    }else{
//        [self loadTypes];
//    }
    
        
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
    [self loadTopics];
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
    [_types release];
    [_topics release];
    [typeId release];
    [_imageScrollView release];
    [_pageControl release];
    [_lb_topic release];
    [_topView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    _datas = nil;
    _types = nil;
    typeId = nil;
    [self setImageScrollView:nil];
    [self setPageControl:nil];
    [self setLb_topic:nil];
    [self setTopView:nil];
    [super viewDidUnload];
}

- (IBAction)catoryChangAction:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
    filter = control.selectedSegmentIndex;
    [self reloadDatas];
}

- (IBAction)searchAction:(id)sender {
    SearchViewController *vlc = [[SearchViewController alloc]initWithNibName:@"SearchViewController" bundle:nil];
    [self.navigationController pushViewController:vlc animated:YES];
    [vlc release];
    
}

-(void)handleSingleTapFrom:(UIGestureRecognizer *)gestureRecognizer{
    int tag = gestureRecognizer.view.tag;
    JCTopic *topic = [_topics objectAtIndex:tag];
    GuideListViewController *vlc = [[GuideListViewController alloc]initWithNibName:@"GuideListViewController" bundle:nil];
    vlc.topic = topic;
    [self.navigationController pushViewController:vlc animated:YES];
    [vlc release];
}


//- (IBAction)typeChooseAction:(id)sender {
//    [self showTypes];
//}

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (filter == 0) {
        return _types.count;
    }
    return [_datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    if (filter == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TYPECELL"];
        if (!cell) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TYPECELL"]autorelease];
            cell.textLabel.font = [UIFont systemFontOfSize:13];
            cell.textLabel.textColor = [UIColor darkTextColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        JCType *type = [_types objectAtIndex:indexPath.row];
        [cell.imageView setImageWithURL:[NSURL URLWithString:type.cover.url]];
        cell.textLabel.text = type.name;
    }else{
        cell = [tableView dequeueReusableCellWithBeeUIGirdCellClass:[GuideInfoCell class]];
        cell.gridCell.cellData = [_datas objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (filter == 0) return 46;
    return [GuideInfoCell sizeInBound:CGSizeMake(320, 250) forData:[_datas objectAtIndex:indexPath.row]].height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (filter == 0){
        GuideListViewController *vlc = [[GuideListViewController alloc]initWithNibName:@"GuideListViewController" bundle:nil];
        vlc.type = [_types objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:vlc animated:YES];
        [vlc release];
    }else{
        GuideViewController *vlc =[[[GuideViewController alloc]initWithNibName:@"GuideViewController" bundle:nil]autorelease];
        JCGuide *guide = [_datas objectAtIndex:indexPath.row];
        vlc.guide = guide;
        [self.navigationController pushViewController:vlc animated:YES];
    }
}


#pragma mark - CycleScrollViewDelegate
- (void)cycleScrollView:(CycleScrollView *)cycleScrollView didScrollView:(int)index;{
    _pageControl.currentPage = index;
    JCTopic *topic = [_topics objectAtIndex:index];
    _lb_topic.text = topic.name;
}

#pragma mark - CycleScrollViewDataSource
- (UIView *)cycleScrollView:(CycleScrollView *)cycleScrollView viewAtPage:(NSInteger)page{
    
    JCTopic *topic = [_topics objectAtIndex:page];
    UIImageView *imageView = [[[MyWebImgView alloc]initWithFrame:CGRectMake(0, 0, cycleScrollView.frame.size.width, cycleScrollView.frame.size.height)]autorelease];
    imageView.tag = page;
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView setImageWithURL:[NSURL URLWithString:topic.cover.url]];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer* singleRecognizer;  
    singleRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)]autorelease];
    singleRecognizer.numberOfTapsRequired = 1; // 单击  
    [imageView addGestureRecognizer:singleRecognizer]; 
     return imageView;
}

- (NSInteger)numberOfViewsInCycleScrollView:(CycleScrollView *)cycleScrollView{
    return _topics.count;
}

@end
