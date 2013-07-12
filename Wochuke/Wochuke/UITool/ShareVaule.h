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
#define NOTIFICATION_COMMENTCOUNTCHANGE @"NOTIFICATION_COMMENTCOUNTCHANGE"
#define NOTIFICATION_FAVORITECOUNT @"NOTIFICATION_FAVORITECOUNT"
#define NOTIFICATION_VIEWCOUNTCHANGE @"NOTIFICATION_VIEWCOUNTCHANGE"
#define NOTIFICATION_FOLLOWSTATECHANGE @"NOTIFICATION_FOLLOWSTATECHANGE"

#define KEY_TYPELIST @"KEY_TYPELIST"

#define QQAPPID   @"100454485"

#define kAppKey             @"732356489"
#define kAppSecret          @"ef8ddba071d92652c0f65b4aff79a451"
#define kAppRedirectURI     @"http://www.sina.com.cn"

#define KShareSDKAppKey     @"5baad35997a"


#define FILEBLOCKLENGTH 2048

#define UITEXTVIEW_MARGIN 10.0

#import <Foundation/Foundation.h>
#import <Guide.h>

@interface ShareVaule : NSObject{
    
}

+(ShareVaule *)shareInstance;

@property(nonatomic,retain) JCGuideEx *editGuideEx;

@property(nonatomic,retain) JCUser *user;

@property(nonatomic,retain) NSString *userId;

@property(nonatomic,retain) NSMutableDictionary *stepImageDic;

@property(nonatomic,retain) NSData *guideImage;

@property(nonatomic,assign) BOOL noChanged;

-(void)removeStep:(JCStep *)step;

-(void)moveStepFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

-(void)putImageData:(NSData *)data step:(JCStep *)step;

-(NSData *)getImageDataByStep:(JCStep *)step;

-(void)removeImageDataByStep:(JCStep *)step;

+(void)addDriverByName:(NSString *)name devId:(NSString *)devId;

+(NSString *)devIdByName:(NSString *)name;

+(BOOL)devNameExits:(NSString *)name;

+(void)deleteDirverByName:(NSString *)name;

+(NSArray *)allDriverNames;

@end