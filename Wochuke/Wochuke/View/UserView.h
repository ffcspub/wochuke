//
//  UserView.h
//  Wochuke
//
//  Created by he songhang on 13-7-5.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bee_UIGridCell.h"
#import <Guide.h>

@interface UserView : UIView

@end

@protocol UserCellDeleagte ;

@interface UserCell : BeeUIGridCell{
    UIImageView *iv_heard;//头像
    UILabel *lb_name;//姓名
    UILabel *lb_guides;//多少条指南
    UIButton *btn_following;//关注
}

@property(nonatomic,assign) id<UserCellDeleagte> delegate;

@end

@protocol UserCellDeleagte <NSObject>

-(void) followUser:(JCUser *)user;

@end
