//
//  AppDelegate.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "ICETool.h"
#import "Guide.h"
#import "CatoryViewController.h"
#import "SearchViewController.h"
#import "MainViewController.h"
#import "MobClick.h"
#import "SinaWeibo.h"
#import<TencentOpenAPI/QQApiInterface.h> 
#import<TencentOpenAPI/TencentOAuth.h>

@implementation AppDelegate

@synthesize tencentOAuth;
@synthesize sinaweibo;

- (void)dealloc
{
    [tencentOAuth release];
    [_window release];
    [super dealloc];
}

- (void)initializePlat
{
    //向微信注册
    [WXApi registerApp:weixinAppId];
    
    
}

-(void)loadUser{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            id<JCAppIntfPrx> proxy = [[ICETool shareInstance] createProxy];
            @try {
                JCUser * user = [proxy getUserById:[ShareVaule shareInstance].userId userId:[ShareVaule shareInstance].userId];
                if (user) {
                    [ShareVaule shareInstance].user = user;
                }
                NSString *slogon = [proxy getSlogon];
                [[NSUserDefaults standardUserDefaults]setObject:slogon forKey:@"SLOGON"];
            }
            @catch (ICEException *exception) {
                
            }
            @finally {
                
            }
        }@catch (ICEException *exception) {
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                [SVProgressHUD showErrorWithStatus:@"服务访问异常"];
            //            });
        }
    });
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializePlat];
    
    [MobClick startWithAppkey:@"51e1270b56240b518708d2ee"];
    [MobClick checkUpdate];
    
    [self loadUser];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
//    HomeViewController *vlc = [[[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil]autorelease];
//    CatoryViewController *vlc = [[[CatoryViewController alloc]initWithNibName:@"CatoryViewController" bundle:nil]autorelease];
    MainViewController *vlc = [[[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil]autorelease];
//    UINavigationController *navigationController =[[[UINavigationController alloc]initWithRootViewController:vlc]autorelease];
//    [navigationController setNavigationBarHidden:YES];
    self.window.rootViewController = vlc;
    
    [self.window makeKeyAndVisible];
    
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url scheme] isEqualToString:@"sinaweibosso.732356489"]) {
        return [[ShareVaule shareInstance].sinaweibo handleOpenURL:url];
    }else if ([[url scheme] isEqualToString:@"tencent100454485"]) {
        return [TencentOAuth HandleOpenURL:url];
    }else{
       return [WXApi handleOpenURL:url delegate:self];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[url scheme] isEqualToString:@"sinaweibosso.732356489"]) {
        return [[ShareVaule shareInstance].sinaweibo handleOpenURL:url];
    }else if ([[url scheme] isEqualToString:@"tencent100454485"]) {
        return [TencentOAuth HandleOpenURL:url];
    }else{
        return  [WXApi handleOpenURL:url delegate:self];
    }
    return YES;
}


-(void) onReq:(BaseReq*)req
{
        
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (resp.errCode == WXSuccess) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }else if (resp.errCode !=WXErrCodeUserCancel){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
        
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
//        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
//        NSString *strMsg = [NSString stringWithFormat:@"Auth结果:%d", resp.errCode];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        [alert release];
    }
}

@end
