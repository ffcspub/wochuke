//
//  StepEditController.h
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import <Guide.h>

@interface StepEditController : UIViewController<GMGridViewDataSource,GMGridViewSortingDelegate,GMGridViewActionDelegate>{
   IBOutlet GMGridView *_girdView;
    IBOutlet UIButton *btn_add;
}

@property(nonatomic,retain) JCGuide *guide;

- (IBAction)createStepAction:(id)sender;

- (IBAction)publishAction:(id)sender;

@end
