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
    [super dealloc];
}

-(void)viewDidUnload{
    [self unobserveAllNotifications];
    _homeViewNaviationController = nil;
    _catoryViewNaviationController = nil;
    _searchViewNaviationController = nil;
    _myViewNaviationController = nil;
    [self setToolBar:nil];
    [super viewDidUnload];
    
}

#pragma mark -
-(IBAction)showControllerView:(id)sender;{
    UIView *view = (UIView *)sender;
    int tag = view.tag;
    [self showNaviationController:tag];
}

@end
