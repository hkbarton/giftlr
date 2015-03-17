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
#import "SettingViewController.h"
#import "PaymentSettingViewController.h"
#import "SideViewTransition.h"
#import "UIColor+giftlr.h"

@interface MainViewController () <UITabBarDelegate, GiftListViewControllerDelegate, SettingViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *tabbar;
@property (weak, nonatomic) IBOutlet UIButton *btnTabEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnTabGifts;
@property (weak, nonatomic) IBOutlet UIButton *btnTabProfile;

@property (strong, nonatomic) EventListViewController *eventListViewController;
@property (strong, nonatomic) GiftListViewController *giftListViewController;
@property (strong, nonatomic) UINavigationController *eventNavigationController;
@property (strong, nonatomic) UIViewController *currentViewController;

@property (strong, nonatomic) SideViewTransition *menuViewTransition;

- (IBAction)onTabItemClick:(id)sender;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // tabbar
    self.tabbar.backgroundColor = [UIColor lightGreyBackgroundColor];
    [self.btnTabEvent setImage:[UIImage imageNamed:@"event-tab-select"] forState:UIControlStateSelected];
    [self.btnTabGifts setImage:[UIImage imageNamed:@"gift-tab-select"] forState:UIControlStateSelected];
    [self.btnTabProfile setImage:[UIImage imageNamed:@"profile-tab-select"] forState:UIControlStateSelected];
    self.btnTabEvent.selected = YES;
    // container view controller
    self.eventListViewController = [[EventListViewController alloc] init];
    self.giftListViewController = [[GiftListViewController alloc] init];
    self.eventNavigationController = [[UINavigationController alloc] initWithRootViewController:self.eventListViewController];
    self.giftListViewController.delegate = self;
    [self showContentViewController:self.eventNavigationController];
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
       [self goToViewController:self.eventNavigationController];
    } else if (sender == self.btnTabGifts) {
        [self goToViewController:self.giftListViewController];
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
        [self presentViewController:psvc animated:YES completion:nil];
    }
}

-(void)setSelectedTabButton:(id)sender {
    self.btnTabEvent.selected = NO;
    self.btnTabGifts.selected = NO;
    self.btnTabProfile.selected = NO;
    UIButton *button = (UIButton *)sender;
    button.selected = YES;
}

#pragma mark - Gift List View Controller
- (void)goToEventListWithGiftListViewController:(GiftListViewController *)giftListViewController {
    [self goToViewController:self.eventListViewController];
    [self setSelectedTabButton:self.btnTabEvent];
}

@end
