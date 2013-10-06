//
//  SPOAppDelegate.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 05/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPOAppDelegate.h"
#import "SPOUserStore.h"
#import "SPOActiveUser.h"
#import <FXKeychain.h>

@implementation SPOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    SPOUserStore *store = [[SPOUserStore alloc] init];
//    [store loginWithEmail:@"sendoa@gmail.com" password:@"qwertyuiop" onCompletion:^(SPOUser *user, NSError *error) {
//        if (!error) {
//            NSLog(@"Respuesta: %@", user);
//            [[SPOActiveUser sharedInstance] setUser:user];
//        }
//    }];
    
    return YES;
}

@end
