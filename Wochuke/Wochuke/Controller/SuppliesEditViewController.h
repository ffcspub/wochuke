//
//  SuppliesEditViewController.h
//  Wochuke
//
//  Created by he songhang on 13-6-28.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuppliesView.h"

@interface SuppliesEditViewController : UIViewController

@property (retain, nonatomic) IBOutlet SuppliesEditView *suppliesEditView;

- (IBAction)backAction:(id)sender;

@end
