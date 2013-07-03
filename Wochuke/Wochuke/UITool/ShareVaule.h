//
//  ShareVaule.h
//  Wochuke
//
//  Created by he songhang on 13-6-26.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#define ERROR_MESSAGE @":<，网络无法连接了.."

#define NOTIFICATION_HIDETOOLBAR @"NOTIFICATION_HIDETOOLBAR"
#define NOTIFICATION_SHOWTOOLBAR @"NOTIFICATION_SHOWTOOLBAR"

#define NOTIFICATION_SUPPLIECELLDELETE @"NOTIFICATION_SUPPLIECELLDELETE"

#define NOTIFICATION_ORDINALCHANGE @"NOTIFICATION_ORDINALCHANGE"

#define KEY_TYPELIST @"KEY_TYPELIST"

#import <Foundation/Foundation.h>
#import <Guide.h>

@interface ShareVaule : NSObject{
    
}

+(ShareVaule *)shareInstance;

@property(nonatomic,retain) JCGuideEx *editGuideEx;

@property(nonatomic,retain) NSMutableDictionary *stepImageDic;

-(void)removeStep:(JCStep *)step;

-(void)moveStepFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end