//
//  EventListViewController.m
//  giftlr
//
//  Created by Yingming Chen on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

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
#import "EventInvite.h"
#import "UIColor+giftlr.h"

typedef NS_ENUM(NSInteger, EventListWithPendingSectionIndex) {
    EventListWithPendingSectionIndexPending = 0,
    EventListWithPendingSectionIndexUpcoming = 1,
    EventListWithPendingSectionIndexPast = 2,
    EventListWithPendingSectionIndexMax = 3
};

typedef NS_ENUM(NSInteger, EventListWithoutPendingSectionIndex) {
    EventListWithoutPendingSectionIndexUpcoming = 0,
    EventListWithoutPendingSectionIndexPast = 1,
    EventListWithoutPendingSectionIndexMax = 2
};


@interface EventListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, EKEventEditViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *eventSourceTypeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *eventSourceBottomBorderView;
@property (weak, nonatomic) IBOutlet UIButton *eventNotificationButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventNotificationTopConstraint;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *invitedButton;
@property (weak, nonatomic) IBOutlet UIButton *hostingButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *allEvents;
@property (strong, nonatomic) NSMutableArray *pendingEvents;
@property (strong, nonatomic) NSMutableArray *upcomingEvents;
@property (strong, nonatomic) NSMutableArray *pastEvents;
@property (assign, nonatomic) NSInteger upcomingEventsCount;
@property (assign, nonatomic) NSInteger pastEventsCount;

@property (strong, nonatomic) NSMutableArray *myEvents;
@property (strong, nonatomic) NSMutableArray *searchEvents;
@property (assign, nonatomic) NSInteger upcomingMyEventsCount;
@property (assign, nonatomic) NSInteger pastMyEventsCount;

@property (assign, nonatomic) BOOL isMyEventMode;
@property (assign, nonatomic) BOOL isSearchMode;
@property (assign, nonatomic) BOOL showPendingEvents;

@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;
@property (nonatomic, strong) UIView *searchBgView;
@property (nonatomic, weak) UIImageView *navBarHairlineImageView;

//@property (nonatomic, strong) EKEventEditViewController *eventEditViewController;
@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) EKCalendar *defaultCalendar;

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
    self.showPendingEvents = NO;
    self.upcomingEventsCount = self.pastEventsCount = self.pastMyEventsCount = self.upcomingMyEventsCount = 0;
    self.eventSourceTypeView.backgroundColor = [UIColor lightGreyBackgroundColor];
    self.eventSourceBottomBorderView.backgroundColor = [UIColor redPinkColor];
    self.eventNotificationButton.hidden = YES;
    self.eventNotificationButton.layer.cornerRadius = 10;
    self.eventNotificationButton.clipsToBounds = YES;
    self.eventNotificationButton.tintColor = [UIColor hotPinkColor];
    [self setEventSourceSwitchState];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"EventViewCell" bundle:nil] forCellReuseIdentifier:@"EventViewCell"];
    self.tableView.rowHeight = 266;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 0)];
    UIPanGestureRecognizer *tablePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    tablePanGestureRecognizer.delegate = self;
    [self.tableView addGestureRecognizer:tablePanGestureRecognizer];
    self.searchBar.delegate = self;
    self.searchBar.tintColor = [UIColor hotPinkColor];
    self.searchBar.backgroundColor = [UIColor lightGreyBackgroundColor];
    self.searchEvents = [NSMutableArray array];
    
//    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    // Hide the border line of navigation bar: http://stackoverflow.com/questions/19226965/how-to-hide-ios7-uinavigationbar-1px-bottom-line
    self.navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    
    self.title = @"Events";
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Search-25-pink"] style:UIBarButtonItemStylePlain target:self action:@selector(showSearchBar)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Plus-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onAddEvent)];
    self.navigationItem.rightBarButtonItems = @[searchItem];
    
    // "pull to refresh" support
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableRefreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.tableRefreshControl atIndex:0];
    
    self.eventStore = [[EKEventStore alloc] init];
    self.defaultCalendar = [self.eventStore defaultCalendarForNewEvents];
    
    [self loadCurrentUserFBData];
    [self fetchParseEvents];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navBarHairlineImageView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navBarHairlineImageView.hidden = NO;
}

# pragma mark - navigation bar actions

// https://developer.apple.com/library/mac/documentation/DataManagement/Conceptual/EventKitProgGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40004759-SW1
// TODO: create a giftlr calendar
- (void)onAddEvent {
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            EKEventEditViewController *eventEditViewController = [[EKEventEditViewController alloc] init];
            eventEditViewController.eventStore = self.eventStore;
            eventEditViewController.editViewDelegate = self;
            [self presentViewController:eventEditViewController animated:YES completion:^{
            }];
        } else {
            NSLog(@"no access granted");
        }
    }];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    EKEvent *ekEvent = controller.event;
    switch (action) {
        case EKEventEditViewActionCanceled:
            NSLog(@"event creation cancel");
            break;
        case EKEventEditViewActionSaved:
            NSLog(@"event created %@", ekEvent);
            [self addEventWithEKEvent:ekEvent];
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void) addEventWithEKEvent:(EKEvent *)ekEvent {
    Event *event = [[Event alloc] initWithEKEvent:ekEvent type:EventTypeCreated];
    [event saveToParseWithCompletion:^(NSError *error) {
        // save the relations
        [[User currentUser] linkUserWithEvent:event];
        [self.allEvents addObject:event];
        [self.myEvents addObject:event];
        [self sortEvents];
        [self.tableView reloadData];
    }];
}

- (void)showSearchBar {
    if (self.isSearchMode) {
        return;
    }
    
    if (!self.searchBgView) {
        self.searchBgView = [[UIView alloc] initWithFrame:self.tableView.bounds];
        self.searchBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    
    [self.tableView addSubview:self.searchBgView];
    self.isSearchMode = YES;
    self.searchBarTopConstraint.constant = 64;
    [self.searchBar setNeedsLayout];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.searchBar layoutIfNeeded];
        [self.searchBar becomeFirstResponder];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - gesture controls

// Need to allow parent container to handle pan gesture while the table view scroll still working
// See http://stackoverflow.com/questions/17614609/table-view-doesnt-scroll-when-i-use-gesture-recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)onPan:(UIPanGestureRecognizer *)sender {
    CGPoint velocity = [sender velocityInView:self.view];
    NSLog(@"on pan");
    if (sender.state == UIGestureRecognizerStateBegan) {
    } else if (sender.state == UIGestureRecognizerStateChanged) {
    } else if (sender.state == UIGestureRecognizerStateEnded) {
//        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            [self.view layoutIfNeeded];
//        } completion:^(BOOL finished) {
//        }];
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
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.searchBar layoutIfNeeded];
    } completion:^(BOOL finished) {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSearchMode) {
        return 1;
    }
    
    if (self.showPendingEvents) {
        return EventListWithPendingSectionIndexMax;
    } else {
        return EventListWithoutPendingSectionIndexMax;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.isSearchMode) {
        return @"";
    }
    
    if (!self.isMyEventMode && self.showPendingEvents) {
        switch (section) {
            case EventListWithPendingSectionIndexUpcoming:
                return @"Upcoming events";
            case EventListWithPendingSectionIndexPending:
                return @"New invites";
            case EventListWithPendingSectionIndexPast:
                return @"Past events";
            default:
                return @"";
        }
    }

    switch (section) {
        case EventListWithoutPendingSectionIndexUpcoming:
            return @"Upcoming events";
        case EventListWithoutPendingSectionIndexPast:
            return @"Past events";
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
    if (self.isSearchMode) {
        return self.searchEvents.count;
    }

    if (self.isMyEventMode) {
        switch (section) {
            case EventListWithoutPendingSectionIndexUpcoming:
                return self.upcomingMyEventsCount;
            case EventListWithoutPendingSectionIndexPast:
                return self.pastMyEventsCount;
            default:
                return 0;
        }
    }
    
    if (self.showPendingEvents) {
        switch (section) {
            case EventListWithPendingSectionIndexPending:
                return self.pendingEvents.count;
            case EventListWithPendingSectionIndexUpcoming:
                return self.upcomingEventsCount;
            case EventListWithPendingSectionIndexPast:
                return self.pastEventsCount;
            default:
                return 0;
        }
    }
    
    switch (section) {
        case EventListWithoutPendingSectionIndexUpcoming:
            return self.upcomingEventsCount;
        case EventListWithoutPendingSectionIndexPast:
            return self.pastEventsCount;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventViewCell"];
    cell.event = [self getEventForCell:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    EventDetailViewController *edvc = [[EventDetailViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:edvc];
    edvc.event = [self getEventForCell:indexPath];
    [self presentViewController:nvc animated:YES completion:^{
    }];
}

- (Event *)getEventForCell:(NSIndexPath *)indexPath {
    Event *event = nil;
    if (self.isSearchMode) {
        event = self.searchEvents[indexPath.row];
        return event;
    } else if (self.isMyEventMode) {
        switch (indexPath.section) {
            case EventListWithoutPendingSectionIndexUpcoming:
                event = self.myEvents[indexPath.row];
                break;
            case EventListWithoutPendingSectionIndexPast:
                event = self.myEvents[indexPath.row + self.upcomingMyEventsCount];
                break;
            default:
                break;
        }
        return event;
    } else {
        if (self.showPendingEvents) {
            switch (indexPath.section) {
                case EventListWithPendingSectionIndexPending:
                    event = self.pendingEvents[indexPath.row];
                    break;
                case EventListWithPendingSectionIndexUpcoming:
                    event = self.allEvents[indexPath.row];
                    break;
                case EventListWithPendingSectionIndexPast:
                    event = self.allEvents[indexPath.row + self.upcomingEventsCount];
                    break;
                default:
                    break;
            }
            return event;
        }
        
        switch (indexPath.section) {
            case EventListWithoutPendingSectionIndexUpcoming:
                event = self.allEvents[indexPath.row];
                break;
            case EventListWithoutPendingSectionIndexPast:
                event = self.allEvents[indexPath.row + self.upcomingEventsCount];
                break;
            default:
                break;
        }

        return event;
    }
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

- (IBAction)onEventNotificaionClicked:(id)sender {
    self.eventNotificationButton.hidden = YES;
    self.showPendingEvents = YES;
    [self.tableView reloadData];
}

- (void)onRefresh {
    self.showPendingEvents = NO;
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

// TODO: move this to somewhere else
- (void)loadCurrentUserFBData {
    [User fetchFBFriendsWithCompletion:[User currentUser] completion:^(NSError *error) {
    }];
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
                    [self.tableRefreshControl endRefreshing];
                    [self sortEvents];
                    [self.tableView reloadData];
                    [EventInvite fetchPendingInvitesWithCompletion:[User currentUser] completion:^(NSArray *events, NSError *error) {
                        if (events.count > 0) {
                            NSLog(@"pending request found");
                            self.pendingEvents = [NSMutableArray arrayWithArray:events];
                            self.eventNotificationButton.hidden = NO;
                        }
                    }];
                } else {
                    NSLog(@"failed get fb event %@", error);
                }
            }];
        }
    }];
}

- (void) sortEvents {
    [self.allEvents sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((Event *)obj2).startTime compare:((Event *)obj1).startTime];
    }];
    
    self.upcomingEventsCount = 0;
    NSDate *now = [NSDate date];
    for (int i = 0; i < self.allEvents.count; i ++) {
        Event *event = self.allEvents[i];
        if ([event.startTime compare:now] != NSOrderedAscending) {
            self.upcomingEventsCount ++;
        } else {
            break;
        }
    }
    self.pastEventsCount = self.allEvents.count - self.upcomingEventsCount;
    
    [self.myEvents sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((Event *)obj2).startTime compare:((Event *)obj1).startTime];
    }];

    self.upcomingMyEventsCount = 0;
    for (int i = 0; i < self.myEvents.count; i ++) {
        Event *event = self.myEvents[i];
        if ([event.startTime compare:now] != NSOrderedAscending) {
            self.upcomingMyEventsCount ++;
        } else {
            break;
        }
    }
    self.pastMyEventsCount = self.myEvents.count - self.upcomingMyEventsCount;
}

@end
