//
//  ProductDetailTextView.h
//  giftlr
//
//  Created by Ke Huang on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductGift.h"

@interface ProductDetailTextView : UIView

@property (nonatomic, strong)ProductGift *product;

-(ProductGift *)getUpdatedProductGift;

@end
