//
//  SPONoteCell.h
//  NetworkingPlayground
//
//  Created by Sendoa Portuondo on 06/10/13.
//  Copyright (c) 2013 Sendoa Portuondo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SPONote;

UIKIT_EXTERN NSString * const SPONoteCellIdentifier;

@interface SPONoteCell : UITableViewCell

- (void)bindWithNote:(SPONote *)note;

@end
