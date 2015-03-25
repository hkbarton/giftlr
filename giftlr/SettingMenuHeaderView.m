//
//  SettingMenuHeaderView.m
//  giftlr
//
//  Created by Ke Huang on 3/15/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "SettingMenuHeaderView.h"
#import "User.h"

@interface SettingMenuHeaderView()

@property (weak, nonatomic) IBOutlet UIImageView *imageProfile;

@end

@implementation SettingMenuHeaderView

- (void)awakeFromNib {
    self.imageProfile.layer.cornerRadius = 35;
    self.imageProfile.clipsToBounds = YES;
    self.imageProfile.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.imageProfile.layer.borderWidth = 2;
    [User addUserProfileImage:self.imageProfile profilePicView:[User currentUser].profilePicView];
}

@end
