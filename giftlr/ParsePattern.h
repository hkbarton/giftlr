//
//  ParsePattern.h
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParsePattern : NSObject

@property (nonatomic, strong) NSString *pattern;
@property (nonatomic, assign) NSInteger extractGroupIndex;

+(ParsePattern *)defaultParsePattern;

@end
