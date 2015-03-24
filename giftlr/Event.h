//
//  Event.h
//  giftlr
//
//  Created by Yingming Chen on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//
#import <EventKit/EventKit.h>
#import <Parse/Parse.h>
#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

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
@property (nonatomic, strong) NSString *defaultEventProfileImage;

// Data from the /event API result
@property (nonatomic, strong) NSString *eventDescription;
@property (nonatomic, strong) NSString *eventHostId;
@property (nonatomic, strong) NSString *eventHostName;
@property (nonatomic, assign) BOOL isHostEvent;
@property FBProfilePictureView *eventHostProfilePicView;


// Data from /event/picture
@property (nonatomic, strong) NSString *profileUrl;
@property (nonatomic, strong) UIImage *profileImage;

@property (strong, nonatomic) PFObject *pfObject;
@property (strong, nonatomic) NSMutableDictionary *guests;

- (id)initWithPFObject:(PFObject *)pfObject;

- (id)initWithData:(NSDictionary *)data type:(EventType)type;

- (id)initWithEKEvent:(EKEvent *)event type:(EventType)type;

- (void)inviteGuests:(NSArray *)guests;

- (void)getInvitedGuestsWithCompletion:(void (^)(NSDictionary *guests, NSError *error))completion;

- (void)saveToParse;

- (void)saveToParseWithCompletion:(void (^)(NSError *error))completion;

- (void)fetchEventDetailWithCompletion:(void (^)(NSError *error))completion;

+ (void)fetchFBEventsWithCompletion:(NSString *)userId completion:(void (^)(NSDictionary *events, NSError *error))completion;

+ (void)fetchEventWithFacebookEventID:(NSString *)facebookEventID completion:(void (^)(NSArray *events, NSError *error))completion;

+ (void)searchEventsByKeyword:(NSString *)keyword withCompletion:(void (^)(NSArray * events))completion;

+ (EventType)stringToEventType:(NSString *)eventTypeString;

@end
