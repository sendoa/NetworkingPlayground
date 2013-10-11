//
//  SPONewNoteViewController.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 06/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPONewNoteViewController.h"
#import "SPONotesStore.h"
#import "SPOActiveUser.h"
#import "SPOUser.h"

@interface SPONewNoteViewController () <UITextViewDelegate>

@property (strong, nonatomic) SPONotesStore *notesStore;
@property (weak, nonatomic) IBOutlet UITextView *txtNoteText;

@end

@implementation SPONewNoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.notesStore = [[SPONotesStore alloc] init];
    
    [self initialUISetup];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.txtNoteText becomeFirstResponder];
}

#pragma mark - Action methods
- (void)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveNoteButtonTapped:(id)sender
{
    BOOL isFormValid = YES;
    
    // Data validation
    if ([self.txtNoteText.text isEqualToString:@""]) isFormValid = NO;
    
    // POST
    if (isFormValid) {
        NSDictionary *params = @{
                                 @"user_id"         : [SPOActiveUser sharedInstance].user.userId,
                                 @"text_content"    : self.txtNoteText.text
                                 };
        [self postNewNoteWithParameters:params];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"¡Ups!"
                                                        message:@"Debes indicar un contenido para la nota"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Helpers
- (void)initialUISetup
{
    // leftBarButtonItem
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancelar" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    // rightBarButtonItem
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Guardar" style:UIBarButtonItemStylePlain target:self action:@selector(saveNoteButtonTapped:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)postNewNoteWithParameters:(NSDictionary *)parameters
{
    [self.notesStore newNoteWithParameters:parameters onCompletion:^(NSError *error) {
        if (!error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"¡Ups!"
                                                            message:@"Error desconocido al crear nota"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

@end
