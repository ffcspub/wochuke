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

@interface PublishViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UIImagePickerController *_picker;
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
    _iv_photo.layer.cornerRadius = 6;
    _iv_photo.layer.masksToBounds = YES;
    _iv_photo.contentMode = UIViewContentModeScaleAspectFill;
    
    UITapGestureRecognizer* singleRecognizer;  
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)];  
    singleRecognizer.numberOfTapsRequired = 1; // 单击  
    [_iv_photo addGestureRecognizer:singleRecognizer];  
    
    [self loadImage];
    // Do any additional setup after loading the view from its nib.
}

-(void)handleSingleTapFrom{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_iv_photo release];
    [_btn_type release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setIv_photo:nil];
    [self setBtn_type:nil];
    [super viewDidUnload];
}

- (IBAction)typeChooseAction:(id)sender {
    [self showInputAlert];
}


-(void)loadImage{
    if ([ShareVaule shareInstance].guideImage) {
        UIImage *image = [UIImage imageWithData:[ShareVaule shareInstance].guideImage];
        [_iv_photo setImage:image];
    }else if([ShareVaule shareInstance].editGuideEx.guideInfo.cover.url.length>0){
        [_iv_photo setImageWithURL:[NSURL URLWithString:[ShareVaule shareInstance].editGuideEx.guideInfo.cover.url]];
    }
}


#define FILEBLOCKLENGTH 1024*2
#pragma mark - dataSend
-(void)pubishAction{
    [SVProgressHUD showWithStatus:@"正在提交..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
        @try {
            JCGuideEx *guideEx = [proxy saveGuideEx:[ShareVaule shareInstance].editGuideEx];
            
            //上传封面
            if ([ShareVaule shareInstance].guideImage) {
                NSString *fileId = guideEx.guideInfo.cover.id_;
                NSData *guideImagedata = [ShareVaule shareInstance].guideImage;
               
                int count =  (guideImagedata.length / FILEBLOCKLENGTH);
                int loc = 0;
                for (int i= 0; i<count; i++) {
                    NSData *data = [guideImagedata subdataWithRange:NSMakeRange(loc, FILEBLOCKLENGTH)];
                    JCFileBlock *fileBlock = [JCFileBlock fileBlock:fileId blockIdx:i blockSize:data.length isLastBlock:i==count-1 data:data];
                    [proxy saveFileBlock:fileBlock];
                }
                
                // 上传步骤图片
                if ([ShareVaule shareInstance].stepImageDic) {
                    for (JCStep *step in [ShareVaule shareInstance].stepImageDic.allKeys) {
                        NSData *stepFileData = [[ShareVaule shareInstance].stepImageDic objectForKey:step];
                        JCStep *resultStep = [guideEx.steps objectAtIndex:step.ordinal];
                        NSString *fileId = resultStep.photo.id_;
                        int count =  (stepFileData.length / FILEBLOCKLENGTH);
                        int loc = 0;
                        for (int i= 0; i<count; i++) {
                            NSData *data = [stepFileData subdataWithRange:NSMakeRange(loc, FILEBLOCKLENGTH)];
                            JCFileBlock *fileBlock = [JCFileBlock fileBlock:fileId blockIdx:i blockSize:data.length isLastBlock:i==(count-1) data:data];
                            [proxy saveFileBlock:fileBlock];
                        }
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:@"上传成功!"];
                [self.navigationController popViewControllerAnimated:YES];
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
    });
}

#pragma mark -
-(void)showInputAlert{
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
    [ShareVaule shareInstance].guideImage = blobImage;

    
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
