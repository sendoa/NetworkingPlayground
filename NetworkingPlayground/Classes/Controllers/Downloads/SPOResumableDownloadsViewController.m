//
//  SPOResumableDownloadsViewController.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 10/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPOResumableDownloadsViewController.h"

NSString * const SPOResumableDownloadsViewControllerDownloadFileURLString = @"http://www.hfrmovies.com/TheHobbitDesolationOfSmaug48fps.mp4";

@interface SPOResumableDownloadsViewController () <NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnDownloadButton;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionConfiguration *sessionConfiguration;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (copy, nonatomic) NSString *downloadedFilesDirectoryPath;
@property (copy, nonatomic) NSData *partiallyDownloadedFileData;

- (IBAction)downloadButtonTapped:(id)sender;

@end

@implementation SPOResumableDownloadsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Custom getters/setters
- (NSString *)downloadedFilesDirectoryPath
{
    if (_downloadedFilesDirectoryPath) return _downloadedFilesDirectoryPath;
    
    NSArray* cacheDirectoryPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    _downloadedFilesDirectoryPath = [cacheDirectoryPaths[0] stringByAppendingPathComponent:@"com.sportuondo.networkingplayground.downloadedfiles"];
    BOOL directoryExists = [[NSFileManager defaultManager] fileExistsAtPath:_downloadedFilesDirectoryPath];
    
    if (!directoryExists) {
        NSError* error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:_downloadedFilesDirectoryPath
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error]) {
            NSAssert(NO, @"Couldn't create the directory for downloaded files. Error: %@", error);
        }
    }
    
    return _downloadedFilesDirectoryPath;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"Download progress: %lld of %lld", totalBytesWritten, totalBytesExpectedToWrite);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadProgressView.progress = (double)totalBytesWritten / totalBytesExpectedToWrite;
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // Determine downloaded file destination URL (local directory path)
    NSString *downloadedFileName = [downloadTask.originalRequest.URL lastPathComponent];
    NSString *downloadedFileDestinationPath = [self.downloadedFilesDirectoryPath stringByAppendingPathComponent:downloadedFileName];
    NSURL *downloadedFileNameDestinationURL = [NSURL fileURLWithPath:downloadedFileDestinationPath];
    
    // Copy the downloaded file from the temp directory to the definitive path
    NSError *error;
    BOOL downloadedFileCopyResult = [[NSFileManager defaultManager] copyItemAtURL:location toURL:downloadedFileNameDestinationURL error:&error];
    if (!downloadedFileCopyResult) {
        NSLog(@"Couldn't copy the downloaded file to the downloads directory");
    }
    
    // Remove any partially downloaded data
    self.partiallyDownloadedFileData = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadProgressView.progress = 0;
        [self.btnDownloadButton setTitle:@"Archivo descargado" forState:UIControlStateNormal];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"Download resumed at offset %lld", fileOffset);
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        // Save resume data to allow the download to continue later
        self.partiallyDownloadedFileData = [error.userInfo valueForKey:NSURLSessionDownloadTaskResumeData];
        [self.btnDownloadButton setTitle:@"Recuperar descarga" forState:UIControlStateNormal];
        self.downloadProgressView.progress = 0;
    } else {
        [self.btnDownloadButton setTitle:@"Iniciar descarga" forState:UIControlStateNormal];
        self.downloadProgressView.progress = 0;
        self.partiallyDownloadedFileData = nil;
        self.downloadTask = nil;
    }
}

#pragma mark - Action methods
- (IBAction)downloadButtonTapped:(id)sender {
    // Create a new download task if not already created
    if (!self.downloadTask && !self.partiallyDownloadedFileData) {
        self.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURL *url = [NSURL URLWithString:SPOResumableDownloadsViewControllerDownloadFileURLString];
        self.downloadTask = [self.session downloadTaskWithURL:url];
        [self.downloadTask resume];
        
        [self.btnDownloadButton setTitle:@"Cancelar descarga" forState:UIControlStateNormal];
        
        return;
    }
    
    // Manage cancel/resume commands
    if (self.partiallyDownloadedFileData) {
        self.downloadTask = [self.session downloadTaskWithResumeData:self.partiallyDownloadedFileData];
        [self.downloadTask resume];
        self.partiallyDownloadedFileData = nil;
        [self.btnDownloadButton setTitle:@"Cancelar descarga" forState:UIControlStateNormal];
    } else if (self.downloadTask.state == NSURLSessionTaskStateRunning) {
        [self.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
            
        }];
        [self.btnDownloadButton setTitle:@"Recuperar descarga" forState:UIControlStateNormal];
        self.downloadProgressView.progress = 0;
    }
}

@end
