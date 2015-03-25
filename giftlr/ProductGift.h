//
//  ProductGift.h
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Event.h"

extern NSString *const ProductGiftStatusUnclaimed;
extern NSString *const ProductGiftStatusClaimed;
extern NSString *const ProductGiftBought;

@interface ProductGift : NSObject

@property (nonatomic, strong) NSString *giftID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *productDescription;
@property (nonatomic, strong) NSString *productURL;
@property (nonatomic, strong) NSDecimalNumber *price;
@property (nonatomic, strong) NSMutableArray *imageURLs;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) Event *hostEvent;
@property (nonatomic, strong) NSString *claimerFacebookUserID;
@property (nonatomic, strong) NSString *claimerName;
@property (nonatomic, strong) NSDate *claimDate;

-(void)saveToParse;
-(void)deleteFromParse;
-(PFObject *)getPFObject;
-(id)initWithPFObject:(PFObject *)pfObject;
-(id)clone;

+(ProductGift*)parseProductFromWeb:(NSURL *)url withHTML:(NSString *)html;
+(BOOL)isProductParseAbleFromWeb:(NSURL *)url withHTML:(NSString *)html;
+(void)loadProductGiftsByEvent:(Event *)event withCallback:(void (^)(NSArray *productGifts, NSError *error))callback;
+(void)searchProductGiftsByKeyword:(NSString *)keyword withCallback:(void (^)(NSArray *productGifts, NSError *error))callback;

@end
