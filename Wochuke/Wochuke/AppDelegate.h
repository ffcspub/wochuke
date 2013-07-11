//
//  AppDelegate.h
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>

@class SinaWeibo;
@class LoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    SinaWeibo *sinaweibo;
    TencentOAuth *tencentOAuth;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, nonatomic) SinaWeibo *sinaweibo;

@property (readonly, nonatomic) TencentOAuth *tencentOAuth;

@property (strong, nonatomic) LoginViewController *loginViewController;

@end
