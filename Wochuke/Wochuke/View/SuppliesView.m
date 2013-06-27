//
//  SuppliesView.m
//  Wochuke
//
//  Created by he songhang on 13-6-25.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "SuppliesView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SuppliesView

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _tableView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain]autorelease];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        
        lb_omit = [[[UILabel alloc]init]autorelease];
        [self addSubview:lb_omit];
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
    }
    return self;
}

-(void)setList:(NSArray *)list{
    if (_list) {
        [_list release];
        _list = nil;
    }
    _list = [list retain];
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

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

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

@implementation SuppliesMinView

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _tableView.frame = CGRectMake(0, 40, frame.size.width, frame.size.height - 60);
    lb_omit.frame = CGRectMake(0,frame.size.height - 25, frame.size.width, 20);
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
        lb_omit.font = [UIFont systemFontOfSize:11];
        lb_omit.text = @"...";
        lb_omit.textAlignment = UITextAlignmentCenter;
        lb_omit.textColor = [UIColor darkTextColor];
        lb_omit.backgroundColor = [UIColor clearColor];
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
