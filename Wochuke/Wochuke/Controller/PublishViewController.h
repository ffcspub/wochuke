//
//  PublishViewController.h
//  Wochuke
//
//  Created by he songhang on 13-7-9.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublishViewController : BaseViewController

@property (retain, nonatomic) IBOutlet UIImageView *iv_photo;

@property (retain, nonatomic) IBOutlet UIView *photoBackview;

@property (retain, nonatomic) IBOutlet UIButton *btn_type;

- (IBAction)typeChooseAction:(id)sender;

- (IBAction)backAction:(id)sender;

- (IBAction)pubishAction:(id)sender;


@end
