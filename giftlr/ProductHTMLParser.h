//
//  ProductHTMLParser.h
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductHTMLParser : NSObject

@property (nonatomic, strong) NSString *nameParsePattern;
@property (nonatomic, strong) NSString *imageURLParsePattern;
@property (nonatomic, strong) NSString *priceParsePattern;

+(ProductHTMLParser *)getParserByURL:(NSURL *)url;

@end
