//
//  SPOLoginViewController.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 06/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPOLoginViewController.h"
#import "SPOUserStore.h"
#import "SPOActiveUser.h"
#import "SPOUser.h"

@interface SPOLoginViewController () <UITextFieldDelegate>

#pragma mark - Properties
@property (strong, nonatomic) SPOUserStore *userStore;

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

#pragma mark - Action methods
- (IBAction)loginButtontapped:(id)sender;

@end

@implementation SPOLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userStore = [[SPOUserStore alloc] init];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    // "Next" button implementation
    static NSInteger maxTag = 1;
    
    if (textField.tag < maxTag) {
        NSInteger nextTag = textField.tag + 1;
        UIResponder* nextResponder = [[self view] viewWithTag:nextTag];
        if (nextResponder) {
            [textField resignFirstResponder]; // So we get automatic scrolling for free
            [nextResponder becomeFirstResponder];
        } else {
            [textField resignFirstResponder];
        }
    }
    
    if (textField.tag == maxTag) {
        [textField resignFirstResponder];
        [self loginWithEmail:self.txtEmail.text password:self.txtPassword.text];
    }
    
    // Avoid \n returns
    return NO;
}

#pragma mark - Action methods
- (IBAction)loginButtontapped:(id)sender {
    [self loginWithEmail:self.txtEmail.text password:self.txtPassword.text];
}

#pragma mark - Helpers
- (void)loginWithEmail:(NSString *)email password:(NSString *)password
{
    [self.userStore loginWithEmail:email password:password onCompletion:^(SPOUser *user, NSError *error) {
        if (!error) {
            if (user) {
                [[SPOActiveUser sharedInstance] setUser:user];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"¡Ups!"
                                                                message:@"Usuario o contraseña incorrectos"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        } else {
            NSAssert(NO, @"Error while login user %@", error);
        }
    }];
}

@end
