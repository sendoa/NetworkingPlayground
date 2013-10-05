//
//  SPOUserStore.h
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 05/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPOUser;

typedef void (^LoginCompletionBlock)(SPOUser *user, NSError *error);

@interface SPOUserStore : NSObject

@property (strong, nonatomic) NSURL *baseURL;

- (void)loginWithEmail:(NSString *)email password:(NSString *)password onCompletion:(LoginCompletionBlock)completionBlock;

@end
