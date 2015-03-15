//
//  EventInviteGuestViewController.m
//  giftlr
//
//  Created by Yingming Chen on 3/15/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "EventInviteGuestViewController.h"
#import "User.h"
#import "CheckBoxCell.h"
#import "EventInvite.h"

typedef NS_ENUM(NSInteger, FriendsSectionIndex) {
    FriendsSectionIndexGiftlr = 0,
    FriendsSectionIndexMax = 1
};

@interface EventInviteGuestViewController () <UITableViewDataSource, UITableViewDelegate, CheckBoxCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *guestsToInvite;
@property (strong, nonatomic) NSArray *giftlrFriends;

@end

@implementation EventInviteGuestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"CheckBoxCell" bundle:nil] forCellReuseIdentifier:@"CheckBoxCell"];
    self.tableView.rowHeight = 40;
    
    self.title = @"Invite Guests";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"check-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onCheck)];
    
    self.giftlrFriends = [[NSArray alloc] init];
    self.guestsToInvite = [NSMutableDictionary dictionary];
    [[User currentUser] getFriendsWithCompletion:^(NSArray *friends, NSError *error) {
        if (error) {
            NSLog(@"failed to get friends");
        } else {
            self.giftlrFriends = friends;
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return FriendsSectionIndexMax;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Friends on giftlr";
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case FriendsSectionIndexGiftlr:
            return self.giftlrFriends.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CheckBoxCell *checkBoxCell = [tableView dequeueReusableCellWithIdentifier:@"CheckBoxCell"];
    checkBoxCell.delegate = self;
    User *user = (User *)self.giftlrFriends[indexPath.row];
    checkBoxCell.titleLabel.text = user.name;
    checkBoxCell.user = user;
    checkBoxCell.checked = NO;
    return checkBoxCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - delegates

- (void)checkBoxCell:(CheckBoxCell *)checkBoxCell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:checkBoxCell];
    
    switch (indexPath.section) {
        case FriendsSectionIndexGiftlr:
            if (!value) {
                [self.guestsToInvite removeObjectForKey:checkBoxCell.user.fbUserId];
            } else {
                [self.guestsToInvite setObject:checkBoxCell.user forKey:checkBoxCell.user.fbUserId];
            }
            break;
        default:
            break;
    }
    
    // Try to reload all the sections. If we only reload the section touched, sometimes, we have issues
    // where other sections showing rows from previous sections
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 0)] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Navigation

- (void)onBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onCheck {
    [EventInvite inviteGuests:self.event guests:self.guestsToInvite.allValues];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
