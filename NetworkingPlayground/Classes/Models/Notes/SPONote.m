//
//  SPONote.m
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 06/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import "SPONote.h"
#import "SPOUser.h"

@interface SPONote () <MTLJSONSerializing>

@property (copy, nonatomic) NSDictionary *userData;

@end

@implementation SPONote

#pragma mark - Mantle related methods
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"noteId"      : @"id",
             @"textContent" : @"text_content",
             @"imageURL"    : @"image_URL",
             @"userData"    : @"user_data"
             };
}

+ (NSValueTransformer *)imageURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

- (SPOUser *)user
{
    NSError *error;
    SPOUser *user = [MTLJSONAdapter modelOfClass:[SPOUser class] fromJSONDictionary:_userData error:&error];
    if (error) NSAssert(NO, @"Error creating user model for note");
    
    return user;
}

@end
