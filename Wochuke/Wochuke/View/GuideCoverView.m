//
//  GuideCoverView.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "GuideCoverView.h"
#import "MyWebImgView.h"

@implementation GuideCoverView

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    backImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    imageView.frame = CGRectMake(11, 11, self.frame.size.width -22 , self.frame.size.height - 22);
    tagImageView.frame = CGRectMake(0, 20, 73, 25);
    lb_type.frame = CGRectMake(14, 20, 100, 20);
    lb_name.frame = CGRectMake(18, self.frame.size.height - 22 - 50, self.frame.size.width - 36, 35);
    lb_publisher.frame = CGRectMake(18, self.frame.size.height - 22 - 20, self.frame.size.width - 36, 20);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backImageView = [[[UIImageView alloc]init]autorelease];
        UIImage *backImage = [[UIImage imageNamed:@"lightBoard"]resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
        [backImageView setImage:backImage];
        
        tagImageView = [[[UIImageView alloc]init]autorelease];
        tagImageView.image = [UIImage imageNamed:@"tag_home_card"];
        
        // Initialization code
        imageView = [[[MyWebImgView alloc]init]autorelease];
        imageView.layer.cornerRadius = 6;
        imageView.layer.masksToBounds = YES;
        imageView.showProgress = YES;
        
        lb_type = [[[UILabel alloc]init]autorelease];
        lb_type.font = [UIFont systemFontOfSize:14];
        lb_type.backgroundColor = [UIColor clearColor];
        lb_type.textColor = [UIColor whiteColor];
        
        lb_name = [[[UILabel alloc]init]autorelease];
        lb_name.font = [UIFont systemFontOfSize:16];
        lb_name.backgroundColor = [UIColor clearColor];
        lb_name.textColor = [UIColor whiteColor];
        lb_name.numberOfLines = 2;
        
        lb_publisher = [[[UILabel alloc]init]autorelease];
        lb_publisher.font = [UIFont systemFontOfSize:13];
        lb_publisher.backgroundColor = [UIColor clearColor];
        lb_publisher.textColor = [UIColor whiteColor];
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:backImageView];
        [self addSubview:imageView];
        [self addSubview:tagImageView];
        [self addSubview:lb_type];
        [self addSubview:lb_name];
        [self addSubview:lb_publisher];
        
    }
    return self;
}

-(void)dealloc{
    [_guide release];
    [super dealloc];
}


-(void)upGuide:(JCGuide *)mguide;{
    self.guide = mguide;
    lb_name.text = mguide.title;
    if (mguide.userName.length >0) {
        lb_publisher.text = [NSString stringWithFormat:@"by %@",mguide.userName];
    }else{
        lb_publisher.text = nil;
    }
    lb_type.text = mguide.typeName;
    [imageView setImageWithURL:[NSURL URLWithString:mguide.cover.url]];
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

