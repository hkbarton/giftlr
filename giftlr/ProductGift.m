//
//  ProductGift.m
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ProductGift.h"
#import "ProductHTMLParser.h"

NSString *const ProductGiftStatusUnclaimed = @"Unclaimed";
NSString *const ProductGiftStatusClaimed = @"Claimed";
NSString *const ProductGiftBought = @"Bought";

NSString *const PFObjectClassName = @"ProductGift";

@interface ProductGift()

@property (nonatomic, strong) PFObject *pfObject;

@end

@implementation ProductGift

-(id)initWithPFObject:(PFObject *)pfObject {
    if (self = [super init]) {
        self.giftID = pfObject.objectId;
        self.name = pfObject[@"name"];
        self.productDescription = pfObject[@"productDescription"];
        self.productURL = pfObject[@"productURL"];
        self.price = [[NSDecimalNumber alloc] initWithFloat:[pfObject[@"price"] floatValue]];
        self.quantity = [pfObject[@"quantity"] integerValue];
        self.imageURLs = pfObject[@"imageURLs"];
        self.status = pfObject[@"status"];
        NSString *fbEventId = pfObject[@"fbEventId"];
        if (fbEventId!=nil) {
            // TODO change to load event from Event object
            self.hostEvent = [[Event alloc] init];
            self.hostEvent.fbEventId = fbEventId;
        }
    }
    return self;
}

-(PFObject *)getPFObject {
    return self.pfObject;
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
    self.pfObject[@"quantity"] = @(self.quantity);
    if (self.imageURLs != nil) {
        self.pfObject[@"imageURLs"] = self.imageURLs;
    }
    self.pfObject[@"status"] = self.status;
    if (self.hostEvent != nil) {
        self.pfObject[@"fbEventId"] = self.hostEvent.fbEventId;
    }
    if (self.claimerFacebookUserID != nil) {
        self.pfObject[@"claimerFacebookUserID"] = self.claimerFacebookUserID;
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
    result.quantity = 1;
    NSString *imageURL = [ProductHTMLParser parseData:html withParsePatterns:parser.imageURLParsePatterns];
    if (imageURL != nil) {
        result.imageURLs = [NSMutableArray arrayWithObjects:imageURL, nil];
    }
    result.status = ProductGiftStatusUnclaimed;
    return result;
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

@end
