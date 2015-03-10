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

@implementation Event

static NSDateFormatter *df = nil;

- (id)initWithData:(NSDictionary *)data type:(EventType)type{
    self = [super init];

    if (self) {
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
        [df setDateFormat:@"MMM"];
        self.startTimeMonth =[df stringFromDate:self.startTime];
        [df setDateFormat:@"dd"];
        self.startTimeDay =[df stringFromDate:self.startTime];
        [df setDateFormat:@"EEEE, MMMM dd 'at' h:mma"];
        self.startTimeString =[df stringFromDate:self.startTime];
    }

    return self;
}

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
                                          event.eventHost = [User currentUser];
                                          [myEvents addObject:event];
                                      }
                                      [eventResults setObject:myEvents forKey:@"myEvents"];
                                      
                                      NSMutableArray *otherEvents = [NSMutableArray array];
                                      for (NSString *eventSubEdge in fbEventSubEdges) {
                                          if (![eventSubEdge isEqualToString:@"created"]) {
                                              NSArray *myRawEvents = [rawEventResults valueForKeyPath:[NSString stringWithFormat:@"%@.data", eventSubEdge]];
                                              for (NSDictionary *eventData in myRawEvents) {
                                                  EventType type = [Event stringToEventType:eventSubEdge];
                                                  Event *event = [[Event alloc] initWithData:eventData type:type];
                                                  [otherEvents addObject:event];
                                              }
                                          }
                                      }
                                      [otherEvents sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                          return [((Event *)obj2).startTime compare:((Event *)obj1).startTime];
                                      }];
                                      
                                      [eventResults setObject:otherEvents forKey:@"otherEvents"];
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
