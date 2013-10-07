//
//  SPONotesStore.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 06/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPONotesStore.h"
#import "SPOUser.h"
#import "SPONote.h"

#pragma mark - Internal use constants
static NSString * const SPONotesStoreBaseURL = @"http://simplenotes.sportuondo.dev/api/v1";
static NSString * const SPONotesStoreAPIKey = @"55e76dc4bbae25b066cb";

@interface SPONotesStore ()

@property (strong, nonatomic) NSURLSessionConfiguration *baseConfiguration;

@end

@implementation SPONotesStore

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    _baseURL = [NSURL URLWithString:SPONotesStoreBaseURL];
    _baseConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _baseConfiguration.HTTPAdditionalHeaders = @{
                                                 @"api-key"   : SPONotesStoreAPIKey
                                                 };
    
    return self;
}

- (void)fetchNotesForUser:(SPOUser *)user onCompletion:(FetchNotesCompletionBlock)completionBlock
{
    NSParameterAssert(user);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // FETCH data
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@/notes", SPONotesStoreBaseURL, user.userId]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.baseConfiguration];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Check HTTP status code
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        if (HTTPResponse.statusCode == 200) {
            // Convert from JSON to NSArray
            NSError *JSONError;
            NSArray *JSONnotes = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
            if (!JSONError) {
                NSMutableArray *notes = [[NSMutableArray alloc] initWithCapacity:[JSONnotes count]];
                for (NSDictionary *JSONnote in JSONnotes) {
                    NSError *noteModelError;
                    SPONote *note = [MTLJSONAdapter modelOfClass:[SPONote class] fromJSONDictionary:JSONnote error:&noteModelError];
                    if (!noteModelError) {
                        [notes addObject:note];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                            completionBlock(nil, noteModelError);
                        });
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    completionBlock(notes, nil);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    completionBlock(nil, JSONError);
                });
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"SPOUserStoreNetworkingError" code:HTTPResponse.statusCode userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                completionBlock(nil, error);
            });
        }
    }];
    [dataTask resume];
}

- (void)newNoteWithParameters:(NSDictionary *)params onCompletion:(NewNoteCompletionBlock)completionBlock
{
    NSParameterAssert(params);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Prepare POST data
    NSMutableString *POSTDataString = [@"" mutableCopy];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [POSTDataString appendFormat:@"%@=%@&", key, obj];
    }];
    
    // POST data
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", SPONotesStoreBaseURL, @"notes"]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.baseConfiguration];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = [POSTDataString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Check HTTP status code
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        if (HTTPResponse.statusCode == 200) {
            // Convert from JSON to NSDictionary
            NSError *JSONError;
            NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
            if (!JSONError) {
                // Is the request correct?
                if ([responseBody[@"code"] isEqualToString:@"200"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                        completionBlock(nil);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                        NSError *error = [NSError errorWithDomain:@"SPONotesStoreNewNoteCreationError" code:HTTPResponse.statusCode userInfo:nil];
                        completionBlock(error);
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    completionBlock(JSONError);
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                NSError *error = [NSError errorWithDomain:@"SPONotesStoreNetworkingError" code:HTTPResponse.statusCode userInfo:nil];
                completionBlock(error);
            });
        }
    }];
    [dataTask resume];
}

@end
