//
//  StepView.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "StepView.h"
#import "UIImagePreView.h"
#import "NSObject+Notification.h"

@implementation StepView

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    backImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    tagImageView.frame = CGRectMake(0, 20, 45, 25);
    lb_step.frame = CGRectMake(10, 20, 35, 20);
    CGSize size = [_step.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(frame.size.width -14, 1000)];
    btn_comment.frame = CGRectMake(11, frame.size.height - 11 - 30, 40, 30);
    lb_comment.frame = CGRectMake(52, frame.size.height - 11 - 30, 40, 30);
    
    if (_step.photo.url){
        imageView.frame = CGRectMake(11, 11, frame.size.width -22 , frame.size.height - 22 - 45 - MIN(size.height, 100));
        lb_text.frame = CGRectMake(11, frame.size.height - 22 - 30 - size.height, size.width, MIN(size.height, 100));
    }else{
        imageView.frame = CGRectZero;
        lb_text.frame = CGRectMake(11,  11 , frame.size.width - 22, frame.size.height - 22 - 40);
    }
}

-(void)imageTap{
    [UIImagePreView showInView:imageView image:imageView.image];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        backImageView = [[[UIImageView alloc]init]autorelease];
        UIImage *backImage = [[UIImage imageNamed:@"lightBoard"]resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
        [backImageView setImage:backImage];
        
        tagImageView = [[[UIImageView alloc]init]autorelease];
        tagImageView.contentMode = UIViewContentModeScaleToFill;
        tagImageView.image = [UIImage imageNamed:@"tag_home_card"];
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:backImageView];
        
        // Initialization code
        imageView = [[[MyWebImgView alloc]init]autorelease];
        imageView.layer.cornerRadius = 6;
        imageView.layer.masksToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.showProgress = YES;
        [self addSubview:imageView];
        
        [self addSubview:tagImageView];
        
        lb_step = [[[UILabel alloc]init]autorelease];
        lb_step.font = [UIFont systemFontOfSize:14];
        lb_step.backgroundColor = [UIColor clearColor];
        lb_step.textColor = [UIColor whiteColor];
        [self addSubview:lb_step];
        
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer* singleRecognizer;
        singleRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)]autorelease];
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        [imageView addGestureRecognizer:singleRecognizer];
        
        lb_text = [[[UILabel alloc]init]autorelease];
        lb_text.font = [UIFont systemFontOfSize:14];
        lb_text.backgroundColor = [UIColor clearColor];
        lb_text.textColor = [UIColor darkTextColor];
        lb_text.numberOfLines = 100;
        
        [self addSubview:lb_text];
        
        btn_comment = [[[UIButton alloc]init]autorelease];
        btn_comment.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn_comment setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self addSubview:btn_comment];
        
        lb_comment = [[[UILabel alloc]init]autorelease];
        lb_comment.font = [UIFont systemFontOfSize:14];
        lb_comment.backgroundColor = [UIColor clearColor];
        lb_comment.textColor = [UIColor grayColor];
        lb_comment.text = @"评论";
        [self addSubview:lb_comment];
    }
    return self;
}

-(void)dealloc{
    [_step release];
    [super dealloc];
}

-(void)setStep:(JCStep *)step{
    if (_step) {
        [_step release];
        _step = nil;
    }
    _step = [step retain];
    lb_step.text = [NSString stringWithFormat:@"%d/%d",step.ordinal,_stepCount];
    [btn_comment setTitle: [NSString stringWithFormat:@"%d",_step.commentCount] forState:UIControlStateNormal];
    lb_text.text = step.text;
    if (_step.photo.url) {
        [imageView setImageWithURL:[NSURL URLWithString:_step.photo.url]];
        lb_text.font = [UIFont systemFontOfSize:14];
    }else{
        [imageView setImage:nil];
        lb_text.font = [UIFont systemFontOfSize:18];
    }
}

-(void)setStepCount:(int)stepCount{
    _stepCount = stepCount;
    lb_step.text = [NSString stringWithFormat:@"%d/%d",_step.ordinal,_stepCount];
}

@end

@implementation StepEditView

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    backImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    tagImageView.frame = CGRectMake(0, 20, 45, 25);
    lb_step.frame = CGRectMake(10, 20, 35, 20);
    CGSize size = [_step.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(frame.size.width -22 - 16, 1000)];
    imageView.frame = CGRectMake(11, 11, frame.size.width -22 , frame.size.height - 22 - 45 - MIN(size.height+16, 150));
    tv_text.frame = CGRectMake(11, frame.size.height - 22 - 30 - size.height - 8 , size.width + 16, MIN(size.height + 16, 150));
}

-(void)imageTap{
    if (_delegate && [_delegate respondsToSelector:@selector(imageTapFromStepEditView:)]) {
        [_delegate imageTapFromStepEditView:self];
    }
}

-(void)upImage;{
    NSData *data = (NSData *)[[ShareVaule shareInstance].stepImageDic objectForKey:[NSNumber numberWithInt:_step.ordinal]];
    if (data) {
        [imageView setImage:[UIImage imageWithData:data]];
    }else{
        [imageView setImageWithURL:[NSURL URLWithString:_step.photo.url]];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        backImageView = [[[UIImageView alloc]init]autorelease];
        UIImage *backImage = [[UIImage imageNamed:@"lightBoard"]resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
        [backImageView setImage:backImage];
        
        tagImageView = [[[UIImageView alloc]init]autorelease];
        tagImageView.contentMode = UIViewContentModeScaleToFill;
        tagImageView.image = [UIImage imageNamed:@"tag_home_card"];
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:backImageView];
        
        // Initialization code
        imageView = [[[MyWebImgView alloc]init]autorelease];
        imageView.backgroundColor = [UIColor grayColor];
        imageView.layer.cornerRadius = 6;
        imageView.layer.masksToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.showProgress = YES;
        [self addSubview:imageView];
        
        [self addSubview:tagImageView];
        
        lb_step = [[[UILabel alloc]init]autorelease];
        lb_step.font = [UIFont systemFontOfSize:14];
        lb_step.backgroundColor = [UIColor clearColor];
        lb_step.textColor = [UIColor whiteColor];
        [self addSubview:lb_step];
        
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer* singleRecognizer;
        singleRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)]autorelease];
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        [imageView addGestureRecognizer:singleRecognizer];
        
        tv_text = [[[HPGrowingTextView alloc]init]autorelease];
        tv_text.font = [UIFont systemFontOfSize:14];
        tv_text.backgroundColor = [UIColor clearColor];
        tv_text.textColor = [UIColor darkTextColor];
        tv_text.delegate = self;
        tv_text.placeholder = @"步骤内容描述";
        tv_text.maxNumberOfLines = 6;
        tv_text.textMaxLength = 200;
        [self addSubview:tv_text];
        
        UITapGestureRecognizer* viewsingleRecognizer = nil;
        viewsingleRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)]autorelease];
        viewsingleRecognizer.numberOfTapsRequired = 1; // 单击
        [self addGestureRecognizer:viewsingleRecognizer];
        self.userInteractionEnabled = YES;
        
    }
    return self;
}

#pragma mark -HPGrowingTextViewDelegate

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = growingTextView.frame.size.height - height;
    growingTextView.frame = CGRectMake(growingTextView.frame.origin.x, growingTextView.frame.origin.y + diff, growingTextView.frame.size.width, growingTextView.frame.size.height - diff);
    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width,imageView.frame.size.height + diff);
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView;{
    if (growingTextView == tv_text) {
        oldCenter = self.center;
        [UIView animateWithDuration:0.3 animations:^{
            self.center = CGPointMake(oldCenter.x, oldCenter.y - 220);
            imageView.userInteractionEnabled = NO;
            panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
            [self addGestureRecognizer:panGestureRecognizer];
        }];
    }
    return YES;
}


-(void)hideKeyBoard{
    [tv_text resignFirstResponder];
    if (oldCenter.y > 0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.center = oldCenter;
            imageView.userInteractionEnabled = YES;
            [self removeGestureRecognizer:panGestureRecognizer];
            [panGestureRecognizer release];
            panGestureRecognizer = nil;
        }];
    }
}

-(void)dealloc{
    [panGestureRecognizer release];
    [_step release];
    [super dealloc];
}

-(void)setStep:(JCStep *)step{
    if (_step) {
        [_step release];
        _step = nil;
    }
    _step = [step retain];
    lb_step.text = [NSString stringWithFormat:@"%d",step.ordinal];
    tv_text.text = step.text;
    tv_text.font = [UIFont systemFontOfSize:14];
    [self upImage];
}



@end

@implementation StepMinView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor clearColor];
//        self.layer.cornerRadius = 6;
//        self.layer.masksToBounds = YES;
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    backImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    tagImageView.frame = CGRectMake(0, 15, 25, 25);
    lb_step.frame = CGRectMake(10, 20, 15, 20);
    btn_comment.frame = CGRectZero;
    lb_comment.frame = CGRectZero;
    if (self.step.photo.url){
        imageView.frame = CGRectMake(10, 10, frame.size.width -20 , frame.size.height - 50);
        lb_text.frame = CGRectMake(10, frame.size.height - 35  , frame.size.width -20, 25);
    }else{
        imageView.frame = CGRectZero;
        lb_text.frame = CGRectMake(10,  10 , frame.size.width - 20, frame.size.height - 20);
    }
}

-(void)setStep:(JCStep *)step{
    [super setStep:step];
    lb_step.text = [NSString stringWithFormat:@"%d",step.ordinal];
    if (step.photo.url) {
        lb_text.font = [UIFont systemFontOfSize:11];
    }else{
        [imageView setImage:nil];
        lb_text.font = [UIFont systemFontOfSize:14];
    }
}

-(void)imageTap{
   
}

@end
