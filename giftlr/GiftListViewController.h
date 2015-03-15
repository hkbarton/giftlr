//
//  GiftListViewController.h
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GiftListViewController;

@protocol GiftListViewControllerDelegate

-(void)goToEventListWithGiftListViewController:(GiftListViewController *)giftListViewController;

@end

@interface GiftListViewController : UIViewController

@property (weak, nonatomic) id<GiftListViewControllerDelegate> delegate;

@end
