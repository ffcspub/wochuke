//
//  ShareVaule.m
//  Wochuke
//
//  Created by he songhang on 13-6-27.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "ShareVaule.h"
#import "NSObject+Notification.h"

static ShareVaule *_shareVaule;

@implementation ShareVaule

+(ShareVaule *)shareInstance;{
    if (!_shareVaule) {
        _shareVaule = [[ShareVaule alloc]init];
        _shareVaule.stepImageDic = [[[NSMutableDictionary alloc]init]autorelease];
    }
    return _shareVaule;
}

-(void)dealloc{
    [_stepImageDic release];
    [_editGuideEx release];
    [_user release];
    [super dealloc];
}


-(void)removeStep:(JCStep *)step;{
    NSMutableArray *steps = (NSMutableArray *)[ShareVaule shareInstance].editGuideEx.steps;
    int index = [steps indexOfObject:step];
    [[ShareVaule shareInstance].stepImageDic  removeObjectForKey:step];
    [steps removeObjectAtIndex:index];
    
    for (int i=0; i<steps.count; i++) {
        JCStep *step = (JCStep *)[steps objectAtIndex:i];
        NSData *data = [[[ShareVaule shareInstance].stepImageDic objectForKey:step]retain];
        if (data) {
            [[ShareVaule shareInstance].stepImageDic removeObjectForKey:step];
        }
        step.ordinal = i+1;
        if (data) {
            [[ShareVaule shareInstance].stepImageDic  setObject:data forKey:step];
            [data release];
        }
    }
    
    [self postNotification:NOTIFICATION_ORDINALCHANGE];
}

-(void)moveStepFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;{
    NSMutableArray *steps = (NSMutableArray *)[ShareVaule shareInstance].editGuideEx.steps;
    JCStep *oldStep = [steps objectAtIndex:fromIndex];
    [steps removeObjectAtIndex:fromIndex];
    [steps insertObject:oldStep atIndex:toIndex];
    for (int i=0; i<steps.count; i++) {
        JCStep *step = (JCStep *)[steps objectAtIndex:i];
        NSData *data = [[[ShareVaule shareInstance].stepImageDic objectForKey:step]retain];
        if (data) {
            [[ShareVaule shareInstance].stepImageDic  removeObjectForKey:step];
        }
        step.ordinal = i+1;
        if (data) {
            [[ShareVaule shareInstance].stepImageDic  setObject:data forKey:step];
            [data release];
        }
    }
    [self postNotification:NOTIFICATION_ORDINALCHANGE];
}

@end
