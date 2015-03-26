//
//  LoginViewController.m
//  giftlr
//
//  Created by Yingming Chen on 3/5/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "LoginViewController.h"
#import "ProductSearchViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "EventListViewController.h"
#import "MainViewController.h"
#import "User.h"
#import "Activity.h"
#import "SideViewTransition.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

- (IBAction)onLogin:(id)sender;

@property (nonatomic, strong) SideViewTransition *mainViewTransition;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogin:(id)sender {
        NSArray *permissions = @[@"email", @"user_friends", @"public_profile", @"user_birthday",
                                 @"user_interests", @"user_events"];
        [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
            self.btnLogin.hidden = YES;
            if (!user) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                return;
            }
            [User loadCurrentUserFBData];
            if (user.isNew) {
//                // To acquire publishing permissions
//                [PFFacebookUtils reauthorizeUser:[PFUser currentUser]
//                          withPublishPermissions:@[@"rsvp_event"]
//                                        audience:FBSessionDefaultAudienceFriends
//                                           block:^(BOOL succeeded, NSError *error) {
//                                               if (succeeded) {
//                                                   NSLog(@"got rsvp_event permission");
//                                                   // Your app now has publishing permissions for the user
//                                                   [self presentEventListView];
//                                               }
//                                           }];
                [User loadCurrentUserFBDataWithCompletion:^(NSArray *friends, NSError *error) {
                    if (error) {
                        NSLog(@"Failed to load data");
                    } else {
                        for (NSDictionary *friend in friends) {
                            Activity *activity = [[Activity alloc]initWithFriendJoin:friend];
                            [activity saveToParse];
                        }
                        [self presentEventListView];
                        
                    }
                }];
            } else {
                [User loadCurrentUserFBData];
                [self presentEventListView];
            }
        }];
    
}

- (void)presentEventListView {
    MainViewController *mvc = [[MainViewController alloc] init];
    self.mainViewTransition = [SideViewTransition newTransitionWithTargetViewController:mvc andSideDirection:RightSideDirection];
    self.mainViewTransition.widthPercent = 1.0;
    self.mainViewTransition.AnimationTime = 0.5;
    self.mainViewTransition.addModalBgView = NO;
    self.mainViewTransition.slideFromViewPercent = 0.3;
    mvc.transitioningDelegate = self.mainViewTransition;
    [self presentViewController:mvc animated:YES completion:^{
        self.btnLogin.hidden = NO;
    }];
}

@end
