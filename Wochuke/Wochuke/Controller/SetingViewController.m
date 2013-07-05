//
//  SetingViewController.m
//  Wochuke
//
//  Created by Geory on 13-6-28.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "SetingViewController.h"

@interface SetingViewController ()

@property (nonatomic, retain) UISwitch *sinaSwitch;

@property (nonatomic, retain) UISwitch *qqSwitch;

@property (nonatomic, retain) UIView *btnView;

@property (nonatomic, retain) UIButton *cancelBtn;

@end

@implementation SetingViewController

@synthesize sinaSwitch = _sinaSwitch;
@synthesize qqSwitch = _qqSwitch;
@synthesize cancelBtn = _cancelBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)switchChanged: (UISwitch *)senderSwitch
{
    if ([senderSwitch isEqual:self.sinaSwitch]) {
        if (self.sinaSwitch.on) {//点击后变为ON时
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"新浪"
                                                         message:@"新浪微博登陆"
                                                        delegate:nil
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:nil];
            [av show];
        } else {//点击后变为OFF时
            
        }
    }else if ([senderSwitch isEqual:self.qqSwitch]){
        if (self.qqSwitch.on) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"QQ"
                                                         message:@"腾讯QQ登陆"
                                                        delegate:nil
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:nil];
            [av show];
        } else {
            
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"设置";
    
    self.sinaSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.sinaSwitch.on = NO;
    [self.sinaSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.qqSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.qqSwitch.on = NO;
    [self.qqSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.btnView = [[UIView alloc] initWithFrame:CGRectMake(40, 0, 250, 90)];
    
    self.cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 5, 90, 35)];
    self.cancelBtn.titleLabel.text = @"退出登录";
    
    [self.btnView addSubview:self.cancelBtn];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 70, 50)];
    cancelButton.titleLabel.text = @"退出登录";
    
    UIView *vlc = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 70, 50)];
    [vlc addSubview:cancelButton];
    
    self.tableView.tableFooterView = vlc;
    [vlc release];
}

- (void)viewDidUnload
{
    self.sinaSwitch = nil;
    self.qqSwitch = nil;
    self.cancelBtn = nil;
    self.btnView = nil;
    
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }else if (section == 1){
        return 1;
    }else if (section == 2){
        return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"绑定新浪微博";
        }else if (indexPath.row ==1){
            cell.textLabel.text = @"绑定腾讯QQ";
        }
    }else if (indexPath.section == 1){
        cell.textLabel.text = @"厨具管理";
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"意见反馈";
        }else if (indexPath.row ==1){
            cell.textLabel.text = @"清除缓存";
        }else if (indexPath.row ==2){
            cell.textLabel.text = @"关于";
        }
        tableView.tableFooterView = self.cancelBtn;
    }
//    else if (indexPath.section == 3){
//        cell.textLabel.text = @"退出登录";
//        cell.textLabel.textAlignment = NSTextAlignmentCenter;
//    }
    
    if (indexPath.section ==0) {
        if (indexPath.row == 0) {
            cell.accessoryView = self.sinaSwitch;
        }else if (indexPath.row == 1){
            cell.accessoryView = self.qqSwitch;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
//    tableView.tableFooterView = self.cancelBtn;
    tableView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}
@end
