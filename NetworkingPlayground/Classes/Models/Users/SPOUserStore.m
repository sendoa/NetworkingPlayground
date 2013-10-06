//
//  SPOUserStore.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 05/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPOUserStore.h"
#import "SPOUser.h"

#pragma mark - Internal use constants
static NSString * const SPOUserStoreBaseURL = @"http://simplenotes.sendoadev.com/api/v1";
static NSString * const SPOUserStoreAPIKey = @"55e76dc4bbae25b066cb";

@interface SPOUserStore ()

@property (strong, nonatomic) NSURLSessionConfiguration *baseConfiguration;

@end

@implementation SPOUserStore

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    _baseURL = [NSURL URLWithString:SPOUserStoreBaseURL];
    _baseConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _baseConfiguration.HTTPAdditionalHeaders = @{
                                                 @"api-key"   : SPOUserStoreAPIKey
                                                 };
    
    return self;
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password onCompletion:(LoginCompletionBlock)completionBlock
{
    // Prepare POST data
    NSString *POSTDataString = [NSString stringWithFormat:@"email=%@&password=%@", email, password];
    
    // POST data
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", SPOUserStoreBaseURL, @"users/login"]];
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
                // Is login correct?
                if ([responseBody[@"code"] isEqualToString:@"200"]) {
                    // Initialize user model
                    NSError *userModelError;
                    SPOUser *user = [MTLJSONAdapter modelOfClass:[SPOUser class] fromJSONDictionary:responseBody[@"user_data"] error:&userModelError];
                    user.password = password;
                    if (!userModelError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(user, nil);
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(nil, userModelError);
                        });
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(nil, nil);
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(nil, JSONError);
                });
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"SPOUserStoreNetworkingError" code:HTTPResponse.statusCode userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil, error);
            });
        }
    }];
    [dataTask resume];
}

@end
