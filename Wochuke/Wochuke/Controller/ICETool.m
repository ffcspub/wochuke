//
//  ICETool.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "ICETool.h"


@implementation ICETool

static NSString* hostnameKey = @"hostnameKey";

static ICETool *_shareInstance;

+(ICETool *)shareInstance;{
    if (!_shareInstance) {
        _shareInstance = [[ICETool alloc]init];
    }
    return _shareInstance;
}

+(void)initialize
{
    NSDictionary* appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:@"127.0.0.1", hostnameKey, nil];
	
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
}

-(void)applicationWillTerminate
{
    [communicator destroy];
}

-(id)init{
    self = [super init];
    if (self) {
        ICEInitializationData* initData = [ICEInitializationData initializationData];
        initData.properties = [ICEUtil createProperties];
        
        [initData.properties setProperty:@"Ice.Default.Locator" value:@"CookGrid/Locator:tcp -h wochuke.com -p 4061"];
        
        // Dispatch AMI callbacks on the main thread
        initData.dispatcher = ^(id<ICEDispatcherCall> call, id<ICEConnection> con)
        {
            dispatch_sync(dispatch_get_main_queue(), ^ { [call run]; });
        };
        
        communicator = [[ICEUtil createCommunicator:initData] retain];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
    return self;
}

-(id<JCAppIntfPrx>)createProxy
{
    NSString* prxStr = @"testIntf";
    
    ICEObjectPrx* prx = [communicator stringToProxy:prxStr];
    
    int timeout = (int)(10 * 1000.0f); // Convert to ms.
    if(timeout != 0)
    {
        prx = [prx ice_timeout:timeout];
    }
    
    return [JCAppIntfPrx uncheckedCast:prx];
}


@end
