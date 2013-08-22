//
//  PageListViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 2/6/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "PageViewController.h"
#import "TextReaderViewController.h"
#import "SGBook.h"
#import <UIKit/UIKit.h>

@interface PageListViewController : UITableViewController <TextReaderViewControllerDelegate>

@property (nonatomic) SGBook *book;
@property NSString *savePath;
@property NSString *documentsDirectory;

@end
