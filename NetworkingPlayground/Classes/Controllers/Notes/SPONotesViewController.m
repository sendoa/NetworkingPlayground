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

@interface SPONotesViewController ()

@property (strong, nonatomic) SPOUserStore *userStore;

@end

@implementation SPONotesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userStore = [[SPOUserStore alloc] init];
    
    [self checkUserCredentials];
}

#pragma mark - Helpers
- (void)checkUserCredentials
{
    [self performSegueWithIdentifier:@"LoginScreenSegue" sender:self];
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
                NSLog(@"Incorrect login");
            }
        } else {
            NSAssert(NO, @"Error while login user %@", error);
        }
    }];
}

@end
