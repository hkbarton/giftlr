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
#import "EventDetailViewController.h"
#import "EventViewCell.h"
#import "LoginViewController.h"
#import "User.h"
#import "Event.h"

@interface EventListViewController () <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIView *eventSourceTypeView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *invitedButton;
@property (weak, nonatomic) IBOutlet UIButton *hostingButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray *allEvents;
@property (strong, nonatomic) NSArray *myEvents;
@property (strong, nonatomic) NSMutableArray *searchEvents;
@property (assign, nonatomic) BOOL isMyEventMode;
@property (assign, nonatomic) BOOL isSearchMode;

@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

- (IBAction)onInvitedClicked:(id)sender;
- (IBAction)onHostingClicked:(id)sender;

@end

@implementation EventListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.myEvents = [[NSArray alloc] init];
    self.allEvents = [[NSArray alloc] init];
    self.isMyEventMode = NO;
    self.isSearchMode = NO;
    [self setEventSourceSwitchState];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"EventViewCell" bundle:nil] forCellReuseIdentifier:@"EventViewCell"];
    self.tableView.rowHeight = 266;

    self.tabBar.delegate = self;
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    
    self.searchBar.delegate = self;
    self.searchBar.hidden = YES;
    self.searchEvents = [NSMutableArray array];

    [self loadCurrentUserFBProfile];
    [self fetchFBEvents];
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
            self.searchBar.hidden = YES;
            self.eventSourceTypeView.hidden = NO;
            [self.tableView reloadData];
        }
    } else if ([item.title isEqualToString:@"Gifts"]) {
    } else if ([item.title isEqualToString:@"Search"]) {
        self.searchBar.hidden = NO;
        self.eventSourceTypeView.hidden = YES;
        self.isSearchMode = YES;
        [self.searchBar becomeFirstResponder];
    } else if ([item.title isEqualToString:@"Logout"]) {
        [self onLogout];
    } else {
        
    }
}

#pragma mark - search bar control

// Search bar event listener
- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar sizeToFit];
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.searchEvents removeAllObjects];
    NSString *text = searchBar.text;
    for (Event *event in self.allEvents) {
        // Search title and host name
        NSRange nameRange = [event.name rangeOfString:text options:NSCaseInsensitiveSearch];
        NSRange hostNameRange = [event.eventHostName rangeOfString:text options:NSCaseInsensitiveSearch];
        NSRange descriptionRange = [event.eventDescription rangeOfString:text options:NSCaseInsensitiveSearch];
        if(nameRange.location != NSNotFound || hostNameRange.location != NSNotFound || descriptionRange.location != NSNotFound) {
            [self.searchEvents addObject:event];
        }
    }
    
    [self.tableView reloadData];
}

// Reset search bar state after cancel button clicked
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.searchBar.text = @"";
    // Select Events
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    self.isSearchMode = NO;
    self.searchBar.hidden = YES;
    self.eventSourceTypeView.hidden = NO;
    [self.tableView reloadData];
    [searchBar sizeToFit];
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

#pragma mark - helper functions

- (void)setEventSourceSwitchState {
    // hot pink #ff69b4
    UIColor *hotPink = [UIColor  colorWithRed:255.0f/255.0f green:105.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
    UIColor *lightGrey = [UIColor  colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
    
    if (self.isMyEventMode) {
        self.hostingButton.backgroundColor = hotPink;
        self.hostingButton.tintColor = [UIColor whiteColor];
        self.invitedButton.backgroundColor = lightGrey;
        self.invitedButton.tintColor = hotPink;
    } else {
        self.hostingButton.backgroundColor = lightGrey;
        self.hostingButton.tintColor = hotPink;
        self.invitedButton.backgroundColor = hotPink;
        self.invitedButton.tintColor = [UIColor whiteColor];
    }
}

- (void)loadCurrentUserFBProfile {
    if ([User currentUser] != nil) {
        NSLog(@"no need to load user profile");
        return;
    }
    [User fetchFBUserProfileWithCompletion:@"me" completion:^(User *user, NSError *error) {
        if (!error) {
            [User setCurrentUser:user];
        } else {
            NSLog(@"Failed to get user profile");
        }
    }];
}

- (void)fetchFBEvents {
    [Event fetchFBEventsWithCompletion:@"me" completion:^(NSDictionary *events, NSError *error) {
        if (!error) {
            self.allEvents = events[@"otherEvents"];
            self.myEvents = events[@"myEvents"];
            [self.tableView reloadData];
        }
    }];
}

@end
