//
//  MainViewController.m
//  Wochuke
//
//  Created by he songhang on 13-6-27.
//  Copyright (c) 2013年 he songhang. All rights reserved.
//

#import "MainViewController.h"
#import "HomeViewController.h"
#import "CatoryViewController.h"
#import "ActInfoViewController.h"
#import "MyViewController.h"
#import "NSObject+Notification.h"

@interface MainViewController ()<UITabBarDelegate>{
    UINavigationController *_homeViewNaviationController;
    UINavigationController *_catoryViewNaviationController;
    UINavigationController *_actionViewNaviationController;
    UINavigationController *_myViewNaviationController;
    UINavigationController *currentController;
}

@end

@implementation MainViewController

-(void)handleNotification:(NSNotification *)notification{
    if ([notification.name isEqual:NOTIFICATION_HIDETOOLBAR]) {
        [self hideToolBar];
    }else if([notification.name isEqual:NOTIFICATION_SHOWTOOLBAR]){
        [self showToolBar];
    }
}

-(void)showToolBar{
    _toolBar.hidden = NO;
}

-(void)hideToolBar{
    _toolBar.hidden = YES;
}

-(void)showNaviationController:(int)tag{
    
    if (tag == 1) {
        if (!_homeViewNaviationController) {
            HomeViewController *vlc = [[[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil]autorelease];
            _homeViewNaviationController = [[UINavigationController alloc]initWithRootViewController:vlc];
            _homeViewNaviationController.navigationBarHidden = YES;
            [_homeViewNaviationController.view setFrame: [self.view bounds]];
            [self.view addSubview:_homeViewNaviationController.view];
        }
        currentController = _homeViewNaviationController;
    }else if(tag ==2){
        if (!_catoryViewNaviationController) {
            CatoryViewController *vlc = [[[CatoryViewController alloc]initWithNibName:@"CatoryViewController" bundle:nil]autorelease];
            _catoryViewNaviationController = [[UINavigationController alloc]initWithRootViewController:vlc];
            _catoryViewNaviationController.navigationBarHidden = YES;
            [_catoryViewNaviationController.view setFrame: [self.view bounds]];
            [self.view addSubview:_catoryViewNaviationController.view];
        }
        currentController = _catoryViewNaviationController;
    }else if(tag ==3){
        if (!_actionViewNaviationController) {
            ActInfoViewController *vlc = [[[ActInfoViewController alloc]initWithNibName:@"ActInfoViewController" bundle:nil]autorelease];
            _actionViewNaviationController = [[UINavigationController alloc]initWithRootViewController:vlc];
            _actionViewNaviationController.navigationBarHidden = YES;
            [_actionViewNaviationController.view setFrame: [self.view bounds]];
            [self.view addSubview:_actionViewNaviationController.view];
        }
        currentController = _actionViewNaviationController;
    }else if(tag ==4){
        if (!_myViewNaviationController) {
            MyViewController *vlc = [[[MyViewController alloc]initWithNibName:@"MyViewController" bundle:nil]autorelease];
            _myViewNaviationController = [[UINavigationController alloc]initWithRootViewController:vlc];
            _myViewNaviationController.navigationBarHidden = YES;
            [_myViewNaviationController.view setFrame: [self.view bounds]];
            [self.view addSubview:_myViewNaviationController.view];
        }
        currentController = _myViewNaviationController;
    }
    [self.view bringSubviewToFront:currentController.view];
    [self.view bringSubviewToFront:_toolBar];
}

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
    [_toolBar setSelectedItem:_btn_type];
    [self showNaviationController:1];
    [self observeNotification:NOTIFICATION_HIDETOOLBAR];
    [self observeNotification:NOTIFICATION_SHOWTOOLBAR];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [_homeViewNaviationController release];
    [_catoryViewNaviationController release];
    [_actionViewNaviationController release];
    [_myViewNaviationController release];
    [_toolBar release];
    [_btn_type release];
    [_btn_catory release];
    [_btn_search release];
    [_btn_mine release];
    [super dealloc];
}

-(void)viewDidUnload{
    [self unobserveAllNotifications];
    _homeViewNaviationController = nil;
    _catoryViewNaviationController = nil;
    _actionViewNaviationController = nil;
    _myViewNaviationController = nil;
    [self setToolBar:nil];
    [self setBtn_type:nil];
    [self setBtn_catory:nil];
    [self setBtn_search:nil];
    [self setBtn_mine:nil];
    [super viewDidUnload];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;{
    [self showControllerView:item];
}

#pragma mark -
-(IBAction)showControllerView:(id)sender;{
    UIView *view = (UIView *)sender;
    int tag = view.tag;
    
    BOOL nothingChange = NO;
    nothingChange = (currentController == _homeViewNaviationController && tag == 1) || (currentController == _catoryViewNaviationController && tag == 2) || (currentController == _actionViewNaviationController && tag ==3) || (currentController == _myViewNaviationController && tag == 4);
    if (nothingChange) {
        return;
    }
//    [_btn_type setImage:[UIImage imageNamed:@"bg_home_good_bottom_pressed"] forState:UIControlStateSelected];
//    [_btn_type setImage:[UIImage imageNamed:@"bg_home_good_bottom"] forState:UIControlStateNormal];
//    [_btn_catory setImage:[UIImage imageNamed:@"bg_home_classify_bottom"] forState:UIControlStateNormal];
//    [_btn_catory setImage:[UIImage imageNamed:@"bg_home_good_bottom_pressed"] forState:UIControlStateSelected];
//    [_btn_search setImage:[UIImage imageNamed:@"bg_home_activity_bottom"] forState:UIControlStateNormal];
//    [_btn_search setImage:[UIImage imageNamed:@"bg_home_activity_bottom_pressed"] forState:UIControlStateSelected];
//    [_btn_mine setImage:[UIImage imageNamed:@"bg_home_user_bottom"] forState:UIControlStateNormal];
//    [_btn_mine setImage:[UIImage imageNamed:@"bg_home_user_bottom_pressed"] forState:UIControlStateSelected];
//    if (tag == 1) {
//        [_btn_type setImage:[UIImage imageNamed:@"bg_home_good_bottom_pressed"] forState:UIControlStateNormal];
//    }else if(tag == 2){
//        [_btn_catory setImage:[UIImage imageNamed:@"bg_home_classify_bottom_pressed"] forState:UIControlStateNormal];
//    }else if(tag == 3){
//        [_btn_search setImage:[UIImage imageNamed:@"bg_home_activity_bottom_pressed"] forState:UIControlStateNormal];
//    }else if(tag == 4){
//        [_btn_mine setImage:[UIImage imageNamed:@"bg_home_user_bottom_pressed"] forState:UIControlStateNormal];
//    }
    [self showNaviationController:tag];
}

- (IBAction)typeAction:(id)sender {
    [self showControllerView:sender];
}

- (IBAction)catoryAction:(id)sender {
    [self showControllerView:sender];
    
}

- (IBAction)searchAction:(id)sender {
    [self showControllerView:sender];
    
}

- (IBAction)mineAction:(id)sender {
    
    [self showControllerView:sender];
}

@end
