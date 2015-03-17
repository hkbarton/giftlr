//
//  EventInvite.h
//  giftlr
//
//  Created by Yingming Chen on 3/15/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#import "Event.h"
#import "User.h"

@interface EventInvite : NSObject

@property (nonatomic, strong) NSString *guestUserId;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) NSDate *inviteDate;
@property (strong, nonatomic) PFObject *pfObject;

- (id)initWithEvent:(Event *)event guest:(User *)guest;
- (id)initWithPFObject:(PFObject *)pfObject;
- (void)saveToParse;

+ (void)fetchPendingInvitesWithCompletion:(User *)user completion:(void (^)(NSArray *events, NSError *error))completion;

@end
