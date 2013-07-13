//
//  PersonalSettingsViewController.m
//  Wochuke
//
//  Created by Geory on 13-7-7.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "PersonalSettingsViewController.h"
#import "UIImageView+WebCache.h"
#import <Guide.h>
#import "PECropViewController.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import <Guide.h>
#import "ICETool.h"
#import "SVProgressHUD.h"


@interface PersonalSettingsViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UIImagePickerController *_picker;
    NSData *_blobImage;
}

@end

@implementation PersonalSettingsViewController

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
    // Do any additional setup after loading the view from its nib.
    UIImage *backImage = [[UIImage imageNamed:@"bg_register&login_card"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [_iv_back setImage:backImage];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([ShareVaule shareInstance].user.id_) {
        [_iv_face setImageWithURL:[NSURL URLWithString:[ShareVaule shareInstance].user.avatar.url] placeholderImage:[UIImage imageNamed:@"ic_user_top"]];
        _tf_nickname.text = [ShareVaule shareInstance].user.name;
        _tf_email.text = [ShareVaule shareInstance].user.email;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)faceAction:(id)sender {
    [self showInputAlert];
}

- (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (IBAction)saveAction:(id)sender {
    if (_tf_email.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请输入电子邮箱" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }else if(![self isValidateEmail:_tf_email.text]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"输入电子邮箱格式不正确" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    if (_tf_password.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请输入密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    if (_tf_confirm.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请输入确认密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    if (![_tf_password.text isEqual:_tf_confirm.text]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"两次输入的密码不相同" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCUser *user = [JCUser user:[ShareVaule shareInstance].user.id_ name:_tf_nickname.text email:_tf_email.text password:_tf_password.text  avatar:[ShareVaule shareInstance].user.avatar mobile:[ShareVaule shareInstance].user.mobile realname:[ShareVaule shareInstance].user.realname intro:[ShareVaule shareInstance].user.intro roleCode:[ShareVaule shareInstance].user.roleCode followerCount:[ShareVaule shareInstance].user.followerCount followingCount:[ShareVaule shareInstance].user.followingCount followState:[ShareVaule shareInstance].user.followState guideCount:[ShareVaule shareInstance].user.guideCount favoriteCount:[ShareVaule shareInstance].user.favoriteCount snsIds:[ShareVaule shareInstance].user.snsIds];
                JCUser *usertemp = [proxy saveUser:user];
                if (_blobImage) {
                    NSString *fileId = usertemp.avatar.id_;
                    int length = _blobImage.length;
                    int count =  ceil((float)length / FILEBLOCKLENGTH);
                    int loc = 0;
                    for (int i= 0; i<count; i++) {
                        NSData *data = [_blobImage subdataWithRange:NSMakeRange(loc, MIN(FILEBLOCKLENGTH,_blobImage.length - loc))];
                        if (i==count-1) {
                            NSLog(@"last");
                        }
                        JCFileBlock *fileBlock = [JCFileBlock fileBlock:fileId blockIdx:i blockSize:data.length isLastBlock:i==count-1 data:data];
                        [proxy saveFileBlock:fileBlock];
                        loc += FILEBLOCKLENGTH;
                    }
                }
                [ShareVaule shareInstance].user = [proxy getUserById:[ShareVaule shareInstance].userId userId:[ShareVaule shareInstance].userId];
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showSuccessWithStatus:@"保存成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            @catch (ICEException *exception) {
                if ([exception isKindOfClass:[JCGuideException class]]) {
                    JCGuideException *_exception = (JCGuideException *)exception;
                    if (_exception.reason_) {
                        dispatch_async(dispatch_get_main_queue(), ^{                                [SVProgressHUD showErrorWithStatus:_exception.reason_];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{                              [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
                        });
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{                          [SVProgressHUD showErrorWithStatus:ERROR_MESSAGE];
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

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _tf_nickname) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -10, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }else if (textField == _tf_email){
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -126, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }else if (textField == _tf_password){
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -142, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }else if (textField == _tf_confirm){
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -158, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc {
    [_tf_nickname release];
    [_tf_email release];
    [_tf_password release];
    [_tf_confirm release];
    [_iv_back release];
    [_iv_face release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTf_nickname:nil];
    [self setTf_email:nil];
    [self setTf_password:nil];
    [self setTf_confirm:nil];
    [self setIv_back:nil];
    [self setIv_face:nil];
    [super viewDidUnload];
}

#pragma mark -
-(void)showInputAlert{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"图片来源" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册",@"拍照", nil];
    sheet.tag = 10086;
    [sheet showInView:self.view];
    [sheet release];
}

#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;{
    if (actionSheet.tag == 10086) {
        if (buttonIndex == 0) {
            _picker = [[UIImagePickerController alloc]init];
            //        [_picker setAllowsEditing:YES];1
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
   _blobImage =  UIImageJPEGRepresentation(croppedImage, kImageCompressRate);//圖片壓縮為NSData
    [_iv_face setImage:croppedImage];
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
