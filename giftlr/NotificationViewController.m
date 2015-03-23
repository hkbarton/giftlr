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

@interface NotificationViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *activities;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"NotificationCell" bundle:nil] forCellReuseIdentifier:@"NotificationCell"];
    
    self.tableView.rowHeight = 60;
    self.tableView.backgroundColor = [UIColor lightGreyBackgroundColor];
    
    self.title = @"Notifications";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    UIImageView *navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    navBarHairlineImageView.hidden = YES;
    
    self.activities = [[NSArray alloc] init];
    [Activity getActivitiesWithCompletion:[User currentUser].fbUserId completion:^(NSArray *activities, NSError *error) {
        if (error) {
            NSLog(@"failed to get activities with error %@", error);
        } else {
            self.activities = activities;
            [self.tableView reloadData];
        }
    }];
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
                [self presentViewController:nvc animated:YES completion:^{
                }];
            }
            break;
        case ActivityTypeFriendJoin:
            break;
        default:
            break;
    }
}

@end
