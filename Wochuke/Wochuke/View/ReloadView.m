//
//  ReloadView.m
//  Wochuke
//
//  Created by he songhang on 13-6-28.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "ReloadView.h"

@implementation ReloadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        lb_text = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]autorelease];
        [self addSubview:lb_text];
        lb_text.font = [UIFont systemFontOfSize:15];
        lb_text.textAlignment = UITextAlignmentCenter;
        lb_text.textColor = [UIColor grayColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)setTitle:(NSString *)title{
    lb_text.text = title;
}

-(void)handleSingleTapFrom:(UITapGestureRecognizer *)gestureRecognizer{
    [self.target performSelector:_action];
    [self removeFromSuperview];
}


+(id)showInView:(UIView *)view message:(NSString *)message target:(id)target action:(SEL) action;{
    ReloadView *reloadView = [[[ReloadView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)]autorelease];
    reloadView.target = target;
    reloadView.action = action;
    [reloadView setTitle:message];
    UITapGestureRecognizer* singleRecognizer;  
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:reloadView action:@selector(handleSingleTapFrom:)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击  
    [reloadView addGestureRecognizer:singleRecognizer];  
    [view addSubview:reloadView];
    return reloadView;
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
