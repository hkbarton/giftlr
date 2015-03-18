//
//  PaymentInfo.m
//  giftlr
//
//  Created by Ke Huang on 3/17/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "PaymentInfo.h"

@interface PaymentInfo()

@property (strong, nonatomic) PFObject *pfObj;

@end

@implementation PaymentInfo

-(id)initWithPFObject:(PFObject *)pfObject{
    if (self = [super init]) {
        self.pfObj = pfObject;
        self.fbUserId = pfObject[@"fbUserId"];
        self.last4 = pfObject[@"last4"];
        self.token = pfObject[@"token"];
        self.cardType = [pfObject[@"cardType"] shortValue];
        self.isBankAccount = pfObject[@"isBankAccount"];
    }
    return self;
}

-(void)saveToParse {
    if (!self.pfObj) {
        self.pfObj = [PFObject objectWithClassName:@"PaymentInfo"];
    }
    self.pfObj[@"fbUserId"] = self.fbUserId;
    self.pfObj[@"last4"] = self.last4;
    self.pfObj[@"token"] = self.token;
    self.pfObj[@"cardType"] = @(self.cardType);
    self.pfObj[@"isBankAccount"] = @(self.isBankAccount);
    [self.pfObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"save payment info with error %@", error);
        }
    }];
}

-(void)deleteFromParse {
    [self.pfObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"delete payment info with error %@", error);
        }
    }];
}

-(PFObject *)getPFObject {
    return self.pfObj;
}

+(void)loadCreditCardsByUser:(User *)user withCallback:(void (^)(NSArray *pamentInfos, NSError *error))callback {
    PFQuery *query = [PFQuery queryWithClassName:@"PaymentInfo"];
    [query whereKey:@"fbUserId" equalTo:user.fbUserId];
    [query whereKey:@"isBankAccount" equalTo:@(NO)];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *result = nil;
        if (!error) {
            result = [NSMutableArray array];
            for (int i=0;i<[objects count];i++) {
                PFObject *pfObj = objects[i];
                [result addObject:[[PaymentInfo alloc] initWithPFObject:pfObj]];
            }
        }
        callback(result, error);
    }];
}

+(void)loadBankInfosByUser:(User *)user withCallback:(void (^)(NSArray *pamentInfos, NSError *error))callback {
    PFQuery *query = [PFQuery queryWithClassName:@"PaymentInfo"];
    [query whereKey:@"fbUserId" equalTo:user.fbUserId];
    [query whereKey:@"isBankAccount" equalTo:@(YES)];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *result = nil;
        if (!error) {
            result = [NSMutableArray array];
            for (int i=0;i<[objects count];i++) {
                PFObject *pfObj = objects[i];
                [result addObject:[[PaymentInfo alloc] initWithPFObject:pfObj]];
            }
        }
        callback(result, error);
    }];
}

@end
