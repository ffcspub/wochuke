//
//  DriverManagerViewController.m
//  Wochuke
//
//  Created by hesh on 13-7-12.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//


#import "DriverManagerViewController.h"
#import "UITableView+BeeUIGirdCell.h"
#import "DriverEditViewController.h"

@protocol DriverCellDelegate ;

@interface DriverCell : BeeUIGridCell{
    UILabel *lable;
    UIButton *btn_edit;
    UIButton *btn_delete;
    UIView *line;
}

@property(nonatomic,assign) id<DriverCellDelegate> delegate;

@end

@protocol DriverCellDelegate <NSObject>

-(void) cellDeleteAction:(NSString *)name;

-(void) cellEditAction:(NSString *)name;

@end

@implementation DriverCell

+ (CGSize)sizeInBound:(CGSize)bound forData:(NSObject *)data
{
	return bound;
}

- (void)layoutInBound:(CGSize)bound forCell:(BeeUIGridCell *)cell
{
    lable.frame = CGRectMake(10, 0, 170, bound.height);
    btn_edit.frame = CGRectMake(190, 10, 50, bound.height - 20);
    btn_delete.frame = CGRectMake(190 + 50 + 10, 10,50,bound.height - 20);
    line.frame = CGRectMake(0, bound.height - 0.6, bound.width, 0.6);
}

- (void)dataDidChanged
{
    if (self.cellData) {
        lable.text = self.cellData;
    }
}

-(void)editAction{
    if (_delegate) {
        [_delegate cellEditAction:self.cellData];
    }
}

-(void)delAction{
    if (_delegate) {
        [_delegate cellDeleteAction:self.cellData];
    }
}

- (void)load
{
    
    lable = [[[UILabel alloc]init]autorelease];
    lable.textColor = [UIColor darkTextColor];
    lable.backgroundColor = [UIColor clearColor];
    lable.font = [UIFont systemFontOfSize:14];
    lable.numberOfLines = 2;
    [self addSubview:lable];
    
    UIImage *back = [[UIImage imageNamed:@"btn_top"]resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    
    btn_edit = [[[UIButton alloc]init]autorelease];
    [btn_edit setTitle:@"编辑" forState:UIControlStateNormal];
    btn_edit.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn_edit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_edit addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
    
    btn_delete = [[[UIButton alloc]init]autorelease];
    [btn_delete setTitle:@"删除" forState:UIControlStateNormal];
    btn_delete.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn_delete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_delete addTarget:self action:@selector(delAction) forControlEvents:UIControlEventTouchUpInside];
   
    [btn_delete setBackgroundImage:back forState:UIControlStateNormal];
    [btn_edit setBackgroundImage:back forState:UIControlStateNormal];
    
    line = [[[UIView alloc]init]autorelease];
    line.backgroundColor = [UIColor lightGrayColor];
    
    [self addSubview:btn_delete];
    [self addSubview:btn_edit];
    [self addSubview:line];
}

@end



@interface DriverManagerViewController ()<DriverCellDelegate>{
    NSString *_name;
}

@end

@implementation DriverManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_name release];
    [_tableView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (IBAction)addDriverAction:(id)sender;{
    DriverEditViewController *vlc = [[ DriverEditViewController alloc]initWithNibName:@"DriverEditViewController" bundle:nil];
    [self.navigationController pushViewController:vlc animated:YES];
    [vlc release];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return [ShareVaule allDriverNames].count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;{
    UITableViewCell *cell = [tableView dequeueReusableCellWithBeeUIGirdCellClass:[DriverCell class]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.gridCell.cellData = [[ShareVaule allDriverNames] objectAtIndex:indexPath.row];
    DriverCell *driverCell = (DriverCell *)cell.gridCell;
    driverCell.delegate = self;
    return cell;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;{
    if (buttonIndex == 1) {
        [ShareVaule deleteDirverByName:_name];
        [_tableView reloadData];
        [_name release];
        _name = nil;
    }
}



#pragma mark - DriverCellDelegate

-(void) cellDeleteAction:(NSString *)name;{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"确定要删除吗？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    if (_name) {
        [_name release];
        _name = nil;
    }
    _name = [name retain];
    [alert show];
    [alert release];
}

-(void) cellEditAction:(NSString *)name;{
    DriverEditViewController *vlc = [[ DriverEditViewController alloc]initWithNibName:@"DriverEditViewController" bundle:nil];
    vlc.name = name;
    [self.navigationController pushViewController:vlc animated:YES];
    [vlc release];
}


@end
