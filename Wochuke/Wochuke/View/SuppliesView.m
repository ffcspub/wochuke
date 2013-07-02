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

        
        UIImage *backImage = [[UIImage imageNamed:@"lightBoard"]resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
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
