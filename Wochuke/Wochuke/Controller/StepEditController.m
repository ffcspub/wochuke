//
//  StepEditController.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "StepEditController.h"

#import "GuideInfoView.h"
#import "SuppliesView.h"
#import "StepView.h"
#import "SVProgressHUD.h"
#import "ICETool.h"
#import "GuideCreateViewController.h"


@interface StepEditController (){
    NSInteger _lastDeleteItemIndexAsked;
}

@end

@implementation StepEditController

//返回
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//发布
- (IBAction)pulishAction:(id)sender {
    
    
}

-(void)setGuide:(JCGuide *)guide{
    if (_guide) {
        [_guide release];
        _guide = nil;
    }
    _guide = [guide retain];
    NSMutableArray *steps = [[NSMutableArray alloc]init];
    NSMutableArray *supplies = [[NSMutableArray alloc]init];
    JCGuide * guideInfo = [guide copy];
    [ShareVaule shareInstance].editGuideEx = [[JCGuideEx guideEx:guideInfo supplies:supplies steps:steps]retain];
    [[ShareVaule shareInstance].stepImageDic removeAllObjects];
    [self loadDetail];
}

-(void)loadDetail{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
        @try {
            JCGuideDetail *detail = [proxy getGuideDetail:[ShareVaule shareInstance].user.id_ guideId:_guide.id_];
            if (detail) {
                [(NSMutableArray *)[ShareVaule shareInstance].editGuideEx.steps addObjectsFromArray:detail.steps];
                [(NSMutableArray *)[ShareVaule shareInstance].editGuideEx.supplies addObjectsFromArray:detail.supplies];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [_girdView reloadData];
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
    NSInteger spacing = 5;
//    _girdView.enableEditOnLongPress = YES;
    _girdView.dataSource = self;
    _girdView.style = GMGridViewStylePush;
    _girdView.disableEditOnEmptySpaceTap = YES;
    _girdView.itemSpacing = spacing;
    _girdView.actionDelegate = self;
    _girdView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    _girdView.centerGrid = NO;
    _girdView.sortingDelegate = self;
//    [_girdView reloadData];
    // Do any additional setup after loading the view from its nib.
}

-(void)dealloc{
    [[ShareVaule shareInstance].editGuideEx release];
    [[ShareVaule shareInstance].stepImageDic removeAllObjects];
    [super dealloc];
}

-(void)viewDidUnload{
    _girdView = nil;
    [ShareVaule shareInstance].editGuideEx = nil;
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_girdView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -GMGridViewSortingDelegate
- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex;{
    NSLog(@"%d<-->%d",oldIndex,newIndex);
    [[ShareVaule shareInstance] moveStepFromIndex:oldIndex-2 toIndex:newIndex-2];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2;{
    [((NSMutableArray *)[ShareVaule shareInstance].editGuideEx.steps) exchangeObjectAtIndex:index1-2 withObjectAtIndex:index2 -2];
}

- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return index>1; //index % 2 == 0;
}


#pragma mark - GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position;{
    GuideCreateViewController *guideCreateViewController = [[[GuideCreateViewController alloc]initWithNibName:@"GuideCreateViewController" bundle:nil]autorelease];
    [self.navigationController pushViewController:guideCreateViewController animated:YES];
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [guideCreateViewController scrollToIndex:position];
    });
}

-(BOOL)GMGridView:(GMGridView *)gridView shouldAllowActionForItemAtIndex:(NSInteger)index{
    if (index == 0) {
        return NO;
    }else if(index == 1 && [ShareVaule shareInstance].editGuideEx.supplies.count >0){
        return NO;
    }
    return YES;
}


- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要删除该步骤?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    
    [alert show];
    
    _lastDeleteItemIndexAsked = index;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSMutableArray *steps = (NSMutableArray *)[ShareVaule shareInstance].editGuideEx.steps;
        
        JCStep *oldStep = [steps objectAtIndex:_lastDeleteItemIndexAsked -2];
        [[ShareVaule shareInstance]removeStep:oldStep];
        [_girdView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
    }
}

#pragma mark -GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [ShareVaule shareInstance].editGuideEx.steps.count + 2;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(100, 130);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //NSLog(@"Creating view indx %d", index);
    
//    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = nil;
    if (index == 0) {
       cell = [gridView dequeueReusableCellWithIdentifier:@"GUIDEINFOCELL"];
        if (!cell)
        {
            cell = [[[GMGridViewCell alloc] init]autorelease];
            cell.reuseIdentifier = @"GUIDEINFOCELL";
            cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
            cell.deleteButtonOffset = CGPointMake(-15, -15);
            GuideInfoMinView *view = [[GuideInfoMinView alloc]init];
            view.guide = _guide;
            cell.contentView = view;
        }
    }else if(index == 1){
        cell = [gridView dequeueReusableCellWithIdentifier:@"SUPPLIESCELL"];
        if (!cell)
        {
            cell = [[[GMGridViewCell alloc] init]autorelease];
            cell.reuseIdentifier = @"SUPPLIESCELL";
            cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
            cell.deleteButtonOffset = CGPointMake(-15, -15);
            SuppliesMinView *view = [[[SuppliesMinView alloc]init]autorelease];
            view.list = [ShareVaule shareInstance].editGuideEx.supplies;
            cell.contentView = view;
        }
    }else{
        cell = [gridView dequeueReusableCellWithIdentifier:@"STEPCELL"];
        if (!cell)
        {
            cell = [[[GMGridViewCell alloc] init]autorelease];
            cell.reuseIdentifier = @"STEPCELL";
            cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
            cell.deleteButtonOffset = CGPointMake(-15, -15);
            StepMinView *view = [[StepMinView alloc]init];
            cell.contentView = view;
        }
        StepView *view = (StepView *)cell.contentView;
        int indextemp = index - 2;
        view.step = [[ShareVaule shareInstance].editGuideEx.steps objectAtIndex:indextemp];
    }
    return cell;
}


@end
