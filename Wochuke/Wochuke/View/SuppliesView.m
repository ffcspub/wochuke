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
    iv_omit.frame = CGRectMake(0, 20, 45, 25);
    lb_omit.frame = CGRectMake(10, 20, 35, 20);
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
        
        _tableView = [[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain]autorelease];
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


-(void)dealloc{
    [super dealloc];
}

-(void)cellDelete{
    [self postNotification:NOTIFICATION_SUPPLIECELLDELETE withObject:self];
}

-(void)load{
    _tf_name = [[[EMKeyboardBarTextField alloc]init]autorelease];
    _tf_name.placeholder = @"食材";
    _tf_name.textAlignment = UITextAlignmentCenter;
    _tf_name.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tf_name.delegate = self;
    [self addSubview:_tf_name];
    
    _tf_quantity = [[EMKeyboardBarTextField alloc]init];
    _tf_quantity.placeholder = @"分量";
    _tf_quantity.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tf_quantity.textAlignment = UITextAlignmentCenter;
    _tf_quantity.delegate = self;
    [self addSubview:_tf_quantity];
    
    _btn_del = [[UIButton alloc]init];
    [_btn_del setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [_btn_del setTitle:@"删除" forState:UIControlStateNormal];
    [_btn_del addTarget:self action:@selector(cellDelete) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btn_del];
    
    _line = [[[UIView alloc]init]autorelease];
    _line.backgroundColor = [UIColor grayColor];
    [self addSubview:_line];
    
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
    _btn_del.frame = CGRectMake((bound.width-6)/5 * 4 , 3, (bound.width-6)/5 , bound.height - 6);
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
    if (textField == _tf_name) {
        JCSupply *supply = self.cellData;
        supply.name = _tf_name.text;
    }else{
        JCSupply *supply = self.cellData;
        supply.quantity = textField.text;
    }
    return YES;
}

@end

@implementation SuppliesEditView

-(void)handleNotification:(NSNotification *)notification{
    if ([notification.name isEqual:NOTIFICATION_SUPPLIECELLDELETE]) {
        SuppliesEditCell *cell = (SuppliesEditCell *)notification.object;
        JCSupply *supply = (JCSupply *)cell.cellData;
        NSInteger index = [[ShareVaule shareInstance].editGuideEx.supplies indexOfObject:supply];
        [(NSMutableArray *)[ShareVaule shareInstance].editGuideEx.supplies removeObjectAtIndex:index];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    backImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _tableView.frame = CGRectMake(10, 10, frame.size.width-20, frame.size.height-20);
    _btn_delete.frame = CGRectMake((frame.size.width - _btn_delete.frame.size.width)/2, 0, _btn_delete.frame.size.width, _btn_delete.frame.size.height);
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
    
    _btn_delete = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [_btn_delete addTarget:self action:@selector(addCell) forControlEvents:UIControlEventTouchUpInside];
    _tableView.tableFooterView = _btn_delete;
    [self addSubview:_tableView];
    
    [self observeNotification:NOTIFICATION_SUPPLIECELLDELETE];
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
    [(NSMutableArray *)[ShareVaule shareInstance].editGuideEx.supplies addObject:supply];
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[ShareVaule shareInstance].editGuideEx.supplies.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)dealloc{
    [self unobserveNotification:NOTIFICATION_SUPPLIECELLDELETE];
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
    addImageView.frame = CGRectMake(10, 40, frame.size.width - 20, frame.size.height - 40);
    iv_omit.frame = CGRectZero;
}

-(void)setList:(NSArray *)list{
    [super setList:list];
    if (list.count == 0) {
        [addImageView setHidden:NO];
    }else{
        [addImageView setHidden:YES];
    }
}

-(CGSize)tableViewCellSize{
    return CGSizeMake(_tableView.frame.size.width, 17);
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
        
        addImageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"success"]]autorelease];
        [self addSubview:addImageView];
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *lb_name = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *lb_quantity = (UILabel *)[cell.contentView viewWithTag:2];
    lb_name.font = [UIFont systemFontOfSize:11];
    lb_quantity.font = [UIFont systemFontOfSize:11];
    return cell;
}


@end
