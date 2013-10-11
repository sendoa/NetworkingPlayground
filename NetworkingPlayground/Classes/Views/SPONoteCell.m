//
//  SPONoteCell.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 06/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPONoteCell.h"
#import "SPONote.h"
#import "SPOUser.h"

NSString * const SPONoteCellIdentifier = @"SPONoteCell";

@interface SPONoteCell ()

@property (weak, nonatomic) IBOutlet UILabel *lblNoteText;
@property (weak, nonatomic) IBOutlet UIImageView *noteImageView;

@end

@implementation SPONoteCell

- (void)bindWithNote:(SPONote *)note
{
    self.lblNoteText.text = note.textContent;
    
    // Download attached if image (if present)
    if (note.imageURL) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        
        // Tarea de descarga de archivo
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:note.imageURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.noteImageView.image = downloadedImage;
            });
        }];
        [downloadTask resume];
    }
}

@end
