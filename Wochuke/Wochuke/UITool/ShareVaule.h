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

#define kAppKey             @"732356489"
#define kAppSecret          @"ef8ddba071d92652c0f65b4aff79a451"
#define kAppRedirectURI     @"http://www.sina.com.cn"

#import <Foundation/Foundation.h>
#import <Guide.h>

@interface ShareVaule : NSObject{
    
}

+(ShareVaule *)shareInstance;

@property(nonatomic,retain) JCGuideEx *editGuideEx;

@property(nonatomic,retain) JCUser *user;

@property(nonatomic,retain) NSString *userId;

@property(nonatomic,retain) NSMutableDictionary *stepImageDic;

-(void)removeStep:(JCStep *)step;

-(void)moveStepFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end