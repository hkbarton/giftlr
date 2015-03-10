//
//  Event.h
//  giftlr
//
//  Created by Yingming Chen on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

typedef NS_ENUM(NSInteger, EventType) {
    EventTypeCreated = 0,
    EventTypeAttending = 1,
    EventTypeMaybe = 2,
    EventTypeNotReplied = 3,
    EventTypeDeclined = 4,
    EventTypeUnknown = 5
};

@interface Event : NSObject

// Data from the /events result
@property (nonatomic, strong) NSString *fbEventId;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *rsvpStatus;
@property (nonatomic, strong) NSString *timezone;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSString *startTimeString;
@property (nonatomic, strong) NSString *startTimeMonth;
@property (nonatomic, strong) NSString *startTimeDay;
@property (nonatomic, strong) NSString *startTimeYear;
@property (nonatomic, strong) NSString *startTimeWeekday;
@property (nonatomic, assign) EventType eventType;

// Data from the /event API result
@property (nonatomic, strong) NSString *eventDescription;
@property (nonatomic, strong) NSString *eventHostId;
@property (nonatomic, strong) NSString *eventHostName;
@property (nonatomic, assign) BOOL isHostEvent;

// Data from /event/picture
@property (nonatomic, strong) NSString *profileUrl;

@property (nonatomic, strong) User *eventHost;

- (id)initWithData:(NSDictionary *)data type:(EventType)type;

- (void)fetchEventDetailWithCompletion:(void (^)(NSError *error))completion;

+ (void)fetchFBEventsWithCompletion:(NSString *)userId completion:(void (^)(NSDictionary *events, NSError *error))completion;

+ (EventType)stringToEventType:(NSString *)eventTypeString;

@end
