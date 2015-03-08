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

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    // Add FB login view
//    FBLoginView *loginView = [[FBLoginView alloc] init];
//    loginView.center = self.view.center;
//    [self.view addSubview:loginView];

    /*
    NSArray *permissions = @[@"email", @"user_friends", @"public_profile", @"user_birthday", @"user_interests", @"user_events"]; // , @"rsvp_event"
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            NSLog(@"user data %@", user);
            
            // To acquire publishing permissions
            [PFFacebookUtils reauthorizeUser:[PFUser currentUser]
                      withPublishPermissions:@[@"rsvp_event"]
                                    audience:FBSessionDefaultAudienceFriends
                                       block:^(BOOL succeeded, NSError *error) {
                                           if (succeeded) {
                                               NSLog(@"got rsvp_event permission");
                                               // Your app now has publishing permissions for the user
                                           }
                                       }];
        } else {
            NSLog(@"User logged in through Facebook!");
        }
    }];
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onProductSearchClick:(id)sender {
    ProductSearchViewController *psvc = [[ProductSearchViewController alloc] init];
    UINavigationController *psnvc = [[UINavigationController alloc] initWithRootViewController:psvc];
    [self presentViewController:psnvc animated:YES completion:nil];
}


@end
