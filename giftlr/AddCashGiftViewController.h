//
//  AddCashGiftViewController.h
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@class AddCashGiftViewController;

@protocol AddCashGiftViewControllerDelegate

@optional
-(void)addCashGiftViewController:(AddCashGiftViewController *)addCashGiftViewController didGiftAdd:(NSArray *)gifts;

@end

@interface AddCashGiftViewController : UIViewController

@property (nonatomic, strong) Event* event;
@property (nonatomic, weak) id<AddCashGiftViewControllerDelegate> delegate;


@end
