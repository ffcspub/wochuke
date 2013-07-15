//
//  StepImageChooseViewController.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "StepImageChooseViewController.h"

#import "GuideInfoView.h"
#import "SuppliesView.h"
#import "StepView.h"
#import "ShareVaule.h"
#import "UIImageView+WebCache.h"

@interface StepImageChooseViewController (){
    NSMutableArray *_imageSteps;
}

@end

@implementation StepImageChooseViewController

-(void)dealloc{
    [_imageSteps release];
    [super dealloc];
}


- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
//    self.title = @"步骤总览";
//    [self.navigationController setNavigationBarHidden:NO];
    NSInteger spacing = 5;
//    _girdView.actionDelegate = self;
    _girdView.dataSource = self;
    _girdView.style = GMGridViewStylePush;
//    _girdView.disableEditOnEmptySpaceTap = YES;
    _girdView.itemSpacing = spacing;
    _girdView.actionDelegate = self;
    _girdView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    _girdView.centerGrid = NO;
    
    _imageSteps = [[NSMutableArray alloc]init];
    for (JCStep * step in [ShareVaule shareInstance].editGuideEx.steps) {
        NSData *data = [[ShareVaule shareInstance] getImageDataByStep:step];
        if (data) {
            [ShareVaule shareInstance].guideImage = [NSData dataWithData:data];
            [_imageSteps addObject:step];
        }else{
            if (step.photo.url.length>0) {
                [_imageSteps addObject:step];
            }
        }
        
    }
//    _girdView.actionDelegate = self;
    [_girdView reloadData];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillDisappear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return _imageSteps.count;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(100, 130);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //NSLog(@"Creating view indx %d", index);
    GMGridViewCell *cell = nil;
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
    view.step = [_imageSteps objectAtIndex:index];
    return cell;
}

#pragma mark - GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position;{
    JCStep *step = [_imageSteps objectAtIndex:position];
    NSData *data = [[ShareVaule shareInstance] getImageDataByStep:step];
    if (data) {
        [ShareVaule shareInstance].guideImage = [NSData dataWithData:data];
    }else{
        UIImageView *view = [[[UIImageView alloc]init]autorelease];
        [view setImageWithURL:[NSURL URLWithString: step.photo.url]];
        [ShareVaule shareInstance].editGuideEx.guideInfo.cover.url = step.photo.url;
        [ShareVaule shareInstance].guideImage = UIImageJPEGRepresentation(view.image, 1.0);
    }
    [self.navigationController popViewControllerAnimated:NO];
}

@end
