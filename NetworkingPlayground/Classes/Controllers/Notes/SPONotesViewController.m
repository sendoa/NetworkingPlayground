//
//  SPONotesViewController.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 06/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPONotesViewController.h"
#import <FXKeychain.h>
#import "SPOUserStore.h"
#import "SPOActiveUser.h"
#import "SPOUser.h"
#import "SPOLoginViewController.h"

@interface SPONotesViewController ()

@property (strong, nonatomic) SPOUserStore *userStore;

@end

@implementation SPONotesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Subscribe to successful login notifications from login controller
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoginSucceedNotiticationObserver:)
                                                 name:SPOLoginViewControllerLoginSucceedNotificationKey
                                               object:nil];
    
    self.userStore = [[SPOUserStore alloc] init];
    
    [self checkUserCredentials];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification observers
- (void)userLoginSucceedNotiticationObserver:(NSNotification *)notification
{
    NSLog(@"Login success notification from login controller received");
    [self.tableView reloadData];
}

#pragma mark - Helpers
- (void)checkUserCredentials
{
    // Get credentials from keychain
    NSString *userEmail = [[FXKeychain defaultKeychain] objectForKey:SPOActiveUserKeychainEmailKey];
    NSString *userPassword = [[FXKeychain defaultKeychain] objectForKey:SPOActiveUserKeychainPasswordKey];
    
    if (!userEmail) {
        // Show login screen
        NSLog(@"No user credentials found on keychain");
        
        return;
    }
    
    // Try to login
    [self.userStore loginWithEmail:userEmail password:userPassword onCompletion:^(SPOUser *user, NSError *error) {
        if (!error) {
            [[SPOActiveUser sharedInstance] setUser:user];
            if ([[SPOActiveUser sharedInstance] isUserLoggedIn]) {
                // Load notes from user
                NSLog(@"Load notes for user %@", [SPOActiveUser sharedInstance].user.userId);
            } else {
                // Show login screen
                [self performSegueWithIdentifier:@"LoginScreenSegue" sender:self];
            }
        } else {
            NSAssert(NO, @"Error while login user %@", error);
        }
    }];
}

@end
