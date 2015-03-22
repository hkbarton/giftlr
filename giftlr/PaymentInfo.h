//
//  PaymentInfo.h
//  giftlr
//
//  Created by Ke Huang on 3/17/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "PTKCardType.h"
#import "User.h"

@interface PaymentInfo : NSObject

@property (nonatomic, strong) NSString *fbUserId;
@property (nonatomic, strong) NSString *last4;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, assign) PTKCardType cardType;
@property (nonatomic, assign) BOOL isBankAccount;

-(void)saveToParse;
-(void)deleteFromParse;
-(PFObject *)getPFObject;
-(id)initWithPFObject:(PFObject *)pfObject;

+(PaymentInfo*)creditCardOfCurUser:(NSString *) last4 withToken:(NSString *)token andType:(PTKCardType)type;

+(void)loadCreditCardsByUser:(User *)user withCallback:(void (^)(NSArray *pamentInfos, NSError *error))callback;
+(void)loadBankInfosByUser:(User *)user withCallback:(void (^)(NSArray *pamentInfos, NSError *error))callback;

@end
