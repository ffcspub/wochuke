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
        _shareVaule.stepImageDic = [[NSMutableDictionary alloc]init];
        _shareVaule.noChanged = YES;
    }
    return _shareVaule;
}

-(void)dealloc{
    [_stepImageDic release];
    [_editGuideEx release];
    [_user release];
    [super dealloc];
}

- (NSString *)userId
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];
}

- (void)setUserId:(NSString *)userId
{
    [[NSUserDefaults standardUserDefaults] setValue:userId forKey:@"userId"];
}

- (void)setUser:(JCUser *)user
{
    if (_user) {
        [_user release];
        _user = nil;
    }
    _user = [user retain];
}

-(void)removeStep:(JCStep *)step;{
    NSMutableArray *steps = (NSMutableArray *)[ShareVaule shareInstance].editGuideEx.steps;
    int index = [steps indexOfObject:step];
    [[ShareVaule shareInstance] removeImageDataByStep:step];
    [steps removeObjectAtIndex:index];
    
    for (int i=0; i<steps.count; i++) {
        JCStep *step = (JCStep *)[steps objectAtIndex:i];
        NSData *data = [[[ShareVaule shareInstance] getImageDataByStep:step]retain];
        if (data) {
            [[ShareVaule shareInstance] removeImageDataByStep:step];
        }
        step.ordinal = i+1;
        if (data) {
            [[ShareVaule shareInstance]putImageData:data step:step];
            [data release];
        }
    }
    _noChanged = NO;
    [self postNotification:NOTIFICATION_ORDINALCHANGE];
}

-(void)moveStepFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;{
    NSMutableArray *steps = (NSMutableArray *)[ShareVaule shareInstance].editGuideEx.steps;
    JCStep *oldStep = [steps objectAtIndex:fromIndex];
    [steps removeObjectAtIndex:fromIndex];
    [steps insertObject:oldStep atIndex:toIndex];
    for (int i=0; i<steps.count; i++) {
        JCStep *step = (JCStep *)[steps objectAtIndex:i];
        NSData *data = [[[ShareVaule shareInstance]getImageDataByStep:step]retain];
        if (data) {
            [[ShareVaule shareInstance] removeImageDataByStep:step];
        }
        step.ordinal = i+1;
        if (data) {
            [[ShareVaule shareInstance] putImageData:data step:step];
            [data release];
        }
    }
    _noChanged = NO;
    [self postNotification:NOTIFICATION_ORDINALCHANGE];
}

-(void)putImageData:(NSData *)data step:(JCStep *)step;{
    _noChanged = NO;
    [self removeImageDataByStep:step];
    [_stepImageDic setObject:data forKey:[NSString stringWithFormat:@"%d",step.ordinal]];
}

-(NSData *)getImageDataByStep:(JCStep *)step;{
    NSString *stepOrdinal = [NSString stringWithFormat:@"%d",step.ordinal];
    return  [_stepImageDic objectForKey:stepOrdinal];
}

-(void)removeImageDataByStep:(JCStep *)step;{
    NSString *stepOrdinal = [NSString stringWithFormat:@"%d",step.ordinal];
    [_stepImageDic removeObjectForKey:stepOrdinal];
}

@end
