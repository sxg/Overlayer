//
//  BookListViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/31/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageListViewController.h"

@interface BookListViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic) NSMutableArray *books;
@property NSString *documentsDirectory;

- (IBAction)addBook:(id)sender;

@end
