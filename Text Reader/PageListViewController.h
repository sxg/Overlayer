//
//  PageListViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 2/6/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "PageViewController.h"
#import <UIKit/UIKit.h>

@interface PageListViewController : UITableViewController

@property NSString *book;
@property NSMutableArray *pages;
@property NSString *savePath;
@property NSString *documentsDirectory;
@property PageViewController *pageViewController;
@property BOOL edit;

@end
