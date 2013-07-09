//
//  GuideViewController.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "CreateStepViewController.h"
#import <Ice/Ice.h>
#import "ICETool.h"
#import "SVProgressHUD.h"
#import "GuideInfoView.h"
#import "SuppliesView.h"
#import "StepView.h"
#import "StepPreviewController.h"
#import "SuppliesEditViewController.h"
#import "PECropViewController.h"

@interface CreateStepViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIActionSheetDelegate,StepEditViewDelegate>{
    StepEditView *_editView;
    UIImagePickerController *_picker;
    JCStep *step;
}

@end

@implementation CreateStepViewController

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
    
    step = [JCStep step];
    [((NSMutableArray *)[ShareVaule shareInstance].editGuideEx.steps) addObject:step];
    step.ordinal = [ShareVaule shareInstance].editGuideEx.steps.count;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillUnload{
    [super viewWillUnload];
}

-(void)handleNotification:(NSNotification *)notification{
    if ([notification is:StepPreviewController.TAP]) {
        NSNumber *index = (NSNumber *)notification.object;
        [_pagedFlowView scrollToPage:[index integerValue] animation:NO];
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
    [((NSMutableArray *)[ShareVaule shareInstance].editGuideEx.steps) removeObject:step];
    [[ShareVaule shareInstance].stepImageDic removeObjectForKey:step];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    StepEditView *view = (StepEditView *)[flowView dequeueReusableCellWithClass:[StepEditView class]];
    if (!view) {
        view = [[[StepEditView alloc]init]autorelease];
        view.delegate = self;
    }
    view.step = step;
    view.noDeleteAble = YES;
    return view;
}


#pragma mark -StepEditViewDelegate
-(void)imageTapFromStepEditView:(StepEditView *)editView;{
    _editView = editView;
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"图片来源" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册",@"拍照", nil];
    [sheet showInView:self.view];
    [sheet release];
}

#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;{
    if (buttonIndex == 0) {
        _picker = [[UIImagePickerController alloc]init];
//        [_picker setAllowsEditing:YES];
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _picker.delegate = self;
        [self presentModalViewController:_picker animated:YES];
    }else if(buttonIndex == 1){
        _picker = [[UIImagePickerController alloc]init];
//        [_picker setAllowsEditing:YES];
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.delegate = self;
        [self presentModalViewController:_picker animated:YES];
    }
}

#pragma mark -UIImagePickerControllerDelegate
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#define kImageScaleRate 0.3
#define kImageCompressRate 0.5
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];//
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor:image];
        [_picker release];
        _picker = nil;
    }];    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
    [_picker release];
    _picker = nil;
}

#pragma mark -

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    //    UIImage *cmpImg = [self scaleImage:image toScale:kImageScaleRate];//縮圖
    //    UIImageWriteToSavedPhotosAlbum(cmpImg, nil, nil, nil);
    NSData *blobImage = UIImageJPEGRepresentation(croppedImage, kImageCompressRate);//圖片壓縮為NSData
    if (_editView) {
        [[ShareVaule shareInstance].stepImageDic setObject:blobImage forKey:step];
        [_editView upImage];
        _editView = nil;
    }
    __block PECropViewController *_controller = controller;
    [controller dismissViewControllerAnimated:YES completion:^{
        [_controller release];
        _controller = nil;
    }];
    
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (void)openEditor:(UIImage *)image
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = image;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

@end
