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

- (id)initWithPFUser:(PFUser *)pfUser {
    self = [super init];
    if (self) {
        self.pfUser = pfUser;
        
        self.fbUserData = pfUser[@"fbUserData"];
        self.fbUserId = pfUser[@"fbUserId"];
        self.email = pfUser[@"email"];
        self.firstName = pfUser[@"first_name"];
        self.lastName = pfUser[@"last_name"];
        self.name = pfUser[@"name"];
        self.profilePicView = [[FBProfilePictureView alloc] initWithProfileID:self.fbUserId pictureCropping:FBProfilePictureCroppingSquare];
    }
    
    return self;
}

- (void)setUserProfileImage:(UIView *)profileContainerView {
    for (UIView *view in profileContainerView.subviews) {
        [view removeFromSuperview];
    }
    
    self.profilePicView.bounds = profileContainerView.bounds;
    [profileContainerView addSubview:self.profilePicView];
    self.profilePicView.center = CGPointMake(profileContainerView.frame.size.width / 2, profileContainerView.frame.size.height / 2);
}

#pragma mark - Parse related helpers
- (void)saveToParse {
    if (!self.pfUser) {
        // What is gonna be the user name/pwd here?
        // This will be used fo our own signup purpose
        self.pfUser = [PFUser user];
    }
    
    self.pfUser[@"fbUserData"] = self.fbUserData;
    self.pfUser[@"fbUserId"] = self.fbUserId;
    self.pfUser[@"email"] = self.email;
    self.pfUser[@"first_name"] = self.firstName;
    self.pfUser[@"last_name"] = self.lastName;
    self.pfUser[@"name"] = self.name;
    
    [self.pfUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
            NSLog(@"user saved successfully %@", self.pfUser.objectId);
        } else {
            NSLog(@"failed to save user data");
            // There was a problem, check error.description
        }
    }];
}

- (void)linkUserWithEvent:(Event *)event {
    if (event.pfObject && self.pfUser) {
        PFRelation *relation = [self.pfUser relationForKey:@"events"];
        [relation addObject:event.pfObject];
        [self.pfUser saveInBackground];
    }
}

- (void)linkUserWithEvents:(NSArray *)events {
    if (events.count > 0 && self.pfUser) {
        PFRelation *relation = [self.pfUser relationForKey:@"events"];
        for (Event *event in events) {
            [relation addObject:event.pfObject];
        }

        [self.pfUser saveInBackground];
    }
}

- (void)linkUserWithFbFriend:(NSString *)fbUserId {
    PFQuery *parseQuery = [PFUser query];
    [parseQuery whereKey:@"fbUserId" equalTo:fbUserId];
    [parseQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFRelation *relation = [self.pfUser relationForKey:@"friends"];
        for (PFUser *user in objects) {
            [relation addObject:user];
        }
        [self.pfUser saveInBackground];
    }];
}

- (void)getFriendsWithCompletion:(void (^)(NSArray *friends, NSError *error))completion {
    PFRelation *relation = [self.pfUser relationForKey:@"friends"];
    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *pfUsers, NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            NSMutableArray *friends = [NSMutableArray array];
            for (PFUser *pfUser in pfUsers) {
                User *user = [[User alloc] initWithPFUser:pfUser];
                [friends addObject:user];
                completion(friends, nil);
            }
        }
    }];
}

# pragma mark - fb related helpers

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

+ (void)fetchFBFriendsWithCompletion:(User *)user completion:(void (^)(NSError *error))completion {
    NSString *fbUserId = user.fbUserId;
    if (user == [User currentUser]) {
        fbUserId = @"me";
    }
    NSString *friendsGraphPath = [NSString stringWithFormat:@"%@/friends?limit=100", fbUserId];
    [FBRequestConnection startWithGraphPath:friendsGraphPath
                          completionHandler:^(FBRequestConnection *connection, NSDictionary *result, NSError *error) {
                              if (!error) {
                                  NSLog(@"friend list %@", result);
                                  NSArray *friends = result[@"data"];
                                  for (NSDictionary *friend in friends) {
                                      [user linkUserWithFbFriend:friend[@"id"]];
                                  }
                                  completion(nil);
                              } else {
                                  NSLog(@"failed to get friends list %@", error);
                                  completion(error);
                              }
                          }];
}

#pragma mark - current user methods

static User *_currentUser = nil;

+ (User *)currentUser {
    // Should we still save to user defaults?
    if (_currentUser == nil) {
        PFUser *user = [PFUser currentUser];
        if (user != nil) {
            _currentUser = [[User alloc] initWithPFUser:user];
        }
    }
    
    return _currentUser;
}

+ (void)setCurrentUser:(User *)user {
    _currentUser = user;
    if (_currentUser != nil) {
        [user saveToParse];
    }
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
