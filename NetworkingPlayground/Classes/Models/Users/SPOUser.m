//
//  SPOUser.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 05/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPOUser.h"

@interface SPOUser () <MTLJSONSerializing>

@end

@implementation SPOUser

#pragma mark - Mantle related methods
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userId"      : @"id"
             };
}

#pragma mark - Other methods


@end
