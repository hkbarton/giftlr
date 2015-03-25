//
//  ProductGift.m
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ProductGift.h"
#import "ProductHTMLParser.h"
#import "User.h"
#import "Event.h"

NSString *const ProductGiftStatusUnclaimed = @"Unclaimed";
NSString *const ProductGiftStatusClaimed = @"Claimed";
NSString *const ProductGiftBought = @"Bought";

@interface ProductGift()

@property (nonatomic, strong) PFObject *pfObject;

@end

@implementation ProductGift

NSString *const PFObjectClassName = @"ProductGift";

-(id)initWithPFObject:(PFObject *)pfObject {
    if (self = [super init]) {
        self.pfObject = pfObject;
        self.giftID = pfObject.objectId;
        self.name = pfObject[@"name"];
        self.productDescription = pfObject[@"productDescription"];
        self.productURL = pfObject[@"productURL"];
        self.price = [[NSDecimalNumber alloc] initWithFloat:[pfObject[@"price"] floatValue]];
        self.imageURLs = pfObject[@"imageURLs"];
        self.status = pfObject[@"status"];
        self.claimerName = pfObject[@"claimerName"];
        self.claimerFacebookUserID = pfObject[@"claimerFacebookUserID"];
        self.claimDate = pfObject[@"claimDate"];
        NSString *fbEventId = pfObject[@"fbEventId"];
        if (fbEventId!=nil) {
            // TODO change to load event from Event object
            self.hostEvent = [[Event alloc] init];
            self.hostEvent.fbEventId = fbEventId;
            self.hostEvent.eventHostId = pfObject[@"hostFacebookUserID"];
            self.hostEvent.eventHostName = pfObject[@"hostName"];
            self.hostEvent.name = pfObject[@"eventName"];
        }
    }
    return self;
}

-(id)clone {
    ProductGift *result = [[ProductGift alloc] init];
    result.name = self.name;
    result.productDescription = self.productDescription;
    result.productURL = self.productURL;
    result.price = [[NSDecimalNumber alloc] initWithFloat: [self.price floatValue]];
    result.imageURLs = [NSMutableArray arrayWithArray:self.imageURLs];
    result.status = self.status;
    if (self.hostEvent) {
        result.hostEvent = [[Event alloc] init];
        result.hostEvent.fbEventId = self.hostEvent.fbEventId;
        result.hostEvent.eventHostId = self.hostEvent.eventHostId;
        result.hostEvent.eventHostName = self.hostEvent.eventHostName;
        result.hostEvent.name = self.hostEvent.name;
    }
    result.claimerFacebookUserID = self.claimerFacebookUserID;
    result.claimerName = self.claimerName;
    result.claimDate = self.claimDate;
    return result;
}

-(PFObject *)getPFObject {
    return self.pfObject;
}

-(void)deleteFromParse {
    [self.pfObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"deleted with error %@", error);
        }
    }];
}

-(void)saveToParse {
    // save gift
    if (!self.pfObject) {
        self.pfObject = [PFObject objectWithClassName:PFObjectClassName];
    }
    self.pfObject[@"name"] = self.name;
    if (self.productDescription != nil) {
        self.pfObject[@"productDescription"] = self.productDescription;
    }
    self.pfObject[@"productURL"] = self.productURL;
    self.pfObject[@"price"] = @([self.price floatValue]);
    if (self.imageURLs != nil) {
        self.pfObject[@"imageURLs"] = self.imageURLs;
    }
    self.pfObject[@"status"] = self.status;
    if (self.hostEvent != nil) {
        self.pfObject[@"fbEventId"] = self.hostEvent.fbEventId;
        if (self.hostEvent.eventHostId != nil) {
            self.pfObject[@"hostFacebookUserID"] = self.hostEvent.eventHostId;
        }
        if (self.hostEvent.eventHostName != nil) {
            self.pfObject[@"hostName"] = self.hostEvent.eventHostName;
        }
        if (self.hostEvent.name != nil) {
            self.pfObject[@"eventname"] = self.hostEvent.name;
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
            self.giftID = self.pfObject.objectId;
        } else {
            // TODO
        }
    }];
}

+(ProductGift*)parseProductFromWeb:(NSURL *)url withHTML:(NSString *)html {
    ProductGift *result = [[ProductGift alloc] init];
    ProductHTMLParser *parser = [ProductHTMLParser getParserByURL:url];
    result.name = [ProductHTMLParser parseData:html withParsePatterns:parser.nameParsePatterns];
    if (parser.urlParsePatterns!=nil && [parser.urlParsePatterns count]>0) {
        result.productURL = [ProductHTMLParser parseData:html withParsePatterns:parser.urlParsePatterns];
    } else {
        result.productURL = url.absoluteString;
    }
    NSString *priceStr = [ProductHTMLParser parseData:html withParsePatterns:parser.priceParsePatterns];
    if (priceStr != nil) {
        result.price = [NSDecimalNumber decimalNumberWithString:priceStr];
    } else {
        result.price = [[NSDecimalNumber alloc] initWithFloat:0];
    }
    NSString *imageURL = [ProductHTMLParser parseData:html withParsePatterns:parser.imageURLParsePatterns];
    if (imageURL != nil) {
        result.imageURLs = [NSMutableArray arrayWithObjects:imageURL, nil];
    }
    result.status = ProductGiftStatusUnclaimed;
    return result;
}

+(BOOL)isProductParseAbleFromWeb:(NSURL *)url withHTML:(NSString *)html {
    if ([url absoluteString].length == 0) {
        return NO;
    }
    // TODO remove this logic to ProductHTMLParser
    NSString *domain = [ProductHTMLParser getDomainFromURL:url];
    if ([domain isEqualToString:@"bloomingdales.com"]) {
        return YES;
    }
    ProductGift *product = [ProductGift parseProductFromWeb:url withHTML:html];
    if (product.imageURLs != nil && [product.imageURLs count] > 0) {
        return YES;
    }
    return NO;
}

+(void)loadProductGiftsByEvent:(Event *)event withCallback:(void (^)(NSArray *productGifts, NSError *error))callback {
    PFQuery *query = [PFQuery queryWithClassName:PFObjectClassName];
    [query whereKey:@"fbEventId" equalTo:event.fbEventId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *result = nil;
        if (!error) {
            result = [NSMutableArray array];
            for (int i=0;i<[objects count];i++) {
                PFObject *pfObj = objects[i];
                [result addObject:[[ProductGift alloc] initWithPFObject:pfObj]];
            }
        }
        callback(result, error);
    }];
}

+(void)searchProductGiftsByKeyword:(NSString *)keyword withCallback:(void (^)(NSArray *productGifts, NSError *error))callback {
    [Event fetchEventOfCurrentUser:^(NSArray *events, NSError *error) {
        if (error) {
            callback(nil, error);
            return;
        }
        NSMutableArray *eventIDs = [NSMutableArray array];
        for (int i=0;i<events.count;i++) {
            Event *event = events[i];
            [eventIDs addObject:event.fbEventId];
        }
        PFQuery *giftNameQuery = [PFQuery queryWithClassName:PFObjectClassName];
        [giftNameQuery whereKey:@"fbEventId" containedIn:eventIDs];
        [giftNameQuery whereKey:@"name" containsString:keyword];
        
        PFQuery *giftDesQuery = [PFQuery queryWithClassName:PFObjectClassName];
        [giftDesQuery whereKey:@"fbEventId" containedIn:eventIDs];
        [giftDesQuery whereKey:@"productDescription" containsString:keyword];
        
        PFQuery *query = [PFQuery orQueryWithSubqueries:@[giftNameQuery, giftDesQuery]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSMutableArray *result = nil;
            if (!error) {
                result = [NSMutableArray array];
                for (int i=0;i<[objects count];i++) {
                    PFObject *pfObj = objects[i];
                    ProductGift *gift = [[ProductGift alloc] initWithPFObject:pfObj];
                    for (int j=0;j<events.count;j++) {
                        Event *event = events[j];
                        if ([gift.hostEvent.fbEventId isEqualToString:event.fbEventId]) {
                            gift.hostEvent = event;
                            break;
                        }
                    }
                    [result addObject:gift];
                }
            }
            callback(result, error);
        }];
    }];
}

@end
