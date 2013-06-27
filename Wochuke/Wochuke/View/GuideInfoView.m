//
//  GuideInfoView.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "GuideInfoView.h"


@implementation GuideInfoView

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    iv_photo.frame = CGRectMake((frame.size.width - 40)/2, 60, 40 , 40);
    lb_title.frame = CGRectMake(0, 20, frame.size.width, 20);
    lb_publisher.frame = CGRectMake(0, 110, frame.size.width, 20);
    CGFloat btnwidth = fabsf((frame.size.width - 100)/3);
    btn_viewCount.frame = CGRectMake(50,130,btnwidth,30);
    btn_favoriteCount.frame = CGRectMake(50 + btnwidth,130,btnwidth,30);
    btn_commentCount.frame = CGRectMake(50 + btnwidth + btnwidth,130,btnwidth,30);
    
    CGSize contentSize = [_guide.description_ sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(frame.size.width - 30, 1000)];
    
    tv_content.frame = CGRectMake(15, 180, contentSize.width +16.0, contentSize.height +16.0);
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        iv_photo = [[[MyWebImgView alloc]init]autorelease];
        iv_photo.layer.cornerRadius = 6;
        iv_photo.layer.masksToBounds = YES;
        
        lb_title = [[[UILabel alloc]init]autorelease];
        lb_title.font = [UIFont boldSystemFontOfSize:18];
        lb_title.backgroundColor = [UIColor clearColor];
        lb_title.textColor = [UIColor darkTextColor];
        lb_title.textAlignment = UITextAlignmentCenter;
        lb_title.numberOfLines = 2;
        
        lb_publisher = [[[UILabel alloc]init]autorelease];
        lb_publisher.font = [UIFont boldSystemFontOfSize:16];
        lb_publisher.backgroundColor = [UIColor clearColor];
        lb_publisher.textColor = [UIColor darkTextColor];
        lb_publisher.textAlignment = UITextAlignmentCenter;
        
        btn_viewCount = [[[UIButton alloc]init]autorelease];
        btn_viewCount.titleLabel.font = [UIFont systemFontOfSize:12];
        btn_viewCount.backgroundColor = [UIColor clearColor];
        [btn_viewCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        btn_favoriteCount = [[[UIButton alloc]init]autorelease];
        btn_favoriteCount.titleLabel.font = [UIFont systemFontOfSize:12];
        btn_favoriteCount.backgroundColor = [UIColor clearColor];
        [btn_favoriteCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        btn_commentCount = [[[UIButton alloc]init]autorelease];
        btn_commentCount.titleLabel.font = [UIFont systemFontOfSize:12];
        btn_commentCount.backgroundColor = [UIColor clearColor];
        [btn_commentCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        tv_content = [[[UITextView alloc]init]autorelease];
        tv_content.font = [UIFont systemFontOfSize:12];
        tv_content.backgroundColor = [UIColor clearColor];
        tv_content.textColor = [UIColor grayColor];
        
        [self addSubview:lb_title];
        [self addSubview:iv_photo];
        [self addSubview:lb_publisher];
        [self addSubview:btn_viewCount];
        [self addSubview:btn_favoriteCount];
        [self addSubview:btn_commentCount];
        [self addSubview:tv_content];
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        
    }
    return self;
}


-(void)setGuide:(JCGuide *)guide{
    if (_guide) {
        [_guide release];
        _guide = nil;
    }
    _guide = [guide retain];
    lb_title.text = _guide.title;
    [iv_photo setImageWithURL:[NSURL URLWithString:_guide.userAvatar.url]];
    lb_publisher.text = _guide.userName;
    [btn_viewCount setTitle:[NSString stringWithFormat:@"%d",_guide.viewCount] forState:UIControlStateNormal];
    [btn_favoriteCount setTitle:[NSString stringWithFormat:@"%d",_guide.favoriteCount] forState:UIControlStateNormal];
    [btn_commentCount setTitle:[NSString stringWithFormat:@"%d",_guide.commentCount] forState:UIControlStateNormal];
    tv_content.text = _guide.description_;
}

-(void)dealloc{
    [_guide release];
    [super dealloc];
}

@end

@implementation GuideInfoMinView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        lb_title.font = [UIFont boldSystemFontOfSize:12];
        lb_publisher.font = [UIFont systemFontOfSize:10];
        lb_title.numberOfLines = 2;
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    iv_photo.frame = CGRectMake((frame.size.width - 30)/2, 40, 30 , 30);
    lb_title.frame = CGRectMake(0, 10, frame.size.width, 30);
    lb_publisher.frame = CGRectMake(0, 80, frame.size.width, 20);
    btn_viewCount.frame = CGRectZero;
    btn_favoriteCount.frame = CGRectZero;
    btn_commentCount.frame = CGRectZero;
}

@end


#pragma mark -Cell

@implementation GuideInfoCell


+ (CGSize)sizeInBound:(CGSize)bound forData:(NSObject *)data
{
	return bound;
}

- (void)layoutInBound:(CGSize)bound forCell:(BeeUIGridCell *)cell
{
    backImageView.frame = CGRectMake(10, 10, bound.width -20, bound.height -20);
    
    iv_photo.frame = CGRectMake(22, 22, bound.width - 44, bound.height - 44);
    lb_title.frame = CGRectMake(32, bound.height - 22 - 50, bound.width - 44 - 64, 20);
    
    line.frame = CGRectMake(22, bound.height - 22 - 25, bound.width - 44, 0.5);
    
    btn_viewCount.frame = CGRectMake(30,bound.height - 22 - 25,40,25);
    btn_favoriteCount.frame = CGRectMake(70 ,bound.height - 22 - 25,40,25);
    btn_commentCount.frame = CGRectMake(110 , bound.height - 22 - 25,40,25);
    lb_publisher.frame = CGRectMake(140, bound.height - 22 - 25, bound.width - 22 - 140 - 10,25);
}

- (void)dataDidChanged
{
    if (self.cellData) {
        JCGuide *_guide = self.cellData;
        lb_title.text = _guide.title;
        [iv_photo setImageWithURL:[NSURL URLWithString:_guide.cover.url]];
        lb_publisher.text = [NSString stringWithFormat:@"by %@",_guide.userName];
        [btn_viewCount setTitle:[NSString stringWithFormat:@"%d",_guide.viewCount] forState:UIControlStateNormal];
        [btn_favoriteCount setTitle:[NSString stringWithFormat:@"%d",_guide.favoriteCount] forState:UIControlStateNormal];
        [btn_commentCount setTitle:[NSString stringWithFormat:@"%d",_guide.commentCount] forState:UIControlStateNormal];
    }
}

- (void)load
{
    iv_photo = [[[MyWebImgView alloc]init]autorelease];
    iv_photo.layer.cornerRadius = 6;
    iv_photo.layer.masksToBounds = YES;
    
    lb_title = [[[UILabel alloc]init]autorelease];
    lb_title.font = [UIFont boldSystemFontOfSize:18];
    lb_title.backgroundColor = [UIColor clearColor];
    lb_title.textColor = [UIColor whiteColor];
    lb_title.textAlignment = UITextAlignmentLeft;
    lb_title.numberOfLines = 2;
    
    lb_publisher = [[[UILabel alloc]init]autorelease];
    lb_publisher.font = [UIFont boldSystemFontOfSize:12];
    lb_publisher.backgroundColor = [UIColor clearColor];
    lb_publisher.textColor = [UIColor whiteColor];
    lb_publisher.textAlignment = UITextAlignmentRight;
    
    btn_viewCount = [[[UIButton alloc]init]autorelease];
    btn_viewCount.titleLabel.font = [UIFont systemFontOfSize:12];
    btn_viewCount.backgroundColor = [UIColor clearColor];
    [btn_viewCount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    btn_favoriteCount = [[[UIButton alloc]init]autorelease];
    btn_favoriteCount.titleLabel.font = [UIFont systemFontOfSize:12];
    btn_favoriteCount.backgroundColor = [UIColor clearColor];
    [btn_favoriteCount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    btn_commentCount = [[[UIButton alloc]init]autorelease];
    btn_commentCount.titleLabel.font = [UIFont systemFontOfSize:12];
    btn_commentCount.backgroundColor = [UIColor clearColor];
    [btn_commentCount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    line = [[[UIView alloc]init]autorelease];
    line.backgroundColor = [UIColor whiteColor];
    
    backImageView = [[[UIImageView alloc]init]autorelease];
    UIImage *backImage = [[UIImage imageNamed:@"lightBoard"]resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [backImageView setImage:backImage];
    
    [self addSubview:backImageView];
    [self addSubview:iv_photo];
    [self addSubview:lb_title];
    [self addSubview:line];
    [self addSubview:lb_publisher];
    [self addSubview:btn_viewCount];
    [self addSubview:btn_favoriteCount];
    [self addSubview:btn_commentCount];
    
}

@end


@implementation GuideInfoMinCell

- (void)layoutInBound:(CGSize)bound forCell:(BeeUIGridCell *)cell
{
    backImageView.frame = CGRectZero;
    
    iv_photo.frame = CGRectMake(10, 10, 50, 50);
    lb_title.frame = CGRectMake(70, 10, bound.width - 60 - 14, 30);
    
    line.frame = CGRectMake(0, bound.height - 1, bound.width, 0.5);
    
    btn_viewCount.frame = CGRectMake(60, 40, 40, 25);
    btn_favoriteCount.frame = CGRectMake(100 ,40,40,25);
    btn_commentCount.frame = CGRectMake(140 , 40,40,25);
    lb_publisher.frame = CGRectMake(170, 40, bound.width - 170 - 10,25);
}

- (void)load
{
    [super load];
    iv_photo.layer.cornerRadius = 4;
    self.backgroundColor = [UIColor whiteColor];
    line.backgroundColor = [UIColor grayColor];
    lb_publisher.textColor = [UIColor grayColor];
    lb_publisher.font = [UIFont systemFontOfSize:10];
    lb_title.font = [UIFont boldSystemFontOfSize:16];
    lb_title.numberOfLines = 2;
    lb_title.textColor = [UIColor darkTextColor];
    [btn_commentCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn_favoriteCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn_viewCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}
@end
