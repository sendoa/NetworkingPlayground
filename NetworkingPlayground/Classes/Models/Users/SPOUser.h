//
//  SPOUser.h
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 05/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@interface SPOUser : MTLModel

@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *lastname;

@end
