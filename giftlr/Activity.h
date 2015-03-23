//
//  Activity.h
//  giftlr
//
//  Created by Yingming Chen on 3/21/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "EventInvite.h"
#import "ProductGift.h"
#import "CashGift.h"

typedef NS_ENUM(NSInteger, ActivityType) {
    ActivityTypeEventInvite = 0,
    ActivityTypeFriendJoin = 1,
    ActivityTypeGiftClaim = 2,
    ActivityTypeGiftDue = 3
};

@interface Activity : NSObject

@property (nonatomic, strong) NSString *fromUserId;
@property (nonatomic, strong) NSString *fromUserName;
@property (nonatomic, strong) NSString *toUserId;
@property (nonatomic, strong) NSString *toUserName;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSDate *activityDate;
@property (nonatomic, assign) NSInteger activityType;
@property (strong, nonatomic) PFObject *pfObject;

- (id)initWithPFObject:(PFObject *)pfObject;

- (id)initWithData:(NSDictionary *)data type:(ActivityType)type;

- (id)initWithEventInvite:(EventInvite *)invite;
- (id)initWithFriendJoin:(NSDictionary *)friendData;
- (id)initWithProductGiftClaim:(ProductGift *)gift;
- (id)initWithCashGiftClaim:(CashGift *)gift;

- (void)saveToParse;

- (void)saveToParseWithCompletion:(void (^)(NSError *error))completion;

+ (void)getActivitiesWithCompletion:(NSString *)userId completion:(void (^)(NSArray *activities, NSError *error))completion;
@end
