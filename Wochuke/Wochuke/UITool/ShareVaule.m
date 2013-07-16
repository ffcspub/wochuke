//
//  ShareVaule.m
//  Wochuke
//
//  Created by he songhang on 13-6-27.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "ShareVaule.h"
#import "NSObject+Notification.h"
#import "NSString+BeeExtension.h"
#import "NSDate+BeeExtension.h"

#define DRIVERKEY @"DRIVERKEY"

static ShareVaule *_shareVaule;

@implementation ShareVaule

+(ShareVaule *)shareInstance;{
    if (!_shareVaule) {
        _shareVaule = [[ShareVaule alloc]init];
    }
    return _shareVaule;
}

-(id)init{
    self = [super init];
    if (self) {
        _stepImageDic = [[NSMutableDictionary alloc]init];
        _noChanged = YES;
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAPPID andDelegate:nil];
        _sinaweibo = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI andDelegate:nil];
    }
    return self;
}

-(void)setQqName:(NSString *)qqName{
    [[NSUserDefaults standardUserDefaults]setValue:qqName forKey:@"QQNAME"];
}

-(NSString *)qqName{
    return [[NSUserDefaults standardUserDefaults]stringForKey:@"QQNAME"];
}

-(void)setSinaweiboName:(NSString *)sinaName{
    [[NSUserDefaults standardUserDefaults]setValue:sinaName forKey:@"SIANNAME"];
}

-(NSString *)sinaweiboName{
    return [[NSUserDefaults standardUserDefaults]stringForKey:@"SIANNAME"];
}

-(void)dealloc{
    [_tencentOAuth release];
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

- (NSString *)nameForBindSina
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"nameForBindSina"];
}

- (void)setNameForBindSina:(NSString *)nameForBindSina
{
    [[NSUserDefaults standardUserDefaults] setValue:nameForBindSina forKey:@"nameForBindSina"];
}

- (NSString *)nameForBindQQ
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"nameForBindQQ"];
}

- (void)setNameForBindQQ:(NSString *)nameForBindQQ
{
    [[NSUserDefaults standardUserDefaults] setValue:nameForBindQQ forKey:@"nameForBindQQ"];
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
    
    NSMutableArray * imageArray = [NSMutableArray arrayWithCapacity:steps.count];
    for (JCStep *step in steps) {
        NSData *data = [[ShareVaule shareInstance]getImageDataByStep:step];
        if (!data) {
            [imageArray addObject:[NSNull null]];
        }else{
            [imageArray addObject:[NSData dataWithData:data]];
        }
    }
    int index = [steps indexOfObject:step];
    [steps removeObjectAtIndex:index];
    [imageArray removeObjectAtIndex:index];
    [[ShareVaule shareInstance].stepImageDic removeAllObjects];
    
    for (int i=0; i<steps.count; i++) {
        JCStep *step = (JCStep *)[steps objectAtIndex:i];
        step.ordinal = i+1;
        
        NSData *data  = [imageArray objectAtIndex:i];
        if (![data isEqual: [NSNull null]]) {
            [[ShareVaule shareInstance]putImageData:data step:step];
        }
    }
    _noChanged = NO;
    [self postNotification:NOTIFICATION_ORDINALCHANGE];
}

-(void)moveStepFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;{
    
    
    NSMutableArray *steps = (NSMutableArray *)[ShareVaule shareInstance].editGuideEx.steps;
    
    NSMutableArray * imageArray = [NSMutableArray arrayWithCapacity:steps.count];
    for (JCStep *step in steps) {
        NSData *data = [[ShareVaule shareInstance]getImageDataByStep:step];
        if (!data) {
            [imageArray addObject:[NSNull null]];
        }else{
            [imageArray addObject:[NSData dataWithData:data]];
        }
    }
    
    [[ShareVaule shareInstance].stepImageDic removeAllObjects];
    
    JCStep *oldStep = [steps objectAtIndex:fromIndex];
    [steps removeObjectAtIndex:fromIndex];
    [steps insertObject:oldStep atIndex:toIndex];
    

    NSObject *oldData = [imageArray objectAtIndex:fromIndex];
    [imageArray removeObjectAtIndex:fromIndex];
    [imageArray insertObject:oldData atIndex:toIndex];
    
    
    for (int i=0; i<steps.count; i++) {
        JCStep *step = (JCStep *)[steps objectAtIndex:i];
        step.ordinal = i+1;
        
        NSData *data  = [imageArray objectAtIndex:i];
        if (![data isEqual: [NSNull null]]) {
            [[ShareVaule shareInstance]putImageData:data step:step];
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

-(NSData *)getImageDataByStepOrdinal:(int)ordinal;{
    NSString *stepOrdinal = [NSString stringWithFormat:@"%d",ordinal];
    return  [_stepImageDic objectForKey:stepOrdinal];
}

-(NSData *)getImageDataByStep:(JCStep *)step;{
    NSString *stepOrdinal = [NSString stringWithFormat:@"%d",step.ordinal];
    return  [_stepImageDic objectForKey:stepOrdinal];
}

-(void)removeImageDataByStep:(JCStep *)step;{
    NSString *stepOrdinal = [NSString stringWithFormat:@"%d",step.ordinal];
    [_stepImageDic removeObjectForKey:stepOrdinal];
}

+(void)addDriverByName:(NSString *)name devId:(NSString *)devId{
    NSMutableDictionary *temp =  nil;
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults]dictionaryForKey:DRIVERKEY];
    if (dict) {
        temp = [NSMutableDictionary dictionaryWithDictionary:dict];
    }else{
        temp = [NSMutableDictionary dictionary];
    }
    [temp setValue:name forKey:devId];
    [[NSUserDefaults standardUserDefaults]setValue:temp forKey:DRIVERKEY];
}

+(NSString *)devIdByName:(NSString *)name{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults]dictionaryForKey:DRIVERKEY];
    if (dict) {
        return [dict objectForKey:name];
    }
    return nil;
}

+(NSArray *)allDriverNames{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults]dictionaryForKey:DRIVERKEY];
    if (dict) {
        return dict.allKeys;
    }
    return nil;
}

+(BOOL)devNameExits:(NSString *)name;{
     NSDictionary *dict = [[NSUserDefaults standardUserDefaults]dictionaryForKey:DRIVERKEY];
    if (dict) {
        return [dict objectForKey:name] != nil;
    }
    return NO;
}

+(void)deleteDirverByName:(NSString *)name;{
    NSMutableDictionary *temp =  nil;
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults]dictionaryForKey:DRIVERKEY];
    if (dict) {
        temp = [NSMutableDictionary dictionaryWithDictionary:dict];
    }else{
        temp = [NSMutableDictionary dictionary];
    }
    [temp removeObjectForKey:name];
    [[NSUserDefaults standardUserDefaults]setValue:temp forKey:DRIVERKEY];

}

+(NSString *)formatDate:(NSString *)dateString;{
    NSDate *date = [dateString date];
    NSInteger subtime = abs([date timeIntervalSinceNow]);
    if (subtime < 60) {
        return @"刚刚";
    }
    if (subtime < 60 * 60) {
        return [NSString stringWithFormat:@"%d分钟前",subtime/60];
    }
    if ([[date stringWithDateFormat:@"yyyy-MM-dd"] isEqual:[[NSDate date]stringWithDateFormat:@"yyyy-MM-dd"]]) {
        return [NSString stringWithFormat:@"今天 %@",[date stringWithDateFormat:@"HH:mm"]];
    }
    
    NSInteger time = [[NSDate date] timeIntervalSinceNow];
    time -= 60 * 60 *24;
    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:time];
    if ([[date stringWithDateFormat:@"yyyy-MM-dd"] isEqual:[yesterday stringWithDateFormat:@"yyyy-MM-dd"]]) {
        return [NSString stringWithFormat:@"昨天 %@",[date stringWithDateFormat:@"HH:mm"]];
    }
    if ([[date stringWithDateFormat:@"yyyy"] isEqual:[[NSDate date]stringWithDateFormat:@"yyyy"]]) {
        return [date stringWithDateFormat:@"MM-dd HH:mm"];
    }
    return [date stringWithDateFormat:@"yyyy-MM-dd HH:mm"];
}

@end
