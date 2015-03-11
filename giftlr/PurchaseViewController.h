//
//  PurchaseViewController.h
//  giftlr
//
//  Created by Ke Huang on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductGift.h"

@class PurchaseViewController;

@protocol PurchaseViewControllerDelegate

@optional
-(void)purchaseViewController:(PurchaseViewController *)purchaseViewController didProductGiftBought:(ProductGift *)product;

@end

@interface PurchaseViewController : UIViewController

@property (nonatomic, weak) id<PurchaseViewControllerDelegate> delegate;

-(id)initWithProduct: (ProductGift *)product;

@end
