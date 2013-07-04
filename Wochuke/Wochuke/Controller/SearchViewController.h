//
//  SearchViewController.h
//  Wochuke
//
//  Created by he songhang on 13-6-26.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopViewController.h"
#import "UIKeyboardViewController.h"

@interface SearchViewController : TopViewController<UITableViewDataSource,UITableViewDelegate,UIKeyboardViewControllerDelegate>

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;

- (IBAction)backAction:(id)sender;

@end
