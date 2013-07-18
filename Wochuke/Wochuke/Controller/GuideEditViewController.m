//
//  GuideViewController.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "GuideEditViewController.h"
#import <Ice/Ice.h>
#import "ICETool.h"
#import "SVProgressHUD.h"
#import "GuideInfoView.h"
#import "SuppliesView.h"
#import "StepView.h"
#import "StepPreviewController.h"
#import "SuppliesEditViewController.h"
#import "PECropViewController.h"
#import "PublishViewController.h"
#import "UIImageView+WebCache.h"

@interface GuideEditViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIActionSheetDelegate,StepEditViewDelegate>{
    JCStep *_steptemp;
    UIImagePickerController *_picker;
}

@end

@implementation GuideEditViewController

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
    _pagedFlowView.minimumPageAlpha = 1.0;
    _pagedFlowView.minimumPageScale = 1.0;
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
    [[ShareVaule shareInstance]removeEmptySupply];
    [_steptemp release];
    [_pagedFlowView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setPagedFlowView:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_pagedFlowView reloadData];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (IBAction)popAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)scrollToIndex:(int)index;{
    [_pagedFlowView scrollToPage:index animation:NO];
}

- (IBAction)pubishAction:(id)sender {
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


#pragma mark -PagedFlowViewDelegate
- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView;{
    return  CGSizeMake(flowView.frame.size.width - 20, flowView.frame.size.height - 10);
}

- (void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index;{
//    if (index == 1) {
//        SuppliesEditViewController *vlc = [[SuppliesEditViewController alloc]initWithNibName:@"SuppliesEditViewController" bundle:nil];
//        [self.navigationController pushViewController:vlc animated:YES];
//        [vlc release];
//    }else{
//       
//    }
}

#pragma mark -PagedFlowViewDataSource
//返回显示View的个数
- (NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView{
    return [ShareVaule shareInstance].editGuideEx.steps.count + 2;
}

//返回给某列使用的View
- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index;{
    if (index == 0) {
        GuideEditView *view = (GuideEditView *)[flowView dequeueReusableCellWithClass:[GuideEditView class]];
        if (!view) {
            view = [[[GuideEditView alloc]init]autorelease];
        }
        return view;
    }else if(index == 1){
        SuppliesEditView *view = (SuppliesEditView *)[flowView dequeueReusableCellWithClass:[SuppliesEditView class]];
        if (!view) {
            view = [[[SuppliesEditView alloc]init]autorelease];
        }
//        view.list = [ShareVaule shareInstance].editGuideEx.supplies;
        return view;
    }else{
        StepEditView *view = (StepEditView *)[flowView dequeueReusableCellWithClass:[StepEditView class]];
        if (!view) {
            view = [[[StepEditView alloc]init]autorelease];
            view.delegate = self;
        }
        int indextemp = index - 2;
        view.step = [[ShareVaule shareInstance].editGuideEx.steps objectAtIndex:indextemp];
        return view;
    }
    return nil;
}


#pragma mark -StepEditViewDelegate
-(void)imageTapFromStepEditView:(StepEditView *)editView;{
    _steptemp = [editView.step retain];
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"图片来源" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册",@"拍照", nil];
    [sheet showInView:self.view];
    [sheet release];
}

-(void)delBtnClickedFromStepEditView:(StepEditView *)editView{
    _steptemp = [editView.step retain];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要删除该步骤?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[ShareVaule shareInstance] removeStep:_steptemp];
        [_steptemp release];
        _steptemp = nil;
        [_pagedFlowView reloadData];
    }
}


#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;{
    if (buttonIndex == 0) {
        _picker = [[UIImagePickerController alloc]init];
//        [_picker setAllowsEditing:YES];
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _picker.delegate = self;
        [self presentViewController:_picker animated:YES completion:nil];
    }else if(buttonIndex == 1){
        _picker = [[UIImagePickerController alloc]init];
//        [_picker setAllowsEditing:YES];
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.delegate = self;
        [self presentViewController:_picker animated:YES completion:nil];
    }
}

#pragma mark -UIImagePickerControllerDelegate
#pragma mark -UIImagePickerControllerDelegate

- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

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
    image = [self fixOrientation:image];
    image = [self scaleImage:image toScale:kImageScaleRate];//縮圖
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor:image];
        [_picker release];
        _picker = nil;
    }];    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    [_picker release];
    _picker = nil;
}

#pragma mark -

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    //    UIImage *cmpImg = [self scaleImage:image toScale:kImageScaleRate];//縮圖
    //    UIImageWriteToSavedPhotosAlbum(cmpImg, nil, nil, nil);
    NSData *blobImage = UIImageJPEGRepresentation(croppedImage, kImageCompressRate);//圖片壓縮為NSData
    if (_steptemp) {
        [[ShareVaule shareInstance] putImageData:blobImage step:_steptemp];
        [_pagedFlowView reloadData];
        [_steptemp release];
        _steptemp = nil;
    }
    __block PECropViewController *_controller = controller;
    [controller dismissViewControllerAnimated:YES completion:^{
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
    PECropViewController *controller = [[[PECropViewController alloc] init]autorelease];
    controller.delegate = self;
    controller.image = image;
    
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller]autorelease];
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

@end
