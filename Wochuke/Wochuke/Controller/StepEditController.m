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


@interface StepEditController ()

@end

@implementation StepEditController

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
    self.title = @"步骤总览";
    [self.navigationController setNavigationBarHidden:NO];
    NSInteger spacing = 20;
//    _girdView.actionDelegate = self;
    _girdView.dataSource = self;
    _girdView.style = GMGridViewStylePush;
    _girdView.itemSpacing = spacing;
    _girdView.actionDelegate = self;
    _girdView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    _girdView.centerGrid = NO;
    _girdView.sortingDelegate = self;
    [_girdView reloadData];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -GMGridViewSortingDelegate
- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex;{
    
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2;{
    
}


#pragma mark - GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position;{
    
}

-(BOOL)GMGridView:(GMGridView *)gridView shouldAllowActionForItemAtIndex:(NSInteger)index{
    if (index == 0) {
        return NO;
    }else if(index == 1 && _detail.supplies.count >0){
        return NO;
    }
    return YES;
}

#pragma mark -GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    if (_detail.supplies.count>0) {
        return _detail.steps.count + 2;
    }
    return _detail.steps.count + 1;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(80, 110);
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
            cell = [[GMGridViewCell alloc] init];
            cell.reuseIdentifier = @"GUIDEINFOCELL";
            cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
            cell.deleteButtonOffset = CGPointMake(-15, -15);
            GuideInfoMinView *view = [[GuideInfoMinView alloc]init];
            view.guide = _guide;
            cell.contentView = view;
        }
    }else if(_detail.supplies.count>0 && index == 1){
        cell = [gridView dequeueReusableCellWithIdentifier:@"SUPPLIESCELL"];
        if (!cell)
        {
            cell = [[GMGridViewCell alloc] init];
            cell.reuseIdentifier = @"SUPPLIESCELL";
            cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
            cell.deleteButtonOffset = CGPointMake(-15, -15);
            SuppliesMinView *view = [[[SuppliesMinView alloc]init]autorelease];
            view.list = _detail.supplies;
            cell.contentView = view;
        }
    }else{
        cell = [gridView dequeueReusableCellWithIdentifier:@"STEPCELL"];
        if (!cell)
        {
            cell = [[GMGridViewCell alloc] init];
            cell.reuseIdentifier = @"STEPCELL";
            cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
            cell.deleteButtonOffset = CGPointMake(-15, -15);
            StepMinView *view = [[StepMinView alloc]init];
            cell.contentView = view;
        }
        StepView *view = (StepView *)cell.contentView;
        int indextemp = index - 1;
        if (_detail.supplies.count>0) {
            indextemp = index - 2;
        }
        view.step = [_detail.steps objectAtIndex:indextemp];
    }
    return cell;
}


@end
