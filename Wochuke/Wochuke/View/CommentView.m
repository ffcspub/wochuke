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
    if (data) {
        JCComment *comment = (JCComment *)data;
        CGSize size = [comment.content sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(bound.width - 80, 100) lineBreakMode:NSLineBreakByWordWrapping];
       CGFloat subheight =  size.height - (bound.height-20)/2;
        if (subheight > 0) {
            return CGSizeMake(bound.width, bound.height + subheight);
        }
    }
	return bound;
}

- (void)layoutInBound:(CGSize)bound forCell:(BeeUIGridCell *)cell
{
    iv_heard.frame = CGRectMake(10, (bound.height - 40)/2, 40, 40);
    lb_name.frame = CGRectMake(60, 10, bound.width - 80, (bound.height-20)/2);
//    JCComment *comment = self.cellData;
//    CGSize size = [comment.content sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(bound.width - 80, 100) lineBreakMode:NSLineBreakByWordWrapping];
//    CGFloat subheight =  size.height - (bound.height-20)/2;
//    if (subheight < 0) {
//        subheight = 0;
//    }
    lb_comment.frame = CGRectMake(60, bound.height/2 ,  bound.width - 80, bound.height/2 - 10);
    lb_time.frame = CGRectMake(bound.width - 90, 10, 60, (bound.height-20)/2);
}

- (void)dataDidChanged
{
    if (self.cellData) {
        JCComment *comment = self.cellData;
        [iv_heard setImageWithURL:[NSURL URLWithString:comment.userAvatar.url] placeholderImage:[UIImage imageNamed:@"ic_user_top"]];
        lb_name.text = comment.userName;
        lb_comment.text = [NSString stringWithFormat:@"%@",comment.content];
        lb_time.text = [ShareVaule formatDate:comment.timestamp];
    }
}

- (void)load
{
    iv_heard = [[[MyWebImgView alloc]init]autorelease];
    iv_heard.contentMode = UIViewContentModeScaleAspectFill;
    iv_heard.layer.cornerRadius = 6;
    iv_heard.layer.masksToBounds = YES;
    
    lb_name = [[[UILabel alloc]init]autorelease];
    lb_name.font = [UIFont boldSystemFontOfSize:13];
    lb_name.backgroundColor = [UIColor clearColor];
    lb_name.textColor = [UIColor grayColor];
    lb_name.textAlignment = UITextAlignmentLeft;
    lb_name.numberOfLines = 2;
    
    
    lb_comment = [[[UILabel alloc]init]autorelease];
    lb_comment.font = [UIFont boldSystemFontOfSize:11];
    lb_comment.backgroundColor = [UIColor clearColor];
    lb_comment.textColor = [UIColor darkTextColor];
    lb_comment.textAlignment = UITextAlignmentLeft;
    lb_comment.numberOfLines = 10;
    lb_comment.lineBreakMode = NSLineBreakByWordWrapping;
    
    lb_time = [[[UILabel alloc]init]autorelease];
    lb_time.font = [UIFont boldSystemFontOfSize:10];
    lb_time.backgroundColor = [UIColor clearColor];
    lb_time.textColor = [UIColor grayColor];
    lb_time.textAlignment = UITextAlignmentLeft;
    
    [self addSubview:iv_heard];
    [self addSubview:lb_name];
    [self addSubview:lb_comment];
    [self addSubview:lb_time];
    
}


@end