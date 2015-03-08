//
//  ProductHTMLParser.h
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParsePattern.h"

@interface ProductHTMLParser : NSObject

@property (nonatomic, strong) NSArray *nameParsePatterns;
@property (nonatomic, strong) NSArray *imageURLParsePatterns;
@property (nonatomic, strong) NSArray *priceParsePatterns;
@property (nonatomic, strong) NSArray *urlParsePatterns;

+(ProductHTMLParser *)getParserByURL:(NSURL *)url;
+(NSString *)parseData:(NSString *) data withParsePatterns:(NSArray *)patterns;

@end
