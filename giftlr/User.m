//
//  User.m
//  giftlr
//
//  Created by Yingming Chen on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "User.h"

@interface User ()

@property (nonatomic, strong) NSDictionary *fbUserData;

@end

@implementation User

- (id)initWithFbUserData:(NSDictionary *)fbUserData {
    self = [super init];
    if (self) {
        self.fbUserData = fbUserData;
        self.fbUserId = fbUserData[@"id"];
        self.email = fbUserData[@"email"];
        self.firstName = fbUserData[@"first_name"];
        self.lastName = fbUserData[@"last_name"];
        self.name = fbUserData[@"name"];
        self.profilePicView = [[FBProfilePictureView alloc] initWithProfileID:self.fbUserId pictureCropping:FBProfilePictureCroppingSquare];
    }
    return self;
}

+ (void)fetchFBUserProfileWithCompletion:(NSString *)userId completion:(void (^)(User *user, NSError *error))completion {
    NSString *userGraphPath = [NSString stringWithFormat:@"%@", userId];
    [FBRequestConnection startWithGraphPath:userGraphPath
                          completionHandler:^(FBRequestConnection *connection, NSDictionary *fbUserData, NSError *error) {
        if (!error) {
            User *user = [[User alloc] initWithFbUserData:fbUserData];
            NSLog(@"user data %@", fbUserData);
            completion(user, nil);
        } else {
            completion(nil, error);
        }
    }];
}

#pragma mark - current user methods

static User *_currentUser = nil;
NSString * const kCurrentUserKey = @"kCurrentUserKey";

+ (User *)currentUser {
    if (_currentUser == nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        if (data != nil) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            _currentUser = [[User alloc] initWithFbUserData:dictionary];
        }
    }
    return _currentUser;
}

+ (void)setCurrentUser:(User *)user {
    _currentUser = user;
    if (_currentUser != nil) {
        NSData  *data = [NSJSONSerialization dataWithJSONObject:user.fbUserData options:0 error:NULL];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
    } else {
        // clear the saved object
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCurrentUserKey];
    }
    
    // Force to save to disk
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)logout {
    [User setCurrentUser:nil];
    [PFUser logOut];
}

+ (void)setUserProfileImage:(UIView *)profileContainerView fbUserId:(NSString *)fbUserId {
    FBProfilePictureView *profilePicView = [[FBProfilePictureView alloc] initWithProfileID:fbUserId pictureCropping:FBProfilePictureCroppingSquare];
    profilePicView.bounds = profileContainerView.bounds;
    [profileContainerView addSubview:profilePicView];
    profilePicView.center = CGPointMake(profileContainerView.frame.size.width / 2, profileContainerView.frame.size.height / 2);
}

@end
