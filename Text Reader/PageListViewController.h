//
//  PageListViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 2/6/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "PageViewController.h"
#import "TextReaderViewController.h"
#import <UIKit/UIKit.h>

@interface PageListViewController : UITableViewController <TextReaderViewControllerDelegate>

@property NSString *book;
@property (nonatomic) NSMutableArray *pages;
@property NSString *savePath;
@property NSString *documentsDirectory;
@property PageViewController *pageViewController;
@property UIBarButtonItem *drawLinesButton;
@property dispatch_queue_t backgroundQueue;

@end
