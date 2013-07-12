//
//  AppDelegate.h
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    TencentOAuth *tencentOAuth;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, nonatomic) TencentOAuth *tencentOAuth;

@end
