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
        self.detail = [NSString stringWithFormat:@"joined GiftHub!"];
        self.fromUserProfilePicView = [[FBProfilePictureView alloc] initWithProfileID:self.fromUserId pictureCropping:FBProfilePictureCroppingSquare];
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
        self.event = invite.event;
        self.activityDate = [NSDate date];
        self.detail = [NSString stringWithFormat:@"invited you to the event:"];
        self.fromUserProfilePicView = [[FBProfilePictureView alloc] initWithProfileID:self.fromUserId pictureCropping:FBProfilePictureCroppingSquare];
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
        self.event = gift.hostEvent;
        self.gift = gift;
        self.activityDate = gift.claimDate;
        self.detail = [NSString stringWithFormat:@"bring a gift to \"%@\":", self.eventName];
        self.fromUserProfilePicView = [[FBProfilePictureView alloc] initWithProfileID:self.fromUserId pictureCropping:FBProfilePictureCroppingSquare];
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
        self.event = gift.hostEvent;
        self.activityDate = gift.claimDate;
        self.detail = [NSString stringWithFormat:@"contribute %@$ the event:", gift.amount];
        self.fromUserProfilePicView = [[FBProfilePictureView alloc] initWithProfileID:self.fromUserId pictureCropping:FBProfilePictureCroppingSquare];
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
        if (pfObject[@"event"]) {
            self.event = [[Event alloc]initWithPFObject:(pfObject[@"event"])];
        }
        if (pfObject[@"gift"]) {
            self.gift = [[ProductGift alloc] initWithPFObject:pfObject[@"gift"]];
        }
        
        self.fromUserProfilePicView = [[FBProfilePictureView alloc] initWithProfileID:self.fromUserId pictureCropping:FBProfilePictureCroppingSquare];
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
    if (self.event.pfObject) {
        self.pfObject[@"event"] = self.event.pfObject;
    }
    
    if (self.gift) {
        PFObject *giftPFObject = [self.gift getPFObject];
        if (giftPFObject) {
            self.pfObject[@"gift"] = giftPFObject;
        }
    }
    
    [self.pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
        } else {
            // There was a problem, check error.description
        }
        completion(error);
    }];
}


+ (void)getActivitiesWithCompletion:(NSString *)userId completion:(void (^)(NSArray *activities, NSError *error))completion {
    PFQuery *queryActivitiesToMe = [PFQuery queryWithClassName:@"Activity"];
    [queryActivitiesToMe whereKey:@"toUserId" equalTo:userId];
    
    PFQuery *queryActivitiesFromMe = [PFQuery queryWithClassName:@"Activity"];
    [queryActivitiesFromMe whereKey:@"fromUserId" equalTo:userId];

    PFQuery *query = [PFQuery orQueryWithSubqueries:@[queryActivitiesFromMe,queryActivitiesToMe]];
    [query orderByDescending:@"activityDate"];
    [query includeKey:@"event"];
    [query includeKey:@"gift"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *pfObjects, NSError *error) {
        NSMutableArray *activities = [NSMutableArray array];
        for (PFObject *pfObject in pfObjects) {
            Activity *activity = [[Activity alloc] initWithPFObject:pfObject];
            [activities addObject:activity];
        }
        [activities sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [((Activity *)obj2).activityDate compare:((Activity *)obj1).activityDate];
        }];
        
        completion(activities, error);
    }];
}

@end
