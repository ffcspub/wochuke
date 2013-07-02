//
//  GuideViewController.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "GuideCreateViewController.h"
#import <Ice/Ice.h>
#import "ICETool.h"
#import "SVProgressHUD.h"
#import "GuideInfoView.h"
#import "SuppliesView.h"
#import "StepView.h"
#import "StepPreviewController.h"

@interface GuideCreateViewController (){
    JCGuideDetail *_detail;
}

@end

@implementation GuideCreateViewController


-(void)setGuide:(JCGuide *)guide{
    if (_guide) {
        [_guide release];
        _guide = nil;
    }
    _guide = [guide retain];
    [ShareVaule shareInstance].editGuide = [guide copy];
}

-(void)loadDetail{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
        @try {
            JCGuideDetail *detail = [proxy getGuideDetail:_guide.id_ userId:nil];
            if (detail) {
                _detail = [detail retain];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
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
    _pagedFlowView.delegate = self;
    _pagedFlowView.dataSource = self;
    _pagedFlowView.minimumPageAlpha = 0.3;
    _pagedFlowView.minimumPageScale = 0.9;
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
        [_pagedFlowView scrollToPage:[index integerValue]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_pagedFlowView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setPagedFlowView:nil];
    [super viewDidUnload];
}

- (IBAction)popAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showPreviewAction:(id)sender {
    StepPreviewController *vlc = [[[StepPreviewController alloc]initWithNibName:@"StepPreviewController" bundle:nil]autorelease];
    
//    StepEditController *vlc = [[StepEditController alloc]initWithNibName:@"StepEditController" bundle:nil];
    vlc.guide = _guide;
    vlc.detail = _detail;
    [self.navigationController pushViewController:vlc animated:YES];
}


#pragma mark -PagedFlowViewDelegate
- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView;{
    return  CGSizeMake(flowView.frame.size.width - 30, flowView.frame.size.height - 10);
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
- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index;{
    if (index == 0) {
        GuideEditView *view = (GuideEditView *)[flowView dequeueReusableCellWithClass:[GuideEditView class]];
        if (!view) {
            view = [[[GuideEditView alloc]init]autorelease];
        }
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
        return view;
    }
    return nil;
}

@end
