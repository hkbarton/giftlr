//
//  Event.m
//  giftlr
//
//  Created by Yingming Chen on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <DateTools.h>

#import "Event.h"
#import "User.h"
#import "EventInvite.h"

@interface Event ()

@end

@implementation Event

static NSDateFormatter *df = nil;

- (id)initWithData:(NSDictionary *)data type:(EventType)type{
    self = [super init];

    if (self) {
        self.pfObject = nil;
        self.guests = [NSMutableDictionary dictionary];
        
        self.fbEventId = data[@"id"];
        self.location = data[@"location"];
        self.rsvpStatus  = data[@"rsvp_status"];
        self.timezone = data[@"timezone"];
        self.name = data[@"name"];
        if (df == nil) {
            df = [[NSDateFormatter alloc] init];
        }
        self.eventType = type;
        self.isHostEvent = (self.eventType == EventTypeCreated);

        //2010-12-01T21:35:43+0000
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
        NSString *startTimeString = data[@"start_time"];
        self.startTime = [df dateFromString:startTimeString];
        if (self.startTime == nil) {
            [df setDateFormat:@"yyyy-MM-dd"];
            NSString *startTimeString = data[@"start_time"];
            self.startTime = [df dateFromString:startTimeString];
            [df setDateFormat:@"EEE, MMM dd, yyyy"];
            self.startTimeString =[df stringFromDate:self.startTime];
        } else {
            [df setDateFormat:@"EEE, MMM dd, yyyy 'at' h:mma"];
            self.startTimeString =[df stringFromDate:self.startTime];
        }
        [df setDateFormat:@"MMM"];
        self.startTimeMonth =[df stringFromDate:self.startTime];
        [df setDateFormat:@"dd"];
        self.startTimeDay =[df stringFromDate:self.startTime];
    }

    return self;
}

- (id)initWithEKEvent:(EKEvent *)event type:(EventType)type {
    self = [super init];
    
    if (self) {
        self.pfObject = nil;
        self.guests = [NSMutableDictionary dictionary];

        // @TODO: maybe use some different id filed?
        self.fbEventId = [NSString stringWithFormat:@"EKEvent-%@", [[NSUUID UUID] UUIDString]];
        self.location = event.location;
        self.name = event.title;
        if (df == nil) {
            df = [[NSDateFormatter alloc] init];
        }
        self.eventType = type;
        self.isHostEvent = (self.eventType == EventTypeCreated);
        
        if (self.isHostEvent) {
            self.eventHostId = [User currentUser].fbUserId;
            self.eventHostName = [User currentUser].name;
        }
        
        self.startTime = event.startDate;
        [df setDateFormat:@"EEE, MMM dd, yyyy 'at' h:mma"];
        self.startTimeString =[df stringFromDate:self.startTime];
        [df setDateFormat:@"MMM"];
        self.startTimeMonth =[df stringFromDate:self.startTime];
        [df setDateFormat:@"dd"];
        self.startTimeDay =[df stringFromDate:self.startTime];
        
        self.eventDescription = event.notes;
    }
    
    return self;
}

- (id)initWithPFObject:(PFObject*)pfObject {
    self = [super init];
    if (self) {
        self.pfObject = pfObject;
        self.guests = [NSMutableDictionary dictionary];
        
        self.fbEventId = pfObject[@"fbEventId"];
        self.location = pfObject[@"location"];
        // TODO: how to determine RSVP status?
        // self.rsvpStatus  = data[@"rsvp_status"];
        self.name = pfObject[@"name"];
        if (df == nil) {
            df = [[NSDateFormatter alloc] init];
        }
        self.startTime = pfObject[@"startTime"];
        [df setDateFormat:@"MMM"];
        self.startTimeMonth =[df stringFromDate:self.startTime];
        [df setDateFormat:@"dd"];
        self.startTimeDay =[df stringFromDate:self.startTime];
        [df setDateFormat:@"EEE, MMM dd, yyyy 'at' h:mma"];
        self.startTimeString =[df stringFromDate:self.startTime];
        
        self.eventHostName = pfObject[@"eventHostName"];
        self.eventHostId = pfObject[@"eventHostId"];
        self.eventDescription = pfObject[@"eventDescription"];
        self.profileUrl = pfObject[@"profileUrl"];

        self.isHostEvent = ([self.eventHostId isEqualToString:[User currentUser].fbUserId]);
    }
    
    return self;
}

- (void)saveToParse {
    [self saveToParseWithCompletion:^(NSError *error) {
    }];
}

- (void)saveToParseWithCompletion:(void (^)(NSError *error))completion {
    if (!self.pfObject) {
        self.pfObject = [PFObject objectWithClassName:@"Event"];
    }
    
    // @TODO: figure out how to save rsvp data?
    
    self.pfObject[@"name"] = self.name;
    self.pfObject[@"fbEventId"] = self.fbEventId;
    if (self.location) {
        self.pfObject[@"location"] = self.location;
    }
    if (self.startTime) {
        self.pfObject[@"startTime"] = self.startTime;
    }
    if (self.eventHostId) {
        self.pfObject[@"eventHostId"] = self.eventHostId;
    }
    if (self.eventHostName) {
        self.pfObject[@"eventHostName"] = self.eventHostName;
    }
    if (self.eventDescription) {
        self.pfObject[@"eventDescription"] = self.eventDescription;
    }
    if (self.profileUrl) {
        self.pfObject[@"profileUrl"] = self.profileUrl;
    }
    
    [self.pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"saved event '%@' successfully with id %@", self.name, self.pfObject.objectId);
        } else {
            // There was a problem, check error.description
        }
        
        completion(error);
    }];
}

- (void)inviteGuests:(NSArray *)guests {
    PFRelation *relation = [self.pfObject relationForKey:@"invitedGuests"];
    for (User *guest in guests) {
        // Make sure we don't invite one person twice
        if ([self.guests objectForKey:guest.fbUserId] == nil) {
            EventInvite *invite = [[EventInvite alloc] initWithEvent:self guest:guest];
            [invite saveToParse];
            [relation addObject:guest.pfUser];
            [self.guests setObject:guest forKey:guest.fbUserId];
        }
    }
    [self saveToParse];
}

- (void)getInvitedGuestsWithCompletion:(void (^)(NSDictionary *guests, NSError *error))completion {
    PFRelation *relation = [self.pfObject relationForKey:@"invitedGuests"];
    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *pfUsers, NSError *error) {
        if (error) {
            NSLog(@"Failed to get guest lists with error %@", error);
            completion(nil, error);
        } else {
            for (PFUser *pfUser in pfUsers) {
                User *user = [[User alloc] initWithPFUser:pfUser];
                [self.guests setObject:user forKey:user.fbUserId];
            }
            completion(self.guests, nil);
        }
    }];
}

# pragma mark -- helper functions to fetch from FB

- (void)fetchEventDetailWithCompletion:(void (^)(NSError *error))completion {
    __block NSInteger resultCount = 0;
    NSString *eventGraphPath = [NSString stringWithFormat:@"/%@", self.fbEventId];
    [FBRequestConnection startWithGraphPath:eventGraphPath
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (!error) {
                                  self.eventDescription = result[@"description"];
                                  self.eventHostName = [result valueForKeyPath:@"owner.name"];
                                  self.eventHostId = [result valueForKeyPath:@"owner.id"];
                                  if ([self.eventHostId isEqualToString:[User currentUser].fbUserId]) {
                                      self.isHostEvent = YES;
                                  }
                              }
                              
                              resultCount ++;
                              if (resultCount == 2) {
                                  [self saveToParse];
                                  completion(nil);
                              }
                          }];
    
    eventGraphPath = [NSString stringWithFormat:@"/%@/photos", self.fbEventId];
    [FBRequestConnection startWithGraphPath:eventGraphPath
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (!error) {
                                  NSArray *photos = result[@"data"];
                                  if (photos != nil && photos.count > 0) {
                                      NSArray *images = (photos[0])[@"images"];
                                      if (images != nil && images.count > 0) {
                                          NSString *imageUrl = (images[0])[@"source"];
                                          self.profileUrl = imageUrl;
                                      }
                                  }
                              }
                              
                              resultCount ++;
                              if (resultCount == 2) {
                                  [self saveToParse];
                                  completion(nil);
                              }
                          }];
}

#pragma mark - factory functions

+ (void)fetchFBEventsWithCompletion:(NSString *)userId completion:(void (^)(NSDictionary *events, NSError *error))completion {
    // Get the events in last year
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.month = -12;
    NSDate *date = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    NSInteger sinceTimestamp = (int)[date timeIntervalSince1970];
    
    __block NSInteger responseCount = 0;
    NSArray *fbEventSubEdges = @[@"not_replied", @"attending", @"created", @"maybe"]; // Don't get the declined ones
    NSMutableDictionary *rawEventResults = [NSMutableDictionary dictionary];
    NSMutableDictionary *eventResults = [NSMutableDictionary dictionary];
    
    for (NSString *eventSubEdge in fbEventSubEdges) {
        NSString *eventsGraphPath = [NSString stringWithFormat:@"%@/events/%@?since=%ld", userId, eventSubEdge, sinceTimestamp];
        if ([eventSubEdge isEqualToString:@"attending"]) {
            eventsGraphPath = [NSString stringWithFormat:@"%@/events?since=%ld", userId, sinceTimestamp];
        }
        // See https://developers.facebook.com/docs/graph-api/making-multiple-requests/ to batch them
        [FBRequestConnection startWithGraphPath:eventsGraphPath
                              completionHandler:^(FBRequestConnection *connection, NSDictionary *result, NSError *error) {
                                  if (!error) {
                                      [rawEventResults setObject:result forKey:eventSubEdge];
                                  } else {
                                      NSLog(@"error %@", error);
                                  }
                                  responseCount++;
                                  // Check whether we get all response back
                                  if (responseCount == fbEventSubEdges.count) {
                                      NSMutableArray *myEvents = [NSMutableArray array];
                                      NSArray *myRawEvents = [rawEventResults valueForKeyPath:@"created.data"];
                                      for (NSDictionary *eventData in myRawEvents) {
                                          Event *event = [[Event alloc] initWithData:eventData type:EventTypeCreated];
                                          [myEvents addObject:event];
                                      }
                                      [eventResults setObject:myEvents forKey:@"myEvents"];
                                      
                                      NSMutableArray *allEvents = [NSMutableArray array];
                                      for (NSString *eventSubEdge in fbEventSubEdges) {
                                          if (![eventSubEdge isEqualToString:@"created"]) {
                                              NSArray *myRawEvents = [rawEventResults valueForKeyPath:[NSString stringWithFormat:@"%@.data", eventSubEdge]];
                                              for (NSDictionary *eventData in myRawEvents) {
                                                  EventType type = [Event stringToEventType:eventSubEdge];
                                                  Event *event = [[Event alloc] initWithData:eventData type:type];
                                                  [allEvents addObject:event];
                                              }
                                          }
                                      }
                                      [allEvents sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                          return [((Event *)obj2).startTime compare:((Event *)obj1).startTime];
                                      }];
                                      
                                      [eventResults setObject:allEvents forKey:@"allEvents"];
                                      completion(eventResults, nil);
                                  }
                              }];
    }
}

+ (EventType)stringToEventType:(NSString *)eventTypeString {
    if ([eventTypeString isEqualToString:@"not_replied"]) {
        return EventTypeNotReplied;
    } else if ([eventTypeString isEqualToString:@"attending"]) {
        return EventTypeAttending;
    } else if ([eventTypeString isEqualToString:@"created"]) {
        return EventTypeCreated;
    } else if ([eventTypeString isEqualToString:@"maybe"]) {
        return EventTypeMaybe;
    } else if ([eventTypeString isEqualToString:@"declined"]) {
        return EventTypeDeclined;
    } else {
        return EventTypeUnknown;
    }
}

@end
