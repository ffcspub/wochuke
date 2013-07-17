//
//  StepPreviewController.h
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import <Guide.h>
#import "NSObject+Notification.h"

@interface StepPreviewController : BaseViewController<GMGridViewDataSource,GMGridViewActionDelegate>{
   IBOutlet GMGridView *_girdView;
}

@property(nonatomic,retain) JCGuide *guide;
@property(nonatomic,retain) JCGuideDetail *detail;

AS_NOTIFICATION(TAP)

@end
