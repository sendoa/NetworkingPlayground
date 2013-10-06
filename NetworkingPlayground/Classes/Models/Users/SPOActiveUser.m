//
//  SPOActiveUser.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 06/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPOActiveUser.h"
#import <FXKeychain.h>
#import "SPOUser.h"

NSString * const SPOActiveUserKeychainEmailKey = @"SPOActiveUserKeychainEmail";
NSString * const SPOActiveUserKeychainPasswordKey = @"SPOActiveUserKeychainPassword";

@interface SPOActiveUser ()

@property (assign, nonatomic, readwrite, getter = isUserLoggedIn) BOOL userLoggedIn;

@end

@implementation SPOActiveUser

+ (instancetype)sharedInstance {
    static SPOActiveUser *_sharedActiveUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedActiveUser = [[SPOActiveUser alloc] init];
    });
    
    return _sharedActiveUser;
}

- (id)init
{
    self = [super init];
    if (self) {
        _userLoggedIn = NO;
    }
    return self;
}

- (void)setUser:(SPOUser *)user
{
    _user = user;
    
    if (user) {
        _userLoggedIn = YES;
        FXKeychain *defaultKeychain = [FXKeychain defaultKeychain];
        [defaultKeychain setObject:user.email forKey:SPOActiveUserKeychainEmailKey];
        [defaultKeychain setObject:user.password forKey:SPOActiveUserKeychainPasswordKey];
    } else {
        _userLoggedIn = NO;
        [self removeUserCredentialsEntriesFromKeychain];
    }
}

- (void)removeUserCredentialsEntriesFromKeychain {
    FXKeychain *defaultKeychain = [FXKeychain defaultKeychain];
    [defaultKeychain removeObjectForKey:SPOActiveUserKeychainEmailKey];
    [defaultKeychain removeObjectForKey:SPOActiveUserKeychainPasswordKey];
}

@end
