//
//  SPOActiveUser.h
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 06/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SPOUser;

UIKIT_EXTERN NSString * const SPOActiveUserKeychainEmailKey;
UIKIT_EXTERN NSString * const SPOActiveUserKeychainPasswordKey;

@interface SPOActiveUser : NSObject

@property (strong, nonatomic) SPOUser *user;

@property (assign, nonatomic, readonly, getter = isUserLoggedIn) BOOL userLoggedIn;

+ (instancetype)sharedInstance;

@end
