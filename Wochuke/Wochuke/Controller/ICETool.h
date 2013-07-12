//
//  ICETool.h
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Ice/Ice.h>
#import <Guide.h>
#import <Cook.h>

@interface ICETool : NSObject{
    id<ICECommunicator> communicator;
}

-(id<JCAppIntfPrx>)createProxy;
-(id<JCAgentLocatorPrx>)createLocalProxy;
//-(id)<JCCookAgentPrx>createCookAgentPrx:(NSString *)token localProxy:(id<JCAgentLocatorPrx>)localProxy;

+(ICETool *)shareInstance;



@end
