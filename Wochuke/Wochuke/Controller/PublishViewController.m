//
//  PublishViewController.m
//  Wochuke
//
//  Created by he songhang on 13-7-9.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "PublishViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PECropViewController.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import <Guide.h>
#import "ICETool.h"
#import "StepImageChooseViewController.h"
#import "GuideEditViewController.h"

@interface PublishViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UIImagePickerController *_picker;
    NSMutableArray *_types;
    NSString *_typeId;
}

@end

@implementation PublishViewController

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
    BOOL flag = NO;
    if ([ShareVaule shareInstance].editGuideEx.guideInfo.cover.url.length > 0) {
        NSString *url = [ShareVaule shareInstance].editGuideEx.guideInfo.cover.url;
        NSString *pngname = [[url componentsSeparatedByString:@"/"]lastObject];
        if ([pngname isEqual:@"default.png"]) {
            flag = YES;
        }
    }else{
        flag = YES;
    }
    
    if (flag && ![ShareVaule shareInstance].guideImage) {
        int count = [ShareVaule shareInstance].editGuideEx.steps.count;
        for (int i = count-1; i>=0; i--) {
            JCStep *step = [[ShareVaule shareInstance].editGuideEx.steps objectAtIndex:i];
            NSData *data = [[ShareVaule shareInstance]getImageDataByStep:step];
            if (data) {
                [ShareVaule shareInstance].guideImage = data;
                break;
            }else if (step.photo.url) {
                UIImageView *imageView = [[[UIImageView alloc]init]autorelease];
                [imageView setImageWithURL:[NSURL URLWithString:step.photo.url]];
                [ShareVaule shareInstance].guideImage = UIImageJPEGRepresentation(imageView.image, 1.0);
                break;
            }
            
        }
    }

    [[ShareVaule shareInstance]removeEmptySupply];
    _photoBackview.layer.cornerRadius = 6;
    _photoBackview.layer.masksToBounds = YES;
    
    _iv_photo.layer.cornerRadius = 6;
    _iv_photo.layer.masksToBounds = YES;
    _iv_photo.contentMode = UIViewContentModeScaleAspectFill;
    
    UITapGestureRecognizer* singleRecognizer;  
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击  
    [_iv_photo addGestureRecognizer:singleRecognizer];  
    // Do any additional setup after loading the view from its nib.
    
    _types = [[NSMutableArray alloc]init];
    if ([ShareVaule shareInstance].editGuideEx.guideInfo.typeId.length>0) {
        [_btn_type setTitle:[ShareVaule shareInstance].editGuideEx.guideInfo.typeName forState:UIControlStateNormal];
        _typeId = [[ShareVaule shareInstance].editGuideEx.guideInfo.typeId retain];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self loadImage];
    [self loadTypes];
}

-(void)handleSingleTapFrom{
    [self showInputAlert];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_typeId release];
    [_types release];
    [_iv_photo release];
    [_btn_type release];
    [_photoBackview release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setIv_photo:nil];
    [self setBtn_type:nil];
    [self setPhotoBackview:nil];
    [super viewDidUnload];
}

- (IBAction)typeChooseAction:(id)sender {
    UIActionSheet *sheet = [[[UIActionSheet alloc]init]autorelease];
    sheet.tag = 10086;
    sheet.delegate = self;
    sheet.title = @"选择分类";
    for (JCType *type in _types) {
        [sheet addButtonWithTitle:type.name];
    }
    [sheet addButtonWithTitle:@"取消"];
    sheet.cancelButtonIndex = _types.count;
    [sheet showInView:self.view];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pubishAction:(id)sender {
    [self pubishAction];
}


-(void)loadImage{
    if ([ShareVaule shareInstance].guideImage) {
        UIImage *image = [UIImage imageWithData:[ShareVaule shareInstance].guideImage];
        [_iv_photo setImage:image];
    }else if([ShareVaule shareInstance].editGuideEx.guideInfo.cover.url.length>0){
        [_iv_photo setImageWithURL:[NSURL URLWithString:[ShareVaule shareInstance].editGuideEx.guideInfo.cover.url]];
    }
}

#pragma mark - DataLoad
-(void)loadTypes;{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCTypeList * list = [proxy getTypeList:nil];
                if (list) {
                    [_types removeAllObjects];
                    if (list.count > 0) {
                        [_types addObjectsFromArray:list];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    NSString *typeid = [ShareVaule shareInstance].editGuideEx.guideInfo.typeId;
                    if (typeid.length>0) {
                        for (JCType *type in list) {
                            if ([type.id_ isEqual:typeid]) {
                                if (_typeId) {
                                    [_typeId release];
                                    _typeId = nil;
                                }
                                _typeId = [type.id_ retain];
                                [_btn_type setTitle:type.name forState:UIControlStateNormal];
                                break;
                            }
                        }
                    }else{
                        JCType *type = [_types objectAtIndex:0];
                        if (_typeId) {
                            [_typeId release];
                            _typeId = nil;
                        }
                        _typeId = [type.id_ retain];
                        [ShareVaule shareInstance].editGuideEx.guideInfo.typeId = _typeId;
                        [ShareVaule shareInstance].noChanged = NO;
                        [_btn_type setTitle:type.name forState:UIControlStateNormal];
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

        }@catch (ICEException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"服务访问异常"];
            });
        }
    });
}




#pragma mark - dataSend
-(void)pubishAction{
    [SVProgressHUD showWithStatus:@"正在提交..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                [ShareVaule shareInstance].editGuideEx.guideInfo.published = YES;
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
                    [SVProgressHUD showSuccessWithStatus:@"发布成功!"];
                    
                    UIViewController *vlc = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
                    if ([vlc isKindOfClass:[GuideEditViewController class]] ) {
                        GuideEditViewController *controller = (GuideEditViewController *)vlc;
                        [((UIViewController *)controller.controllerDelegate).navigationController dismissViewControllerAnimated:YES completion:nil];
                    }else{
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }
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



#pragma mark -
-(void)showInputAlert{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"图片来源" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"选自步骤",@"相册",@"拍照", nil];
    [sheet showInView:self.view];
    [sheet release];
}

#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;{
    if (actionSheet.tag == 10086) {
        if (buttonIndex < _types.count) {
            JCType *type = [_types objectAtIndex:buttonIndex];
            if (![_typeId isEqual:type.id_]) {
                [_typeId release];
                _typeId = nil;
            }else{
                return;
            }
            _typeId = [type.id_ retain];
            [ShareVaule shareInstance].editGuideEx.guideInfo.typeId = _typeId;
            [ShareVaule shareInstance].noChanged = NO;
            [_btn_type setTitle:type.name forState:UIControlStateNormal];
        }
        return;
    }
    
    if (buttonIndex == 0) {
        StepImageChooseViewController *vlc = [[StepImageChooseViewController alloc]initWithNibName:@"StepImageChooseViewController" bundle:nil];
        [self.navigationController pushViewController:vlc animated:YES];
        [vlc release];
    }else if (buttonIndex == 1) {
        _picker = [[UIImagePickerController alloc]init];
        //        [_picker setAllowsEditing:YES];1
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _picker.delegate = self;
        [self presentViewController:_picker animated:YES completion:nil];
    }else if(buttonIndex == 2){
        _picker = [[UIImagePickerController alloc]init];
        //        [_picker setAllowsEditing:YES];
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.delegate = self;
        [self presentViewController:_picker animated:YES completion:nil];
    }
}

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
    [ShareVaule shareInstance].guideImage = blobImage;
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
    controller.image = [image retain];
    
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller]autorelease];
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}


@end
