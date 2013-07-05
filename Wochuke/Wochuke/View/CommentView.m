//
//  CommentView.m
//  Wochuke
//
//  Created by he songhang on 13-7-5.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "CommentView.h"

#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "MyWebImgView.h"

@implementation CommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end


@implementation CommentCell

+ (CGSize)sizeInBound:(CGSize)bound forData:(NSObject *)data
{
	return bound;
}

- (void)layoutInBound:(CGSize)bound forCell:(BeeUIGridCell *)cell
{
    iv_heard.frame = CGRectMake(10, 10, bound.width -20, bound.height -20);
    lb_name.frame = CGRectMake(bound.height, 10, bound.width - 80, (bound.height-20)/2);
    lb_comment.frame = CGRectMake(bound.height, (bound.height-20)/2, bound.width - 80, (bound.height-20)/2);
    lb_time.frame = CGRectMake(bound.width - 90, 10, 60, (bound.height-20)/2);
}

- (void)dataDidChanged
{
    if (self.cellData) {
        JCComment *comment = self.cellData;
        [iv_heard setImageWithURL:[NSURL URLWithString:comment.userAvatar.url]];
        lb_name.text = comment.userName;
        lb_comment.text = [NSString stringWithFormat:@"%@",comment.content];
        lb_time.text = [comment.timestamp substringWithRange:NSMakeRange(6, 11)];
    }
}

- (void)load
{
    iv_heard = [[[MyWebImgView alloc]init]autorelease];
    iv_heard.contentMode = UIViewContentModeScaleAspectFill;
    iv_heard.layer.cornerRadius = 6;
    iv_heard.layer.masksToBounds = YES;
    
    lb_name = [[[UILabel alloc]init]autorelease];
    lb_name.font = [UIFont boldSystemFontOfSize:11];
    lb_name.backgroundColor = [UIColor grayColor];
    lb_name.textColor = [UIColor darkTextColor];
    lb_name.textAlignment = UITextAlignmentLeft;
    lb_name.numberOfLines = 2;
    
    lb_comment = [[[UILabel alloc]init]autorelease];
    lb_comment.font = [UIFont boldSystemFontOfSize:11];
    lb_comment.backgroundColor = [UIColor clearColor];
    lb_comment.textColor = [UIColor darkTextColor];
    lb_comment.textAlignment = UITextAlignmentLeft;
    
    lb_time = [[[UILabel alloc]init]autorelease];
    lb_time.font = [UIFont boldSystemFontOfSize:11];
    lb_time.backgroundColor = [UIColor clearColor];
    lb_time.textColor = [UIColor darkTextColor];
    lb_time.textAlignment = UITextAlignmentLeft;
    
    [self addSubview:iv_heard];
    [self addSubview:lb_name];
    [self addSubview:lb_comment];
    [self addSubview:lb_time];
    
}


@end