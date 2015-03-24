//
//  CCPickerViewController.h
//  giftlr
//
//  Created by Ke Huang on 3/23/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentInfo.h"

@class CCPickerViewController;

@protocol CCPickerViewControllerDelegate

@optional
-(void)CCPickerViewController:(CCPickerViewController *)ccPickerViewController didPickCreditCard: (PaymentInfo *)paymentInfo;

@end

@interface CCPickerViewController : UIViewController

@property(nonatomic, weak)id<CCPickerViewControllerDelegate> delegate;

@end
