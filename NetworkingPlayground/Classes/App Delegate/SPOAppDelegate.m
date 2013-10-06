//
//  SPOAppDelegate.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 05/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPOAppDelegate.h"
#import "SPOUserStore.h"
#import "SPOActiveUser.h"
#import <FXKeychain.h>

@implementation SPOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupStandardUserDefaults];
    [self setupMemberLoginStatus];
    
    return YES;
}

#pragma mark - Helpers
- (void)setupStandardUserDefaults
{
    NSDictionary *defaults = @{
                               SPONetworkingPlaygroundConstantsFirstRunKey  : @YES
                               };
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:defaults];
}

- (void)setupMemberLoginStatus
{
    // Remove keychain entries on first run
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SPONetworkingPlaygroundConstantsFirstRunKey]) {
        [[SPOActiveUser sharedInstance] removeUserCredentialsEntriesFromKeychain];
    }
}

@end
