//
//  User.h
//  giftlr
//
//  Created by Yingming Chen on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Event.h"


@interface User : NSObject

@property (nonatomic, strong) NSString *fbUserId;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) FBProfilePictureView *profilePicView;

@property (nonatomic, strong) PFUser *pfUser;

- (id)initWithFbUserData:(NSDictionary *)fbUserData;
- (void)saveToParse;
- (id)initWithPFUser:(PFUser *)pfUser;
- (void)linkUserWithEvent:(Event *)event;
- (void)linkUserWithEvents:(NSArray *)events;
- (void)linkUserWithFbFriend:(NSString *)fbUserId;
- (void)getFriendsWithCompletion:(void (^)(NSArray *friends, NSError *error))completion;
- (void)setUserProfileImage:(UIView *)profileContainerView;

+ (void)loadCurrentUserFBData;
+ (void)loadCurrentUserFBDataWithCompletion:(void (^)(NSArray *friends, NSError *error))completion;
+ (void)fetchFBFriendsWithCompletion:(User *)user completion:(void (^)(NSArray *friends, NSError *error))completion;
+ (void)fetchFBUserProfileWithCompletion:(NSString *)userId completion:(void (^)(User *user, NSError *error))completion;
+ (void)setUserProfileImage:(UIView *)profileContainerView fbUserId:(NSString *)fbUserId;
+ (void)addUserProfileImage:(UIView *)profileContainerView profilePicView:(FBProfilePictureView *)profilePicView;
+ (FBProfilePictureView *)createUserProfileImage:(NSString *)fbUserId;

+ (User *)currentUser;
+ (void)setCurrentUser:(User *)user;

+ (void)logout;

@end
