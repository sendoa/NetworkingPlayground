//
//  SPORegistrationViewController.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 06/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPORegistrationViewController.h"
#import "SPOUserStore.h"
#import "SPOActiveUser.h"
#import "SPOUser.h"

NSString * SPORegistrationViewControllerRegistrationSucceedNotificationKey = @"SPORegistrationViewControllerRegistrationSucceedNotification";

@interface SPORegistrationViewController () <UITextFieldDelegate>

#pragma mark - Properties
@property (strong, nonatomic) SPOUserStore *userStore;

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastname;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword1;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword2;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *texfieldsCollection;

- (IBAction)registerButtonTapped:(id)sender;

@end

@implementation SPORegistrationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userStore = [[SPOUserStore alloc] init];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    // "Next" button implementation
    static NSInteger maxTag = 4;
    
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
        [self registerButtonTapped:nil];
    }
    
    // Avoid \n returns
    return NO;
}

#pragma mark - Action methods
- (IBAction)registerButtonTapped:(id)sender {
    BOOL isFormValid = YES;
    
    // Data validation
    for (UITextField *textField in self.texfieldsCollection) {
        if ([textField.text isEqualToString:@""]) isFormValid = NO;
    }
    if (![self.txtPassword1.text isEqualToString:self.txtPassword2.text]) isFormValid = NO;
    
    // POST
    if (isFormValid) {
        NSDictionary *params = @{
                                 @"email"       : self.txtEmail.text,
                                 @"password"    : self.txtPassword1.text,
                                 @"name"        : self.txtName.text,
                                 @"lastname"    : self.txtLastname.text
                                 };
        [self registerWithParameters:params];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"¡Ups!"
                                                        message:@"Debes rellenar todos los campos y las contraseñas deben coincidir"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Helpers
- (void)registerWithParameters:(NSDictionary *)parameters
{
    [self.userStore newUserWithParameters:parameters onCompletion:^(SPOUser *user, NSError *error) {
        if (!error) {
            if (user) {
                [[SPOActiveUser sharedInstance] setUser:user];
                [[NSNotificationCenter defaultCenter] postNotificationName:SPORegistrationViewControllerRegistrationSucceedNotificationKey object:self];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"¡Ups!"
                                                                message:@"Error al registrar usuario"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        } else {
            NSAssert(NO, @"Error while registering user %@", error);
        }
    }];
}

@end
