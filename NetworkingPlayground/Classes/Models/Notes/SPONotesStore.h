//
//  SPONotesStore.h
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 06/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SPOUser;

typedef void (^FetchNotesCompletionBlock)(NSArray *notes, NSError *error);
typedef void (^NewNoteCompletionBlock)(NSError *error);

@interface SPONotesStore : NSObject

@property (strong, nonatomic) NSURL *baseURL;

- (void)fetchNotesForUser:(SPOUser *)user onCompletion:(FetchNotesCompletionBlock)completionBlock;
- (void)newNoteWithParameters:(NSDictionary *)params onCompletion:(NewNoteCompletionBlock)completionBlock;

@end
