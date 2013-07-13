//
//  FeedbackViewController.h
//  Wochuke
//
//  Created by Geory on 13-7-7.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@interface FeedbackViewController : UIViewController<UITextFieldDelegate>{
    HPGrowingTextView *textView;
}

@property (retain, nonatomic) IBOutlet UIImageView *iv_back;
@property (retain, nonatomic) IBOutlet UITextField *tf_phone;

- (IBAction)backAction:(id)sender;
- (IBAction)sendAction:(id)sender;
- (IBAction)backgroundClick:(id)sender;
@end
