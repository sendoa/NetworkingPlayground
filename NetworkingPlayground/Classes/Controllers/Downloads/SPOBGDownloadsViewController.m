//
//  SPODownloadsViewController.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 10/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPOBGDownloadsViewController.h"

NSString * const SPODownloadsViewControllerDownloadFileURLString = @"http://www.hfrmovies.com/TheHobbitDesolationOfSmaug48fps.mp4";

@interface SPOBGDownloadsViewController () <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnDownloadButton;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionConfiguration *sessionConfiguration;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (copy, nonatomic) NSString *downloadedFilesDirectoryPath;

- (IBAction)downloadButtonTapped:(id)sender;

@end

@implementation SPOBGDownloadsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Subscribe to ending background transfers notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundDownloadDidEndWithNotification:)
                                                 name:@"BackgroundTransferDidEndNotification"
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.downloadProgressView.progress = 0;
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
    NSString *downloadedFileDestinationPath = [self.downloadedFilesDirectoryPath stringByAppendingString:downloadedFileName];
    NSURL *downloadedFileNameDestinationURL = [NSURL fileURLWithPath:downloadedFileDestinationPath];
    
    // Copy the downloaded file from the temp directory to the definitive path
    NSError *error;
    BOOL downloadedFileCopyResult = [[NSFileManager defaultManager] copyItemAtURL:location toURL:downloadedFileNameDestinationURL error:&error];
    if (!downloadedFileCopyResult) {
        NSLog(@"Couldn't copy the downloaded file to the downloads directory");
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadProgressView.progress = 0;
        [self.btnDownloadButton setTitle:@"Archivo descargado" forState:UIControlStateNormal];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"Download resumed at offset %lld", fileOffset);
}

#pragma mark - Action methods
- (IBAction)downloadButtonTapped:(id)sender {
    // Create a new download task if not already created
    if (!self.downloadTask) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            self.sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.sportuondo.networkingplayground.backgroundsession"];
            self.sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
            NSURL *url = [NSURL URLWithString:SPODownloadsViewControllerDownloadFileURLString];
            self.downloadTask = [self.session downloadTaskWithURL:url];
            NSLog(@"Session task state: %d", self.downloadTask.state);
            [self.downloadTask resume];
            
            [self.btnDownloadButton setTitle:@"Pausar descarga" forState:UIControlStateNormal];
        });
        
        return;
    }
    
    // Manage pause/resume commands
    if (self.downloadTask.state == NSURLSessionTaskStateSuspended) {
        [self.downloadTask resume];
        [self.btnDownloadButton setTitle:@"Pausar descarga" forState:UIControlStateNormal];
    } else if (self.downloadTask.state == NSURLSessionTaskStateRunning) {
        [self.downloadTask suspend];
        [self.btnDownloadButton setTitle:@"Continuar descarga" forState:UIControlStateNormal];
    }
}

#pragma mark - Notitication observers
- (void)backgroundDownloadDidEndWithNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update UI
        [self.btnDownloadButton setTitle:@"Iniciar descarga" forState:UIControlStateNormal];
        self.downloadProgressView.progress = 0;
        
        // Call the completion handler to inform the system that we're done
        void(^completionHandler)(void) = notification.userInfo[@"completionHandler"];
        completionHandler();
    });
}

@end
