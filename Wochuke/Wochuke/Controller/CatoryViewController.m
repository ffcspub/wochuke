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

@interface CatoryCell : BeeUIGridCell{
    UIImageView *imageView;
    UILabel *lb_title;
    UIView *line;
}

@end

@implementation CatoryCell

+ (CGSize)sizeInBound:(CGSize)bound forData:(NSObject *)data
{
	return bound;
}

- (void)layoutInBound:(CGSize)bound forCell:(BeeUIGridCell *)cell
{
    imageView.frame = CGRectMake(5, 5, bound.height - 10, bound.height -10);
    lb_title.frame = CGRectMake(5 + bound.height - 10 + 10, 5, bound.width - (bound.height -10) - 10, bound.height -10);
    line.frame = CGRectMake(0, bound.height - 0.6, bound.width, 0.6);
}

- (void)dataDidChanged
{
    if (self.cellData) {
        JCType *type = self.cellData;
        [imageView setImageWithURL:[NSURL URLWithString:type.cover.url]];
        lb_title.text = type.name;
    }
}

- (void)load
{
    imageView = [[[UIImageView alloc]init]autorelease];
    
    lb_title = [[[UILabel alloc]init]autorelease];
    lb_title.font = [UIFont boldSystemFontOfSize:13];
    lb_title.backgroundColor = [UIColor clearColor];
    lb_title.textColor = [UIColor darkTextColor];
    lb_title.textAlignment = UITextAlignmentLeft;
    lb_title.numberOfLines = 2;
    
    line = [[[UIView alloc]init]autorelease];
    line.backgroundColor = [UIColor grayColor];
    
    [self addSubview:imageView];
    [self addSubview:lb_title];
    [self addSubview:line];
}


@end


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
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    pageIndex = 0;
    [self loadDatas];
}

-(void)loadTopics{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
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
        }
        @catch (ICEException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"服务访问异常"];
            });
        }
        
        
    });
}


-(void)loadDatas{
    if (filter == 0) {
        [self loadTypes];
        _tableView.backgroundColor = [UIColor whiteColor];
    }else{
        [self loadGuides];
        _tableView.backgroundColor = [UIColor clearColor];
    }
}

-(void)loadTypes;{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
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
        }
        @catch (ICEException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"服务访问异常"];
            });
        }
        
        
    });
}



-(void)loadGuides{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
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
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_classify"]]];
//    [_navBar setBackgroundImage:[UIImage imageNamed:@"bg_classify_top"] forBarMetrics:UIBarMetricsDefault];
    
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadDatas];
    [self loadTopics];
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
    [_navBar release];
    [_btn_catory release];
    [_btn_hot release];
    [_btn_news release];
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
    [self setNavBar:nil];
    [self setBtn_catory:nil];
    [self setBtn_hot:nil];
    [self setBtn_news:nil];
    [super viewDidUnload];
}

-(void)btnImageSet{
    [_btn_catory setBackgroundImage:[UIImage imageNamed:@"btn_classify_top_1"] forState:UIControlStateNormal];
    [_btn_hot setBackgroundImage:[UIImage imageNamed:@"btn_classify_top_2"] forState:UIControlStateNormal];
    [_btn_news setBackgroundImage:[UIImage imageNamed:@"btn_classify_top_3"] forState:UIControlStateNormal];
    if (filter == 0) {
        [_btn_catory setBackgroundImage:[UIImage imageNamed:@"btn_classify_top_1_pressed"] forState:UIControlStateNormal];
    }else if(filter == 1){
         [_btn_hot setBackgroundImage:[UIImage imageNamed:@"btn_classify_top_2_pressed"] forState:UIControlStateNormal];
    }else if(filter == 2){
        [_btn_news setBackgroundImage:[UIImage imageNamed:@"btn_classify_top_3_pressed"] forState:UIControlStateNormal];
    }
}

- (IBAction)catoryChangAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    filter = btn.tag;
    [self btnImageSet];
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
        cell = [tableView dequeueReusableCellWithBeeUIGirdCellClass:[CatoryCell class]];
        cell.gridCell.cellData = [_types objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell = [tableView dequeueReusableCellWithBeeUIGirdCellClass:[GuideInfoCell class]];
        cell.gridCell.cellData = [_datas objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (filter == 0) return 60;
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
