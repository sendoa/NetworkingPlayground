//
//  SPONote.h
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 06/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>
@class SPOUser;

@interface SPONote : MTLModel

@property (copy, nonatomic) NSString *noteId;
@property (strong, nonatomic) SPOUser *user;
@property (copy, nonatomic) NSString *textContent;
@property (strong, nonatomic) NSURL *imageURL;

@end
