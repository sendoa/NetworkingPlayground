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
#import "SPONotesStore.h"
#import "SPONote.h"
#import "SPOLoginViewController.h"
#import "SPORegistrationViewController.h"
#import "SPONoteCell.h"

@interface SPONotesViewController ()

@property (copy, nonatomic) NSArray *notes;
@property (strong, nonatomic) SPOUserStore *userStore;
@property (strong, nonatomic) SPONotesStore *notesStore;

@end

@implementation SPONotesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // This is not the first run anymore
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SPONetworkingPlaygroundConstantsFirstRunKey];
    
    // Subscribe to successful login notifications from login controller and registration controller
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoginSucceedNotiticationObserver:)
                                                 name:SPOLoginViewControllerLoginSucceedNotificationKey
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoginSucceedNotiticationObserver:)
                                                 name:SPORegistrationViewControllerRegistrationSucceedNotificationKey
                                               object:nil];
    
    self.userStore = [[SPOUserStore alloc] init];
    self.notesStore = [[SPONotesStore alloc] init];
    
    [self initialUISetup];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self checkUserCredentials];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDelegate & UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPONoteCell *cell = [tableView dequeueReusableCellWithIdentifier:SPONoteCellIdentifier];
    [cell bindWithNote:self.notes[indexPath.row]];
    
    return cell;
}

#pragma mark - Notification observers
- (void)userLoginSucceedNotiticationObserver:(NSNotification *)notification
{
    NSLog(@"Login success notification from login controller received");
    [self.tableView reloadData];
}

#pragma mark - Action methods
- (void)addNewNoteButtonTapped:(id)sender
{
    NSLog(@"Segue");
    [self performSegueWithIdentifier:@"NewNoteSegue" sender:sender];
}

#pragma mark - Helpers
- (void)initialUISetup
{
    // rightBarButtonItem
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Nueva" style:UIBarButtonItemStylePlain target:self action:@selector(addNewNoteButtonTapped:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)checkUserCredentials
{
    // Get credentials from keychain
    NSString *userEmail = [[FXKeychain defaultKeychain] objectForKey:SPOActiveUserKeychainEmailKey];
    NSString *userPassword = [[FXKeychain defaultKeychain] objectForKey:SPOActiveUserKeychainPasswordKey];
    
    if (!userEmail) {
        // Show login screen
        NSLog(@"No user credentials found on keychain");
        [self performSegueWithIdentifier:@"LoginScreenSegue" sender:self];
    } else {
        // Try to login
        [self.userStore loginWithEmail:userEmail password:userPassword onCompletion:^(SPOUser *user, NSError *error) {
            if (!error) {
                [[SPOActiveUser sharedInstance] setUser:user];
                if ([[SPOActiveUser sharedInstance] isUserLoggedIn]) {
                    // Load user's notes
                    NSLog(@"Load notes for user %@", [SPOActiveUser sharedInstance].user.userId);
                    [self fetchNotesWithCompletionHandler:nil];
                } else {
                    // Show login screen
                    [self performSegueWithIdentifier:@"LoginScreenSegue" sender:self];
                }
            } else {
                NSAssert(NO, @"Error while login user %@", error);
            }
        }];
    }
}

- (void)performBackgroundNotesFetchingWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // Get credentials from keychain
    NSString *userEmail = [[FXKeychain defaultKeychain] objectForKey:SPOActiveUserKeychainEmailKey];
    NSString *userPassword = [[FXKeychain defaultKeychain] objectForKey:SPOActiveUserKeychainPasswordKey];
    
    if (!userEmail) {
        // Show login screen
        NSLog(@"No user credentials found on keychain");
        completionHandler(UIBackgroundFetchResultFailed);
    } else {
        // Try to login
        [self.userStore loginWithEmail:userEmail password:userPassword onCompletion:^(SPOUser *user, NSError *error) {
            if (!error) {
                [[SPOActiveUser sharedInstance] setUser:user];
                if ([[SPOActiveUser sharedInstance] isUserLoggedIn]) {
                    // Load user's notes
                    [self fetchNotesWithCompletionHandler:completionHandler];
                } else {
                    // Incorrect login
                    completionHandler(UIBackgroundFetchResultFailed);
                }
            } else {
                NSLog(@"Error while login user %@", error);
                completionHandler(UIBackgroundFetchResultFailed);
            }
        }];
    }
}

- (void)fetchNotesWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self.notesStore fetchNotesForUser:[SPOActiveUser sharedInstance].user onCompletion:^(NSArray *notes, NSError *error) {
        if (!error) {
            if ([self.notes isEqualToArray:notes]) {
                NSLog(@"NO Se han recibido nuevas notas");
                if (completionHandler) completionHandler(UIBackgroundFetchResultNoData);
            } else {
                NSLog(@"Se han recibido nuevas notas");
                self.notes = notes;
                [self.tableView reloadData];
                 if (completionHandler) completionHandler(UIBackgroundFetchResultNewData);
            }
        } else {
            NSLog(@"Error while fetching notes %@", error);
            if (completionHandler) completionHandler(UIBackgroundFetchResultFailed);
        }
    }];
}

@end
