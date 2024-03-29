//
//  EventInvite.m
//  giftlr
//
//  Created by Yingming Chen on 3/15/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "EventInvite.h"

@interface EventInvite ()

@end

@implementation EventInvite

- (id)initWithEvent:(Event *)event guest:(User *)guest {
    self = [super init];
    if (self) {
        self.event = event;
        self.eventId = event.fbEventId;
        self.guestUserId = guest.fbUserId;
        self.guest = guest;
        self.inviteDate = [NSDate date];
    }
    
    return self;
}

- (id)initWithPFObject:(PFObject *)pfObject {
    self = [super init];
    if (self) {
        self.pfObject = pfObject;
        
        self.eventId = pfObject[@"eventId"];
        self.guestUserId = pfObject[@"guestUserId"];
        self.inviteDate = pfObject[@"inviteDate"];
    }
    
    return self;
    
}

- (void)saveToParse {
    if (!self.pfObject) {
        self.pfObject = [PFObject objectWithClassName:@"EventInvite"];
    }
    
    self.pfObject[@"eventId"] = self.eventId;
    self.pfObject[@"inviteDate"] = self.inviteDate;
    self.pfObject[@"guestUserId"] = self.guestUserId;
    self.pfObject[@"event"] = self.event.pfObject;
    [self.pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"saved event invite '%@' successfully with id %@", self.eventId, self.pfObject.objectId);
        } else {
            // There was a problem, check error.description
        }
    }];
}

-(void)deleteFromParse {
    NSLog(@"try to delete %@", self.pfObject.objectId);
    [self.pfObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"deleted with error %@", error);
        }
    }];
}

// Fetch the pending invites. It will then delete those invites and add events into user's event field
+ (void)fetchPendingInvitesWithCompletion:(User *)user completion:(void (^)(NSArray *events, NSError *error))completion {
    PFQuery *inviteQuery = [PFQuery queryWithClassName:@"EventInvite"];
    NSString *userId = user.fbUserId;
    [inviteQuery whereKey:@"guestUserId" equalTo:userId];
    [inviteQuery includeKey:@"event"];
    [inviteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *events = [NSMutableArray array];
        for (PFObject *object in objects) {
            EventInvite *invite = [[EventInvite alloc] initWithPFObject:object];
            PFObject *eventPFObject = object[@"event"];
            Event *event = [[Event alloc] initWithPFObject:eventPFObject];
            [events addObject:event];
            [invite deleteFromParse];
            [user linkUserWithEvents:events];
        }
        completion(events, error);
    }];
}

@end
