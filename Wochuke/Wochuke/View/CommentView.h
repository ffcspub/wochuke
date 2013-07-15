//
//  CommentView.h
//  Wochuke
//
//  Created by he songhang on 13-7-5.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bee_UIGridCell.h"

@interface CommentView : UIView

@end


@interface CommentCell : BeeUIGridCell{
    UIImageView *iv_heard;//头像
    UILabel *lb_name;//姓名
    UILabel *lb_comment;//评论内容
    UILabel *lb_time;//时间
    UIView *line;
}

@end