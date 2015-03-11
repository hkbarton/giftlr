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
NSString *const CashGiftBought = @"Bought";

@implementation CashGift

-(void)saveToParse {
    PFObject *cashGift = [PFObject objectWithClassName:@"CashGift"];
    cashGift[@"name"] = self.name;
    cashGift[@"amount"] = @([self.amount floatValue]);
    cashGift[@"facebookEventID"] = self.facebookEventID;
    
    [cashGift saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            self.pfObject = cashGift;
        } else {
            NSLog(@"error saving CashGift = %@", error);
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
        self.facebookEventID = [pfObject objectForKey:@"facebookEventID"];
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
