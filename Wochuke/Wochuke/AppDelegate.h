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

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    TencentOAuth *tencentOAuth;
    SinaWeibo *sinaweibo;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, nonatomic) TencentOAuth *tencentOAuth;
@property (readonly, assign) SinaWeibo *sinaweibo;

@end
