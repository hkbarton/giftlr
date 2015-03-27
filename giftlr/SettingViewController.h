//
//  SettingViewController.h
//  giftlr
//
//  Created by Ke Huang on 3/15/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const SettingMenuPayment;
extern NSString *const SettingMenuLogout;
extern NSString *const SettingMenuWishlist;
extern NSString *const SettingMenuContacts;


@class SettingViewController;

@protocol SettingViewControllerDelegate

@optional

-(void)settingViewController:(SettingViewController *)settingViewController didMenuItemSelected:(NSString *)menuID;

@end

@interface SettingViewController : UIViewController

@property (nonatomic, weak) id<SettingViewControllerDelegate> delegate;

@end
