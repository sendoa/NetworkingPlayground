//
//  SPOAppDelegate.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 05/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPOAppDelegate.h"
#import <FXKeychain.h>
#import "SPOUserStore.h"
#import "SPOActiveUser.h"
#import "SPONotesViewController.h"

@implementation SPOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupStandardUserDefaults];
    [self setupMemberLoginStatus];
    
    return YES;
}

#pragma mark - Background fething
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    UIViewController *rootVC = self.window.rootViewController;
    UITabBarController *tabBarController = (UITabBarController *)rootVC;
    
    // We only have interest in updating data if the selected tab is the notes one
    id selectedVC = tabBarController.selectedViewController;
    if ([selectedVC isMemberOfClass:UINavigationController.class]) {
        id topVC = [(UINavigationController *)selectedVC topViewController];
        if ([topVC isMemberOfClass:[SPONotesViewController class]]) {
            // 1
            [(SPONotesViewController *)topVC performBackgroundNotesFetchingWithCompletionHandler:completionHandler];
        }
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    // Throw notification with information about ended background transfer
    NSDictionary* userInfo = @{
                               @"completionHandler" : completionHandler,
                               @"sessionIdentifier" : identifier
                               };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackgroundTransferDidEndNotification"
                                                        object:nil
                                                      userInfo:userInfo];
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
