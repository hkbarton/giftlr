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
@property (nonatomic, assign) NSInteger quantity;
@property (nonatomic, strong) NSMutableArray *imageURLs;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) Event *hostEvent;

-(void)saveToParse;
-(PFObject *)getPFObject;
-(id)initWithPFObject:(PFObject *)pfObject;

+(ProductGift*)parseProductFromWeb:(NSURL *)url withHTML:(NSString *)html;

@end
