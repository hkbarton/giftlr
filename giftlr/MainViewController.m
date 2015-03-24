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
#import "SearchViewController.h"
#import "SettingViewController.h"
#import "PaymentSettingViewController.h"
#import "SideViewTransition.h"
#import "BottomUpTransition.h"
#import "NotificationViewController.h"
#import "UIColor+giftlr.h"

@interface MainViewController () <UITabBarDelegate, SettingViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *tabbar;
@property (weak, nonatomic) IBOutlet UIButton *btnTabEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnTabSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnTabProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnTabNotification;

@property (strong, nonatomic) NotificationViewController *notificationListViewController;
@property (strong, nonatomic) UINavigationController *notificationListNavigationController;
@property (strong, nonatomic) UIViewController *eventListViewController;
@property (strong, nonatomic) UIViewController *searchViewController;
@property (strong, nonatomic) UIViewController *currentViewController;

@property (strong, nonatomic) SideViewTransition *menuViewTransition;
@property (strong, nonatomic) BottomUpTransition *paymentSettingViewTransition;

- (IBAction)onTabItemClick:(id)sender;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // tabbar
    self.tabbar.backgroundColor = [UIColor whiteColor];
    [self.btnTabEvent setImage:[UIImage imageNamed:@"event-tab-select"] forState:UIControlStateSelected];
    [self.btnTabSearch setImage:[UIImage imageNamed:@"search-tab-select"] forState:UIControlStateSelected];
    [self.btnTabNotification setImage:[UIImage imageNamed:@"Globe-26-selected"] forState:UIControlStateSelected];
    self.btnTabEvent.selected = YES;
    // container view controller
    self.notificationListViewController = [[NotificationViewController alloc] init];
    self.notificationListNavigationController = [[UINavigationController alloc] initWithRootViewController:self.notificationListViewController];
    self.eventListViewController = [[UINavigationController alloc] initWithRootViewController:[[EventListViewController alloc] init]];
    self.searchViewController = [[SearchViewController alloc] init];
    [self showContentViewController:self.eventListViewController];
}

- (void)viewDidAppear:(BOOL)animated {
    // tabbar shadow
    self.tabbar.layer.masksToBounds = NO;
    self.tabbar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.tabbar.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.tabbar.layer.shadowOpacity = 0.5f;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.tabbar.bounds];
    self.tabbar.layer.shadowPath = shadowPath.CGPath;
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

- (IBAction)onTabItemClick:(id)sender {
    if (sender != self.btnTabProfile) {
        [self setSelectedTabButton:sender];
    }
    if (sender == self.btnTabEvent) {
       [self goToViewController:self.eventListViewController];
    } else if (sender == self.btnTabSearch) {
        [self goToViewController:self.searchViewController];
    } else if (sender == self.btnTabNotification) {
        [self goToViewController:self.notificationListNavigationController];
    } else if (sender == self.btnTabProfile) {
        SettingViewController *svc = [[SettingViewController alloc] init];
        self.menuViewTransition = [SideViewTransition newTransitionWithTargetViewController:svc andSideDirection:RightSideDirection];
        svc.transitioningDelegate = self.menuViewTransition;
        svc.delegate = self;
        [self presentViewController:svc animated:YES completion:nil];
    }
}

-(void)settingViewController:(SettingViewController *)settingViewController didMenuItemSelected:(NSString *)menuID {
    if ([menuID isEqualToString:SettingMenuLogout]) {
        [self onLogout];
    } else if ([menuID isEqualToString:SettingMenuPayment]) {
        PaymentSettingViewController *psvc = [[PaymentSettingViewController alloc] init];
        self.paymentSettingViewTransition = [BottomUpTransition newTransitionWithTargetViewController:psvc];
        psvc.transitioningDelegate = self.paymentSettingViewTransition;
        [self presentViewController:psvc animated:YES completion:nil];
    }
}

-(void)setSelectedTabButton:(id)sender {
    self.btnTabEvent.selected = NO;
    self.btnTabSearch.selected = NO;
    self.btnTabProfile.selected = NO;
    self.btnTabNotification.selected = NO;
    UIButton *button = (UIButton *)sender;
    button.selected = YES;
}

#pragma mark - Gift List View Controller
/*
- (void)goToEventListWithGiftListViewController:(GiftListViewController *)giftListViewController {
    [self goToViewController:self.eventListViewController];
    [self setSelectedTabButton:self.btnTabEvent];
}
*/

@end
