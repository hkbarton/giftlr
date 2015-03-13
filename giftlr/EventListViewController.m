//
//  EventListViewController.m
//  giftlr
//
//  Created by Yingming Chen on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "EventListViewController.h"
#import "GiftListViewController.h"
#import "EventDetailViewController.h"
#import "EventViewCell.h"
#import "LoginViewController.h"
#import "User.h"
#import "Event.h"
#import "UIColor+giftlr.h"

@interface EventListViewController () <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIView *eventSourceTypeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopConstraint;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *invitedButton;
@property (weak, nonatomic) IBOutlet UIButton *hostingButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *allEvents;
@property (strong, nonatomic) NSMutableArray *myEvents;
@property (strong, nonatomic) NSMutableArray *searchEvents;
@property (assign, nonatomic) BOOL isMyEventMode;
@property (assign, nonatomic) BOOL isSearchMode;

@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;
@property (nonatomic, strong) UIView *searchBgView;

@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

- (IBAction)onInvitedClicked:(id)sender;
- (IBAction)onHostingClicked:(id)sender;

@end

@implementation EventListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.myEvents = [[NSMutableArray alloc] init];
    self.allEvents = [[NSMutableArray alloc] init];
    self.isMyEventMode = NO;
    self.isSearchMode = NO;
    [self setEventSourceSwitchState];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"EventViewCell" bundle:nil] forCellReuseIdentifier:@"EventViewCell"];
    self.tableView.rowHeight = 266;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 0)];

    self.tabBar.delegate = self;
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    
    self.searchBar.delegate = self;
    self.searchBar.tintColor = [UIColor hotPinkColor];
    self.searchEvents = [NSMutableArray array];

    // "pull to refresh" support
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableRefreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.tableRefreshControl atIndex:0];
    
    [self loadCurrentUserFBProfile];
    [self fetchParseEvents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tab bar
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([item.title isEqualToString:@"Events"]) {
        if (self.isSearchMode) {
            self.isSearchMode = NO;
            [self.searchBar resignFirstResponder];
            self.searchBarTopConstraint.constant = -30;
            [self.searchBar setNeedsLayout];
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
                [self.searchBar layoutIfNeeded];
                self.eventSourceTypeView.hidden = NO;
                self.searchBgView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.searchBgView removeFromSuperview];
                [self.tableView reloadData];
            }];
        }
    } else if ([item.title isEqualToString:@"Gifts"]) {
        GiftListViewController *vc = [[GiftListViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([item.title isEqualToString:@"Search"]) {
        if (self.isSearchMode) {
            return;
        }
        
        if (!self.searchBgView) {
            self.searchBgView = [[UIView alloc] initWithFrame:self.tableView.bounds];
            self.searchBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        }

        [self.tableView addSubview:self.searchBgView];
        self.isSearchMode = YES;
        self.searchBarTopConstraint.constant = 20;
        self.searchBgView.alpha = 0;
        [self.searchBar setNeedsLayout];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
            [self.searchBar layoutIfNeeded];
            self.searchBgView.alpha = 1;
            self.eventSourceTypeView.hidden = YES;
            [self.searchBar becomeFirstResponder];
        } completion:^(BOOL finished) {
        }];
        
        //self.searchBar.hidden = NO;
    } else if ([item.title isEqualToString:@"Logout"]) {
        [self onLogout];
    } else {
        
    }
}

#pragma mark - search bar control

// Search bar event listener
- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text {
    [self.searchEvents removeAllObjects];
    
    if (text.length > 0) {
        for (Event *event in self.allEvents) {
            // Search title and host name
            NSRange nameRange = [event.name rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange hostNameRange = [event.eventHostName rangeOfString:text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound || hostNameRange.location != NSNotFound) {
                [self.searchEvents addObject:event];
            }
        }
    }
    if (self.searchEvents.count == 0) {
        [self.tableView addSubview:self.searchBgView];
    }
    else {
        [self.searchBgView removeFromSuperview];
    }

    [self.tableView reloadData];
}

// Reset search bar state after cancel button clicked
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBgView removeFromSuperview];
    self.searchBar.text = @"";
    self.isSearchMode = NO;
    [self.searchBar resignFirstResponder];
    self.searchBarTopConstraint.constant = -30;
    [self.searchBar setNeedsLayout];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [self.searchBar layoutIfNeeded];
        self.eventSourceTypeView.hidden = NO;
    } completion:^(BOOL finished) {
        [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
        [self.tableView reloadData];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.searchEvents removeAllObjects];
    NSString *text = searchBar.text;
    for (Event *event in self.allEvents) {
        // Search title and host name
        NSRange nameRange = [event.name rangeOfString:text options:NSCaseInsensitiveSearch];
        NSRange hostNameRange = [event.eventHostName rangeOfString:text options:NSCaseInsensitiveSearch];
        if(nameRange.location != NSNotFound || hostNameRange.location != NSNotFound) {
            [self.searchEvents addObject:event];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table methods

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
    if (self.isSearchMode) {
        return self.searchEvents.count;
    } else if (self.isMyEventMode) {
        return self.myEvents.count;
    } else {
        return self.allEvents.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventViewCell"];
    Event *event = nil;
    if (self.isSearchMode) {
        event = self.searchEvents[indexPath.row];
    } else if (self.isMyEventMode) {
        event = self.myEvents[indexPath.row];
    } else {
        event = self.allEvents[indexPath.row];
    }
    
    cell.event = event;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    EventDetailViewController *edvc = [[EventDetailViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:edvc];
    Event *event = nil;
    if (self.isMyEventMode) {
        event = self.myEvents[indexPath.row];
    } else {
        event = self.allEvents[indexPath.row];
    }
    edvc.event = event;
    [self presentViewController:nvc animated:YES completion:^{
    }];
}

#pragma mark - event handlers

- (void)onLogout {
    [User logout];
    LoginViewController *lvc = [[LoginViewController alloc] init];
    [self presentViewController:lvc animated:YES completion:^{
    }];
}

- (IBAction)onInvitedClicked:(id)sender {
    if (self.isMyEventMode) {
        self.isMyEventMode = NO;
        [self setEventSourceSwitchState];
        [self.tableView reloadData];
    }
}

- (IBAction)onHostingClicked:(id)sender {
    if (!self.isMyEventMode) {
        self.isMyEventMode = YES;
        [self setEventSourceSwitchState];
        [self.tableView reloadData];
    }
}

- (void)onRefresh {
    [self fetchParseEvents];
}


#pragma mark - helper functions

- (void)setEventSourceSwitchState {
    if (self.isMyEventMode) {
        self.hostingButton.backgroundColor = [UIColor redPinkColor];
        self.hostingButton.tintColor = [UIColor whiteColor];
        self.invitedButton.backgroundColor = [UIColor lightGreyBackgroundColor];
        self.invitedButton.tintColor = [UIColor hotPinkColor];
    } else {
        self.hostingButton.backgroundColor = [UIColor lightGreyBackgroundColor];
        self.hostingButton.tintColor = [UIColor hotPinkColor];
        self.invitedButton.backgroundColor = [UIColor redPinkColor];
        self.invitedButton.tintColor = [UIColor whiteColor];
    }
}

- (void)loadCurrentUserFBProfile {
    [User fetchFBUserProfileWithCompletion:@"me" completion:^(User *user, NSError *error) {
        user.pfUser = [PFUser currentUser];
        if (!error) {
            [User setCurrentUser:user];
        } else {
            NSLog(@"Failed to get user profile");
        }
    }];
}

// Based on the relations to fetch the events for the users
- (void)fetchParseEvents {
    NSMutableArray *allEvents = [NSMutableArray array];
    NSMutableDictionary *allEventsIndexDictionary = [ NSMutableDictionary dictionary];
    NSMutableDictionary *myEventsIndexDictionary = [ NSMutableDictionary dictionary];
    NSMutableArray *myEvents = [NSMutableArray array];
    
    // TODO: move this relation stuff into User Model
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"events"];
    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *pfEvents, NSError *error) {
        if (error) {
            // There was an error
            NSLog(@"failed to get events for the user");
        } else {
            NSLog(@"get %ld events from parse", pfEvents.count);
            for (PFObject *pfEvent in pfEvents) {
                Event *event = [[Event alloc] initWithPFObject:pfEvent];
                [allEvents addObject:event];
                [allEventsIndexDictionary setObject:event forKey:event.fbEventId];
                if ([event.eventHostId isEqualToString:[User currentUser].fbUserId]) {
                    [myEvents addObject:event];
                    [myEventsIndexDictionary setObject:event forKey:event.fbEventId];
                }
            }
            
            [Event fetchFBEventsWithCompletion:@"me" completion:^(NSDictionary *events, NSError *error) {
                if (!error) {
                    NSMutableArray *newEvents = [NSMutableArray array];
                    for (Event *event in events[@"allEvents"]) {
                        // New event, not in parse yet
                        if ([allEventsIndexDictionary objectForKey:event.fbEventId] == nil) {
                            [event saveToParseWithCompletion:^(NSError *error) {
                                if (!error) {
                                    // save the relations
                                    [[User currentUser] linkUserWithEvent:event];
                                }
                            }];
                            [allEvents addObject:event];
                            [allEventsIndexDictionary setObject:event forKey:event.fbEventId];
                            [newEvents addObject:event];
                        }
                    }
                    
                    for (Event *event in events[@"myEvents"]) {
                        // All my events should already be added in allEvents
                        Event *myEvent = [allEventsIndexDictionary objectForKey:event.fbEventId];
                        if (myEvent == nil) {
                            NSLog(@"strange, couldn't fine myevent %@ in allevents", event.fbEventId);
                        } else if ([myEventsIndexDictionary objectForKey:myEvent.fbEventId] == nil) {
                            [myEvents addObject:myEvent];
                            [myEventsIndexDictionary setObject:myEvent forKey:myEvent.fbEventId];
                        }
                    }

                    // Save the new event data
                    self.allEvents = allEvents;
                    self.myEvents = myEvents;
                    
                    [self.allEvents sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        return [((Event *)obj2).startTime compare:((Event *)obj1).startTime];
                    }];
                    [self.myEvents sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        return [((Event *)obj2).startTime compare:((Event *)obj1).startTime];
                    }];
                    
                    [self.tableRefreshControl endRefreshing];
                    [self.tableView reloadData];
                } else {
                    NSLog(@"failed get fb event %@", error);
                }
            }];
        }
    }];
}

@end
