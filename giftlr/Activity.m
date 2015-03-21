//
//  Activity.m
//  giftlr
//
//  Created by Yingming Chen on 3/21/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "Activity.h"

@implementation Activity

static NSDateFormatter *df = nil;

- (id)initWithData:(NSDictionary *)data type:(ActivityType)type{
    self = [super init];
    
    if (self) {
        self.activityType = type;
    }
    
    return self;
}

- (id)initWithFriendJoin:(NSDictionary *)friendData {
    self = [super init];
    
    if (self) {
        self.activityType = ActivityTypeFriendJoin;
        self.fromUserId = [User currentUser].fbUserId;
        self.fromUserName = [User currentUser].name;
        self.toUserId = friendData[@"id"];
        self.toUserName = friendData[@"name"];
        self.activityDate = [NSDate date];
        self.detail = [NSString stringWithFormat:@"%@ joined giftlr!", self.fromUserName];
    }
    
    return self;
}

- (id)initWithEventInvite:(EventInvite *)invite {
    self = [super init];
    
    if (self) {
        self.activityType = ActivityTypeEventInvite;
        self.fromUserId = [User currentUser].fbUserId;
        self.fromUserName = [User currentUser].name;
        self.toUserId = invite.guestUserId;
        self.toUserName = invite.guest.name;
        self.eventId = invite.eventId;
        self.eventName = invite.event.name;
        self.activityDate = [NSDate date];
        self.detail = [NSString stringWithFormat:@"%@ invited you to \"%@\" on %@", self.fromUserName, self.eventName, invite.event.startTimeString];
    }
    
    return self;
}

- (id)initWithProductGiftClaim:(ProductGift *)gift {
    self = [super init];
    
    if (self) {
        self.activityType = ActivityTypeGiftClaim;
        self.fromUserId = [User currentUser].fbUserId;
        self.fromUserName = [User currentUser].name;
        self.toUserId = gift.hostEvent.eventHostId;
        self.toUserName = gift.hostEvent.eventHostName;
        self.eventId = gift.hostEvent.fbEventId;
        self.eventName = gift.hostEvent.name;
        self.activityDate = gift.claimDate;
        self.detail = [NSString stringWithFormat:@"%@ will bring \"%@\" to your event \"%@\"", self.fromUserName, gift.name, self.eventName];
    }
    
    return self;
}

- (id)initWithCashGiftClaim:(CashGift *)gift {
    self = [super init];
    
    if (self) {
        self.activityType = ActivityTypeGiftClaim;
        self.fromUserId = [User currentUser].fbUserId;
        self.fromUserName = [User currentUser].name;
        self.toUserId = gift.hostEvent.eventHostId;
        self.toUserName = gift.hostEvent.eventHostName;
        self.eventId = gift.hostEvent.fbEventId;
        self.eventName = gift.hostEvent.name;
        self.activityDate = gift.claimDate;
        self.detail = [NSString stringWithFormat:@"%@ will contribute %@$ for your event \"%@\"", self.fromUserName, gift.amount, self.eventName];
    }
    
    return self;
}

- (id)initWithPFObject:(PFObject*)pfObject {
    self = [super init];
    if (self) {
        self.pfObject = pfObject;
        
        self.eventId = pfObject[@"eventId"];
        self.eventName = pfObject[@"eventName"];
        self.fromUserId = pfObject[@"fromUserId"];
        self.fromUserName = pfObject[@"fromUserName"];
        self.toUserId = pfObject[@"toUserId"];
        self.toUserName = pfObject[@"toUserName"];
        self.detail = pfObject[@"detail"];
        self.activityDate = pfObject[@"activityDate"];
        self.activityType = [pfObject[@"activityType"] integerValue];
    }
    
    return self;
}

- (void)saveToParse {
    [self saveToParseWithCompletion:^(NSError *error) {
    }];
}

- (void)saveToParseWithCompletion:(void (^)(NSError *error))completion {
    if (!self.pfObject) {
        self.pfObject = [PFObject objectWithClassName:@"Activity"];
    }
    
    if (self.eventId) {
        self.pfObject[@"eventId"] = self.eventId;
    }
    if (self.eventName) {
        self.pfObject[@"eventName"] = self.eventName;
    }
    self.pfObject[@"fromUserId"] = self.fromUserId;
    self.pfObject[@"fromUserName"] = self.fromUserName;
    self.pfObject[@"toUserId"] = self.toUserId;
    if (self.toUserName) {
        self.pfObject[@"toUserName"] = self.toUserName;
    }
    self.pfObject[@"detail"] = self.detail;
    self.pfObject[@"activityDate"] = self.activityDate;
    self.pfObject[@"activityType"] = [NSString stringWithFormat:@"%ld",self.activityType];
    
    [self.pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
        } else {
            // There was a problem, check error.description
        }
        completion(error);
    }];
}

@end
