//
//  CashGift.m
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "CashGift.h"
#import <Parse/Parse.h>

NSString *const CashGiftStatusUnclaimed = @"Unclaimed";
NSString *const CashGiftStatusClaimed = @"Claimed";
NSString *const CashGiftStatusTransferred = @"Bought";

@implementation CashGift

-(void)saveToParse {
    if (!self.pfObject) {
        self.pfObject = [PFObject objectWithClassName:@"CashGift"];
    }

    self.pfObject[@"name"] = self.name;
    self.pfObject[@"amount"] = @([self.amount floatValue]);

    if (!self.status) {
        self.status = CashGiftStatusUnclaimed;
    }
    self.pfObject[@"status"] = self.status;

    if (self.hostEvent != nil) {
        self.pfObject[@"facebookEventID"] = self.hostEvent.fbEventId;
        if (self.hostEvent.eventHostId != nil) {
            self.pfObject[@"hostFacebookUserID"] = self.hostEvent.eventHostId;
        }
        if (self.hostEvent.name) {
            self.pfObject[@"eventName"] = self.hostEvent.name;
        }
    }
    
    if (self.claimerFacebookUserID != nil) {
        self.pfObject[@"claimerFacebookUserID"] = self.claimerFacebookUserID;
    }
    if (self.claimerName != nil) {
        self.pfObject[@"claimerName"] = self.claimerName;
    }
    if (self.claimDate != nil) {
        self.pfObject[@"claimDate"] = self.claimDate;
    }
    
    [self.pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
        } else {
            NSLog(@"error saving CashGift = %@", error);
        }
    }];
}

-(void)deleteFromParse {
    [self.pfObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"deleted with error %@", error);
        }
    }];
}

-(PFObject *)getPFObject {
    return self.pfObject;
}

-(id)initWithPFObject:(PFObject *)pfObject {
    self = [super init];
    if (self) {
        self.pfObject = pfObject;
        
        self.name = [pfObject objectForKey:@"name"];
        self.amount = [pfObject objectForKey:@"amount"];
        self.status = [pfObject objectForKey:@"status"];

        NSString *facebookEventID = [pfObject objectForKey:@"facebookEventID"];
        if (facebookEventID!=nil) {
            // TODO change to load event from Event object
            self.hostEvent = [[Event alloc] init];
            self.hostEvent.fbEventId = facebookEventID;
            self.hostEvent.eventHostId = pfObject[@"hostFacebookUserID"];
            self.hostEvent.name = pfObject[@"eventName"];
        }
        self.claimerFacebookUserID = self.pfObject[@"claimerFacebookUserID"];
        self.claimerName = self.pfObject[@"claimerName"];
        self.claimDate = self.pfObject[@"claimDate"];
    }
    
    return self;
}

+(void)loadCashGiftsByEvent:(Event *)event withCallback:(void (^)(NSArray *cashGifts, NSError *error))callback {
    PFQuery *query = [PFQuery queryWithClassName:@"CashGift"];
    [query whereKey:@"facebookEventID" equalTo:event.fbEventId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *result = nil;
        if (!error) {
            result = [NSMutableArray array];
            for (int i=0;i<[objects count];i++) {
                PFObject *pfObj = objects[i];
                [result addObject:[[CashGift alloc] initWithPFObject:pfObj]];
            }
        }
        callback(result, error);
    }];
}


@end
