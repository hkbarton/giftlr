//
//  ProductDetailViewController.h
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductGift.h"

@class ProductDetailViewController;

@protocol ProductDetailViewControllerDelegate

@optional
-(void)productDetailViewController:(ProductDetailViewController *)productDetailViewController didProductGiftAdd:(ProductGift *)productGift;

@end

@interface ProductDetailViewController : UIViewController

@property (nonatomic, weak) id<ProductDetailViewControllerDelegate> delegate;

-(id)initWithProduct: (ProductGift *)product;

@end
