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
#import "GuideEditViewController.h"
#import "CreateGuideViewController.h"
#import "CreateStepViewController.h"
#import "PublishViewController.h"
#import "StepPreviewController.h"


@interface StepEditController ()<UIActionSheetDelegate,GuideEditViewControllerDelegate>{
    NSInteger _lastDeleteItemIndexAsked;
    UINavigationController *guideEditViewNavigationController ;
    
}

@end

@implementation StepEditController

//返回
- (IBAction)backAction:(id)sender {
    if ([ShareVaule shareInstance].noChanged) {
        [self backAction];
    }else{
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"是否保存到草稿" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存" otherButtonTitles:@"不保存", nil];
        [sheet showInView:self.view];
        [sheet release];
    }
}


-(void)backAction{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


-(void)setGuide:(JCGuide *)guide{
    if (_guide) {
        [_guide release];
        _guide = nil;
    }
    _guide = [guide retain];
    NSMutableArray *steps = [[NSMutableArray alloc]init];
    NSMutableArray *supplies = [[NSMutableArray alloc]init];
    [ShareVaule shareInstance].editGuideEx = [JCGuideEx guideEx:_guide supplies:supplies steps:steps];
    [[ShareVaule shareInstance].stepImageDic removeAllObjects];
    [self loadDetail];
}

-(void)loadDetail{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCGuideDetail *detail = [proxy getGuideDetail:[ShareVaule shareInstance].user.id_ guideId:_guide.id_];
                if (detail) {
                    [(NSMutableArray *)[ShareVaule shareInstance].editGuideEx.steps addObjectsFromArray:detail.steps];
                    [(NSMutableArray *)[ShareVaule shareInstance].editGuideEx.supplies addObjectsFromArray:detail.supplies];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
//                    GuideEditViewController *guideEditViewController = [[[GuideEditViewController alloc]initWithNibName:@"GuideEditViewController" bundle:nil]autorelease];
//                    guideEditViewController.controllerDelegate = self;
//                    guideEditViewNavigationController = [[UINavigationController alloc]initWithRootViewController:guideEditViewController];
//                    guideEditViewNavigationController.navigationBarHidden = YES;
//                    guideEditViewNavigationController.view.hidden = YES;
//                    [guideEditViewNavigationController.view setFrame: [self.view bounds]];
//                    [self.view addSubview:guideEditViewNavigationController.view];
//                    [self.view sendSubviewToBack:guideEditViewNavigationController.view];
                    [guideEditViewNavigationController.topViewController viewWillAppear:YES];
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
    if (!_guide) {
        _guide = [[ShareVaule shareInstance].editGuideEx.guideInfo retain];
    }
    // Do any additional setup after loading the view from its nib.
    
    GuideEditViewController *guideEditViewController = [[[GuideEditViewController alloc]initWithNibName:@"GuideEditViewController" bundle:nil]autorelease];
    guideEditViewController.controllerDelegate = self;
    guideEditViewNavigationController = [[UINavigationController alloc]initWithRootViewController:guideEditViewController];
    guideEditViewNavigationController.navigationBarHidden = YES;
    guideEditViewNavigationController.view.hidden = YES;
    [guideEditViewNavigationController.view setFrame: [self.view bounds]];
    [self.view addSubview:guideEditViewNavigationController.view];
    [self.view sendSubviewToBack:guideEditViewNavigationController.view];
//    [btn_add setBackgroundImage:[[UIImage imageNamed:@"btn_orange_small"]resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)] forState:UIControlStateNormal];
//    [btn_add setBackgroundImage:[[UIImage imageNamed:@"btn_orange_small_press"]resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)] forState:UIControlStateHighlighted];
}

#pragma mark -GuideEditViewControllerDelegate
-(void) controllerWillHide;{
    [UIView animateWithDuration:0.3 animations:^{
        guideEditViewNavigationController.view.frame = CGRectMake(self.view.frame.size.width, 0, guideEditViewNavigationController.view.frame.size.width, guideEditViewNavigationController.view.frame.size.height);
    } completion:^(BOOL finished) {
        guideEditViewNavigationController.view.hidden = YES;
        [self.view sendSubviewToBack:guideEditViewNavigationController.view];
        [_girdView reloadData];
    }];
}

-(void)dealloc{
    [guideEditViewNavigationController release];
    guideEditViewNavigationController = nil;
    [ShareVaule shareInstance].noChanged = YES;
    [ShareVaule shareInstance].editGuideEx.steps = nil;
    [ShareVaule shareInstance].editGuideEx.supplies = nil;
    [ShareVaule shareInstance].editGuideEx = nil;
    [ShareVaule shareInstance].guideImage = nil;
    [[ShareVaule shareInstance].stepImageDic removeAllObjects];
    [_guide release];
    [btn_add release];
    [super dealloc];
}

-(void)viewDidUnload{
    _girdView = nil;
    [btn_add release];
    btn_add = nil;
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
    return index>1;
}

-(void)showGuideViewController{
    [guideEditViewNavigationController.view setFrame:CGRectMake(self.view.frame.size.width, 0, guideEditViewNavigationController.view.frame.size.width, guideEditViewNavigationController.view.frame.size.height)];
    [self.view bringSubviewToFront:guideEditViewNavigationController.view];
    guideEditViewNavigationController.view.hidden = NO;
    [UIView  animateWithDuration:0.3 animations:^{
        guideEditViewNavigationController.view.frame = CGRectMake(0, 0, guideEditViewNavigationController.view.frame.size.width, guideEditViewNavigationController.view.frame.size.height);
    } completion:^(BOOL finished) {
//        [guideEditViewNavigationController.topViewController viewWillAppear:YES];
    }];
}

#pragma mark - GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position;{
    [self postNotification:StepPreviewController.TAP withObject:[NSNumber numberWithInt:position]];
    [self showGuideViewController];
}

-(BOOL)GMGridView:(GMGridView *)gridView shouldAllowActionForItemAtIndex:(NSInteger)index{
    if (index == 0) {
        return NO;
    }else if(index == 1){
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
            GuideInfoMinView *view = [[[GuideInfoMinView alloc]init]autorelease];
            view.guide = [ShareVaule shareInstance].editGuideEx.guideInfo;
            cell.contentView = view;
        }
        GuideInfoMinView *view = (GuideInfoMinView *)cell.contentView;
        view.guide = [ShareVaule shareInstance].editGuideEx.guideInfo;
    }else if(index == 1){
        cell = [gridView dequeueReusableCellWithIdentifier:@"SUPPLIESCELL"];
        if (!cell)
        {
            cell = [[[GMGridViewCell alloc] init]autorelease];
            cell.reuseIdentifier = @"SUPPLIESCELL";
            cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
            cell.deleteButtonOffset = CGPointMake(-15, -15);
            SuppliesMinView *view = [[[SuppliesMinView alloc]init]autorelease];
            cell.contentView = view;
        }
        SuppliesMinView *view = (SuppliesMinView *)cell.contentView;
        view.list = [ShareVaule shareInstance].editGuideEx.supplies;
    }else{
        cell = [gridView dequeueReusableCellWithIdentifier:@"STEPCELL"];
        if (!cell)
        {
            cell = [[[GMGridViewCell alloc] init]autorelease];
            cell.reuseIdentifier = @"STEPCELL";
            cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
            cell.deleteButtonOffset = CGPointMake(-15, -15);
            StepMinView *view = [[[StepMinView alloc]init]autorelease];
            cell.contentView = view;
        }
        StepView *view = (StepView *)cell.contentView;
        int indextemp = index - 2;
        view.step = [[ShareVaule shareInstance].editGuideEx.steps objectAtIndex:indextemp];
    }
    return cell;
}

- (IBAction)createStepAction:(id)sender {
    CreateStepViewController *vlc = [[CreateStepViewController alloc]initWithNibName:@"CreateStepViewController" bundle:nil];
    [self.navigationController pushViewController:vlc animated:YES];
    [vlc release];
}

- (IBAction)publishAction:(id)sender {
    if ([ShareVaule shareInstance].editGuideEx.steps.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"您还未创建步骤" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }else{
        PublishViewController *vlc = [[PublishViewController alloc]initWithNibName:@"PublishViewController" bundle:nil];
        [self.navigationController pushViewController:vlc animated:YES];
        [vlc release];
    }
}

#pragma mark - saveGuide

-(void)saveGuide{
    [SVProgressHUD showWithStatus:@"正在提交..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                [ShareVaule shareInstance].editGuideEx.guideInfo.published = NO;
                [ShareVaule shareInstance].editGuideEx.guideInfo.userId = [ShareVaule shareInstance].user.id_;
                JCGuideEx *guideEx = [proxy saveGuideEx:[ShareVaule shareInstance].editGuideEx];
                //上传封面
                if ([ShareVaule shareInstance].guideImage) {
                    NSString *fileId = guideEx.guideInfo.cover.id_;
                    NSData *guideImagedata = [ShareVaule shareInstance].guideImage;
                    int length = guideImagedata.length;
                    int count =  ceil((float)length / FILEBLOCKLENGTH);
                    int loc = 0;
                    for (int i= 0; i<count; i++) {
                        NSData *data = [guideImagedata subdataWithRange:NSMakeRange(loc, MIN(FILEBLOCKLENGTH,guideImagedata.length - loc))];
                        if (i==count-1) {
                            NSLog(@"last");
                        }
                        JCFileBlock *fileBlock = [JCFileBlock fileBlock:fileId blockIdx:i blockSize:data.length isLastBlock:i==count-1 data:data];
                        [proxy saveFileBlock:fileBlock];
                        loc += FILEBLOCKLENGTH;
                    }
                }
                
                // 上传步骤图片
                if ([ShareVaule shareInstance].stepImageDic.count>0) {
                    for (NSNumber *stepnumber in [ShareVaule shareInstance].stepImageDic.allKeys) {
                        NSData *stepFileData = [[ShareVaule shareInstance].stepImageDic objectForKey:stepnumber];
                        JCStep *resultStep = [guideEx.steps objectAtIndex:[stepnumber intValue]-1];
                        NSString *fileId = resultStep.photo.id_;
                        int count =  ceil((float)stepFileData.length / FILEBLOCKLENGTH);
                        int loc = 0;
                        for (int i= 0; i<count; i++) {
                            NSData *data = [stepFileData subdataWithRange:NSMakeRange(loc, MIN(FILEBLOCKLENGTH,stepFileData.length - loc))];
                            JCFileBlock *fileBlock = [JCFileBlock fileBlock:fileId blockIdx:i blockSize:data.length isLastBlock:i==(count-1) data:data];
                            [proxy saveFileBlock:fileBlock];
                            loc += FILEBLOCKLENGTH;
                        }
                    }
                }
                
                if ([ShareVaule shareInstance].editGuideEx.guideInfo.id_.length == 0) {
                    [ShareVaule shareInstance].user.guideCount ++;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [SVProgressHUD showSuccessWithStatus:@"保存成功!"];
                    [self backAction];
                });
            }
            @catch (NSException *exception) {
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


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;{
    if (buttonIndex == 0) {
        [self saveGuide];
    }else if(buttonIndex == 1){
        [self backAction];
    }
}

@end
