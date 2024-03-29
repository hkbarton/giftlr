//
//  AppDelegate.m
//  giftlr
//
//  Created by Ke Huang on 3/4/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "LoginViewController.h"
#import "EventListViewController.h"
#import "MainViewController.h"
#import "UIColor+giftlr.h"
#import "Stripe.h"
#import "User.h"

@interface AppDelegate ()

@end

NSString * const StripePublishableKey = @"pk_test_0kSKLkULVcRJ4PvPcFH7Qpy5";

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:@"JNKZmlu3K2M6uqCF1FDgtr2bpPYWNFXVfFqpYA2f"
                  clientKey:@"lnacK66DUKvToNmmQTvyDkjQDcouNcCqv28gKpX2"];
    [PFFacebookUtils initializeFacebook];
    
    // track statistics around application opens
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor hotPinkColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    // Check whether user is logged in
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [User loadCurrentUserFBData];
        MainViewController *mvc = [[MainViewController alloc] init];
        self.window.rootViewController = mvc;
    } else {
        LoginViewController *lvc = [[LoginViewController alloc] init];
        self.window.rootViewController = lvc;
    }
    
    [self.window makeKeyAndVisible];
    
    // Setup Stripe
    [Stripe setDefaultPublishableKey:StripePublishableKey];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Logs 'install' and 'app activate' App Events.
    [FBAppEvents activateApp];
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];}

@end
