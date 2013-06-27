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
#import "SearchViewController.h"
#import "MyViewController.h"
#import "NSObject+Notification.h"

@interface MainViewController (){
    UINavigationController *_homeViewNaviationController;
    UINavigationController *_catoryViewNaviationController;
    UINavigationController *_searchViewNaviationController;
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
    if (!_homeViewNaviationController) {
        HomeViewController *vlc = [[[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil]autorelease];
        _homeViewNaviationController = [[UINavigationController alloc]initWithRootViewController:vlc];
        _homeViewNaviationController.navigationBarHidden = YES;
        [_homeViewNaviationController.view setFrame: [self.view bounds]];
        [self.view addSubview:_homeViewNaviationController.view];
    }
    if (!_catoryViewNaviationController) {
        CatoryViewController *vlc = [[[CatoryViewController alloc]initWithNibName:@"CatoryViewController" bundle:nil]autorelease];
        _catoryViewNaviationController = [[UINavigationController alloc]initWithRootViewController:vlc];
        _catoryViewNaviationController.navigationBarHidden = YES;
        [_catoryViewNaviationController.view setFrame: [self.view bounds]];
        [self.view addSubview:_catoryViewNaviationController.view];
    }
    if (!_searchViewNaviationController) {
        SearchViewController *vlc = [[[SearchViewController alloc]initWithNibName:@"SearchViewController" bundle:nil]autorelease];
        _searchViewNaviationController = [[UINavigationController alloc]initWithRootViewController:vlc];
        _searchViewNaviationController.navigationBarHidden = YES;
        [_searchViewNaviationController.view setFrame: [self.view bounds]];
        [self.view addSubview:_searchViewNaviationController.view];
    }
    if (!_myViewNaviationController) {
        MyViewController *vlc = [[[MyViewController alloc]initWithNibName:@"MyViewController" bundle:nil]autorelease];
        _myViewNaviationController = [[UINavigationController alloc]initWithRootViewController:vlc];
        _myViewNaviationController.navigationBarHidden = YES;
        [_myViewNaviationController.view setFrame: [self.view bounds]];
        [self.view addSubview:_myViewNaviationController.view];
    }
    if (tag == 1) {
        currentController = _homeViewNaviationController;
    }else if(tag ==2){
        currentController = _catoryViewNaviationController;
    }else if(tag ==3){
        currentController = _searchViewNaviationController;
    }else if(tag ==4){
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
    [_searchViewNaviationController release];
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
    _searchViewNaviationController = nil;
    _myViewNaviationController = nil;
    [self setToolBar:nil];
    [self setBtn_type:nil];
    [self setBtn_catory:nil];
    [self setBtn_search:nil];
    [self setBtn_mine:nil];
    [super viewDidUnload];
}

#pragma mark -
-(IBAction)showControllerView:(id)sender;{
    UIView *view = (UIView *)sender;
    int tag = view.tag;
    
    BOOL nothingChange = NO;
    nothingChange = (currentController == _homeViewNaviationController && tag == 1) || (currentController == _catoryViewNaviationController && tag == 2) || (currentController == _searchViewNaviationController && tag ==3) || (currentController == _myViewNaviationController && tag == 4);
    if (nothingChange) {
        return;
    }
    
    [_btn_type setImage:[UIImage imageNamed:@"bg_home_good_bottom_pressed"] forState:UIControlStateSelected];
    [_btn_type setImage:[UIImage imageNamed:@"bg_home_good_bottom"] forState:UIControlStateNormal];
    [_btn_catory setImage:[UIImage imageNamed:@"bg_home_classify_bottom"] forState:UIControlStateNormal];
    [_btn_catory setImage:[UIImage imageNamed:@"bg_home_good_bottom_pressed"] forState:UIControlStateSelected];
    [_btn_search setImage:[UIImage imageNamed:@"bg_home_search_bottom"] forState:UIControlStateNormal];
    [_btn_search setImage:[UIImage imageNamed:@"bg_home_search_bottom_pressed"] forState:UIControlStateSelected];
    [_btn_mine setImage:[UIImage imageNamed:@"bg_home_user_bottom"] forState:UIControlStateNormal];
    [_btn_mine setImage:[UIImage imageNamed:@"bg_home_user_bottom_pressed"] forState:UIControlStateSelected];
    if (tag == 1) {
        [_btn_type setImage:[UIImage imageNamed:@"bg_home_good_bottom_pressed"] forState:UIControlStateNormal];
    }else if(tag == 2){
        [_btn_catory setImage:[UIImage imageNamed:@"bg_home_classify_bottom_pressed"] forState:UIControlStateNormal];
    }else if(tag == 3){
        [_btn_search setImage:[UIImage imageNamed:@"bg_home_search_bottom_pressed"] forState:UIControlStateNormal];
    }else if(tag == 4){
        [_btn_mine setImage:[UIImage imageNamed:@"bg_home_user_bottom_pressed"] forState:UIControlStateNormal];
    }
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
