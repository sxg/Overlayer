//
//  SGTableViewController.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 11/17/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

extern NSString *SGTableViewControllerDidSelectDocumentNotification;
extern NSString *SGTableViewControllerDidNameNewDocumentNotification;
extern NSString *SGTableViewControllerDidNameNewFolderNotification;

extern NSString *SGDocumentKey;
extern NSString *SGDocumentNameKey;
extern NSString *SGFolderNameKey;


@interface SGTableViewController : UITableViewController <UITextFieldDelegate>

@end
