//
//  ShareViewController.h
//  Wochuke
//
//  Created by hesh on 13-7-15.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@interface ShareViewController : BaseViewController

@property(nonatomic,retain) NSString *titleText;
@property(nonatomic,retain) NSString *content;
@property(nonatomic,assign) int type;
@property(nonatomic,retain) NSString *imageUrl;

@property (retain, nonatomic) IBOutlet UILabel *lb_count;

@property (retain, nonatomic) IBOutlet HPGrowingTextView *tv_content;

- (IBAction)backAction:(id)sender;

- (IBAction)shareAction:(id)sender;


@end
