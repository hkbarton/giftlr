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
#import "SideViewTransition.h"

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

@property (weak, nonatomic) IBOutlet UIButton *eventNotificationButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

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

@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) EKCalendar *defaultCalendar;

@property (nonatomic, strong) NSIndexPath *willDisplayIndexPath;

@property (strong, nonatomic) SideViewTransition *detailViewTransition;

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
    self.eventNotificationButton.hidden = YES;
    self.eventNotificationButton.layer.cornerRadius = 10;
    self.eventNotificationButton.clipsToBounds = YES;
    self.eventNotificationButton.tintColor = [UIColor hotPinkColor];
    
    self.tableView.backgroundColor = [UIColor lightGreyBackgroundColor];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"EventViewCell" bundle:nil] forCellReuseIdentifier:@"EventViewCell"];
    self.tableView.rowHeight = 266;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 0)];
    UIPanGestureRecognizer *tablePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    tablePanGestureRecognizer.delegate = self;
    [self.tableView addGestureRecognizer:tablePanGestureRecognizer];
    self.searchEvents = [NSMutableArray array];
    
//    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    // Hide the border line of navigation bar: http://stackoverflow.com/questions/19226965/how-to-hide-ios7-uinavigationbar-1px-bottom-line
//    self.navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
//    self.navBarHairlineImageView.hidden = YES;
    
    self.title = @"Events";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Plus-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onAddEvent)];
    
    // "pull to refresh" support
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableRefreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.tableRefreshControl atIndex:0];
    
    self.eventStore = [[EKEventStore alloc] init];
    self.defaultCalendar = [self.eventStore defaultCalendarForNewEvents];
    
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
        [self presentEventDetailViewController:event];
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
    if (sender.state == UIGestureRecognizerStateBegan) {
    } else if (sender.state == UIGestureRecognizerStateChanged) {
    } else if (sender.state == UIGestureRecognizerStateEnded) {
//        EventViewCell *willDisplayCell = (EventViewCell *)[self.tableView cellForRowAtIndexPath:self.willDisplayIndexPath];
//        [willDisplayCell zoomEventProfilePic:YES];
//        if (velocity.y > 0) {
//            if (self.willDisplayIndexPath.row > 0) {
//                NSIndexPath *prevIndexPath = [NSIndexPath indexPathForRow:self.willDisplayIndexPath.row - 1 inSection:self.willDisplayIndexPath.section];
//                EventViewCell *prevCell = (EventViewCell *)[self.tableView cellForRowAtIndexPath:prevIndexPath];
//                [prevCell zoomEventProfilePic:NO];
//            }
//        } else {
//            if (self.willDisplayIndexPath.row + 1 < [self.tableView numberOfRowsInSection:self.willDisplayIndexPath.section]) {
//                NSIndexPath *prevIndexPath = [NSIndexPath indexPathForRow:self.willDisplayIndexPath.row + 1 inSection:self.willDisplayIndexPath.section];
//                EventViewCell *prevCell = (EventViewCell *)[self.tableView cellForRowAtIndexPath:prevIndexPath];
//                [prevCell zoomEventProfilePic:NO];
//            }
//            
//        }
//        
    }
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

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    EventViewCell *eventViewCell = (EventViewCell *)cell;
    [eventViewCell zoomEventProfilePic:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.willDisplayIndexPath = indexPath;
    EventViewCell *eventViewCell = (EventViewCell *)cell;
    [eventViewCell zoomEventProfilePic:YES];
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
    [self presentEventDetailViewController:[self getEventForCell:indexPath]];
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

- (void)presentEventDetailViewController:(Event *)event {
    EventDetailViewController *edvc = [[EventDetailViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:edvc];
    edvc.event = event;
//    [self presentViewController:nvc animated:YES completion:^{
//    }];

    self.detailViewTransition = [SideViewTransition newTransitionWithTargetViewController:nvc andSideDirection:RightSideDirection];
    self.detailViewTransition.widthPercent = 1.0;
    self.detailViewTransition.AnimationTime = 0.5;
    self.detailViewTransition.addModalBgView = NO;
    self.detailViewTransition.slideFromViewPercent = 0.3;
    nvc.transitioningDelegate = self.detailViewTransition;
    [self presentViewController:nvc animated:YES completion:nil];

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
