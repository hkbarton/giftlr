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
    FriendsSectionIndexInvited = 0,
    FriendsSectionIndexGiftlrCandidates = 1,
    FriendsSectionIndexMax = 2
};

@interface EventInviteGuestViewController () <UITableViewDataSource, UITableViewDelegate, CheckBoxCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *guestsToInvite;
@property (strong, nonatomic) NSMutableDictionary *guestsInvited;
@property (strong, nonatomic) NSArray *guestsInvitedArray;
@property (strong, nonatomic) NSMutableArray *guestCandidatesToInviteArray;
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
    
    self.guestsToInvite = [NSMutableDictionary dictionary];
    self.giftlrFriends = nil;
    self.guestsInvited = nil;
    self.guestsInvitedArray = [[NSArray alloc] init];
    self.guestCandidatesToInviteArray = [NSMutableArray array];
    
    [self.event getInvitedGuestsWithCompletion:^(NSDictionary *guests, NSError *error) {
        if (error) {
            NSLog(@"failed to get invited guests");
        } else {
            self.guestsInvited = [[NSMutableDictionary alloc] initWithDictionary:guests];
            self.guestsInvitedArray = self.guestsInvited.allValues;
            if (self.giftlrFriends) {
                [self decideGuestsToInvite];
                [self.tableView reloadData];
            }
        }
    }];
    [[User currentUser] getFriendsWithCompletion:^(NSArray *friends, NSError *error) {
        if (error) {
            NSLog(@"failed to get friends");
        } else {
            self.giftlrFriends = friends;
            if (self.guestsInvited) {
                [self decideGuestsToInvite];
                [self.tableView reloadData];
            }
        }
    }];
}

- (void) decideGuestsToInvite {
    for (User *friend in self.giftlrFriends) {
        if ([self.guestsInvited valueForKey:friend.fbUserId] == nil) {
            [self.guestCandidatesToInviteArray addObject:friend];
        }
    }
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
    switch (section) {
        case FriendsSectionIndexGiftlrCandidates:
            return @"Invite other giftlr friends";
        case FriendsSectionIndexInvited:
            return @"Giftlr friends invited";
        default:
            return @"";
    }
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
        case FriendsSectionIndexGiftlrCandidates:
            if (self.guestCandidatesToInviteArray) {
                return self.guestCandidatesToInviteArray.count;
            } else {
                return 0;
            }
        case FriendsSectionIndexInvited:
            if (self.guestsInvitedArray) {
                return self.guestsInvitedArray.count;
            } else {
                return 0;
            }
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CheckBoxCell *checkBoxCell = [tableView dequeueReusableCellWithIdentifier:@"CheckBoxCell"];
    checkBoxCell.delegate = self;
    User *user;
    
    switch (indexPath.section) {
        case FriendsSectionIndexGiftlrCandidates:
            user = (User *)self.guestCandidatesToInviteArray[indexPath.row];
            checkBoxCell.checked = NO;
            break;
        case FriendsSectionIndexInvited:
            user = (User *)self.guestsInvitedArray[indexPath.row];
            checkBoxCell.checked = YES;
            // TODO: support uninvite friends
            checkBoxCell.lockValue = YES;
            break;
        default:
            return 0;
    }
    
    checkBoxCell.titleLabel.text = user.name;
    checkBoxCell.user = user;
    return checkBoxCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - delegates

- (void)checkBoxCell:(CheckBoxCell *)checkBoxCell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:checkBoxCell];
    
    switch (indexPath.section) {
        case FriendsSectionIndexGiftlrCandidates:
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
    NSArray * guestsToInviteArray = self.guestsToInvite.allValues;
    [self.event inviteGuests:guestsToInviteArray];
    if (guestsToInviteArray.count > 0) {
        for (User *guest in guestsToInviteArray) {
            [self.guestCandidatesToInviteArray removeObject:guest];
            [self.guestsInvited setObject:guest forKey:guest.fbUserId];
        }
        self.guestsInvitedArray = self.guestsInvited.allValues;
        [self.tableView reloadData];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
