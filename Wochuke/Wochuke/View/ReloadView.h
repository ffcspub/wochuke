//
//  ReloadView.h
//  Wochuke
//
//  Created by he songhang on 13-6-28.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReloadView : UIView
{
    UILabel *lb_text;
}

-(void)setTitle:(NSString *)title;

@property(nonatomic,assign) id target;

@property(nonatomic,assign) SEL action;

+(void)showInView:(UIView *)view message:(NSString *)message target:(id)target action:(SEL) action;

@end
