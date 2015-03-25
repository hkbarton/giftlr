//
//  NotificationViewController.m
//  giftlr
//
//  Created by Yingming Chen on 3/22/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "NotificationViewController.h"
#import "EventDetailViewController.h"
#import "NotificationCell.h"
#import "User.h"
#import "UIColor+giftlr.h"
#import "SideViewTransition.h"

@interface NotificationViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *activities;
@property (strong, nonatomic) SideViewTransition *detailViewTransition;
@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"NotificationCell" bundle:nil] forCellReuseIdentifier:@"NotificationCell"];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 0)];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 120;
    
    // "pull to refresh" support
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableRefreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.tableRefreshControl atIndex:0];
    self.tableView.backgroundColor = [UIColor lightGreyBackgroundColor];
    
    self.title = @"News Feed";
    
    self.activities = [[NSArray alloc] init];
    [self fetchActivities];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)onRefresh {
    [self fetchActivities];
}

- (void)fetchActivities {
    [Activity getActivitiesWithCompletion:[User currentUser].fbUserId completion:^(NSArray *activities, NSError *error) {
        [self.tableRefreshControl endRefreshing];
        if (error) {
            NSLog(@"failed to get activities with error %@", error);
        } else {
            self.activities = activities;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Table methods

// consider add index on the right side: see http://www.appcoda.com/ios-programming-index-list-uitableview/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    cell.activity = self.activities[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Activity *activity = self.activities[indexPath.row];
    if (activity.event != nil || activity.gift != nil) {
        return 120;
    } else {
        return 88;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NotificationCell *cell = (NotificationCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    Event *event = cell.activity.event;
    switch (cell.activity.activityType) {
        case ActivityTypeEventInvite:
        case ActivityTypeGiftClaim:
        case ActivityTypeGiftDue:
            if (event) {
                EventDetailViewController *edvc = [[EventDetailViewController alloc] init];
                UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:edvc];
                edvc.event = event;
                self.detailViewTransition = [SideViewTransition newTransitionWithTargetViewController:nvc andSideDirection:RightSideDirection];
                self.detailViewTransition.widthPercent = 1.0;
                self.detailViewTransition.AnimationTime = 0.5;
                self.detailViewTransition.addModalBgView = NO;
                self.detailViewTransition.slideFromViewPercent = 0.3;
                nvc.transitioningDelegate = self.detailViewTransition;
                [self presentViewController:nvc animated:YES completion:nil];
            }
            break;
        case ActivityTypeFriendJoin:
            break;
        default:
            break;
    }
}

@end
