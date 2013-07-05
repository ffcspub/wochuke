//
//  UserView.m
//  Wochuke
//
//  Created by he songhang on 13-7-5.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "UserView.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "MyWebImgView.h"

@implementation UserView

@end

@implementation UserCell

+ (CGSize)sizeInBound:(CGSize)bound forData:(NSObject *)data
{
	return bound;
}

- (void)layoutInBound:(CGSize)bound forCell:(BeeUIGridCell *)cell
{
    iv_heard.frame = CGRectMake(5, 5, bound.width -10, bound.height -10);
    lb_name.frame = CGRectMake(bound.height, 5, bound.width - 60, (bound.height-10)/2);
    lb_guides.frame = CGRectMake(bound.height, (bound.height-10)/2, bound.width - 60, (bound.height-10)/2);
    btn_following.frame = CGRectMake(bound.width - 50, 5, 40, bound.height-10);
}

- (void)dataDidChanged
{
    if (self.cellData) {
        JCUser *user = self.cellData;
        [iv_heard setImageWithURL:[NSURL URLWithString:user.avatar.url]];
        lb_name.text = user.name;
        lb_guides.text = [NSString stringWithFormat:@"%d条指南",user.guideCount];
        [btn_following setTitle:user.followState>0?@"已关注":@"未关注" forState:UIControlStateNormal];
    }
}

- (void)load
{
    iv_heard = [[[MyWebImgView alloc]init]autorelease];
    iv_heard.contentMode = UIViewContentModeScaleAspectFill;
    iv_heard.layer.cornerRadius = 6;
    iv_heard.layer.masksToBounds = YES;
    
    lb_name = [[[UILabel alloc]init]autorelease];
    lb_name.font = [UIFont boldSystemFontOfSize:12];
    lb_name.backgroundColor = [UIColor clearColor];
    lb_name.textColor = [UIColor darkTextColor];
    lb_name.textAlignment = UITextAlignmentLeft;
    lb_name.numberOfLines = 2;
    
    lb_guides = [[[UILabel alloc]init]autorelease];
    lb_guides.font = [UIFont boldSystemFontOfSize:12];
    lb_guides.backgroundColor = [UIColor clearColor];
    lb_guides.textColor = [UIColor darkTextColor];
    lb_guides.textAlignment = UITextAlignmentLeft;
    
    btn_following = [[UIButton alloc]init];
    [btn_following setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [btn_following setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self addSubview:iv_heard];
    [self addSubview:lb_name];
    [self addSubview:lb_guides];
    [self addSubview:btn_following];
    
}

@end
