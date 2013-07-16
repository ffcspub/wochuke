//
//  CommentViewController.h
//  Wochuke
//
//  Created by he songhang on 13-7-5.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Guide.h>
#import "HPGrowingTextView.h"

@interface CommentViewController : UIViewController <HPGrowingTextViewDelegate>{
	UIView *containerView;
    HPGrowingTextView *textView;
}

@property(nonatomic,retain) JCGuide *guide;

@property(nonatomic,retain) JCStep *step;

@property (retain, nonatomic) IBOutlet UILabel *lb_empty;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)backAction:(id)sender;

@end
