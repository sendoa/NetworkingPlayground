//
//  SPONewNoteViewController.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 06/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPONewNoteViewController.h"

@interface SPONewNoteViewController ()

@end

@implementation SPONewNoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initialUISetup];
}

#pragma mark - Action methods
- (void)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveNoteButtonTapped:(id)sender
{
    
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

@end
