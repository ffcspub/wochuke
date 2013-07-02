//
//  SuppliesView.h
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Guide.h>
#import "UIKeyboardViewController.h"
//材料页
@interface SuppliesView : UIView<UITableViewDataSource,UITableViewDelegate>{
    UIImageView *backImageView;
    UITableView *_tableView;
    UILabel *lb_omit;
    UIImageView *iv_omit;
}

@property(nonatomic,retain) JCSupplyList *list;

@end


@interface SuppliesEditView : UIView<UITableViewDataSource,UITableViewDelegate>{
    UIImageView *backImageView;
    UITableView *_tableView;
    UIButton *_btn_delete;
    CGFloat oldy;
}

@end

@interface SuppliesMinView : SuppliesView{
    UILabel *lb_other;
    UIImageView *addImageView;
}

@end
