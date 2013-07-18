//
//  SuppliesView.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "SuppliesView.h"
#import <QuartzCore/QuartzCore.h>
#import "Bee_UIGridCell.h"
#import "UITableView+BeeUIGirdCell.h"
#import "NSObject+Notification.h"
#import "EMKeyboardBarTextField.h"

@implementation SuppliesView

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    backImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _tableView.frame = CGRectMake(10, 10, frame.size.width-20, frame.size.height-20);
    iv_omit.frame = CGRectMake(2, 20, 45, 25);
    lb_omit.frame = CGRectMake(12, 20, 35, 20);
    lb_empty.frame = CGRectMake(10, 10,frame.size.width-20, frame.size.height-20);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backImageView = [[[UIImageView alloc]init]autorelease];
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:backImageView];
        
        UIImage *backImage = [[UIImage imageNamed:@"lightBoard"]resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
        [backImageView setImage:backImage];
        
        lb_empty = [[[UILabel alloc]init]autorelease];
        lb_empty.font = [UIFont systemFontOfSize:17];
        lb_empty.textColor = [UIColor lightGrayColor];
        lb_empty.backgroundColor = [UIColor clearColor];
        lb_empty.text = @"点击进入编辑页";
        lb_empty.textAlignment = UITextAlignmentCenter;
        [self addSubview:lb_empty];
        
        _tableView = [[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain]autorelease];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        
        iv_omit = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tag_home_card"]]autorelease];
        [self addSubview:iv_omit];
        
        lb_omit = [[[UILabel alloc]init]autorelease];
        lb_omit.font = [UIFont systemFontOfSize:14];
        lb_omit.backgroundColor = [UIColor clearColor];
        lb_omit.textColor = [UIColor whiteColor];
        [self addSubview:lb_omit];
        
    }
    return self;
}

-(void)setList:(NSArray *)list{
    if (_list) {
        [_list release];
        _list = nil;
    }
    _list = [list retain];
    lb_omit.text = @"材料";
    if (_list.count == 0) {
        [_tableView setHidden:YES];
        [lb_empty setHidden:NO];
    }else{
        [_tableView setHidden:NO];
        [lb_empty setHidden:YES];
    }
    [_tableView reloadData];
}

-(void)dealloc{
    [_list release];
    [super dealloc];
}

-(CGSize)tableViewCellSize{
    return CGSizeMake(_tableView.frame.size.width, 44);
}

#pragma mark -  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return _list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SUPPLIECELL"];
    if (!cell) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SUPPLIECELL"]autorelease];
        UILabel *lb_name = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableViewCellSize.width/2, self.tableViewCellSize.height)]autorelease];
        lb_name.tag = 1;
        lb_name.font = [UIFont systemFontOfSize:13];
        lb_name.textColor = [UIColor darkTextColor];
        lb_name.textAlignment = UITextAlignmentCenter;
        lb_name.backgroundColor = [UIColor clearColor];
        lb_name.numberOfLines = 2;
        [cell.contentView addSubview:lb_name];
        UILabel *lb_quantity = [[[UILabel alloc]initWithFrame:CGRectMake(self.tableViewCellSize.width/2, 0, self.tableViewCellSize.width/2, self.tableViewCellSize.height)]autorelease];
        lb_quantity.tag = 2;
        lb_quantity.font = [UIFont systemFontOfSize:15];
        lb_quantity.textAlignment = UITextAlignmentCenter;
        lb_quantity.textColor = [UIColor grayColor];
        lb_quantity.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lb_quantity];
        
        UIView *line = [[[UIView alloc]initWithFrame:CGRectMake(0, 44.0-0.6, tableView.frame.size.width, 0.6)]autorelease];
        line.backgroundColor = [UIColor lightGrayColor];
        line.tag = 3;
        [cell.contentView addSubview:line];
    }
    UILabel *lb_name = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *lb_quantity = (UILabel *)[cell.contentView viewWithTag:2];
    JCSupply *supply = [_list objectAtIndex:indexPath.row];
    lb_name.text = supply.name;
    lb_quantity.text = supply.quantity;

    return cell;
}

@end

@interface SuppliesEditCell : BeeUIGridCell<UITextFieldDelegate>{
    UITextField *_tf_name;
    UITextField *_tf_quantity;
    UIView *_line;
    UIButton *_btn_del;
}

@end

@implementation SuppliesEditCell

-(void)handleNotification:(NSNotification *)notification{
    if ([notification.name isEqual:UIKeyboardWillHideNotification]) {
        [_tf_name resignFirstResponder];
        [_tf_quantity resignFirstResponder];
    }else if([notification.name isEqual:NOTIFICATION_CANNELEDIT]){
        [_tf_name resignFirstResponder];
        [_tf_quantity resignFirstResponder];
    }
}

-(void)cellDelete{
    JCSupply *supply = (JCSupply *)self.cellData;
    int index = [[ShareVaule shareInstance].editGuideEx.supplies indexOfObject:supply];
    [self postNotification:NOTIFICATION_SUPPLIECELLDELETE withObject:[NSNumber numberWithInt:index]];
}

-(void)load{
    _tf_name = [[[EMKeyboardBarTextField alloc]init]autorelease];
    _tf_name.placeholder = @"食材";
    _tf_name.textAlignment = UITextAlignmentCenter;
    _tf_name.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tf_name.delegate = self;
    _tf_name.textColor = [UIColor darkTextColor];
    [self addSubview:_tf_name];
    
    _tf_quantity = [[[EMKeyboardBarTextField alloc]init]autorelease];
    _tf_quantity.placeholder = @"分量";
    _tf_quantity.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tf_quantity.textAlignment = UITextAlignmentCenter;
    _tf_quantity.delegate = self;
    _tf_quantity.textColor = [UIColor darkTextColor];
    [self addSubview:_tf_quantity];
    
    _btn_del = [[[UIButton alloc]init]autorelease];
    [_btn_del setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btn_del.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_btn_del setTitle:@"删除" forState:UIControlStateNormal];
    UIImage *backImage = [[UIImage imageNamed:@"btn_top"]resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [_btn_del setBackgroundImage:backImage forState:UIControlStateNormal];
    [_btn_del addTarget:self action:@selector(cellDelete) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btn_del];
    
    _line = [[[UIView alloc]init]autorelease];
    _line.backgroundColor = [UIColor grayColor];
    [self addSubview:_line];
    
    [self observeNotification:UIKeyboardWillHideNotification];
    [self observeNotification:NOTIFICATION_CANNELEDIT];
    
}

-(void)unload{
    [self unobserveNotification:UIKeyboardWillHideNotification];
    [self unobserveNotification:NOTIFICATION_CANNELEDIT];
    [super unload];
}

+ (CGSize)sizeInBound:(CGSize)bound forData:(NSObject *)data
{
	return bound;
}

- (void)layoutInBound:(CGSize)bound forCell:(BeeUIGridCell *)cell
{
    _tf_name.frame = CGRectMake(3,  0, (bound.width-6)/5 * 2,bound.height);
    _line.frame = CGRectMake(3 + (bound.width-6)/5 * 2,  0, 0.5,bound.height);
    _tf_quantity.frame = CGRectMake(5 + (bound.width-6)/5 * 2, 0, (bound.width-6)/5 * 2 - 5, bound.height);
    _btn_del.frame = CGRectMake((bound.width-6)/5 * 4 , 10, (bound.width-6)/5 , bound.height - 20);
    _line.frame = CGRectMake(0, bound.height - 0.6, bound.width, 0.6);
}

- (void)dataDidChanged;{
    if (self.cellData) {
        JCSupply *supply = self.cellData;
        _tf_name.text = supply.name;
        _tf_quantity.text = supply.quantity;
    }else{
        _tf_name.text = nil;
        _tf_quantity.text = nil;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField; {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField;{
    [ShareVaule shareInstance].noChanged = NO;
    if (textField == _tf_name) {
        JCSupply *supply = self.cellData;
        supply.name = _tf_name.text;
    }else{
        JCSupply *supply = self.cellData;
        supply.quantity = textField.text;
    }
}

@end

@implementation SuppliesEditView

-(void)handleNotification:(NSNotification *)notification{
    if ([notification.name isEqual:NOTIFICATION_SUPPLIECELLDELETE]) {
        NSNumber *indexNum = (NSNumber *)notification.object;
        int index = [indexNum intValue];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [_tableView reloadData];
            [_tableView beginUpdates];
            [(NSMutableArray *)[ShareVaule shareInstance].editGuideEx.supplies removeObjectAtIndex:index];
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade]; 
            [_tableView endUpdates];
        });
        [ShareVaule shareInstance].noChanged = NO;
    }else if([notification.name isEqual:NOTIFICATION_SUPPLIERELOAD]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    }
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    backImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _tableView.frame = CGRectMake(10, 10, frame.size.width-20, frame.size.height-20);
//    _btn_delete.frame = CGRectMake((frame.size.width - _btn_delete.frame.size.width)/2, 0, _btn_delete.frame.size.width, _btn_delete.frame.size.height);
}

-(void)handleSingleTapFrom{
    [self postNotification:NOTIFICATION_CANNELEDIT];
}

-(void)initSelf{
    backImageView = [[[UIImageView alloc]init]autorelease];
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:backImageView];
    
    UIImage *backImage = [[UIImage imageNamed:@"lightBoard"]resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
    [backImageView setImage:backImage];
    
    _tableView = [[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain]autorelease];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    UITapGestureRecognizer* singleRecognizer;  
    singleRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)]autorelease];
    singleRecognizer.numberOfTapsRequired = 1; // 单击  
    [_tableView addGestureRecognizer:singleRecognizer];  
       
    _btn_delete = [[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)]autorelease];
    [_btn_delete setImage:[UIImage imageNamed:@"ic_edit_list_add"] forState:UIControlStateNormal];
    [_btn_delete addTarget:self action:@selector(addCell) forControlEvents:UIControlEventTouchUpInside];
    _tableView.tableFooterView = _btn_delete;
    [self addSubview:_tableView];
    
    [self observeNotification:NOTIFICATION_SUPPLIECELLDELETE];
    [self observeNotification:NOTIFICATION_SUPPLIERELOAD];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSelf];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSelf];
    }
    return self;
}

-(void)addCell{
    JCSupply *supply = [[[JCSupply alloc]init]autorelease];
//    BOOL flag = [ShareVaule shareInstance].editGuideEx.supplies.count == 0;
    [(NSMutableArray *)[ShareVaule shareInstance].editGuideEx.supplies addObject:supply];

    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[ShareVaule shareInstance].editGuideEx.supplies.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
//
}

-(void)dealloc{
    [self unobserveNotification:NOTIFICATION_SUPPLIECELLDELETE];
    [self unobserveNotification:NOTIFICATION_SUPPLIERELOAD];
    [super dealloc];
}

-(CGSize)tableViewCellSize{
    return CGSizeMake(_tableView.frame.size.width, 44);
}

#pragma mark -  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    if (section == 0) {
        return [ShareVaule shareInstance].editGuideEx.supplies.count;
    }
    return 1;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return 1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithBeeUIGirdCellClass:[SuppliesEditCell class]];
        JCSupply *supply = [[ShareVaule shareInstance].editGuideEx.supplies objectAtIndex:indexPath.row];
        cell.gridCell.cellData = supply;
    }
    return cell;
}

@end


@implementation SuppliesMinView

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _tableView.frame = CGRectMake(10, 30, frame.size.width - 20, frame.size.height - 50);
    lb_other.frame = CGRectMake(10,frame.size.height - 25, frame.size.width-20, 20);
    lb_omit.frame = CGRectMake(0,10, frame.size.width, 20);
    addImageView.frame = CGRectMake(20, 40, frame.size.width - 40, frame.size.height - 70);
    iv_omit.frame = CGRectZero;
    lb_empty.frame = CGRectZero;
}

-(void)setList:(NSArray *)list{
    [super setList:list];
    if (list.count == 0) {
        [addImageView setHidden:NO];
        [lb_other setHidden:YES];
    }else{
        [addImageView setHidden:YES];
        if (list.count>6) {
            [lb_other setHidden:NO];
        }else{
            [lb_other setHidden:YES];
        }
    
    }
}

-(CGSize)tableViewCellSize{
    return CGSizeMake(_tableView.frame.size.width, 14);
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 17;
        lb_omit.textAlignment = UITextAlignmentCenter;
        lb_omit.textColor = [UIColor darkTextColor];
        lb_omit.font = [UIFont systemFontOfSize:13];
        lb_omit.backgroundColor = [UIColor clearColor];
        
        lb_other = [[[UILabel alloc]init]autorelease];
        lb_other.font = [UIFont systemFontOfSize:11];
        lb_other.text = @"...";
        lb_other.textAlignment = UITextAlignmentCenter;
        lb_other.textColor = [UIColor darkTextColor];
        lb_other.backgroundColor = [UIColor clearColor];
        [self addSubview:lb_other];
        
        addImageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_step_plus"]]autorelease];
        [self addSubview:addImageView];
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *lb_name = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *lb_quantity = (UILabel *)[cell.contentView viewWithTag:2];
    UIView *line = (UIView *)[cell.contentView viewWithTag:3];
    [line setHidden:YES];
    lb_name.font = [UIFont systemFontOfSize:11];
    lb_quantity.font = [UIFont systemFontOfSize:11];
    return cell;
}


@end
