//
//  MainViewController.m
//  giftlr
//
//  Created by Naeim Semsarilar on 3/13/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
#import "User.h"
#import "EventListViewController.h"
#import "GiftListViewController.h"

@interface MainViewController () <UITabBarDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@property (strong, nonatomic) EventListViewController *eventListViewController;
@property (strong, nonatomic) GiftListViewController *giftListViewController;
@property (strong, nonatomic) UINavigationController *eventNavigationController;
@property (strong, nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UITabBarItem *eventListTabBarItem;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.delegate = self;
    
    self.eventListViewController = [[EventListViewController alloc] init];
    self.giftListViewController = [[GiftListViewController alloc] init];
    self.eventNavigationController = [[UINavigationController alloc] initWithRootViewController:self.eventListViewController];
    
    [self.tabBar setSelectedItem:self.eventListTabBarItem];
    [self showContentViewController:self.eventNavigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLogout {
    [User logout];
    LoginViewController *lvc = [[LoginViewController alloc] init];
    [self presentViewController:lvc animated:YES completion:^{
    }];
}

- (void)showContentViewController:(UIViewController *)content {
    [self addChildViewController:content];
    content.view.frame = self.contentView.frame;
    [self.contentView addSubview:content.view];
    self.currentViewController = content;
    [content didMoveToParentViewController:self];
}

- (void)hideCurrentViewController {
    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
}

- (void)goToViewController:(UIViewController *)content {
    if (self.currentViewController != content) {
        [self hideCurrentViewController];
        [self showContentViewController:content];
    }
}

#pragma mark - Tab bar
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([item.title isEqualToString:@"Events"]) {
        [self goToViewController:self.eventNavigationController];
    } else if ([item.title isEqualToString:@"Gifts"]) {
        [self goToViewController:self.giftListViewController];
    } else if ([item.title isEqualToString:@"Logout"]) {
        // TODO: Replace Logout with Settings
        [self onLogout];
    } else {
        
    }
}




@end
