//
//  UserView.h
//  Wochuke
//
//  Created by he songhang on 13-7-5.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bee_UIGridCell.h"

@interface UserView : UIView

@end

@interface UserCell : BeeUIGridCell{
    UIImageView *iv_heard;//头像
    UILabel *lb_name;//姓名
    UILabel *lb_guides;//多少条指南
    UIButton *btn_following;//关注
}

@end
