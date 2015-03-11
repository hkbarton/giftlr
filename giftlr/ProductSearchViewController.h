//
//  ProductSearchViewController.h
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "ProductGift.h"

@class ProductSearchViewController;

@protocol ProductSearchViewControllerDelegate

@optional
-(void)productSearchViewController:(ProductSearchViewController *)productSearchViewController didProductGiftAdd:(ProductGift *)productGift;

@end

@interface ProductSearchViewController : UIViewController

-(id)initWithHostEvent:(Event *) hostEvent;

@property (nonatomic, weak) id<ProductSearchViewControllerDelegate> delegate;

@end
