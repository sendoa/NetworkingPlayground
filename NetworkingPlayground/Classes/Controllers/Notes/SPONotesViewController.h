//
//  SPONotesViewController.h
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 06/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPONotesViewController : UITableViewController

- (void)performBackgroundNotesFetchingWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
