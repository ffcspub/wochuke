//
//  GuideViewController.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "CreateGuideViewController.h"
#import <Ice/Ice.h>
#import "ICETool.h"
#import "GuideInfoView.h"
#import "StepEditController.h"
#import "CreateStepViewController.h"

@interface CreateGuideViewController ()

@end

@implementation CreateGuideViewController

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
    
    JCGuide *guide = [JCGuide guide];
    guide.userId = [ShareVaule shareInstance].user.id_;
    guide.userName = [ShareVaule shareInstance].user.name;
    guide.userAvatar = [ShareVaule shareInstance].user.avatar;
    
    JCGuideEx *guideEx = [JCGuideEx guideEx:guide supplies:[NSMutableArray array] steps:[NSMutableArray array]];
    [ShareVaule shareInstance].editGuideEx = guideEx;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillUnload{
    [super viewWillUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%d",[[ShareVaule shareInstance].editGuideEx retainCount]);
    if ([ShareVaule shareInstance].editGuideEx) {
        [ShareVaule shareInstance].editGuideEx = nil;
    }
    if ([ShareVaule shareInstance].guideImage) {
        [ShareVaule shareInstance].guideImage = nil;
    }
    [[ShareVaule shareInstance].stepImageDic removeAllObjects];
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

- (IBAction)nextAction:(id)sender {
    if ([ShareVaule shareInstance].editGuideEx.guideInfo.title.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入指南名称" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else{
        StepEditController *vlc = [[StepEditController alloc]initWithNibName:@"StepEditController" bundle:nil];
        [self.navigationController pushViewController:vlc animated:YES];
        [vlc release];
    }
}


#pragma mark -PagedFlowViewDelegate
- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView;{
    return  CGSizeMake(flowView.frame.size.width - 30, flowView.frame.size.height - 10);
}

- (void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index;{
    
}

#pragma mark -PagedFlowViewDataSource
//返回显示View的个数
- (NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView{
    return 1;
}

//返回给某列使用的View
- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index;{
    if (index == 0) {
        GuideEditView *view = (GuideEditView *)[flowView dequeueReusableCellWithClass:[GuideEditView class]];
        if (!view) {
            view = [[[GuideEditView alloc]init]autorelease];
        }
        return view;
    }
    return nil;
}

@end
